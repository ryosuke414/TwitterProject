<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, bean.Post, bean.User" %>
<%@ page import="dao.PostDAO, dao.LikeDAO, dao.BookmarkDAO, dao.CommentDAO, dao.RepostDAO" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    // ===== サーバー側準備 ======================================================
    // SearchAction から渡されるもの
    List<String> historyReq   = (List<String>) request.getAttribute("history");
    List<Post>   postResult   = (List<Post>)   request.getAttribute("postResult");
    List<User>   userResult   = (List<User>)   request.getAttribute("userResult");
    Set<Integer> followingIds = (Set<Integer>) request.getAttribute("followingIds");
    User me                   = (User)         request.getAttribute("me");

    // セッション fallback（SearchAction がセッションにも保存する想定）
    if (historyReq == null) {
        @SuppressWarnings("unchecked")
        List<String> sessHist = (List<String>) session.getAttribute("searchHistory");
        historyReq = sessHist;
    }
    if (historyReq == null) {
        historyReq = Collections.emptyList();
    }

    // キーワード
    String keywordParam = request.getParameter("keyword");

    // ヒストリ JSON エスケープ（JS 配列用）
    StringBuilder histJson = new StringBuilder();
    for (int i=0; i<historyReq.size(); i++) {
        String h = historyReq.get(i);
        String esc = h.replace("\\","\\\\")
                      .replace("\"","\\\"")
                      .replace("\r","\\r")
                      .replace("\n","\\n");
        if (i>0) histJson.append(',');
        histJson.append('"').append(esc).append('"');
    }

    // DAO（投稿結果描画用）
    PostDAO pdao = new PostDAO();
    LikeDAO ldao = new LikeDAO();
    BookmarkDAO bdao = new BookmarkDAO();
    CommentDAO cdao = new CommentDAO();
    RepostDAO rdao = new RepostDAO();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>検索</title>
<link rel="stylesheet" href="css/style.css">
<style>
/* メイン検索フォーム */
.search-main-form { max-width:400px; margin-bottom:16px; position:relative; }
.search-main-form input[type="text"]{ width:100%; box-sizing:border-box; padding-right:2.5em; }
.search-main-form button.hidden-submit {
  position:absolute; right:-9999px; width:1px; height:1px; overflow:hidden; opacity:0; pointer-events:none;
}

