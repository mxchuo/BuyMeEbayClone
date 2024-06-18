<%@ page import="java.sql.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<%@ page import="javax.servlet.http.HttpSession"%>
<%
String username = request.getParameter("username");
String password = request.getParameter("password");
boolean loginSuccess = true;

if ("POST".equalsIgnoreCase(request.getMethod()) && username != null && password != null) {
	try (Connection conn = new ApplicationDB().getConnection();
	PreparedStatement stmt = conn
			.prepareStatement("SELECT userID, role FROM users WHERE username = ? AND password = ?")) {
		stmt.setString(1, username);
		stmt.setString(2, password);
		ResultSet rs = stmt.executeQuery();
		if (rs.next()) {
	int userId = rs.getInt("userID");
	String userRole = rs.getString("role");
	session.setAttribute("userID", userId);
	session.setAttribute("user", username);
	session.setAttribute("userRole", userRole);
	response.sendRedirect(request.getContextPath() + "/JSP/dashboard.jsp");
	return;
		} else {
	loginSuccess = false;
		}
		rs.close();
	} catch (SQLException e) {
		e.printStackTrace();
		loginSuccess = false;
	}
}
%>
<!DOCTYPE html>
<html>
<head>
<title>Login</title>
<style>
body {
	text-align: center;
	font-family: Arial, sans-serif;
	margin-top: 50px;
}

input[type="text"], input[type="password"] {
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
	<h2>Login</h2>
	<%
	if (!loginSuccess && "POST".equalsIgnoreCase(request.getMethod())) {
	%>
	<p>Login failed.</p>
	<%
	}
	%>
	<form action="<%=request.getContextPath()%>/JSP/login.jsp"
		method="post">
		Username: <input type="text" name="username" required><br>
		Password: <input type="password" name="password" required><br>
		<button type="submit" class="action-button">Login</button>
	</form>
	<a href="<%=request.getContextPath()%>/JSP/register.jsp"
		class="action-button">Register</a>
</body>
</html>
