<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    Integer loggedInUserId = (Integer) session.getAttribute("userID");
    if (loggedInUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String itemIDParam = request.getParameter("itemID");
    List<HashMap<String, String>> bidHistory = new ArrayList<>();
    List<HashMap<String, String>> userAuctions = new ArrayList<>();
    List<HashMap<String, String>> similarItems = new ArrayList<>();
    HashMap<String, String> initialBid = new HashMap<>();
    String currentItemTitle = "";
    int itemID = 0;

    if (itemIDParam != null && !itemIDParam.isEmpty()) {
        itemID = Integer.parseInt(itemIDParam);
    }

    try (Connection conn = new ApplicationDB().getConnection()) {
        String currentItemTitleQuery = "SELECT title FROM Items WHERE itemID = ?";
        try (PreparedStatement ps = conn.prepareStatement(currentItemTitleQuery)) {
            ps.setInt(1, itemID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentItemTitle = rs.getString("title");
                }
            }
        }

        String bidHistoryQuery = "SELECT b.bidAmount, b.bidDate, u.username, u.userID FROM bids b INNER JOIN users u ON b.userID = u.userID WHERE b.itemID = ? ORDER BY b.bidAmount DESC";
        try (PreparedStatement ps = conn.prepareStatement(bidHistoryQuery)) {
            ps.setInt(1, itemID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, String> bid = new HashMap<>();
                    bid.put("amount", rs.getString("bidAmount"));
                    bid.put("date", rs.getString("bidDate"));
                    bid.put("user", rs.getString("username"));
                    bid.put("userID", rs.getString("userID"));
                    bidHistory.add(bid);
                }
            }
        }


        String initialBidQuery = "SELECT u.username, i.initialPrice, u.userID FROM Items i INNER JOIN Users u ON i.userID = u.userID WHERE i.itemID = ?";
        try (PreparedStatement ps = conn.prepareStatement(initialBidQuery)) {
            ps.setInt(1, itemID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    initialBid.put("user", rs.getString("username"));
                    initialBid.put("amount", rs.getString("initialPrice"));
                    initialBid.put("creatorUserID", rs.getString("userID"));
                }
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
    <title>View Bid History</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        .history-entry {
            margin: 10px auto;
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        .history-link {
            color: #49b8dc;
            text-decoration: none;
            transition: color 0.3s;
        }
        .history-link:hover {
            color: #2b6e84;
        }
        .back-link {
            display: inline-block;
            background-color: #49b8dc;
            color: white;
            padding: 10px 20px;
            margin-top: 20px;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .back-link:hover {
            background-color: #2b6e84;
        }
    </style>
</head>
<body>
    <h1>Bid History for: <%= currentItemTitle %></h1>
    
    <% if (!initialBid.isEmpty()) { %>
        <div class="history-entry">
            Initial Price by <a href="userAuctionsBids.jsp?userID=<%= initialBid.get("creatorUserID") %>" class="history-link"><%= initialBid.get("user") %></a>: $<%= initialBid.get("amount") %>
        </div>
    <% } %>
    
    <% for (HashMap<String, String> bid : bidHistory) { %>
        <div class="history-entry">
            <a href="userAuctionsBids.jsp?userID=<%= bid.get("userID") %>" class="history-link"><%= bid.get("user") %></a> bid $<%= bid.get("amount") %> on <%= bid.get("date") %>
        </div>
    <% } %>

    <a href="searchItems.jsp" class="back-link">Back to Search</a>
</body>
</html>
