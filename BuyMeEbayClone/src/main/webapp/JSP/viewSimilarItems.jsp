<%@ page import="java.sql.*, java.util.List, java.util.ArrayList, java.util.HashMap, java.util.Map, java.net.URLEncoder"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>

<%
    String category = request.getParameter("category");
    String currentItemID = request.getParameter("itemID");
    List<Map<String, Object>> similarItems = new ArrayList<>();

    if (category != null && currentItemID != null) {
        try (Connection conn = new ApplicationDB().getConnection()) {
            String query = "SELECT i.itemID, i.title, i.initialPrice, i.category, i.closeTime FROM Items i "
                         + "WHERE i.category = ? AND i.closeTime BETWEEN DATE_SUB(NOW(), INTERVAL 1 MONTH) AND NOW()";
            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, category);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("itemID", rs.getInt("itemID"));
                        item.put("title", rs.getString("title"));
                        item.put("initialPrice", rs.getFloat("initialPrice"));
                        item.put("category", rs.getString("category"));
                        item.put("closeTime", rs.getString("closeTime"));
                        similarItems.add(item);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
<title>Similar Items</title>
<style>
body {
    text-align: center;
    font-family: Arial, sans-serif;
    margin-top: 50px;
}

.form-input, .form-button, .link-button {
    margin: 10px;
    padding: 10px;
}

.form-input {
    border: 1px solid #ddd;
    border-radius: 5px;
}

.form-button {
    background-color: #49b8dc;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s;
}

.form-button:hover {
    background-color: #2b6e84;
}

.link-button {
    display: inline-block;
    background-color: #49b8dc;
    color: white;
    text-decoration: none;
    border-radius: 5px;
    transition: background-color 0.3s;
}

.link-button:hover {
    background-color: #2b6e84;
}

ul {
    list-style-type: none;
    padding: 0;
}

li {
    margin-bottom: 40px;
}
</style>
</head>
<body>

<h1>Similar Items</h1>
<ul>
    <%
    for (Map<String, Object> item : similarItems) {
    %>
    <li>
        <%= item.get("title") %><br>
        Initial Price: $<%= item.get("initialPrice") %><br>
        Closing Time: <%= item.get("closeTime") %><br>
        <a href="viewBidHistory.jsp?itemID=<%= item.get("itemID") %>" class="link-button">View Bids</a>
    </li>
    <%
    }
    %>
</ul>

<% if (similarItems.isEmpty()) { %>
<p>No similar items found.</p>
<% } %>

<a href="<%=request.getContextPath()%>/JSP/dashboard.jsp" class="link-button">Back to Dashboard</a>
<a href="searchItems.jsp" class="link-button">Back to Search</a>

</body>
</html>