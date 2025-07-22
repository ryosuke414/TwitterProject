<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, bean.User, bean.Post" %>
<%@ page import="dao.PostDAO, dao.LikeDAO, dao.BookmarkDAO, dao.CommentDAO, dao.RepostDAO" %>
<%
    User user = (User) request.getAttribute("user");
    User me   = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Post> posts = (List<Post>) request.getAttribute("posts");
    int followingCount = (Integer) request.getAttribute("followingCount");
    int followerCount  = (Integer) request.getAttribute("followerCount");
    int postCount      = (Integer) request.getAttribute("postCount");
    boolean isFollowing= (Boolean) request.getAttribute("isFollowing");

    final int EDIT_BOX_SIZE   = 300;
    final int DISP_SIZE       = 120;
    final int TWEET_ICON_SIZE = 50;

    String ctx = request.getContextPath();

    String mainImgPath = (user.getProfileImage() != null)
        ? ctx + "/profile_images/" + user.getProfileImage()
        : ctx + "/images/default_icon.jpg";

    int editW = (user.getProfileIconW() != null) ? user.getProfileIconW() : EDIT_BOX_SIZE;
    int editH = (user.getProfileIconH() != null) ? user.getProfileIconH() : EDIT_BOX_SIZE;
    int editX = (user.getProfileIconX() != null) ? user.getProfileIconX() : 0;
    int editY = (user.getProfileIconY() != null) ? user.getProfileIconY() : 0;

    double scaleMain = (double) DISP_SIZE / EDIT_BOX_SIZE;
    int bgMainW = (int)Math.round(editW * scaleMain);
    int bgMainH = (int)Math.round(editH * scaleMain);
    int bgMainX = (int)Math.round(editX * scaleMain);
    int bgMainY = (int)Math.round(editY * scaleMain);

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
<title>プロフィール</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<jsp:include page="sidebar.jsp" />
<jsp:include page="right_sidebar.jsp" />

<div class="main">
    <!-- 戻るボタン -->
    <button type="button" class="back-btn" onclick="history.back();">← 戻る</button>
    <h2>プロフィール</h2>

    <div class="profile-icon"
         style="
            width:<%= DISP_SIZE %>px;
            height:<%= DISP_SIZE %>px;
            background-image:url('<%= mainImgPath %>');
            background-size:<%= bgMainW %>px <%= bgMainH %>px;
            background-position:<%= bgMainX %>px <%= bgMainY %>px;
         ">
    </div>

    <p><strong><%= user.getUsername() %></strong> @<%= user.getHandle() %></p>
    <p><%= (user.getBio()!=null && !user.getBio().isEmpty()) ? user.getBio() : "自己紹介なし" %></p>

    <p>
      <a href="FollowList.action?userId=<%= user.getUserId() %>&type=following">
        フォロー中: <%= followingCount %>
      </a>
      /
      <a href="FollowList.action?userId=<%= user.getUserId() %>&type=followers">
        フォロワー: <%= followerCount %>
      </a>
      / 投稿: <%= postCount %> |
      <% if (me != null && me.getUserId() == user.getUserId()) { %>
          <a href="edit_profile.jsp">プロフィールを編集</a>
      <% } else if (me != null) { %>
          <form action="<%= isFollowing ? "Unfollow.action" : "Follow.action" %>" method="post" style="display:inline;">
              <input type="hidden" name="targetId" value="<%= user.getUserId() %>">
              <button type="submit" class="follow-btn <%= isFollowing ? "following" : "" %>">
                  <%= isFollowing ? "フォロー中" : "フォロー" %>
              </button>
          </form>
          <a href="DM.action?to=<%= user.getUserId() %>" class="dm-btn dm-btn--profile">DM</a>
      <% } %>
    </p>

    <hr>
    <h3>投稿一覧</h3>

