<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String email = request.getParameter("email");
    boolean registrationSuccess = true;
    String errorMessage = "";

    if ("POST".equalsIgnoreCase(request.getMethod()) && username != null && password != null && email != null) {
        try (Connection conn = new ApplicationDB().getConnection();
             PreparedStatement checkUserStmt = conn.prepareStatement("SELECT COUNT(*) AS userCount FROM users WHERE username = ? OR email = ?");
             PreparedStatement insertStmt = conn.prepareStatement("INSERT INTO users (username, password, email) VALUES (?, ?, ?)")) {
            
            checkUserStmt.setString(1, username);
            checkUserStmt.setString(2, email);
            ResultSet rs = checkUserStmt.executeQuery();
            if (rs.next() && rs.getInt("userCount") > 0) {
                registrationSuccess = false;
                errorMessage = "Username or Email already exists.";
            } else {
                insertStmt.setString(1, username);
                insertStmt.setString(2, password);
                insertStmt.setString(3, email);
                if (insertStmt.executeUpdate() > 0) {
                    response.sendRedirect(request.getContextPath() + "/JSP/login.jsp");
                    return;
                } else {
                    registrationSuccess = false;
                    errorMessage = "Registration failed due to an unexpected error.";
                }
            }
        } catch (SQLException e) {
            registrationSuccess = false;
            errorMessage = "Registration failed due to a database error.";
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
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
        .message {
            color: #d9534f;
            margin: 20px;
        }
    </style>
</head>
<body>
    <h1>BuyMe</h1>
    <h2>Register</h2>
    <% if (!registrationSuccess) { %>
        <p><%= errorMessage %></p>
    <% } %>
    <form action="<%=request.getContextPath()%>/JSP/register.jsp" method="post">
        Username: <input type="text" name="username" required><br>
        Password: <input type="password" name="password" required><br>
        Email: <input type="email" name="email" required><br>
        <button type="submit" class="action-button">Register</button>
    </form>
    <a href="<%=request.getContextPath()%>/JSP/login.jsp" class="action-button">Login</a>
</body>
</html>
