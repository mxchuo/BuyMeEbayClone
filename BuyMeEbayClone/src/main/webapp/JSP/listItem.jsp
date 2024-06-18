<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
    String make = request.getParameter("make");
    String model = request.getParameter("model");
    String year = request.getParameter("year");
    String color = request.getParameter("color");
    String description = request.getParameter("description");
    String closeTime = request.getParameter("closeTime");
    int initialPrice = Integer.parseInt(request.getParameter("initialPrice"));
    int minSellPrice = Integer.parseInt(request.getParameter("minSellPrice"));
    int minBidIncrement = Integer.parseInt(request.getParameter("minBidIncrement"));
    String category = request.getParameter("category");
    Integer userId = (Integer) session.getAttribute("userID");

    String title = make + " " + model + " " + year + " " + color;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try (Connection conn = new ApplicationDB().getConnection();
             PreparedStatement stmt = conn.prepareStatement("INSERT INTO Items (userId, make, model, yom, color, description, closeTime, initialPrice, minSellPrice, minBidIncrement, category, title) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")) {
            stmt.setInt(1, userId);
            stmt.setString(2, make);
            stmt.setString(3, model);
            stmt.setInt(4, Integer.parseInt(year)); 
            stmt.setString(5, color);
            stmt.setString(6, description);
            stmt.setString(7, closeTime);
            stmt.setInt(8, initialPrice);
            stmt.setInt(9, minSellPrice);
            stmt.setInt(10, minBidIncrement);
            stmt.setString(11, category);
            stmt.setString(12, title);
            stmt.executeUpdate();
            response.sendRedirect(request.getContextPath() + "/JSP/listingSuccess.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>