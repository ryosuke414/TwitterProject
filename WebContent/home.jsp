<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, bean.Post, bean.User" %>
<%@ page import="dao.PostDAO, dao.LikeDAO, dao.BookmarkDAO, dao.CommentDAO, dao.RepostDAO" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Post> posts = (List<Post>) request.getAttribute("posts");

    final int ICON_SIZE = 50;
    String myIconPath = (me.getProfileImage() != null)
        ? request.getContextPath() + "/profile_images/" + me.getProfileImage()
        : request.getContextPath() + "/images/default_icon.jpg";
    int myW = (me.getProfileIconW() != null) ? me.getProfileIconW() : 300;
    int myH = (me.getProfileIconH() != null) ? me.getProfileIconH() : 300;
    int myX = (me.getProfileIconX() != null) ? me.getProfileIconX() : 0;
    int myY = (me.getProfileIconY() != null) ? me.getProfileIconY() : 0;
    double myScale = ICON_SIZE / 300.0;
    int myBgW = (int)Math.round(myW * myScale);
    int myBgH = (int)Math.round(myH * myScale);
    int myBgX = (int)Math.round(myX * myScale);
    int myBgY = (int)Math.round(myY * myScale);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>タイムライン</title>
<link rel="stylesheet" href="css/home.css">
<link rel="stylesheet" href="css/modal.css">
</head>
<body>
<jsp:include page="sidebar.jsp" />
<jsp:include page="right_sidebar.jsp" />

