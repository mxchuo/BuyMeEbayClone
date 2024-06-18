<%@ page import="java.sql.*, java.util.List, java.util.ArrayList, java.util.HashMap, java.util.Map, java.net.URLEncoder"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>

<%
Integer loggedInUserId = (Integer) session.getAttribute("userID");
if (loggedInUserId == null) {
    response.sendRedirect("login.jsp");
    return;
}

List<Map<String, Object>> searchResults = new ArrayList<>();
String searchQuery = request.getParameter("searchQuery") != null ? request.getParameter("searchQuery") : "";
String searchCriteria = request.getParameter("searchCriteria") != null ? request.getParameter("searchCriteria") : "title";
String sortBy = request.getParameter("sortBy") != null ? request.getParameter("sortBy") : "closeTime";
String order = request.getParameter("order") != null ? request.getParameter("order") : "ASC";

if (!searchQuery.isEmpty()) {
    try (Connection conn = new ApplicationDB().getConnection()) {
        String sql = "SELECT i.itemID, i.title, i.initialPrice, i.category, i.userID AS ownerID, (SELECT MAX(bidAmount) FROM bids WHERE itemID = i.itemID) AS highestBid, i.closeTime, i.minSellPrice, i.minBidIncrement "
            + "FROM Items i WHERE " + searchCriteria + " LIKE ? AND i.closeTime > NOW() ORDER BY " + sortBy + " " + order;
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, "%" + searchQuery + "%");
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("itemID", rs.getInt("itemID"));
            row.put("title", rs.getString("title"));
            row.put("initialPrice", rs.getFloat("initialPrice"));
            row.put("highestBid", rs.getFloat("highestBid"));
            row.put("closeTime", rs.getString("closeTime"));
            row.put("ownerID", rs.getInt("ownerID"));
            row.put("category", rs.getString("category"));
            row.put("minBidIncrement", rs.getFloat("minBidIncrement"));
            searchResults.add(row);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Search Items</title>
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

<%
    String errorMessage = (String) request.getAttribute("errorMessage");
    if (errorMessage != null) {
%>
<div style="color: red; margin-bottom: 20px;"><%= errorMessage %></div>
<%
    }
%>

    <h1>Search for Items</h1>
    <form action="searchItems.jsp" method="post">
        Search Query: <input type="text" name="searchQuery" value="<%= searchQuery %>" class="form-input" required><br>
        Search Criteria: <select name="searchCriteria" class="form-input">
            <option value="title" <%= "title".equals(searchCriteria) ? "selected" : "" %>>Title</option>
            <option value="make" <%= "make".equals(searchCriteria) ? "selected" : "" %>>Make</option>
            <option value="model" <%= "model".equals(searchCriteria) ? "selected" : "" %>>Model</option>
            <option value="yom" <%= "yom".equals(searchCriteria) ? "selected" : "" %>>Year of Manufacture</option>
            <option value="color" <%= "color".equals(searchCriteria) ? "selected" : "" %>>Color</option>
            <option value="description" <%= "description".equals(searchCriteria) ? "selected" : "" %>>Description</option>
            <option value="category" <%= "category".equals(searchCriteria) ? "selected" : "" %>>Category</option>
        </select><br>
        Sort by: <select name="sortBy" class="form-input">
            <option value="initialPrice" <%= "initialPrice".equals(sortBy) ? "selected" : "" %>>Initial Price</option>
            <option value="highestBid" <%= "highestBid".equals(sortBy) ? "selected" : "" %>>Highest Bid</option>
            <option value="closeTime" <%= "closeTime".equals(sortBy) ? "selected" : "" %>>Close Time</option>
        </select><br>
        Order: <select name="order" class="form-input">
            <option value="ASC" <%= "ASC".equals(order) ? "selected" : "" %>>Ascending</option>
            <option value="DESC" <%= "DESC".equals(order) ? "selected" : "" %>>Descending</option>
        </select><br>
        <button type="submit" class="form-button">Search</button>
    </form>
    <h2>Search Results:</h2>
    <%
    if (searchResults != null && !searchResults.isEmpty()) {
    %>
    <ul>
        <%
        for (Map<String, Object> item : searchResults) {
        %>
        <li>
            <%= item.get("title") %><br>
            Initial Price: $<%= item.get("initialPrice") %><br>
            Highest Bid: $<%= item.get("highestBid") %><br>
            Minimum Bid Increment: $<%= item.get("minBidIncrement") != null ? item.get("minBidIncrement").toString() : "N/A" %><br>
            Closing Time: <%= item.get("closeTime") %><br>
            <a href="viewSimilarItems.jsp?category=<%= item.get("category") != null ? URLEncoder.encode(item.get("category").toString(), "UTF-8") : "default_category" %>&itemID=<%= item.get("itemID") != null ? item.get("itemID").toString() : "default_id" %>" class="link-button">View Similar Items</a>
	        <% 
	        Integer ownerId = (Integer) item.get("ownerID");
	        if (ownerId != null && !ownerId.equals(loggedInUserId)) {
	        %>
	        <form action="processBids.jsp" method="post">
		        <script>
					function checkAutoBidLimit() {
					    var autoBidLimit = document.getElementById("autoBidLimit");
					    var autoBidIncrement = document.getElementById("autoBidIncrement");
					    if (autoBidLimit.value != "") {
					        userAutoBidIncrement.required = true;
					    } else {
					        userAutoBidIncrement.required = false;
					    }
					}
				</script>
	            <input type="hidden" name="itemIDToBid" value="<%= item.get("itemID") %>">
	            Bid Amount: <input type="number" name="bidAmount" class="form-input" step="0.01" required><br>
	            Auto-Bid Limit: <input type="number" name="autoBidLimit" class="form-input" step="0.01" placeholder="Optional: Your max limit"><br>
	            Auto-Bid Increment: <input type="number" name="autoBidIncrement" class="form-input" step="0.01" placeholder="Required if auto-bid limit is set">
	            <input type="submit" class="form-button" value="Place Bid">
	        </form>
	        <% } else { %>
	        <form action="deleteItem.jsp" method="post">
	            <input type="hidden" name="itemID" value="<%= item.get("itemID") %>">
	            <input type="submit" class="form-button" value="Delete Listing" onclick="return confirm('Are you sure you want to delete this listing?');">
	        </form>
	        <% } %>
	        <a href="viewBidHistory.jsp?itemID=<%= item.get("itemID") %>" class="link-button">View Bids</a>
        </li>
        <%
        }
        %>
    </ul>
    <%
    } else {
    %>
    <p>No results found.</p>
    <%
    }
    %>

    <a href="<%=request.getContextPath()%>/JSP/dashboard.jsp" class="link-button">Back to Dashboard</a>
</body>
</html>

