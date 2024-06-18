<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>BuyMe Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
            text-align: center;
        }
        .container {
            max-width: 800px;
            margin: auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .header, .section {
            margin-bottom: 20px;
        }
        .link-button, .action-button {
            background-color: #49b8dc;
            color: white;
            padding: 10px 20px;
            margin: 5px;
            border: none;
            border-radius: 5px;
            text-decoration: none;
            display: inline-block;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .link-button:hover, .action-button:hover {
            background-color: #2b6e84;
        }
        table {
            width: 100%;
            margin-top: 20px;
            border-collapse: collapse;
        }
        th, td {
            padding: 8px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f8f9fa;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <img src="../logo.png" alt="Logo" style="width: 100px; height: auto;">
    </div>

    <%
        Integer userId = (Integer) session.getAttribute("userID");
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String userRole = (String) session.getAttribute("userRole");
    %>

    <div class="section">
        <a href="<%=request.getContextPath()%>/JSP/searchItems.jsp" class="link-button">Search Items</a>
        <a href="<%=request.getContextPath()%>/JSP/qaBoard.jsp" class="link-button">Question Board</a>
        <a href="<%=request.getContextPath()%>/JSP/logout.jsp" class="link-button">Logout</a>
    </div>

    <% if (!"custRep".equals(userRole) && !"admin".equals(userRole)) { %>
        <div class="section">
            <a href="<%=request.getContextPath()%>/JSP/listItemForm.jsp" class="link-button">List an Item</a>
            <a href="<%=request.getContextPath()%>/JSP/setAlertsForm.jsp" class="link-button">Set Alerts</a>
            <form action="<%=request.getContextPath()%>/JSP/userAuctionsBids.jsp" method="post" style="display: inline;">
                <input type="hidden" name="userID" value="<%= userId %>">
                <button type="submit" class="action-button">My Bids/Auctions</button>
            </form>
        </div>
    <% } %>
    
    <% if ("admin".equals(userRole)) { %>
        <div class="section">
            <a href="<%=request.getContextPath()%>/JSP/modifyUserInfo.jsp" class="link-button">Modify User Info</a>
            <a href="<%=request.getContextPath()%>/JSP/createCustRepAccount.jsp" class="link-button">Create CustRep Account</a>
            <a href="<%=request.getContextPath()%>/JSP/generateReports.jsp" class="link-button">Generate Reports</a>
        </div>
    <% } %>
    
    <% if ("custRep".equals(userRole)) { %>
    <div class="section">
        <a href="<%=request.getContextPath()%>/JSP/modifyUserInfo.jsp" class="link-button">Modify User Info</a>
    </div>
<% } %>
    
    <% if (!"custRep".equals(userRole) && !"admin".equals(userRole)) { %>
        <div class="section">
            <h2>Your Alerts</h2>
            <table>
                <tr>
                    <th>Make</th>
                    <th>Model</th>
                    <th>Year</th>
                    <th>Color</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
                <% 
                    try (Connection conn = new ApplicationDB().getConnection()) {
                        String queryAlerts = "SELECT * FROM alerts WHERE userID = ?";
                        PreparedStatement psAlerts = conn.prepareStatement(queryAlerts);
                        psAlerts.setInt(1, userId);
                        ResultSet rsAlerts = psAlerts.executeQuery();
                        while (rsAlerts.next()) {
                            String make = rsAlerts.getString("make");
                            String model = rsAlerts.getString("model");
                            int yom = rsAlerts.getInt("yom");
                            String color = rsAlerts.getString("color");
                            int alertID = rsAlerts.getInt("alertID");
                            boolean isMatchFound = false;

                            String queryAuctions = "SELECT COUNT(*) AS matchCount FROM items WHERE make = ? AND model = ? AND yom = ? AND color = ? AND closeTime > NOW()";
                            PreparedStatement psAuctions = conn.prepareStatement(queryAuctions);
                            psAuctions.setString(1, make);
                            psAuctions.setString(2, model);
                            psAuctions.setInt(3, yom);
                            psAuctions.setString(4, color);
                            ResultSet rsAuctions = psAuctions.executeQuery();
                            
                            if (rsAuctions.next()) {
                                isMatchFound = rsAuctions.getInt("matchCount") > 0;
                            }
                %>
                <tr>
                    <td><%= make %></td>
                    <td><%= model %></td>
                    <td><%= yom %></td>
                    <td><%= color %></td>
                    <td><%= isMatchFound ? "<span style='color: green;'>Match Found!</span>" : "Pending" %></td>
                    <td>
                        <form action="<%=request.getContextPath()%>/JSP/deleteAlert.jsp" method="post">
                            <input type="hidden" name="alertID" value="<%= alertID %>">
                            <input type="submit" class="action-button" value="Delete">
                        </form>
                    </td>
                </tr>
                <% 
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                %>
            </table>
        </div>
    <% } %>
</div>
</body>
</html>
