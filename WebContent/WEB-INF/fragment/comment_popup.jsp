<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, bean.Post, bean.Comment, bean.User" %>

<%
Post post = (Post) request.getAttribute("post");
User me    = (User) session.getAttribute("user");

int commentCount = (Integer) request.getAttribute("commentCount");

@SuppressWarnings("unchecked")
List<Comment> comments = (List<Comment>) request.getAttribute("comments");

/* 投稿アイコン（50px） */
final int ICON = 50;
String postIconPath = (post.getProfileImage() != null)
    ? request.getContextPath() + "/profile_images/" + post.getProfileImage()
    : request.getContextPath() + "/images/default_icon.jpg";
int w = (post.getProfileIconW() != null) ? post.getProfileIconW() : 300;
int h = (post.getProfileIconH() != null) ? post.getProfileIconH() : 300;
int x = (post.getProfileIconX() != null) ? post.getProfileIconX() : 0;
int y = (post.getProfileIconY() != null) ? post.getProfileIconY() : 0;
double scale = ICON / 300.0;
int bgW = (int)Math.round(w * scale);
int bgH = (int)Math.round(h * scale);
int bgX = (int)Math.round(x * scale);
int bgY = (int)Math.round(y * scale);
%>

<div class="modal-post-header">
  <a class="modal-post-icon"
     href="Profile.action?userId=<%= post.getUserId() %>"
     style="background-image:url('<%= postIconPath %>');
            background-size:<%= bgW %>px <%= bgH %>px;
            background-position:-<%= bgX %>px -<%= bgY %>px;"></a>
  <div style="flex:1;">
    <a href="Profile.action?userId=<%= post.getUserId() %>" style="font-weight:600; text-decoration:none; color:#000;"><%= post.getUsername() %></a>
    <a href="Profile.action?userId=<%= post.getUserId() %>" style="text-decoration:none; color:#555;">@<%= post.getHandle() %></a><br>
    <div style="margin-top:6px; white-space:pre-wrap;"><%= post.getContent() %></div>
    <div style="margin-top:6px; font-size:12px; color:#666;"><%= post.getCreatedAt() %></div>
  </div>
</div>

<hr>

<h4>コメントを書く</h4>
<form action="Comment.action" method="post">
  <input type="hidden" name="tweetId" value="<%= post.getTweetId() %>">
  <textarea name="content" rows="3" cols="50" required></textarea><br>
  <button type="submit">送信</button>
</form>

<hr>

<h4>コメント一覧（<%= commentCount %>件）</h4>
<%
if (comments != null && !comments.isEmpty()) {
  for (Comment c : comments) {
    String cIconPath = (c.getProfileImage() != null)
        ? request.getContextPath() + "/profile_images/" + c.getProfileImage()
        : request.getContextPath() + "/images/default_icon.jpg";
%>
  <div class="modal-comment">
    <div class="comment-head">
      <a class="modal-comment-icon"
         href="Profile.action?userId=<%= c.getUserId() %>"
         style="background-image:url('<%= cIconPath %>'); background-size:cover; background-position:center;"></a>
      <div style="flex:1;">
        <a href="Profile.action?userId=<%= c.getUserId() %>" style="font-weight:600; text-decoration:none; color:#000;"><%= c.getUsername() %></a>
        <a href="Profile.action?userId=<%= c.getUserId() %>" style="text-decoration:none; color:#555;">@<%= c.getHandle() %></a>
        <div style="margin-top:4px; white-space:pre-wrap;"><%= c.getContent() %></div>
        <small><%= c.getCreatedAt() %></small>
        <% if (me != null && me.getUserId() == c.getUserId()) { %>
          <form action="Comment.action" method="get"
                onsubmit="return confirm('コメントを削除しますか？');"
                style="display:inline; margin-left:8px;">
            <input type="hidden" name="deleteId" value="<%= c.getCommentId() %>">
            <input type="hidden" name="tweetId" value="<%= post.getTweetId() %>">
            <button type="submit" style="background:none; border:none; color:#c00; cursor:pointer;">削除</button>
          </form>
        <% } %>
      </div>
    </div>
  </div>
<%
  }
} else {
%>
  <p class="empty-comments">まだコメントはありません。</p>
<%
}
%>