<%
if (posts != null && !posts.isEmpty()) {
    for (Post p : posts) {
        int tweetId      = p.getTweetId();
        int likeCount    = ldao.countLikes(tweetId);
        int commentCount = cdao.countByTweet(tweetId);
        int repostCount  = rdao.countReposts(tweetId);
        boolean liked    = ldao.isLiked(me.getUserId(), tweetId);
        boolean reposted = rdao.isReposted(me.getUserId(), tweetId);
        boolean bookmarked = bdao.isBookmarked(me.getUserId(), tweetId);
        List<String> imgs = pdao.getImages(tweetId);

        String postIconPath = (p.getProfileImage() != null)
            ? ctx + "/profile_images/" + p.getProfileImage()
            : ctx + "/images/default_icon.jpg";

        int pw = (p.getProfileIconW() != null) ? p.getProfileIconW() : EDIT_BOX_SIZE;
        int ph = (p.getProfileIconH() != null) ? p.getProfileIconH() : EDIT_BOX_SIZE;
        int px = (p.getProfileIconX() != null) ? p.getProfileIconX() : 0;
        int py = (p.getProfileIconY() != null) ? p.getProfileIconY() : 0;

        double scaleTweet = (double) TWEET_ICON_SIZE / EDIT_BOX_SIZE;
        int pbgW = (int)Math.round(pw * scaleTweet);
        int pbgH = (int)Math.round(ph * scaleTweet);
        int pbgX = (int)Math.round(px * scaleTweet);
        int pbgY = (int)Math.round(py * scaleTweet);

        boolean ownPost = (me != null && p.getUserId() == me.getUserId());

        // 編集モーダル用データ属性 (エスケープ)
        String rawContent = (p.getContent() != null) ? p.getContent() : "";
        String attrContent = rawContent
                .replace("&","&amp;")
                .replace("<","&lt;")
                .replace(">","&gt;")
                .replace("\"","&quot;")
                .replace("'","&#39;");
%>
    <% if (p.isReposted()) { %>
        <span class="repost-label"><%= user.getUsername() %> さんがリポストしました</span>
    <% } %>

    <div class="tweet tweet--row">
      <div class="tweet-row">
        <!-- プロフィールアイコン（リンク化） -->
        <a class="tweet-icon"
           href="Profile.action?userId=<%= p.getUserId() %>"
           style="
             width:<%= TWEET_ICON_SIZE %>px; height:<%= TWEET_ICON_SIZE %>px;
             background-image:url('<%= postIconPath %>');
             background-size:<%= pbgW %>px <%= pbgH %>px;
             background-position:-<%= pbgX %>px -<%= pbgY %>px;
             display:block;">
        </a>

        <div class="tweet-body">
          <% if (ownPost) { %>
              <div class="tweet-menu" onclick="toggleMenu(this)">⋯</div>
              <div class="dropdown-menu">
                  <!-- 編集リンクはモーダル起動 -->
                  <a href="#" class="js-edit-post"
                     data-tweet-id="<%= tweetId %>"
                     data-content="<%= attrContent %>">編集</a>
                  <!-- 削除は従来どおりフォーム送信 -->
                  <form action="DeletePost.action" method="post"
                        onsubmit="return confirm('この投稿を削除しますか？');">
                      <input type="hidden" name="tweetId" value="<%= tweetId %>">
                      <button type="submit">削除</button>
                  </form>
              </div>
          <% } %>

          <!-- ヘッダー（ユーザー名/ハンドル） -->
          <div class="tweet-header" style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:4px;">
            <a href="Profile.action?userId=<%= p.getUserId() %>"
               class="user-link" style="font-weight:600; text-decoration:none; color:#000;">
               <%= p.getUsername() %>
            </a>
            <a href="Profile.action?userId=<%= p.getUserId() %>"
               class="handle-link" style="text-decoration:none; color:#555;">
               @<%= p.getHandle() %>
            </a>
          </div>

          <!-- 本文・画像・日時（投稿詳細へのリンク） -->
          <a href="PostDetail.action?tweetId=<%= tweetId %>" class="tweet-link">
            <div style="white-space:pre-wrap;"><%= rawContent %></div>
            <% for (String img : imgs) { %>
              <img src="images/<%= img %>" alt="投稿画像"
                   style="max-width:200px; display:block; margin-top:6px;">
            <% } %>
            <div><small><%= p.getCreatedAt() %></small></div>
          </a>

          <!-- アクションボタン -->
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
          </div>
        </div><!-- /.tweet-body -->
      </div><!-- /.tweet-row -->
    </div><!-- /.tweet -->
<%
    } // for
} else {
%>
    <p>まだ投稿がありません。</p>
<%
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

<!-- 投稿編集モーダル -->
<div id="editPostModalOverlay" class="modal-overlay">
  <div id="editPostModalBox" class="modal-box modal-edit">
    <h3>投稿を編集</h3>
    <form id="editPostForm" method="post" action="EditPost.action">
      <input type="hidden" name="tweetId" id="editTweetId">
      <textarea name="content" id="editContent" rows="4"></textarea><br>
      <button type="submit">更新</button>
      <button type="button" onclick="closeEditModal()">キャンセル</button>
    </form>
  </div>
</div>

<script>
/* ==== ドロップダウンメニュー ==== */
function toggleMenu(elem){
  document.querySelectorAll('.dropdown-menu').forEach(m=>{
    if(m!==elem.nextElementSibling) m.style.display='none';
  });
  const menu = elem.nextElementSibling;
  menu.style.display = (menu.style.display==='block') ? 'none' : 'block';
}
// メニュー以外をクリックで閉じる
document.addEventListener('click', e=>{
  if(!e.target.closest('.tweet-menu') && !e.target.closest('.dropdown-menu')){
     document.querySelectorAll('.dropdown-menu').forEach(m=>m.style.display='none');
  }
});

/* ==== コメントモーダル ==== */
document.addEventListener('click', function(e){
  const btn = e.target.closest('.js-open-comments');
  if (btn) {
    const tweetId = btn.getAttribute('data-tweet-id');
    openCommentModal(tweetId, btn);
  }

  const editLink = e.target.closest('.js-edit-post');
  if (editLink) {
    e.preventDefault();
    openEditModal(editLink.dataset.tweetId, editLink.dataset.content);
  }
});

function openCommentModal(tweetId, triggerBtn) {
  fetch('CommentPopup.action?tweetId=' + encodeURIComponent(tweetId))
    .then(r=>{
      if(!r.ok) throw new Error('通信エラー');
      return r.text();
    })
    .then(html=>{
      document.getElementById('commentModalContent').innerHTML = html;
      document.getElementById('commentModalOverlay').style.display = 'flex';
      setupCommentFormAjax(triggerBtn);
    })
    .catch(err=>{
      alert('コメント取得に失敗しました');
      console.error(err);
    });
}

function closeCommentModal(){
  const ov = document.getElementById('commentModalOverlay');
  ov.style.display = 'none';
  document.getElementById('commentModalContent').innerHTML = '';
}

function setupCommentFormAjax(triggerBtn){
  const form = document.querySelector('#commentModalContent form.comment-form');
  if(!form) return;
  form.addEventListener('submit', function(e){
    e.preventDefault();
    const fd = new FormData(form);
    fetch(form.action, { method:'POST', body:fd })
      .then(r=>{
        if(!r.ok) throw new Error('送信失敗');
        return r.json();
      })
      .then(data=>{
        if(data.status==='ok'){
          if(triggerBtn){
             const countSpan = triggerBtn.querySelector('[data-role="comment-count"]');
             if(countSpan) countSpan.textContent = data.newCount;
          }
          openCommentModal(data.tweetId, triggerBtn);
        } else {
          alert(data.message || '投稿に失敗しました');
        }
      })
      .catch(err=>{
        alert('送信エラー');
        console.error(err);
      });
  });
}

/* ==== 投稿編集モーダル ==== */
function openEditModal(tweetId, contentEscaped){
  // HTMLエスケープ済をデコード
  const tmp = document.createElement('textarea');
  tmp.innerHTML = contentEscaped;
  const decoded = tmp.value;

  document.getElementById('editTweetId').value = tweetId;
  document.getElementById('editContent').value = decoded;
  document.getElementById('editPostModalOverlay').style.display = 'flex';
}
function closeEditModal(){
  document.getElementById('editPostModalOverlay').style.display = 'none';
}

/* ESC キーで両モーダル閉じる */
document.addEventListener('keydown', e=>{
  if(e.key === 'Escape') {
    closeCommentModal();
    closeEditModal();
  }
});

/* オーバーレイ背景クリックで閉じる */
document.getElementById('commentModalOverlay').addEventListener('click', e=>{
  if (e.target.id === 'commentModalOverlay') closeCommentModal();
});
document.getElementById('editPostModalOverlay').addEventListener('click', e=>{
  if (e.target.id === 'editPostModalOverlay') closeEditModal();
});
</script>

<script src="js/right_sidebar.js"></script>
</body>
</html>