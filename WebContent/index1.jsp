<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page session="false" %>
<%
    String loginError = (String) request.getAttribute("loginError");
    String registerError = (String) request.getAttribute("registerError");
    String registered = request.getParameter("registered");
%>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>ログイン / アカウント作成</title>
<link rel="stylesheet" href="css/modal.css">
</head>
<body>

<div class="page-background">
  <div class="choice-card">
    <h2>ようこそ</h2>
    <button id="loginBtn" class="btn btn-primary" type="button">ログイン</button>
    <button id="registerBtn" class="btn btn-outline" type="button">アカウント作成</button>
    <% if ("1".equals(registered)) { %>
      <p class="success-msg">登録が完了しました！ログインしてください。</p>
    <% } %>
  </div>
</div>

<!-- ログインモーダル -->
<div id="loginModal" class="modal-overlay" role="dialog" aria-modal="true" aria-labelledby="loginTitle">
  <div class="modal">
    <h3 id="loginTitle">ログイン</h3>
    <form action="Login.action" method="post">
      <input type="text" name="handle" placeholder="@handle" required>
      <input type="password" name="password" placeholder="password" required>
      <button type="submit" class="btn btn-primary">ログイン</button>
    </form>
    <p class="error-msg"><%= loginError != null ? loginError : "" %></p>
    <button type="button" class="btn btn-close" data-close="loginModal">戻る</button>
  </div>
</div>

<!-- アカウント作成モーダル -->
<div id="registerModal" class="modal-overlay" role="dialog" aria-modal="true" aria-labelledby="registerTitle">
  <div class="modal">
    <h3 id="registerTitle">アカウント作成</h3>
    <form action="Register.action" method="post" enctype="multipart/form-data" accept-charset="UTF-8">
      <input type="text" name="username" placeholder="ユーザー名" required>
      <input type="text" name="handle" placeholder="@handle" required>
      <input type="password" name="password" placeholder="パスワード" required>
      <textarea name="bio" placeholder="自己紹介（任意）"></textarea>
      <input type="file" name="profileImage" accept="image/*">
      <button type="submit" class="btn btn-primary">登録</button>
    </form>
    <p class="error-msg"><%= registerError != null ? registerError : "" %></p>
    <button type="button" class="btn btn-close" data-close="registerModal">戻る</button>
  </div>
</div>

<!-- 外部JSを読み込み -->
<script src="js/modal.js"></script>

</body>
</html>