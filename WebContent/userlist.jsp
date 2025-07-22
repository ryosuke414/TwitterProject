<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, bean.User, bean.Message" %>
<%@ page import="dao.FollowDAO, dao.MessageDAO" %>
<%
  User me = (User) session.getAttribute("user");
  if (me == null) { response.sendRedirect("index.jsp"); return; }

  List<User> users = (List<User>) request.getAttribute("users");
  FollowDAO fdao = new FollowDAO();

  String toStr = request.getParameter("to");
  List<Message> messages = null;
  int toId = -1;
  if (toStr != null) {
      try {
          toId = Integer.parseInt(toStr);
          messages = new MessageDAO().getConversation(me.getUserId(), toId);
      } catch (Exception e) {
          // 無効なIDは無視
      }
  }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>ユーザー一覧</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<jsp:include page="sidebar.jsp" />

<!-- 中央カラム（ユーザー一覧） -->
<div class="center">
    <h2>ユーザー一覧</h2>

    <% for (User u : users) { %>
        <div class="user-entry">
            <strong><%= u.getUsername() %></strong> @<%= u.getHandle() %><br>
            <small><%= u.getBio() != null ? u.getBio() : "" %></small><br>

            <% boolean isFollowing = fdao.isFollowing(me.getUserId(), u.getUserId()); %>
            <form action="Follow.action" method="post" style="display:inline;">
                <input type="hidden" name="target" value="<%= u.getUserId() %>">
                <input type="hidden" name="op" value="<%= isFollowing ? "unfollow" : "follow" %>">
                <button type="submit"><%= isFollowing ? "フォロー解除" : "フォロー" %></button>
            </form>

            <!-- DMリンクで右側に表示 -->
            <a href="UserList.action?to=<%= u.getUserId() %>">DM</a>
        </div>
    <% } %>
</div>

<!-- 右カラム（DM表示） -->
<% if (messages != null) { %>
<div class="right">
    <h2>ダイレクトメッセージ</h2>

    <% for (Message m : messages) { %>
        <div style="margin-bottom: 8px;">
            <strong><%= m.getFromHandle() %></strong>: <%= m.getContent() %>
            <small><%= m.getSentAt() %></small>
        </div>
    <% } %>

    <form action="DM.action" method="post" accept-charset="UTF-8">
        <input type="hidden" name="toId" value="<%= toId %>">
        <textarea name="content" rows="3" cols="40" required></textarea><br>
        <button type="submit">送信</button>
    </form>
</div>
<% } %>

</body>
</html>
