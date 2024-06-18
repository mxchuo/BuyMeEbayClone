<%@ page import="java.sql.*"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>

<%
Integer loggedInUserId = (Integer) session.getAttribute("userID");
if (loggedInUserId == null) {
    response.sendRedirect("login.jsp");
    return;
}

String itemIDToBidStr = request.getParameter("itemIDToBid");
String bidAmountStr = request.getParameter("bidAmount");
String autoBidLimitStr = request.getParameter("autoBidLimit");
String autoBidIncrementStr = request.getParameter("autoBidIncrement");
String errorMessage = null;


Connection conn = null;
PreparedStatement stmt = null;
ResultSet rs = null;

try {
    conn = new ApplicationDB().getConnection();
    int itemIDToBid = Integer.parseInt(itemIDToBidStr);
    float bidAmount = Float.parseFloat(bidAmountStr);
    float autoBidLimit = autoBidLimitStr != null && !autoBidLimitStr.isEmpty() ? Float.parseFloat(autoBidLimitStr) : 0;
    float autoBidIncrement = autoBidIncrementStr != null && !autoBidIncrementStr.isEmpty() ? Float.parseFloat(autoBidIncrementStr) : 0;

    String bidInfoQuery = "SELECT COALESCE(MAX(b.bidAmount), i.initialPrice) AS maxBid, i.initialPrice, i.minBidIncrement FROM items i LEFT JOIN bids b ON b.itemID = i.itemID WHERE i.itemID = ? GROUP BY i.itemID";
    stmt = conn.prepareStatement(bidInfoQuery);
    stmt.setInt(1, itemIDToBid);
    rs = stmt.executeQuery();

    float maxBid = 0;
    float minBidIncrement = 0;
    if (rs.next()) {
        maxBid = rs.getFloat("maxBid");
        minBidIncrement = rs.getFloat("minBidIncrement");
    }

    if (bidAmount >= maxBid + minBidIncrement) {
        String insertBidQuery = "INSERT INTO Bids (itemId, userId, bidDate, bidAmount, autoBid, autoBidIncrement) VALUES (?, ?, ?, ?, ?, ?)";
        stmt = conn.prepareStatement(insertBidQuery);
        stmt.setInt(1, itemIDToBid);
        stmt.setInt(2, loggedInUserId);
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        String currentDate = dateFormat.format(new Date());
        stmt.setString(3, currentDate);
        stmt.setFloat(4, bidAmount);
        stmt.setFloat(5, autoBidLimit);
        stmt.setFloat(6, autoBidIncrement);
        stmt.executeUpdate();

	     String autoBidsQuery = "SELECT userId, autoBid, autoBidIncrement FROM Bids WHERE itemId = ? AND userId != ? AND autoBid >= ?";
	     PreparedStatement autoBidsStmt = conn.prepareStatement(autoBidsQuery);
	     autoBidsStmt.setInt(1, itemIDToBid);
	     autoBidsStmt.setInt(2, loggedInUserId);
	     autoBidsStmt.setFloat(3, bidAmount);
	     ResultSet autoBidsRs = autoBidsStmt.executeQuery();
	
	     while (autoBidsRs.next()) {
	         int autoBidUserId = autoBidsRs.getInt("userId");
	         float userAutoBidLimit = autoBidsRs.getFloat("autoBid");
	         float userAutoBidIncrement = autoBidsRs.getFloat("autoBidIncrement");
	         if (userAutoBidLimit > bidAmount) {
	             float newBidAmount = Math.min(bidAmount + userAutoBidIncrement, userAutoBidLimit);
	             String updateAutoBidQuery = "UPDATE Bids SET bidDate = ?, bidAmount = ? WHERE itemId = ? AND userId = ?";
	             PreparedStatement updateAutoBidStmt = conn.prepareStatement(updateAutoBidQuery);
	             updateAutoBidStmt.setString(1, dateFormat.format(new Date()));
	             updateAutoBidStmt.setFloat(2, newBidAmount);
	             updateAutoBidStmt.setInt(3, itemIDToBid);
	             updateAutoBidStmt.setInt(4, autoBidUserId);
	             updateAutoBidStmt.executeUpdate();
	         }
	     }

        response.sendRedirect("searchItems.jsp");
    } else {
        errorMessage = "Your bid must be higher than the current highest bid plus the minimum bid increment of $" + minBidIncrement;
    }
} catch (SQLException e) {
    e.printStackTrace();
    errorMessage = "Error processing your bid: " + e.getMessage();
} catch (NumberFormatException e) {
    errorMessage = "Invalid bid data provided.";
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
    if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }

    if (errorMessage != null) {
        request.setAttribute("errorMessage", errorMessage);
        request.getRequestDispatcher("searchItems.jsp").forward(request, response);
    }
}
%>