/* 履歴ドロップダウン */
.search-history-dropdown {
  position:absolute; top:100%; left:0; width:100%;
  max-height:240px; overflow-y:auto;
  background:#fff; border:1px solid #ccc; border-top:none;
  z-index:1000; display:none;
}
.search-history-clearall {
  text-align:right; padding:4px 8px;
  border-bottom:1px solid #ccc; background:#fafafa;
}
.search-history-clearall button {
  font-size:12px; background:none; border:none; color:#c00; cursor:pointer; text-decoration:underline;
}
.search-history-dropdown ul { list-style:none; margin:0; padding:0; }
.search-history-dropdown li {
  display:flex; align-items:center; justify-content:space-between;
  padding:4px 8px; border-bottom:1px solid #eee; cursor:pointer;
}
.search-history-dropdown li:hover { background:#f0f0f0; }
.search-history-word {
  flex:1; text-align:left; background:none; border:none;
  padding:0; margin:0; cursor:pointer; font:inherit;
}
.search-history-delete-btn {
  background:none; border:none; color:#c00; cursor:pointer; font-size:14px; line-height:1;
}

/* セクション見出し */
.search-section-title {
  margin-top:24px; border-bottom:2px solid #ddd; padding-bottom:4px; font-size:16px;
}

/* ユーザー結果（簡略／ベースは style.css に委譲） */
.user-result-list { margin-top:10px; }
.user-result-card {
  display:flex; gap:10px; padding:8px 12px; border-bottom:1px solid #eee;
}
.user-result-card:hover { background:#fafafa; }
.user-result-icon {
  width:50px; height:50px; border-radius:50%;
  background-size:cover; background-position:center; flex-shrink:0; display:block;
}
.user-result-body { flex:1; min-width:0; }
.user-result-header { display:flex; flex-wrap:wrap; gap:6px; align-items:center; margin-bottom:4px; }
.user-result-header .name-link { font-weight:600; color:#000; text-decoration:none; }
.user-result-header .handle-link { color:#555; text-decoration:none; }
.user-result-bio { font-size:12px; color:#666; max-height:32px; overflow:hidden; }
.user-result-action { display:flex; align-items:start; }
.follow-btn {
  padding:4px 12px; border-radius:20px; background:#1da1f2; color:#fff;
  border:1px solid #1da1f2; cursor:pointer; font-size:12px;
}
.follow-btn.following { background:#fff; color:#1da1f2; }
.follow-btn.following:hover { background:#ff4d4d; border-color:#ff4d4d; color:#fff; }
</style>
</head>
<body>

<jsp:include page="sidebar.jsp" />
<!-- ★ 検索ページでは右サイドバーを表示しないので include しません -->

<div class="main">
    <h2>検索</h2>

    <!-- メイン検索フォーム（履歴ドロップダウン付き） -->
    <form id="searchMainForm" class="search-main-form" method="get" action="Search.action" autocomplete="off">
        <input type="text" id="searchMainInput" name="keyword"
               value="<%= keywordParam != null ? keywordParam : "" %>"
               placeholder="キーワードを入力" required>
        <button class="hidden-submit" type="submit" aria-hidden="true">検索</button>

        <div id="searchMainHistoryDropdown" class="search-history-dropdown" role="listbox" aria-label="検索履歴候補">
            <div class="search-history-clearall">
                <button type="button" id="searchMainHistoryClearAll">履歴をすべて削除</button>
            </div>
            <ul id="searchMainHistoryItems"><!-- JS で構築 --></ul>
        </div>
    </form>

    <!-- ===== ユーザー結果 ===== -->
    <h3 class="search-section-title">ユーザー</h3>
    <c:choose>
        <c:when test="${not empty userResult}">
            <div class="user-result-list">
                <c:forEach var="u" items="${userResult}">
                    <c:set var="iconPath" value="${pageContext.request.contextPath}/images/default_icon.jpg" />
                    <c:if test="${u.profileImage != null}">
                        <c:set var="iconPath" value="${pageContext.request.contextPath}/profile_images/${fn:escapeXml(u.profileImage)}" />
                    </c:if>
                    <div class="user-result-card">
                        <a class="user-result-icon"
                           href="Profile.action?userId=${u.userId}"
                           style="background-image:url('${iconPath}');"></a>
                        <div class="user-result-body">
                            <div class="user-result-header">
                                <a href="Profile.action?userId=${u.userId}" class="name-link">
                                    ${fn:escapeXml(u.username)}
                                </a>
                                <a href="Profile.action?userId=${u.userId}" class="handle-link">
                                    @${fn:escapeXml(u.handle)}
                                </a>
                            </div>
                            <div class="user-result-bio">
                                <c:choose>
                                    <c:when test="${not empty u.bio}">
                                        ${fn:escapeXml(u.bio)}
                                    </c:when>
                                    <c:otherwise>自己紹介なし</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="user-result-action">
                            <c:if test="${me != null && me.userId != u.userId}">
                                <c:choose>
                                    <c:when test="${followingIds != null && followingIds.contains(u.userId)}">
                                        <form action="Unfollow.action" method="post" style="margin:0;">
                                            <input type="hidden" name="targetId" value="${u.userId}">
                                            <input type="hidden" name="keyword" value="${fn:escapeXml(param.keyword)}">
                                            <button type="submit" class="follow-btn following"
                                                    onmouseenter="this.dataset.text=this.textContent;this.textContent='フォロー解除';"
                                                    onmouseleave="this.textContent=this.dataset.text;">
                                                フォロー中
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <form action="Follow.action" method="post" style="margin:0;">
                                            <input type="hidden" name="targetId" value="${u.userId}">
                                            <input type="hidden" name="keyword" value="${fn:escapeXml(param.keyword)}">
                                            <button type="submit" class="follow-btn">フォロー</button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <c:if test="${param.keyword != null}">
                <p>該当するユーザーがいません。</p>
            </c:if>
        </c:otherwise>
    </c:choose>

    <!-- ===== 投稿結果 ===== -->
    <h3 class="search-section-title">投稿</h3>
    <c:choose>
      <c:when test="${postResult != null && !postResult.isEmpty()}">
        <c:forEach var="p" items="${postResult}">
          <%
             final int ICON_SIZE = 50;
             bean.Post jp = (bean.Post) pageContext.getAttribute("p");

             int tweetId       = jp.getTweetId();
             int likeCount     = ldao.countLikes(tweetId);
             int commentCount  = cdao.countByTweet(tweetId);
             int repostCount   = rdao.countReposts(tweetId);
             boolean liked     = (me != null) && ldao.isLiked(me.getUserId(), tweetId);
             boolean reposted  = (me != null) && rdao.isReposted(me.getUserId(), tweetId);
             boolean bookmarked= (me != null) && bdao.isBookmarked(me.getUserId(), tweetId);
             List<String> imgs = pdao.getImages(tweetId);

             String iconPathPost = (jp.getProfileImage() != null)
                 ? request.getContextPath() + "/profile_images/" + jp.getProfileImage()
                 : request.getContextPath() + "/images/default_icon.jpg";

             int w = (jp.getProfileIconW() != null) ? jp.getProfileIconW() : 300;
             int h = (jp.getProfileIconH() != null) ? jp.getProfileIconH() : 300;
             int x = (jp.getProfileIconX() != null) ? jp.getProfileIconX() : 0;
             int y = (jp.getProfileIconY() != null) ? jp.getProfileIconY() : 0;
             double scale = ICON_SIZE / 300.0;
             int bgW = (int)Math.round(w * scale);
             int bgH = (int)Math.round(h * scale);
             int bgX = (int)Math.round(x * scale);
             int bgY = (int)Math.round(y * scale);
          %>
          <div class="tweet tweet--row">
            <div class="tweet-row">
              <a class="tweet-icon"
                 href="Profile.action?userId=<%= jp.getUserId() %>"
                 style="
                   width:<%= ICON_SIZE %>px; height:<%= ICON_SIZE %>px;
                   background-image:url('<%= iconPathPost %>');
                   background-size:<%= bgW %>px <%= bgH %>px;
                   background-position:-<%= bgX %>px -<%= bgY %>px;
                   display:block;">
              </a>

              <div class="tweet-body">
                <div class="tweet-header" style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:4px;">
                  <a href="Profile.action?userId=<%= jp.getUserId() %>"
                     class="user-link"
                     style="font-weight:600; text-decoration:none; color:#000;">
                     <%= jp.getUsername() %>
                  </a>
                  <a href="Profile.action?userId=<%= jp.getUserId() %>"
                     class="handle-link"
                     style="text-decoration:none; color:#555;">
                     @<%= jp.getHandle() %>
                  </a>
                </div>

                <a href="PostDetail.action?tweetId=<%= tweetId %>" class="tweet-link">
                  <div style="white-space:pre-wrap;"><%= jp.getContent() %></div>
                  <% for (String img : imgs) { %>
                     <img src="images/<%= img %>" alt="投稿画像"
                          style="max-width:200px; display:block; margin-top:6px;">
                  <% } %>
                  <div><small><%= jp.getCreatedAt() %></small></div>
                </a>

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
              </div>
            </div>
          </div>
        </c:forEach>
      </c:when>
      <c:otherwise>
        <c:if test="${param.keyword != null}">
           <p>該当する投稿がありません。</p>
        </c:if>
      </c:otherwise>
    </c:choose>
</div>

<!-- コメントモーダル (既存 JS 流用) -->
<div id="commentModalOverlay" class="modal-overlay">
  <div class="modal-box">
    <button class="modal-close" type="button" onclick="closeCommentModal()">✕</button>
    <div id="commentModalContent"></div>
  </div>
</div>

<script>
  // JSPで生成した検索履歴データはここで定義（必須）
  const SEARCH_MAIN_HISTORY = [<%= histJson.toString() %>];
</script>
<script src="staticjs/search.js"></script>

</body>
</html>