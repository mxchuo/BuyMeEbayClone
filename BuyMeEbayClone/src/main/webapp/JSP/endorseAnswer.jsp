<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int answerID = Integer.parseInt(request.getParameter("answerID"));
    int questionID = Integer.parseInt(request.getParameter("questionID"));
    if ("custRep".equals(session.getAttribute("userRole")) || "admin".equals(session.getAttribute("userRole"))) {
        Connection conn = null;
        try {
            conn = new ApplicationDB().getConnection();
            String sql = "UPDATE answers SET endorsed = TRUE WHERE answerID = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, answerID);
            stmt.executeUpdate();
            stmt.close();
            response.sendRedirect("questionDetails.jsp?id=" + questionID);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
%>