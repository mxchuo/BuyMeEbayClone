<!DOCTYPE html>
<html>
<head>
    <title>Set Alerts</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        .form-input,
        .form-button,
        .link-button {
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
    </style>
</head>
<body>
    <h1>Set an Alert for an Item</h1>
    <form action="<%=request.getContextPath()%>/JSP/setAlerts.jsp" method="post">
        Make: <input type="text" name="make" class="form-input"><br>
        Model: <input type="text" name="model" class="form-input"><br>
        Year: <input type="number" name="yom" class="form-input"><br>
        Color: <input type="text" name="color" class="form-input"><br>
        <button type="submit" class="form-button">Set Alert</button>
    </form>
    <a href="<%=request.getContextPath()%>/JSP/dashboard.jsp" class="link-button">Back to Dashboard</a>
</body>
</html>
