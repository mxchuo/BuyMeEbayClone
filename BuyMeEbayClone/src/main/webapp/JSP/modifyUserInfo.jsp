<%@ page import="java.sql.*, java.util.HashMap, java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Search and Modify User Information</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        input[type="text"], input[type="password"], input[type="email"] {
            padding: 10px;
            margin: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            width: 250px;
        }
        .action-button, .reset-button {
            display: inline-block;
            background-color: #49b8dc;
            color: white;
            padding: 10px 20px;
            margin: 10px;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .action-button:hover, .reset-button:hover {
            background-color: #2b6e84;
        }
        .user-link {
            color: #49b8dc;
            text-decoration: underline;
        }
        .user-link:hover {
            text-decoration: none;
        }
        .user-entry {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <h1>Search and Modify User Information</h1>
    <form action="" method="get">
        Username: <input type="text" name="search" required>
        <button type="submit" class="action-button">Search</button>
    </form>
    <%
    String searchQuery = request.getParameter("search");
    if (searchQuery != null && !searchQuery.isEmpty()) {
        Connection conn = null;
        try {
            conn = new ApplicationDB().getConnection();
            String query = "SELECT userID, username, email FROM users WHERE username LIKE ? AND role = 'user'";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, "%" + searchQuery + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int userId = rs.getInt("userID");
                String username = rs.getString("username");
                String email = rs.getString("email");
                %>
                <div class="user-entry">
                    <a href="<%=request.getContextPath()%>/JSP/userAuctionsBids.jsp?userID=<%= userId %>" class="user-link"><%= username %></a> (<%= email %>)
                    <form action="" method="post">
                        <input type="hidden" name="userID" value="<%= userId %>">
                        <input type="hidden" name="action" value="resetPassword">
                        New Password: <input type="password" name="newPassword" required>
                        <button type="submit" class="reset-button">Reset Password</button>
                    </form>
                    <% if ("custRep".equals(session.getAttribute("userRole")) || "admin".equals(session.getAttribute("userRole"))) { %>
                        <form action="" method="post">
                            <input type="hidden" name="userID" value="<%= userId %>">
                            <input type="hidden" name="action" value="updateEmail">
                            New Email: <input type="email" name="newEmail" required>
                            <button type="submit" class="action-button">Update Email</button>
                        </form>
                    <% } %>
                </div>
                <%
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Error during the search. Please try again.</p>");
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    String action = request.getParameter("action");
    if ("resetPassword".equals(action)) {
        String newPassword = request.getParameter("newPassword");
        int userID = Integer.parseInt(request.getParameter("userID"));
        try (Connection conn = new ApplicationDB().getConnection()) {
            String updateQuery = "UPDATE users SET password = ? WHERE userID = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateQuery)) {
                ps.setString(1, newPassword);
                ps.setInt(2, userID);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Error updating password. Please try again.</p>");
        }
    } else if ("updateEmail".equals(action)) {
        String newEmail = request.getParameter("newEmail");
        int userID = Integer.parseInt(request.getParameter("userID"));
        try (Connection conn = new ApplicationDB().getConnection()) {
            String updateQuery = "UPDATE users SET email = ? WHERE userID = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateQuery)) {
                ps.setString(1, newEmail);
                ps.setInt(2, userID);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Error updating email. Please try again.</p>");
        }
    }
    %>
    <a href="<%=request.getContextPath()%>/JSP/dashboard.jsp" class="action-button">Back to Dashboard</a>
</body>
</html>