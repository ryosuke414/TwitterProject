<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, bean.User" %>
<%
  User me         = (User) request.getAttribute("me");
  User targetUser = (User) request.getAttribute("targetUser");
  @SuppressWarnings("unchecked")
  List<User> list = (List<User>) request.getAttribute("list");
  String type     = (String) request.getAttribute("type"); // "following" or "followers"

  final int ICON_SIZE = 50;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title><%= ("followers".equals(type) ? "フォロワー" : "フォロー中") %>一覧 - <%= targetUser.getHandle() %></title>
<link rel="stylesheet" href="css/style.css">
<style>
.follow-list { max-width:600px; }
.user-row {
  display:flex;
  gap:12px;
  padding:10px 8px;
  border-bottom:1px solid #ddd;
  align-items:flex-start;
  background:#fff;
  position:relative;
}
.user-row-icon {
  width:<%= ICON_SIZE %>px;
  height:<%= ICON_SIZE %>px;
  border-radius:50%;
  background-size:cover;
  background-position:center;
  flex-shrink:0;
}
.user-row-main a.name { font-weight:600; color:#000; text-decoration:none; }
.user-row-main a.handle { color:#555; text-decoration:none; margin-left:4px; }
.user-row-main a.name:hover,
.user-row-main a.handle:hover { text-decoration:underline; }

.follow-btn,
.follow-btn-back {
  padding:6px 14px;
  border:1px solid #1da1f2;
  border-radius:20px;
  background:#1da1f2;
  color:#fff;
  cursor:pointer;
  font:inherit;
}
.follow-btn.following {
  background:#fff;
  color:#1da1f2;
}
.follow-btn.following.hovering { /* hover でフォロー解除表示中 */
  background:#ffeded;
  border-color:#e0245e;
  color:#e0245e;
}
.follow-btn-back { background:#1da1f2; } /* フォローバック */
.follow-empty { padding:20px; color:#666; }

</style>
</head>
<body>
<jsp:include page="sidebar.jsp" />
<jsp:include page="right_sidebar.jsp" />

<div class="main">
    <!-- 戻るボタン -->
    <button type="button" class="back-btn" onclick="history.back();">← 戻る</button>
  <h2>
    <a href="Profile.action?userId=<%= targetUser.getUserId() %>">@<%= targetUser.getHandle() %></a>
    の
    <%= ("followers".equals(type) ? "フォロワー" : "フォロー中") %>一覧
  </h2>

  <div style="margin:8px 0 18px;">
    <a href="FollowList.action?userId=<%= targetUser.getUserId() %>&type=following"
       style="<%= "following".equals(type) ? "font-weight:700;" : "" %>">フォロー中</a>
    /
    <a href="FollowList.action?userId=<%= targetUser.getUserId() %>&type=followers"
       style="<%= "followers".equals(type) ? "font-weight:700;" : "" %>">フォロワー</a>
  </div>

  <div class="follow-list">
    <%
      if (list == null || list.isEmpty()) {
    %>
        <div class="follow-empty">
          <%= ("followers".equals(type) ? "フォロワーはいません。" : "フォロー中のユーザーはいません。") %>
        </div>
    <%
      } else {
        dao.FollowDAO fdao = new dao.FollowDAO();
        for (User u : list) {
          // アイコン計算
          String iconPath = (u.getProfileImage() != null)
             ? request.getContextPath() + "/profile_images/" + u.getProfileImage()
             : request.getContextPath() + "/images/default_icon.jpg";
          int w = (u.getProfileIconW() != null) ? u.getProfileIconW() : 300;
          int h = (u.getProfileIconH() != null) ? u.getProfileIconH() : 300;
          int x = (u.getProfileIconX() != null) ? u.getProfileIconX() : 0;
          int y = (u.getProfileIconY() != null) ? u.getProfileIconY() : 0;
          double scale = ICON_SIZE / 300.0;
          int bgW = (int)Math.round(w * scale);
          int bgH = (int)Math.round(h * scale);
          int bgX = (int)Math.round(x * scale);
          int bgY = (int)Math.round(y * scale);

          boolean iFollow = false;
          if (me != null && me.getUserId() != u.getUserId()) {
              try { iFollow = fdao.isFollowing(me.getUserId(), u.getUserId()); } catch(Exception ignore){}
          }

          boolean isMeLine = (me != null && me.getUserId() == u.getUserId());
    %>
      <div class="user-row" data-user-id="<%= u.getUserId() %>">
        <a class="user-row-icon"
           href="Profile.action?userId=<%= u.getUserId() %>"
           style="
             background-image:url('<%= iconPath %>');
             background-size:<%= bgW %>px <%= bgH %>px;
             background-position:-<%= bgX %>px -<%= bgY %>px;
           "></a>
        <div class="user-row-main" style="flex:1;">
          <div>
            <a class="name" href="Profile.action?userId=<%= u.getUserId() %>"><%= u.getUsername() %></a>
            <a class="handle" href="Profile.action?userId=<%= u.getUserId() %>">@<%= u.getHandle() %></a>
          </div>
          <div style="margin-top:4px; font-size:13px; white-space:pre-wrap; color:#444;">
            <%= (u.getBio()!=null && !u.getBio().isEmpty()) ? u.getBio() : "" %>
          </div>
        </div>

        <!-- ボタン領域 -->
        <div>
          <%
             if (!isMeLine && me != null) {
               if (iFollow) {
          %>
              <!-- 既にフォロー中 -->
              <form action="Unfollow.action" method="post" class="follow-form">
                <input type="hidden" name="targetId" value="<%= u.getUserId() %>">
                <button type="submit"
                        class="follow-btn following"
                        data-state="following">フォロー中</button>
              </form>
          <%
               } else {
                 // followers ページなら「フォローバック」を表示、それ以外は「フォロー」
                 String label = "followers".equals(type) ? "フォローバック" : "フォロー";
          %>
              <form action="Follow.action" method="post" class="follow-form">
                <input type="hidden" name="targetId" value="<%= u.getUserId() %>">
                <button type="submit"
                        class="follow-btn<%= "followers".equals(type) ? " follow-btn-back" : "" %>"
                        data-state="follow"><%= label %></button>
              </form>
          <%
               } // end if iFollow
             } // end if not self
          %>
        </div>
      </div>
    <%
        } // end for
      } // end else list
    %>
  </div>
</div>

<!-- モーダル共通を使いたければここに（今回は不要なら省略） -->

<script>
// フォロー中ボタンの hover で「フォロー解除」表示
document.addEventListener('mouseover', e=>{
  const btn = e.target.closest('.follow-btn.following');
  if (btn) {
    btn.classList.add('hovering');
    btn.dataset.original = btn.textContent;
    btn.textContent = 'フォロー解除';
  }
});
document.addEventListener('mouseout', e=>{
  const btn = e.target.closest('.follow-btn.following.hovering');
  if (btn) {
    btn.classList.remove('hovering');
    btn.textContent = btn.dataset.original || 'フォロー中';
  }
});

/*
 * ここを Ajax 化したい場合：
 *  1) form の submit を preventDefault
 *  2) fetch で Follow.action / Unfollow.action に POST
 *  3) 成功時：Unfollow なら親 .user-row を remove()
 *             Follow なら ボタンを 「フォロー中」状態へ差し替え
 * 今回は再読み込み方式で OK。
 */
</script>

<script src="js/right_sidebar.js"></script>
</body>
</html>
