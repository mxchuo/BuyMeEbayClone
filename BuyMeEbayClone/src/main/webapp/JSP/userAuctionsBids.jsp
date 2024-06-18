<%@ page import="java.sql.*, java.util.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>

<%
String userIDParam = request.getParameter("userID");
int userID = 0;
String username = "";
List<HashMap<String, String>> userActivities = new ArrayList<>();

if (userIDParam != null && !userIDParam.isEmpty()) {
	userID = Integer.parseInt(userIDParam);
}

try (Connection conn = new ApplicationDB().getConnection()) {
	String updateBalanceQuery = "SELECT items.itemID, MAX(bidAmount) AS highestBid FROM bids INNER JOIN items ON bids.itemID = items.itemID WHERE items.userID = ? AND items.closeTime <= NOW() AND items.balanceUpdated = FALSE GROUP BY items.itemID";
	PreparedStatement psUpdateBalance = conn.prepareStatement(updateBalanceQuery);
	psUpdateBalance.setInt(1, userID);
	ResultSet rsUpdateBalance = psUpdateBalance.executeQuery();

	float totalEarnings = 0;
	while (rsUpdateBalance.next()) {
		totalEarnings += rsUpdateBalance.getFloat("highestBid");
		String markProcessedQuery = "UPDATE items SET balanceUpdated = TRUE WHERE itemID = ?";
		PreparedStatement psMarkProcessed = conn.prepareStatement(markProcessedQuery);
		psMarkProcessed.setInt(1, rsUpdateBalance.getInt("itemID"));
		psMarkProcessed.executeUpdate();
	}

	if (totalEarnings > 0) {
		String updateUserBalanceQuery = "UPDATE users SET balance = balance + ?, totalEarned = totalEarned + ? WHERE userID = ?";
		PreparedStatement psUpdateUserBalance = conn.prepareStatement(updateUserBalanceQuery);
		psUpdateUserBalance.setFloat(1, totalEarnings);
		psUpdateUserBalance.setFloat(2, totalEarnings);
		psUpdateUserBalance.setInt(3, userID);
		psUpdateUserBalance.executeUpdate();
	}
}

try (Connection conn = new ApplicationDB().getConnection()) {
	String usernameQuery = "SELECT username FROM users WHERE userID = ?";
	try (PreparedStatement ps = conn.prepareStatement(usernameQuery)) {
		ps.setInt(1, userID);
		try (ResultSet rs = ps.executeQuery()) {
	if (rs.next()) {
		username = rs.getString("username");
	}
		}
	}

	String userActivityQuery = "SELECT 'Bid' as activityType, " + "       b.bidAmount, " + "       b.autoBid, "
	+ "       i.title, " + "       b.bidID, " + "       i.itemID, " + "       i.closeTime, "
	+ "       i.minSellPrice, " + "       i.closeTime <= NOW() as auctionEnded, "
	+ "       (SELECT MAX(bidAmount) FROM bids WHERE itemID = i.itemID) as highestBid, "
	+ "       (SELECT MIN(userID) FROM bids WHERE itemID = i.itemID AND bidAmount = (SELECT MAX(bidAmount) FROM bids WHERE itemID = i.itemID)) as winningUserID "
	+ "FROM bids b " + "INNER JOIN items i ON b.itemID = i.itemID " + "WHERE b.userID = ? " + "UNION ALL "
	+ "SELECT 'Auction' as activityType, " + "       i.initialPrice, " + "       NULL as autoBid, "
	+ "       i.title, " + "       NULL as bidID, " + "       i.itemID, " + "       i.closeTime, "
	+ "       i.minSellPrice, " + "       i.closeTime <= NOW() as auctionEnded, "
	+ "       (SELECT MAX(bidAmount) FROM bids WHERE itemID = i.itemID) as highestBid, "
	+ "       NULL as winningUserID " + "FROM items i " + "WHERE i.userID = ?";
	try (PreparedStatement ps = conn.prepareStatement(userActivityQuery)) {
		ps.setInt(1, userID);
		ps.setInt(2, userID);
		try (ResultSet rs = ps.executeQuery()) {
	while (rs.next()) {
		HashMap<String, String> activity = new HashMap<>();
		activity.put("type", rs.getString("activityType"));
		activity.put("amount", rs.getString("bidAmount") == null ? "N/A" : rs.getString("bidAmount"));
		activity.put("autoBid", rs.getString("autoBid"));
		activity.put("title", rs.getString("title"));
		activity.put("itemID", rs.getString("itemID"));
		activity.put("bidID", rs.getString("bidID") == null ? "N/A" : rs.getString("bidID"));
		activity.put("auctionEnded", rs.getString("auctionEnded"));
		activity.put("highestBid", rs.getString("highestBid") == null ? "N/A" : rs.getString("highestBid"));
		String winningUserID = rs.getString("winningUserID");
		activity.put("winningUserID", winningUserID);
		activity.put("minSellPrice", rs.getString("minSellPrice"));
		Timestamp closeTimestamp = rs.getTimestamp("closeTime");
		String closeTimeString = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(closeTimestamp);
		activity.put("closeTime", closeTimeString);
		userActivities.add(activity);
	}
		}
	}
} catch (SQLException e) {
	e.printStackTrace();
}

