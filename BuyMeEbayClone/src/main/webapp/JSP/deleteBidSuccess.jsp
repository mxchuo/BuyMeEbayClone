<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Bid Withdrawn Successfully</title>
    <style>
body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 20px;
        background-color: #ffffff; 
        color: #000000; 
        text-align: center;
    }
    .message, .error {
        padding: 10px;
        margin-bottom: 20px;
        border-radius: 0;
        display: inline-block;
        border: 1px solid #000;
    }
    a {
        display: inline-block;
        background-color: #ffffff;
        color: #000000;
        padding: 10px 15px;
        margin: 5px;
        text-decoration: none;
        border: 1px solid #000;
    }
    a:hover {
        background-color: #f0f0f0;
    }
    </style>
</head>
<body>

<div class="message">
    <h1>Bid Withdrawn Successfully!</h1>
    <p>Your bid has been successfully withdrawn.</p>
</div>

<a href="dashboard.jsp">Return to Dashboard</a>
<a href="searchItems.jsp">Browse Auctions</a>

</body>
</html>
