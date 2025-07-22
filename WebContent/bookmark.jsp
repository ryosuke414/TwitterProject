<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, bean.Post, bean.User" %>
<%@ page import="dao.PostDAO, dao.LikeDAO, dao.BookmarkDAO, dao.CommentDAO, dao.RepostDAO" %>
<%
    /* ===== ログイン確認 ===== */
    User me = (User) session.getAttribute("user");
    if (me == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    /* ===== コントローラから渡された「ブックマーク済み投稿」 =====
       home.jsp と同じ構造に合わせて Attribute 名を「posts」にしています。
       サーブレット側で List<Post> をセットしてください。 */
    @SuppressWarnings("unchecked")
    List<Post> posts = (List<Post>) request.getAttribute("posts");

    /* ===== 投稿フォーム用（home.jsp と同じ） ===== */
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

    /* ===== DAO ===== */
    PostDAO     pdao = new PostDAO();
    LikeDAO     ldao = new LikeDAO();
    BookmarkDAO bdao = new BookmarkDAO();
    CommentDAO  cdao = new CommentDAO();
    RepostDAO   rdao = new RepostDAO();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ブックマーク</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<jsp:include page="sidebar.jsp" />
<jsp:include page="right_sidebar.jsp" />

<div class="main">
    <h2>ブックマーク</h2>
    <p><strong><%= me.getUsername() %></strong> さんの保存済み投稿一覧</p>

<%
    if (posts != null && !posts.isEmpty()) {
        for (Post p : posts) {
            int tweetId      = p.getTweetId();
            int likeCount    = ldao.countLikes(tweetId);
            int commentCount = cdao.countByTweet(tweetId);
            int repostCount  = rdao.countReposts(tweetId);
            boolean liked    = ldao.isLiked(me.getUserId(), tweetId);
            boolean reposted = rdao.isReposted(me.getUserId(), tweetId);
            boolean bookmarked = bdao.isBookmarked(me.getUserId(), tweetId); // 当然 true のはずだが安全に再判定
            List<String> imgs = pdao.getImages(tweetId);

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
%>
<div class="tweet">
  <div class="tweet-row">
    <!-- アイコン：プロフィールページへ -->
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

      <!-- ヘッダー行（ユーザー名/ハンドル = プロフィールへ） -->
      <div class="tweet-header" style="display:flex; gap:6px; flex-wrap:wrap;">
        <a href="Profile.action?userId=<%= p.getUserId() %>" class="user-link" style="font-weight:600; text-decoration:none; color:#000;">
          <%= p.getUsername() %>
        </a>
        <a href="Profile.action?userId=<%= p.getUserId() %>" class="handle-link" style="text-decoration:none; color:#555;">
          @<%= p.getHandle() %>
        </a>
      </div>

      <!-- 投稿本文・画像・時刻：投稿詳細へ -->
      <a href="PostDetail.action?tweetId=<%= tweetId %>" class="tweet-link">
        <div style="white-space:pre-wrap;"><%= p.getContent() %></div>
        <% for (String img : imgs) { %>
           <img src="images/<%= img %>" alt="投稿画像"
                style="max-width:200px; display:block; margin-top:6px;">
        <% } %>
        <div><small><%= p.getCreatedAt() %></small></div>
      </a>

      <!-- アクションボタン -->
      <div class="post-actions">
        <!-- コメント（モーダル起動） -->
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

        <!-- ブックマーク（解除でこのページに戻りたい → redirect パラメータ追加） -->
        <form action="Bookmark.action" method="post" style="display:inline;">
          <input type="hidden" name="tweetId" value="<%= tweetId %>">
          <input type="hidden" name="op" value="<%= bookmarked ? "remove" : "add" %>">
          <!-- ★ BookmarkAction 改修後に以下を利用： -->
          <input type="hidden" name="redirect" value="BookmarkList.action">
          <button type="submit" class="action-btn">
            <img src="images/<%= bookmarked ? "bookmark_on.png" : "bookmark_off.png" %>" alt="ブックマーク">
          </button>
        </form>
      </div>
    </div><!-- /.tweet-body -->
  </div><!-- /.tweet-row -->
</div><!-- /.tweet -->

<%
        } // for
    } else {
%>
    <p>ブックマークはまだありません。</p>
<%
    } // if posts
%>
</div><!-- /.main -->

<!-- コメントモーダル（home.jsp と共通の構造） -->
<div id="commentModalOverlay" class="modal-overlay">
  <div class="modal-box">
    <button class="modal-close" type="button" onclick="closeCommentModal()">✕</button>
    <div id="commentModalContent"></div>
  </div>
</div>

<script>
/* ===== コメントモーダル制御（home.jsp と同じ） ===== */
document.addEventListener('click', function(e){
  const btn = e.target.closest('.js-open-comments');
  if (btn) {
    const tweetId = btn.getAttribute('data-tweet-id');
    openCommentModal(tweetId, btn);
  }
});

function openCommentModal(tweetId, triggerBtn) {
  fetch('CommentPopup.action?tweetId=' + encodeURIComponent(tweetId))
    .then(r => {
      if(!r.ok) throw new Error('通信エラー');
      return r.text();
    })
    .then(html => {
      document.getElementById('commentModalContent').innerHTML = html;
      document.getElementById('commentModalOverlay').style.display = 'flex';
      setupCommentFormAjax(triggerBtn);
    })
    .catch(err => {
      alert('コメント取得に失敗しました');
      console.error(err);
    });
}

function closeCommentModal() {
  const ov = document.getElementById('commentModalOverlay');
  ov.style.display = 'none';
  document.getElementById('commentModalContent').innerHTML = '';
}

function setupCommentFormAjax(triggerBtn) {
  const form = document.querySelector('#commentModalContent form.comment-form');
  if (!form) return;
  form.addEventListener('submit', function(e){
    e.preventDefault();
    const fd = new FormData(form);
    fetch(form.action, {
      method: 'POST',
      body: fd
    })
    .then(r => {
      if(!r.ok) throw new Error('送信失敗');
      return r.json();
    })
    .then(data => {
      if (data.status === 'ok') {
        // モーダル発火元（コメント数更新）
        if (triggerBtn) {
          const countSpan = triggerBtn.querySelector('[data-role="comment-count"]');
          if (countSpan) countSpan.textContent = data.newCount;
        }
        // モーダルを再取得（最新表示）
        openCommentModal(data.tweetId, triggerBtn);
      } else {
        alert(data.message || '投稿に失敗しました');
      }
    })
    .catch(err => {
      alert('送信エラー');
      console.error(err);
    });
  });
}

/* ESC キーで閉じる */
document.addEventListener('keydown', e=>{
  if (e.key === 'Escape') closeCommentModal();
});

/* オーバーレイクリックで閉じる */
document.getElementById('commentModalOverlay').addEventListener('click', e=>{
  if (e.target.id === 'commentModalOverlay') closeCommentModal();
});
</script>

<script src="js/right_sidebar.js"></script>
</body>
</html>
