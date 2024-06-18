<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int questionId = Integer.parseInt(request.getParameter("id"));
    String questionTitle = "";
    String questionContent = "";
    String answerContent = request.getParameter("content");

    Connection conn = null;
    try {
        conn = new ApplicationDB().getConnection();
        String fetchQuestion = "SELECT title, content FROM questions WHERE questionID = ?";
        PreparedStatement questionStmt = conn.prepareStatement(fetchQuestion);
        questionStmt.setInt(1, questionId);
        ResultSet rs = questionStmt.executeQuery();
        if (rs.next()) {
            questionTitle = rs.getString("title");
            questionContent = rs.getString("content");
        }
        rs.close();
        questionStmt.close(); 

        if ("POST".equalsIgnoreCase(request.getMethod()) && answerContent != null && !answerContent.trim().isEmpty()) {
            String sql = "INSERT INTO answers (questionId, content, userId, timestamp) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, questionId);
            stmt.setString(2, answerContent.trim());
            stmt.setInt(3, (Integer) session.getAttribute("userID"));
            stmt.executeUpdate();
            stmt.close();
            response.sendRedirect("questionDetails.jsp?id=" + questionId);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Answer Question</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        .action-button, input[type="submit"], .return-button {
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
        .action-button:hover, input[type="submit"]:hover, .return-button:hover {
            background-color: #2b6e84;
        }
        textarea {
            padding: 10px;
            margin: 5px;
            border: 1px solid #ddd;
            border-radius: 5px;
            width: 50%;
            min-width: 300px;
            height: 150px;
        }
    </style>
</head>
<body>
    <h1>Answer Question</h1>
    <h2><%= questionTitle %></h2>
    <p><%= questionContent %></p>
    <form method="post">
        <textarea name="content" required placeholder="Type your answer here..."></textarea><br>
        <input type="submit" value="Submit Answer" class="action-button">
    </form>
    <a href="questionDetails.jsp?id=<%= questionId %>" class="return-button">Return to Question Details</a>
</body>
</html>