<%@ page import="java.sql.*, java.util.ArrayList" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    ArrayList<String[]> questions = new ArrayList<>();
    String searchKeyword = request.getParameter("search");
    Connection conn = null;
    try {
        conn = new ApplicationDB().getConnection();
        String sql = "SELECT questionID, title, content FROM questions";
        if (searchKeyword != null && !searchKeyword.isEmpty()) {
            sql += " WHERE title LIKE ? OR content LIKE ?";
        }
        PreparedStatement stmt = conn.prepareStatement(sql);
        if (searchKeyword != null && !searchKeyword.isEmpty()) {
            stmt.setString(1, "%" + searchKeyword + "%");
            stmt.setString(2, "%" + searchKeyword + "%");
        }
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            questions.add(new String[]{rs.getString("questionID"), rs.getString("title")});
        }
        rs.close();
        stmt.close();
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Q&A Board</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        .link-button {
            display: inline-block;
            background-color: #49b8dc;
            color: white;
            padding: 10px 20px;
            margin: 10px;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .link-button:hover {
            background-color: #2b6e84;
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
    <h1>Q&A Board</h1>
    <form action="qaBoard.jsp" method="get">
        <input type="text" name="search" placeholder="Search questions" style="padding: 10px; border-radius: 5px; border: 1px solid #ddd;">
        <input type="submit" value="Search" class="action-button">
    </form>
    <% for (String[] question : questions) { %>
        <p><a href="questionDetails.jsp?id=<%= question[0] %>" class="link-button"><%= question[1] %></a></p>
    <% } %>
    <hr>
    <h2>Post a New Question</h2>
    <form action="postQuestion.jsp" method="post" style="margin: auto; width: 50%;">
        <label>Title:</label>
        <input type="text" name="title" required style="padding: 10px; border-radius: 5px; border: 1px solid #ddd; width: 100%;"><br><br>
        <label>Content:</label>
        <textarea name="content" required style="padding: 10px; border-radius: 5px; border: 1px solid #ddd; width: 100%; height: 150px;"></textarea><br><br>
        <input type="submit" value="Post Question" class="action-button">
    </form>
	    <a href="dashboard.jsp" class="action-button">Return to Dashboard</a>
</body>
</html>