Map<Integer, String> bidAlerts = new HashMap<>();
try (Connection conn = new ApplicationDB().getConnection()) {
	String userHighestBidsQuery = "SELECT b.itemID, MAX(b.bidAmount) AS userHighestBid "
	+ "FROM bids b WHERE b.userID = ? GROUP BY b.itemID";
	PreparedStatement userHighestBidsStmt = conn.prepareStatement(userHighestBidsQuery);
	userHighestBidsStmt.setInt(1, userID);
	ResultSet userHighestBidsRs = userHighestBidsStmt.executeQuery();

	Map<Integer, Float> userHighestBids = new HashMap<>();
	while (userHighestBidsRs.next()) {
		userHighestBids.put(userHighestBidsRs.getInt("itemID"), userHighestBidsRs.getFloat("userHighestBid"));
	}

	String currentHighestBidsQuery = "SELECT b.itemID, MAX(b.bidAmount) AS currentHighestBid "
	+ "FROM bids b GROUP BY b.itemID";
	PreparedStatement currentHighestBidsStmt = conn.prepareStatement(currentHighestBidsQuery);
	ResultSet currentHighestBidsRs = currentHighestBidsStmt.executeQuery();

	while (currentHighestBidsRs.next()) {
		int itemID = currentHighestBidsRs.getInt("itemID");
		float currentHighestBid = currentHighestBidsRs.getFloat("currentHighestBid");
		if (userHighestBids.containsKey(itemID) && userHighestBids.get(itemID) < currentHighestBid) {
	bidAlerts.put(itemID, "higher-bid");
		}
	}
} catch (SQLException e) {
	e.printStackTrace();
}

