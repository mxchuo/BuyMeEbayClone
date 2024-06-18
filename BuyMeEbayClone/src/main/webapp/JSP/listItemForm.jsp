<!DOCTYPE html>
<html>
<head>
    <title>List an Item</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        .form-input,
        .form-select,
        .form-textarea,
        .form-button,
        .link-button {
            margin: 10px;
            padding: 10px;
        }
        .form-input,
        .form-select,
        .form-textarea {
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
    <h1>List a New Item for Sale</h1>
    <form action="<%=request.getContextPath()%>/JSP/listItem.jsp" method="post">
        Make: <input type="text" name="make" class="form-input" required><br>
        Model: <input type="text" name="model" class="form-input" required><br>
        Year: <input type="number" name="year" class="form-input" required><br>
        Color: <input type="text" name="color" class="form-input" required><br>
        Description: <textarea name="description" class="form-textarea" required></textarea><br>
        Close Time: <input type="datetime-local" name="closeTime" class="form-input" required><br>
        Initial Price: <input type="number" name="initialPrice" class="form-input" required><br>
        Minimum Selling Price: <input type="number" name="minSellPrice" class="form-input" required><br>
        Minimum Bid Increment: <input type="number" name="minBidIncrement" class="form-input" required><br>
        Category:
        <select name="category" class="form-select" required>
            <option value="SUV">SUV</option>
            <option value="Car">Car</option>
            <option value="Truck">Truck</option>
        </select><br>
        <button type="submit" class="form-button">List Item</button>
    </form>
    <a href="<%=request.getContextPath()%>/JSP/dashboard.jsp" class="link-button">Back to Dashboard</a>
</body>
</html>