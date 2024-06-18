<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
    String make = request.getParameter("make");
    String model = request.getParameter("model");
    String yomStr = request.getParameter("yom");
    String color = request.getParameter("color");

    Integer userId = (Integer) session.getAttribute("userID");
    int yom = -1;
    try {
        yom = Integer.parseInt(yomStr);
    } catch(NumberFormatException e) {
        yom = -1;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try (Connection conn = new ApplicationDB().getConnection();
             PreparedStatement stmt = conn.prepareStatement("INSERT INTO Alerts (userID, make, model, yom, color) VALUES (?, ?, ?, ?, ?)")) {
            stmt.setInt(1, userId);
            stmt.setString(2, make);
            stmt.setString(3, model);
            if(yom != -1) {
                stmt.setInt(4, yom);
            } else {
                stmt.setNull(4, Types.INTEGER);
            }
            stmt.setString(5, color);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    response.sendRedirect(request.getContextPath() + "/JSP/dashboard.jsp");
    
%>