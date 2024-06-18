<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
String bidIdParam = request.getParameter("bidID");
int bidId = 0;
if (bidIdParam != null && !bidIdParam.isEmpty()) {
    bidId = Integer.parseInt(bidIdParam);
}

Integer userId = (Integer) session.getAttribute("userID");
String userRole = (String) session.getAttribute("userRole");

if (bidId > 0 && userId != null) {
    try (Connection conn = new ApplicationDB().getConnection()) {
        String sql = "DELETE FROM Bids WHERE bidID = ?";
        if (!"custRep".equals(userRole) && !"admin".equals(userRole)) {
            sql += " AND userID = ?";
        }
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, bidId);
        if (!"custRep".equals(userRole) && !"admin".equals(userRole)) {
            ps.setInt(2, userId);
        }
        int rowsAffected = ps.executeUpdate();
        if (rowsAffected > 0) {
            response.sendRedirect("deleteBidSuccess.jsp");
        } else {
            response.sendRedirect("error.jsp?message=Unable to delete bid");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("error.jsp?message=Error deleting bid");
    }
} else {
    response.sendRedirect("error.jsp?message=Invalid bid ID or user ID");
}
%>