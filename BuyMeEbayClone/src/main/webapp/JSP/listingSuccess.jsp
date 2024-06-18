<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Bid Placed Successfully</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
            text-align: center;
        }
        .message {
            background-color: #dff0d8;
            color: #3c763d;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid #d6e9c6;
            border-radius: 4px;
            display: inline-block;
        }
        a {
            display: inline-block;
            background-color: #337ab7;
            color: white;
            padding: 10px 15px;
            margin: 5px;
            text-decoration: none;
            border-radius: 4px;
        }
        a:hover {
            background-color: #286090;
        }
    </style>
</head>
<body>

<div class="message">
    <h1>Item Listed Successfully!</h1>
    <p>Your listing has been successfully recorded.</p>
</div>

<a href="dashboard.jsp">Return to Dashboard</a>
<a href="searchItems.jsp">Browse Auctions</a>

</body>
</html>
