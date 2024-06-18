<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Summary Sales Reports</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        .link-button, .action-button {
            display: inline-block;
            background-color: #49b8dc;
            color: white;
            padding: 10px 20px;
            margin: 10px;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .link-button:hover, .action-button:hover {
            background-color: #2b6e84;
        }
        table {
            margin-top: 20px;
            margin-left: auto;
            margin-right: auto;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>Summary Sales Reports</h1>
    <% 
    try (Connection conn = new ApplicationDB().getConnection()) {
        String totalEarningsQuery = "SELECT SUM(highestBid) AS totalEarnings FROM (SELECT MAX(bidAmount) AS highestBid FROM bids INNER JOIN items ON bids.itemID = items.itemID GROUP BY bids.itemID) AS bidSum";
        PreparedStatement psTotalEarnings = conn.prepareStatement(totalEarningsQuery);
        ResultSet rsTotalEarnings = psTotalEarnings.executeQuery();
        if (rsTotalEarnings.next()) {
            %>
            <p>Total Earnings: $<%= rsTotalEarnings.getFloat("totalEarnings") %></p>
            <%
        }

        String earningsPerItemQuery = "SELECT items.title, MAX(bids.bidAmount) AS highestBid FROM bids INNER JOIN items ON bids.itemID = items.itemID GROUP BY bids.itemID";
        PreparedStatement psEarningsPerItem = conn.prepareStatement(earningsPerItemQuery);
        ResultSet rsEarningsPerItem = psEarningsPerItem.executeQuery();
        %>
        <table>
            <tr>
                <th>Item</th>
                <th>Earnings</th>
            </tr>
            <%
            while (rsEarningsPerItem.next()) {
                %>
                <tr>
                    <td><%= rsEarningsPerItem.getString("title") %></td>
                    <td>$<%= rsEarningsPerItem.getFloat("highestBid") %></td>
                </tr>
                <%
            }
            %>
        </table>
        <%
        String earningsPerItemTypeQuery = "SELECT items.category, SUM(bids.bidAmount) AS totalEarnings FROM items JOIN bids ON items.itemID = bids.itemID GROUP BY items.category";
        PreparedStatement psEarningsPerItemType = conn.prepareStatement(earningsPerItemTypeQuery);
        ResultSet rsEarningsPerItemType = psEarningsPerItemType.executeQuery();
        %>
        <h2>Earnings Per Item Type</h2>
        <table>
            <tr>
                <th>Item Type</th>
                <th>Total Earnings</th>
            </tr>
            <% while (rsEarningsPerItemType.next()) { %>
            <tr>
                <td><%= rsEarningsPerItemType.getString("category") %></td>
                <td>$<%= rsEarningsPerItemType.getFloat("totalEarnings") %></td>
            </tr>
            <% } %>
        </table>
        <%

        String earningsPerEndUserQuery = "SELECT u.userID, u.username, COALESCE(SUM(IF(i.finalBid >= i.minSellPrice, i.finalBid, 0)), 0) AS totalEarnings FROM users u LEFT JOIN (SELECT i.userID, i.itemID, MAX(b.bidAmount) AS finalBid, i.minSellPrice FROM items i LEFT JOIN bids b ON i.itemID = b.itemID GROUP BY i.itemID, i.userID, i.minSellPrice) AS i ON u.userID = i.userID GROUP BY u.userID, u.username;";
        PreparedStatement psEarningsPerEndUser = conn.prepareStatement(earningsPerEndUserQuery);
        ResultSet rsEarningsPerEndUser = psEarningsPerEndUser.executeQuery();
        %>
        <h2>Earnings Per End-User</h2>
        <table>
            <tr>
                <th>User</th>
                <th>Total Earnings</th>
            </tr>
            <% while (rsEarningsPerEndUser.next()) { %>
            <tr>
                <td><%= rsEarningsPerEndUser.getString("username") %></td>
                <td>$<%= rsEarningsPerEndUser.getFloat("totalEarnings") %></td>
            </tr>
            <% } %>
        </table>
        <%

        String bestSellingItemsQuery = "SELECT items.title, MAX(bids.bidAmount) AS highestBid FROM items JOIN bids ON items.itemID = bids.itemID GROUP BY items.itemID ORDER BY highestBid DESC LIMIT 5";
        PreparedStatement psBestSellingItems = conn.prepareStatement(bestSellingItemsQuery);
        ResultSet rsBestSellingItems = psBestSellingItems.executeQuery();
        %>
        <h2>Best-Selling Items</h2>
        <table>
            <tr>
                <th>Item</th>
                <th>Highest Bid</th>
            </tr>
            <% while (rsBestSellingItems.next()) { %>
            <tr>
                <td><%= rsBestSellingItems.getString("title") %></td>
                <td>$<%= rsBestSellingItems.getFloat("highestBid") %></td>
            </tr>
            <% } %>
        </table>
        <%

        String topSpendingUsersQuery = "SELECT users.username, SUM(bids.bidAmount) AS totalSpent FROM users JOIN bids ON users.userID = bids.userID GROUP BY users.userID ORDER BY totalSpent DESC LIMIT 5";
        PreparedStatement psTopSpendingUsers = conn.prepareStatement(topSpendingUsersQuery);
        ResultSet rsTopSpendingUsers = psTopSpendingUsers.executeQuery();
        %>
        <h2>Top Spending End-Users</h2>
        <table>
            <tr>
                <th>User</th>
                <th>Total Spent</th>
            </tr>
            <% while (rsTopSpendingUsers.next()) { %>
            <tr>
                <td><%= rsTopSpendingUsers.getString("username") %></td>
                <td>$<%= rsTopSpendingUsers.getFloat("totalSpent") %></td>
            </tr>
            <% } %>
        </table>
        <%
       
    } catch (SQLException e) {
        e.printStackTrace();
    }
    %>
    <a href="<%=request.getContextPath()%>/JSP/dashboard.jsp" class="link-button">Back to Dashboard</a>
    <%
    %>
</body>
</html>