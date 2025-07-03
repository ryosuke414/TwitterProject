<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Twitter</title>
<link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
</head>
<body>
    <h1>ログイン</h1>
    <form action="Login.action" method="post">
        <label>ID: <input type="text" name="handle"></label><br>
        <label>パスワード: <input type="password" name="password"></label><br>
        <input type="submit" value="ログイン">
        <%
            String error = (String)request.getAttribute("error");
            if (error != null) {
        %>
            <p class="error"><%= error %></p>
        <%
            }
        %>
    </form>
</body>
</html>