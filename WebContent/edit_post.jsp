<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.Post" %>
<%
    Post post = (Post) request.getAttribute("post");
    if (post == null) {
        response.sendRedirect("Profile.action");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>投稿編集</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<jsp:include page="sidebar.jsp" />

<div class="main">
    <h2>投稿を編集</h2>
    <form action="EditPost.action" method="post">
        <input type="hidden" name="tweetId" value="<%= post.getTweetId() %>">
        <textarea name="content" rows="5" cols="60" required><%= post.getContent() %></textarea><br><br>
        <button type="submit">更新</button>
        <a href="Profile.action">キャンセル</a>
    </form>
</div>
</body>
</html>
