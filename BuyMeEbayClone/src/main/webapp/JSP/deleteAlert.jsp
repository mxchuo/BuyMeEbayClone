<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
    String alertIDStr = request.getParameter("alertID");
    if (alertIDStr != null && !alertIDStr.isEmpty()) {
        int alertID = Integer.parseInt(alertIDStr);
        try (Connection conn = new ApplicationDB().getConnection();
             PreparedStatement stmt = conn.prepareStatement("DELETE FROM alerts WHERE alertID = ?")) {
            stmt.setInt(1, alertID);
            stmt.executeUpdate();
            response.sendRedirect(request.getContextPath() + "/JSP/dashboard.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>