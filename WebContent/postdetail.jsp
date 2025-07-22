<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, bean.Post, bean.Comment, bean.User" %>
<%@ page import="dao.PostDAO, dao.LikeDAO, dao.BookmarkDAO, dao.CommentDAO, dao.RepostDAO" %>
<%
    // --- ログイン確認 ---
    User me  = (User) session.getAttribute("user");
    if (me == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // --- 投稿本体 ---
    Post post = (Post) request.getAttribute("post");
    if (post == null) {
        response.sendRedirect("Timeline.action");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Comment> comments = (List<Comment>) request.getAttribute("comments");

    PostDAO     pdao = new PostDAO();
    LikeDAO     ldao = new LikeDAO();
    BookmarkDAO bdao = new BookmarkDAO();
    CommentDAO  cdao = new CommentDAO();
    RepostDAO   rdao = new RepostDAO();

    int tweetId        = post.getTweetId();
    boolean liked      = ldao.isLiked(me.getUserId(), tweetId);
    int likeCount      = ldao.countLikes(tweetId);
    int commentCount   = cdao.countByTweet(tweetId);
    int repostCount    = rdao.countReposts(tweetId);
    boolean reposted   = rdao.isReposted(me.getUserId(), tweetId);
    boolean bookmarked = bdao.isBookmarked(me.getUserId(), tweetId);

    List<String> imgs = pdao.getImages(tweetId);

    // 投稿者アイコン
    String profileImgPath = (post.getProfileImage() != null)
        ? request.getContextPath() + "/profile_images/" + post.getProfileImage()
        : request.getContextPath() + "/images/default_icon.jpg";

    // コメント投稿フォーム用自分のアイコン
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
<title>投稿詳細</title>
<link rel="stylesheet" href="css/style.css">
<style>
.back-btn {
  display:inline-block;
  margin-bottom:10px;
  padding:6px 12px;
  background-color:#f0f0f0;
  border:1px solid #ccc;
  border-radius:4px;
  cursor:pointer;
  font-size:14px;
}
.back-btn:hover {
  background-color:#e2e2e2;
}
</style>
</head>
<body>
<jsp:include page="sidebar.jsp" />
<jsp:include page="right_sidebar.jsp" />

<div class="main">
    <!-- 戻るボタン -->
    <button type="button" class="back-btn" onclick="history.back();">← 戻る</button>

    <h2>投稿詳細</h2>

    <!-- 元投稿表示 -->
    <div class="tweet tweet--row">
      <div class="tweet-row">
        <a class="tweet-icon"
           href="Profile.action?userId=<%= post.getUserId() %>"
           style="display:block; background-image:url('<%= profileImgPath %>');">
        </a>
        <div class="tweet-body">
          <div class="tweet-header" style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:4px;">
            <a href="Profile.action?userId=<%= post.getUserId() %>" style="font-weight:600; text-decoration:none; color:#000;"><%= post.getUsername() %></a>
            <a href="Profile.action?userId=<%= post.getUserId() %>" style="text-decoration:none; color:#555;">@<%= post.getHandle() %></a>
          </div>
          <div style="white-space:pre-wrap;"><%= post.getContent() %></div>
          <% for (String img : imgs) { %>
            <img src="images/<%= img %>" alt="投稿画像" style="max-width:200px; display:block; margin-top:6px;">
          <% } %>

          <div class="post-actions" style="margin-top:6px;">
            <!-- コメント（モーダル表示用ボタン） -->
            <button type="button"
                    class="action-btn js-open-comments"
                    data-tweet-id="<%= tweetId %>">
              <img src="images/comment.png" alt="コメント">
              <span class="count" data-role="comment-count"><%= commentCount %></span>
            </button>

            <!-- リポスト -->
            <form action="Repost.action" method="post" style="display:inline;">
              <input type="hidden" name="tweetId" value="<%= tweetId %>">
              <button type="submit" class="action-btn">
                <img src="images/<%= reposted ? "repost_on.png" : "repost_off.png" %>" alt="リポスト">
                <span class="count"><%= repostCount %></span>
              </button>
            </form>

            <!-- いいね -->
            <form action="Like.action" method="post" style="display:inline;">
              <input type="hidden" name="tweetId" value="<%= tweetId %>">
              <button type="submit" class="action-btn">
                <img src="images/<%= liked ? "like_on.png" : "like_off.png" %>" alt="いいね">
                <span class="count"><%= likeCount %></span>
              </button>
            </form>

            <!-- ブックマーク -->
            <form action="Bookmark.action" method="post" style="display:inline;">
              <input type="hidden" name="tweetId" value="<%= tweetId %>">
              <input type="hidden" name="op" value="<%= bookmarked ? "remove" : "add" %>">
              <button type="submit" class="action-btn">
                <img src="images/<%= bookmarked ? "bookmark_on.png" : "bookmark_off.png" %>" alt="ブックマーク">
              </button>
            </form>
          </div>
          <div><small><%= post.getCreatedAt() %></small></div>
        </div>
      </div>
    </div>

    <hr>

    <!-- 通常送信のコメントフォーム -->
    <h3>コメントを書く</h3>
    <form action="Comment.action" method="post">
      <input type="hidden" name="tweetId" value="<%= tweetId %>">
      <div class="post-form">
        <a class="post-icon"
           href="Profile.action?userId=<%= me.getUserId() %>"
           style="width:<%= ICON_SIZE %>px; height:<%= ICON_SIZE %>px;
                  background-image:url('<%= myIconPath %>');
                  background-size:<%= myBgW %>px <%= myBgH %>px;
                  background-position:-<%= myBgX %>px -<%= myBgY %>px;
                  display:block;">
        </a>
        <div class="post-input">
          <textarea name="content" rows="3" required placeholder="コメントを入力..."></textarea><br>
          <button type="submit">送信</button>
        </div>
      </div>
    </form>

    <hr>

    <!-- コメント一覧 -->
    <h3>コメント一覧（<%= commentCount %>件）</h3>
    <%
      if (comments != null && !comments.isEmpty()) {
        for (Comment c : comments) {
          String commentImgPath = (c.getProfileImage() != null)
              ? request.getContextPath() + "/profile_images/" + c.getProfileImage()
              : request.getContextPath() + "/images/default_icon.jpg";
    %>
      <div class="comment" style="padding:8px 0;">
        <div class="tweet-row" style="margin-left:0; gap:10px;">
          <a class="tweet-icon"
             href="Profile.action?userId=<%= c.getUserId() %>"
             style="display:block; background-image:url('<%= commentImgPath %>');"></a>
          <div style="flex:1;">
            <div style="display:flex; gap:6px; flex-wrap:wrap;">
              <a href="Profile.action?userId=<%= c.getUserId() %>" style="font-weight:600; text-decoration:none; color:#000;"><%= c.getUsername() %></a>
              <a href="Profile.action?userId=<%= c.getUserId() %>" style="text-decoration:none; color:#555;">@<%= c.getHandle() %></a>
            </div>
            <div style="margin-top:4px; white-space:pre-wrap;"><%= c.getContent() %></div>
            <small><%= c.getCreatedAt() %></small>
            <% if (me.getUserId() == c.getUserId()) { %>
              <div class="comment-actions" style="margin-top:4px;">
                <form action="Comment.action" method="get"
                      onsubmit="return confirm('コメントを削除しますか？');" style="display:inline;">
                  <input type="hidden" name="deleteId" value="<%= c.getCommentId() %>">
                  <input type="hidden" name="tweetId" value="<%= tweetId %>">
                  <button type="submit">削除</button>
                </form>
              </div>
            <% } %>
          </div>
        </div>
      </div>
      <hr>
    <%
        }
      } else {
    %>
      <p>コメントはまだありません。</p>
    <%
      }
    %>
</div>

<!-- コメントモーダル -->
<div id="commentModalOverlay" class="modal-overlay">
  <div class="modal-box">
    <button class="modal-close" type="button" onclick="closeCommentModal()">✕</button>
    <div id="commentModalContent"></div>
  </div>
</div>

<script>
// コメントボタンクリックでモーダル読み込み
document.addEventListener('click', function(e){
  const btn = e.target.closest('.js-open-comments');
  if (!btn) return;
  const tweetId = btn.getAttribute('data-tweet-id');
  fetch('CommentPopup.action?tweetId=' + encodeURIComponent(tweetId))
    .then(r=>{
       if(!r.ok) throw new Error();
       return r.text();
    })
    .then(html=>{
       document.getElementById('commentModalContent').innerHTML = html;
       document.getElementById('commentModalOverlay').style.display='flex';
    })
    .catch(()=>{
       alert('コメント取得に失敗しました');
    });
});

function closeCommentModal(){
  const ov = document.getElementById('commentModalOverlay');
  ov.style.display='none';
  document.getElementById('commentModalContent').innerHTML='';
}

document.addEventListener('keydown', e=>{
  if(e.key === 'Escape') closeCommentModal();
});
document.getElementById('commentModalOverlay').addEventListener('click', e=>{
  if(e.target.id === 'commentModalOverlay') closeCommentModal();
});
</script>

<script src="js/right_sidebar.js"></script>
</body>
</html>
