<%@ page import="java.sql.*, java.util.*"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create Customer Representative Account</title>
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
            width: 20%;
        }
        .action-button {
            display: inline-block;
            background-color: #49b8dc;
            color: white;
            padding: 10px 20px;
            margin: 10px;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .action-button:hover {
            background-color: #2b6e84;
        }
    </style>
</head>
<body>
    <h1>Create Customer Representative Account</h1>
    <form action="createCustRepAccount.jsp" method="post">
        Email: <input type="email" name="email" required><br>
        Username: <input type="text" name="username" required><br>
        Password: <input type="password" name="password" required><br>
        <button type="submit" class="action-button">Create Account</button>
    </form>
    <%
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String email = request.getParameter("email");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            
            try (Connection conn = new ApplicationDB().getConnection()) {
                String insertQuery = "INSERT INTO users (email, username, password, role) VALUES (?, ?, ?, 'custRep')";
                try (PreparedStatement ps = conn.prepareStatement(insertQuery)) {
                    ps.setString(1, email);
                    ps.setString(2, username);
                    ps.setString(3, password);
                    ps.executeUpdate();
                    out.println("<p>Customer Representative Account Created Successfully.</p>");
                }
            } catch (SQLIntegrityConstraintViolationException e) {
                out.println("<p>Error: An account with the given email or username already exists.</p>");
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<p>Error: Unable to create account. Please try again later.</p>");
            }
        }
    %>
    <a href="dashboard.jsp" class="action-button">Back to Dashboard</a>
</body>
</html>
