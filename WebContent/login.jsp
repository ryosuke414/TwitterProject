<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Twitter</title>
<link href="<%=request.getContextPath()%>/static/css/login.css" rel="stylesheet">
 <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
</head>
<body>
<body>
    <div class="login-container">
        <div class="login-box">
            <div class="logo">
                <h1>Twitter</h1>
            </div>
            <h2>ログイン</h2>
            <form action="Login.action" method="POST">
                <div class="input-group">
                    <input type="text" name="handle" placeholder="ハンドル名" required>
                </div>
                <div class="input-group">
                    <input type="password" name="password" placeholder="パスワード" required>
                </div>
                <button type="submit" class="login-button">ログイン</button>
                <%
                String error = (String)request.getAttribute("error");
                 if (error != null) {
                 %>
                <p class="error"><%= error %></p>
                 <% } %>
            </form>
            <p class="signup-link">
                アカウントをお持ちでないですか？
                <a href="./register.jsp">登録する</a>
            </p>
        </div>
    </div>
</body>
</html>