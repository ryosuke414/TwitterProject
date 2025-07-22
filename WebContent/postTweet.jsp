<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ツイート投稿</title>
</head>
<body>
    <h2>新規ツイート</h2>

    <form action="PostTweet.action" method="post" enctype="multipart/form-data">
        <label for="content">いまどうしてる？</label><br>
        <textarea name="content" id="content" rows="4" cols="60" placeholder="いまどうしてる？"></textarea><br><br>

        <label for="images">画像を選択（複数可）</label><br>
        <input type="file" name="images" id="images" multiple accept="image/*"><br><br>

        <input type="submit" value="ツイート">
    </form>

    <br>
    <a href="home.jsp">タイムラインに戻る</a>
</body>
</html>