try (Connection conn = new ApplicationDB().getConnection()) {
    String autoBidsQuery = "SELECT itemID, autoBid FROM bids WHERE userID = ? AND autoBid > 0";
    PreparedStatement autoBidsStmt = conn.prepareStatement(autoBidsQuery);
    autoBidsStmt.setInt(1, userID);
    ResultSet autoBidsRs = autoBidsStmt.executeQuery();
    Map<Integer, Float> autoBidLimits = new HashMap<>();
    while (autoBidsRs.next()) {
        autoBidLimits.put(autoBidsRs.getInt("itemID"), autoBidsRs.getFloat("autoBid"));
    }

    String currentHighestBidsQuery = "SELECT b.itemID, MAX(b.bidAmount) AS currentHighestBid, MAX(b.autoBid) AS highestAutoBid FROM bids b GROUP BY b.itemID";
    PreparedStatement currentHighestBidsStmt = conn.prepareStatement(currentHighestBidsQuery);
    ResultSet currentHighestBidsRs = currentHighestBidsStmt.executeQuery();

    while (currentHighestBidsRs.next()) {
        int itemID = currentHighestBidsRs.getInt("itemID");
        float currentHighestBid = currentHighestBidsRs.getFloat("currentHighestBid");
        float highestAutoBid = currentHighestBidsRs.getFloat("highestAutoBid");

        if (autoBidLimits.containsKey(itemID) && autoBidLimits.get(itemID) < currentHighestBid && highestAutoBid > 0) {
            bidAlerts.put(itemID, "outbid-auto");
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}


%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title><%=username%>'s Bids/Auctions</title>
<style>
table {
	width: 100%;
	border-collapse: collapse;
	margin-bottom: 20px;
}

th, td {
	padding: 10px;
	border: 1px solid #ddd;
}

th {
	background-color: #f8f8f8;
}

.return-link {
	text-decoration: none;
	color: blue;
}

.higher-bid {
	background-color: #cceeff;
} /* Light blue */
.outbid-auto {
	background-color: #ccffcc;
} /* Light green */
.both-alerts {
	background-color: #e6ccff;
} /* Light purple */
.legend {
	margin-top: 20px;
	text-align: left;
}

.legend span {
	display: inline-block;
	width: 20px;
	height: 20px;
	margin-right: 5px;
}
</style>

</head>
<body>
	<h1><%=username%>'s Bids/Auctions
	</h1>
	<table>
		<tr>
			<th>Type</th>
			<th>Title</th>
			<th>Amount</th>
			<th>Bid Type</th>
			<th>Status</th>
			<th>Auction End Time</th>
			<th>Action</th>
		</tr>
		<%
		for (HashMap<String, String> activity : userActivities) {
			int itemID = Integer.parseInt(activity.get("itemID"));
			String rowClass = bidAlerts.containsKey(itemID) ? bidAlerts.get(itemID) : "";
			String status = "Active";
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			Date currentTime = new Date();
			Date closeTime = sdf.parse(activity.get("closeTime"));
			float highestBid = 0.0f;
			String highestBidStr = activity.get("highestBid");
			if (highestBidStr != null && !highestBidStr.equals("N/A")) {
				try {
			highestBid = Float.parseFloat(highestBidStr);
				} catch (NumberFormatException e) {
			highestBid = 0.0f;
				}
			}

			float minSellPrice = 0.0f;
			String minSellPriceStr = activity.get("minSellPrice");
			if (minSellPriceStr != null && !minSellPriceStr.equals("N/A")) {
				try {
			minSellPrice = Float.parseFloat(minSellPriceStr);
				} catch (NumberFormatException e) {
			minSellPrice = 0.0f;
				}
			}
			String winningUserID = activity.get("winningUserID");

			if (closeTime.before(currentTime)) {
				if (highestBid >= minSellPrice) {
			if (winningUserID != null && winningUserID.equals(String.valueOf(userID))) {
				status = "Auction Ended - Won";
			} else {
				status = "Auction Ended - Lost";
			}
				} else {
			status = "Auction Ended - No Winners";
				}
			}
		%>
		<tr class="<%=rowClass%>">
			<td><%=activity.get("type")%></td>
			<td><%=activity.get("title")%></td>
			<td><%=activity.get("amount")%></td>
			<td><%=activity.get("autoBid") != null && !activity.get("autoBid").equals("0")
		? "Auto-bid, max: " + activity.get("autoBid")
		: "Manual Bid"%></td>
			<td><%=status%></td>
			<td><%=activity.get("closeTime")%></td>
			<td>
				<%
				if ("Bid".equals(activity.get("type"))) {
				%>
				<form action="deleteBid.jsp" method="post">
					<input type="hidden" name="bidID"
						value="<%=activity.get("bidID")%>">
					<button type="submit">Withdraw Bid</button>
				</form> <%
 } else {
 %>
				<form action="deleteItem.jsp" method="post">
					<input type="hidden" name="itemID"
						value="<%=activity.get("itemID")%>">
					<button type="submit">Delete Auction</button>
				</form> <%
 }
 %>
			</td>
		</tr>
		<%
		}
		%>
	</table>

	<div class="legend">
		<h3>Legend:</h3>
		<div>
			<span class="higher-bid"></span> A higher bid has been placed on an
			item you've bid on.
		</div>
		<div>
			<span class="outbid-auto"></span> Your automatic bid limit has been
			exceeded by another bidder.
		</div>

	</div>

	<a href="<%=request.getContextPath()%>/JSP/dashboard.jsp"
		class="return-link">Back to Dashboard</a>
</body>
</html>

