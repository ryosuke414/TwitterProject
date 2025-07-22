<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.User" %>
<%
    User me = (User) session.getAttribute("user");
    String myIconPath = (me != null && me.getProfileImage() != null)
        ? request.getContextPath() + "/profile_images/" + me.getProfileImage()
        : request.getContextPath() + "/images/default_icon.jpg";
    int ICON_SIZE = 50;
    int w = (me != null && me.getProfileIconW() != null) ? me.getProfileIconW() : 300;
    int h = (me != null && me.getProfileIconH() != null) ? me.getProfileIconH() : 300;
    int x = (me != null && me.getProfileIconX() != null) ? me.getProfileIconX() : 0;
    int y = (me != null && me.getProfileIconY() != null) ? me.getProfileIconY() : 0;
    double scale = ICON_SIZE / 300.0;
    int bgW = (int)Math.round(w * scale);
    int bgH = (int)Math.round(h * scale);
    int bgX = (int)Math.round(x * scale);
    int bgY = (int)Math.round(y * scale);
%>

<div class="sidebar">
    <p><strong>メニュー</strong></p>
    <a href="Timeline.action">タイムライン</a>
    <a href="Search.action">検索</a>
    <a href="DM.action">メッセージ</a>
    <a href="Profile.action">プロフィール</a>
    <a href="BookmarkList.action">ブックマーク</a>
    <a href="Logout.action">ログアウト</a>

    <!-- モーダル起動ボタン -->
    <button type="button" id="openPostModal" class="post-btn">投稿する</button>
</div>

<!-- 投稿モーダル -->
<div id="postModalOverlay" class="modal-overlay" style="display:none;">
  <div class="modal-box">
    <button class="modal-close" type="button" id="closePostModal">✕</button>
    <h3>新規投稿</h3>
    <form id="globalPostForm" action="Post.action" method="post" enctype="multipart/form-data">
        <input type="hidden" name="redirect" value="<%= request.getRequestURI() %>">
        <div class="post-form" style="display:flex; align-items:flex-start; gap:10px;">
            <!-- プロフィールアイコン -->
            <div class="post-icon"
                 style="width:<%= ICON_SIZE %>px; height:<%= ICON_SIZE %>px;
                        background-image:url('<%= myIconPath %>');
                        background-size:<%= bgW %>px <%= bgH %>px;
                        background-position:-<%= bgX %>px -<%= bgY %>px;
                        border-radius:50%; flex-shrink:0;">
            </div>
            <!-- 入力部分 -->
            <div class="post-input" style="flex:1;">
                <textarea name="content" rows="3" placeholder="いまどうしてる？" required></textarea><br>
                <input type="file" name="images" accept="image/*" multiple><br>
                <button type="submit">投稿</button>
            </div>
        </div>
    </form>
  </div>
</div>

<script>
document.getElementById('openPostModal').addEventListener('click', function(){
    document.getElementById('postModalOverlay').style.display = 'flex';
});

document.getElementById('closePostModal').addEventListener('click', function(){
    document.getElementById('postModalOverlay').style.display = 'none';
});

document.getElementById('postModalOverlay').addEventListener('click', function(e){
    if(e.target.id === 'postModalOverlay'){
        document.getElementById('postModalOverlay').style.display = 'none';
    }
});
document.addEventListener('keydown', function(e){
    if (e.key === 'Escape') {
        document.getElementById('postModalOverlay').style.display = 'none';
    }
});
</script>
