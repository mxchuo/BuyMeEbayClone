<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%

    if (session != null && session.getAttribute("user") != null) {
        String username = (String) session.getAttribute("user");

        try (Connection conn = new ApplicationDB().getConnection();
             PreparedStatement stmt = conn.prepareStatement("DELETE FROM users WHERE username = ?")) {
            stmt.setString(1, username);
            stmt.executeUpdate();
        } catch (SQLException e) {
        }
        session.invalidate();
    }
    response.sendRedirect(request.getContextPath() + "/JSP/login.jsp");
%>
