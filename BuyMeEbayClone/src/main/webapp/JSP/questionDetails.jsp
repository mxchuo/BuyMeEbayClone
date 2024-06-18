<%@ page import="java.sql.*, java.util.ArrayList" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int questionId = Integer.parseInt(request.getParameter("id"));
	Integer userId = (Integer) session.getAttribute("userID");
	if (userId == null) { response.sendRedirect("login.jsp"); return; }
    ArrayList<String[]> answers = new ArrayList<>();
    String questionTitle = "";
    String questionContent = "";
    Connection conn = null;
    try {
        conn = new ApplicationDB().getConnection();
        String questionSQL = "SELECT title, content FROM questions WHERE questionID = ?";
        PreparedStatement questionStmt = conn.prepareStatement(questionSQL);
        questionStmt.setInt(1, questionId);
        ResultSet qrs = questionStmt.executeQuery();
        if (qrs.next()) {
            questionTitle = qrs.getString("title");
            questionContent = qrs.getString("content");
        }
        qrs.close();
        questionStmt.close();

        String answersSQL = "SELECT a.answerID, a.content, a.timestamp, a.endorsed, u.username FROM answers a JOIN users u ON a.userId = u.userID WHERE questionID = ? ORDER BY a.timestamp ASC";
        PreparedStatement answersStmt = conn.prepareStatement(answersSQL);
        answersStmt.setInt(1, questionId);
        ResultSet ars = answersStmt.executeQuery();
        while (ars.next()) {
            answers.add(new String[]{ars.getString("answerID"), ars.getString("username"), ars.getString("content"), ars.getString("timestamp"), ars.getBoolean("endorsed") ? "Endorsed" : ""});
        }
        ars.close();
        answersStmt.close();
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) {
            e.printStackTrace();
        }
    }%>
<!DOCTYPE html>
<html>
<head>
    <title>Question Details</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        .link-button, .action-button, .endorse-button {
            display: inline-block;
            background-color: #49b8dc;
            color: white;
            padding: 10px 20px;
            margin: 10px;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .link-button:hover, .action-button:hover, .endorse-button:hover {
            background-color: #2b6e84;
        }
        .endorsed {
            color: green;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h1><%= questionTitle %></h1>
    <p><%= questionContent %></p>
    <hr>
    <h2>Answers</h2>
    <% if (answers.isEmpty()) { %>
        <p>No answers yet.</p>
    <% } else { 
        for (String[] answer : answers) { %>
            <p>
                <strong><%= answer[1] %>:</strong> <%= answer[2] %> <i>(<%= answer[3] %>)</i>
                <% if (answer[4].equals("Endorsed")) { %>
                    <span class="endorsed">Endorsed</span>
                <% } %>
                <% if (("custRep".equals(session.getAttribute("userRole")) || "admin".equals(session.getAttribute("userRole"))) && !answer[4].equals("Endorsed")) { %>
                    <a href="endorseAnswer.jsp?answerID=<%= answer[0] %>&questionID=<%= questionId %>" class="endorse-button">Endorse</a>
                <% } %>
            </p>
        <% }
    } %>
    <a href="answerQuestion.jsp?id=<%= questionId %>" class="action-button">Answer this question</a>
    <a href="qaBoard.jsp" class="link-button">Return to Q&A Board</a>
</body>
</html>
