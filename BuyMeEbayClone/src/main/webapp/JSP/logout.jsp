<%@page import="javax.servlet.http.HttpSession"%>
<%
    if(session != null){
        session.invalidate();
    }
    response.sendRedirect(request.getContextPath() + "/JSP/login.jsp");
%>