<div class="main">
    <h2>タイムライン</h2>
    <p>ようこそ、<strong><%= me.getUsername() %></strong> (@<%= me.getHandle() %>)</p>
    <hr>

    <!-- 投稿フォーム -->
    <form action="Post.action" method="post" enctype="multipart/form-data">
        <div class="post-form">
            <div class="post-icon"
                 style="background-image:url('<%= myIconPath %>');
                        background-size:<%= myBgW %>px <%= myBgH %>px;
                        background-position:-<%= myBgX %>px -<%= myBgY %>px;">
            </div>
            <div class="post-input">
                <textarea name="content" rows="3" placeholder="いまどうしてる？" required></textarea><br>
                <input type="file" name="images" accept="image/*" multiple><br>
                <button type="submit">投稿</button>
            </div>
        </div>
    </form>

    <hr>

    <%-- 投稿の表示 --%>
    <%
        PostDAO pdao = new PostDAO();
        LikeDAO ldao = new LikeDAO();
        BookmarkDAO bdao = new BookmarkDAO();
        CommentDAO cdao = new CommentDAO();
        RepostDAO rdao = new RepostDAO();

        if (posts != null) {
            for (Post p : posts) {
                int tweetId = p.getTweetId();
                int likeCount = ldao.countLikes(tweetId);
                int commentCount = cdao.countByTweet(tweetId);
                int repostCount = rdao.countReposts(tweetId);
                boolean liked = ldao.isLiked(me.getUserId(), tweetId);
                boolean reposted = rdao.isReposted(me.getUserId(), tweetId);
                boolean bookmarked = bdao.isBookmarked(me.getUserId(), tweetId);
                List<String> images = pdao.getImages(tweetId);

                String iconPath = (p.getProfileImage() != null)
                    ? request.getContextPath() + "/profile_images/" + p.getProfileImage()
                    : request.getContextPath() + "/images/default_icon.jpg";

                int w = (p.getProfileIconW() != null) ? p.getProfileIconW() : 300;
                int h = (p.getProfileIconH() != null) ? p.getProfileIconH() : 300;
                int x = (p.getProfileIconX() != null) ? p.getProfileIconX() : 0;
                int y = (p.getProfileIconY() != null) ? p.getProfileIconY() : 0;
                double scale = ICON_SIZE / 300.0;
                int bgW = (int)Math.round(w * scale);
                int bgH = (int)Math.round(h * scale);
                int bgX = (int)Math.round(x * scale);
                int bgY = (int)Math.round(y * scale);
                boolean ownPost = (p.getUserId() == me.getUserId());

                // 編集用に content を属性に入れられるよう軽くエスケープ
                String rawContent = (p.getContent() != null) ? p.getContent() : "";
                String attrContent = rawContent
                        .replace("&","&amp;")
                        .replace("<","&lt;")
                        .replace(">","&gt;")
                        .replace("\"","&quot;")
                        .replace("'","&#39;");
    %>
    <div class="tweet">
      <div class="tweet-row">
        <a class="tweet-icon"
           href="Profile.action?userId=<%= p.getUserId() %>"
           style="
             width:<%= ICON_SIZE %>px; height:<%= ICON_SIZE %>px;
             background-image:url('<%= iconPath %>');
             background-size:<%= bgW %>px <%= bgH %>px;
             background-position:-<%= bgX %>px -<%= bgY %>px;
             display:block;">
        </a>

        <div class="tweet-body">
          <% if (ownPost) { %>
            <div class="tweet-menu" onclick="toggleMenu(this)">⋯</div>
            <div class="dropdown-menu">
                <a href="#" class="js-edit-post"
                   data-tweet-id="<%= tweetId %>"
                   data-content="<%= attrContent %>">編集</a>
                <form action="DeletePost.action" method="post"
                      onsubmit="return confirm('この投稿を削除しますか？');">
                  <input type="hidden" name="tweetId" value="<%= tweetId %>">
                  <button type="submit">削除</button>
                </form>
            </div>
          <% } %>

          <p><strong><%= p.getUsername() %></strong> (@<%= p.getHandle() %>)</p>
          <p><%= rawContent %></p>

          <% if (images != null && !images.isEmpty()) { %>
            <div class="post-images">
              <% for (String img : images) { %>
                <img src="<%= request.getContextPath() + "/images/" + img %>" alt="投稿画像"
                     style="max-width: 200px; max-height: 200px; margin: 5px;">
              <% } %>
            </div>
          <% } %>

          <div class="post-actions">
            <button type="button"
                    class="action-btn js-open-comments"
                    data-tweet-id="<%= tweetId %>">
              <img src="images/comment.png" alt="コメント">
              <span class="count" data-role="comment-count"><%= commentCount %></span>
            </button>

            <form action="Repost.action" method="post" style="display:inline;">
              <input type="hidden" name="tweetId" value="<%= tweetId %>">
              <button type="submit" class="action-btn">
                <img src="images/<%= reposted ? "repost_on.png" : "repost_off.png" %>" alt="リポスト">
                <span class="count"><%= repostCount %></span>
              </button>
            </form>

            <form action="Like.action" method="post" style="display:inline;">
              <input type="hidden" name="tweetId" value="<%= tweetId %>">
              <button type="submit" class="action-btn">
                <img src="images/<%= liked ? "like_on.png" : "like_off.png" %>" alt="いいね">
                <span class="count"><%= likeCount %></span>
              </button>
            </form>

            <form action="Bookmark.action" method="post" style="display:inline;">
              <input type="hidden" name="tweetId" value="<%= tweetId %>">
              <input type="hidden" name="op" value="<%= bookmarked ? "remove" : "add" %>">
              <button type="submit" class="action-btn">
                <img src="images/<%= bookmarked ? "bookmark_on.png" : "bookmark_off.png" %>" alt="ブックマーク">
              </button>
            </form>
          </div><!-- /.post-actions -->

        </div><!-- /.tweet-body -->
      </div><!-- /.tweet-row -->
    </div><!-- /.tweet -->
    <%
            } // for posts
        }
    %>
</div><!-- /.main -->

<!-- コメントモーダル -->
<div id="commentModalOverlay" class="modal-overlay">
  <div class="modal-box">
    <button class="modal-close" type="button" onclick="closeCommentModal()">✕</button>
    <div id="commentModalContent"></div>
  </div>
</div>

<!-- 編集モーダル -->
<div id="editPostModalOverlay">
  <div id="editPostModalBox">
    <h3>投稿を編集</h3>
    <form id="editPostForm" method="post" action="EditPost.action">
      <input type="hidden" name="tweetId" id="editTweetId">
      <textarea name="content" id="editContent" rows="4" style="width:100%;"></textarea><br>
      <button type="submit">更新</button>
      <button type="button" onclick="closeEditModal()">キャンセル</button>
    </form>
  </div>
</div>

<script src="js/home.js"></script>
<script src="js/right_sidebar.js"></script>
</body>
</html>