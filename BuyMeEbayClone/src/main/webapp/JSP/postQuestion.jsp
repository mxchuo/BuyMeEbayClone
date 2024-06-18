<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String questionTitle = request.getParameter("title");
    String questionContent = request.getParameter("content");
    if ("POST".equalsIgnoreCase(request.getMethod()) && questionTitle != null && questionContent != null && !questionTitle.trim().isEmpty() && !questionContent.trim().isEmpty()) {
        Connection conn = null;
        try {
            conn = new ApplicationDB().getConnection();
            String sql = "INSERT INTO questions (title, content, userId, timestamp) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, questionTitle.trim());
            stmt.setString(2, questionContent.trim());
            stmt.setInt(3, (Integer) session.getAttribute("userID"));
            stmt.executeUpdate();
            stmt.close();
            response.sendRedirect("qaBoard.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Post a Question</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        .action-button, input[type="submit"] {
            display: inline-block;
            background-color: #49b8dc;
            color: white;
            padding: 10px 20px;
            margin: 10px;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
            border: none;
            cursor: pointer;
        }
        .action-button:hover, input[type="submit"]:hover {
            background-color: #2b6e84;
        }
        input[type="text"], textarea {
            padding: 10px;
            margin: 5px;
            border: 1px solid #ddd;
            border-radius: 5px;
            width: calc(50% - 22px);
            max-width: 300px;
        }
    </style>
</head>
<body>
    <h1>Post a New Question</h1>
    <form method="post">
        <label>Title:</label><br>
        <input type="text" name="title" required><br>
        <label>Content:</label><br>
        <textarea name="content" required></textarea><br>
        <input type="submit" value="Submit" class="action-button">
    </form>
</body>
</html>