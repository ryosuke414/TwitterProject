<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, bean.Message, bean.User" %>
<%
    User me = (User) session.getAttribute("user");
    if (me == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<User> partners = (List<User>) request.getAttribute("partners"); // DM相手一覧
    User partner = (User) request.getAttribute("partner");               // 選択中相手（null可）

    @SuppressWarnings("unchecked")
    List<Message> messages = (List<Message>) request.getAttribute("messages"); // 会話（null可）

    Integer toId = (Integer) request.getAttribute("toId");

    @SuppressWarnings("unchecked")
    List<User> allUsers = (List<User>) request.getAttribute("allUsers");  // 新しいDM用の全ユーザー

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ダイレクトメッセージ</title>
<link rel="stylesheet" href="css/style.css">
<style>
/* --- DM レイアウト --- */
.dm-partner-list-wrapper {
    margin-left: 220px;   /* 左サイドバー幅 + 余白 */
    margin-right: 420px;  /* 右チャット領域分の余白確保 */
    padding: 20px;
    max-width: 600px;
}
.dm-partner-list-wrapper h2 { margin-top:0; }

.dm-partner-list {
    list-style:none;
    margin:0;
    padding:0;
    border:1px solid #ddd;
    border-radius:6px;
    background:#fff;
    overflow:hidden;
}
.dm-partner-item {
    display:flex;
    align-items:center;
    gap:10px;
    padding:10px 14px;
    border-bottom:1px solid #eee;
    text-decoration:none;
    color:#000;
}
.dm-partner-item:last-child { border-bottom:none; }
.dm-partner-item:hover { background:#f7f7f7; }
.dm-partner-item.active { background:#e8f4ff; }

.dm-partner-item-icon {
    width:40px;
    height:40px;
    border-radius:50%;
    background:center/cover no-repeat;
    flex-shrink:0;
}
.dm-partner-item-name { font-weight:600; }
.dm-partner-item-handle {
    color:#666;
    font-size:13px;
}

/* --- 新しいDMボタン --- */
.new-dm-btn {
    display:inline-block;
    margin-bottom:10px;
    padding:6px 10px;
    background:#3498db;
    color:#fff;
    border-radius:4px;
    text-decoration:none;
    font-size:14px;
}
.new-dm-btn:hover { background:#2980b9; }

/* --- モーダル --- */
#newDmModal {
    display:none;
    position:fixed;
    top:0; left:0;
    width:100%; height:100%;
    background:rgba(0,0,0,0.5);
    justify-content:center;
    align-items:center;
    z-index:999;
}
.new-dm-modal-content {
    background:#fff;
    padding:20px;
    border-radius:8px;
    width:400px;
    max-height:80vh;
    overflow:auto;
    position:relative;
}
.new-dm-modal-content h3 { margin-top:0; }
.new-dm-modal-content input {
    width:100%;
    padding:6px;
    margin-bottom:10px;
    border:1px solid #ccc;
    border-radius:4px;
}

/* 検索結果ユーザー行 */
.new-dm-user-item {
    display:flex;
    align-items:center;
    gap:10px;
    padding:8px;
    border-bottom:1px solid #eee;
    cursor:pointer;
}
.new-dm-user-item:hover { background:#f0f0f0; }
.new-dm-user-item-icon {
    width:36px;
    height:36px;
    border-radius:50%;
    background:center/cover no-repeat;
    flex-shrink:0;
}
.new-dm-user-item-text {
    display:block;
    line-height:1.2;
    font-size:14px;
}
.new-dm-user-item-text .nm { font-weight:600; }
.new-dm-user-item-text .hd { font-size:12px; color:#666; }

/* --- 右側チャットパネル --- */
.dm-chat-panel {
    position:fixed;
    top:0; right:0;
    width:400px;
    height:100vh;
    background:#fff;
    border-left:1px solid #ccc;
    box-shadow:-2px 0 5px rgba(0,0,0,.08);
    display:flex;
    flex-direction:column;
    padding-top:20px;
    z-index:10;
}
.dm-chat-header {
    padding:0 20px 10px;
    border-bottom:1px solid #eee;
}
.dm-chat-header h3 { margin:0; font-size:18px; }
.dm-chat-messages {
    flex:1;
    padding:16px 20px;
    overflow-y:auto;
}
.dm-msg-row {
    margin-bottom:12px;
    max-width:90%;
    clear:both;
}
.dm-msg-me {
    margin-left:auto;
    text-align:right;
}
.dm-msg-other {
    margin-right:auto;
    text-align:left;
}
.dm-msg-bubble {
    display:inline-block;
    padding:8px 12px;
    border-radius:16px;
    background:#f0f0f0;
    word-break:break-word;
    white-space:pre-wrap;
    font-size:14px;
    line-height:1.4;
}
.dm-msg-me .dm-msg-bubble { background:#d6ebff; }
.dm-msg-meta {
    font-size:11px;
    color:#666;
    margin-top:2px;
}

/* 送信フォーム */
.dm-chat-form {
    border-top:1px solid #eee;
    padding:12px 20px;
}
.dm-chat-form textarea { width:100%; resize:vertical; }
.dm-chat-form button { margin-top:6px; float:right; }
.dm-chat-form .hint {
    font-size:11px;
    color:#999;
    margin-bottom:4px;
}
</style>
</head>
<body>

<jsp:include page="sidebar.jsp" />

<!-- 中央: DM 相手一覧 -->
<div class="dm-partner-list-wrapper">
    <h2>ダイレクトメッセージ</h2>

    <a href="#" id="openNewDmModal" class="new-dm-btn">＋ 新しいDM</a>

    <p>メッセージの相手を選択してください。</p>

    <ul class="dm-partner-list">
    <%
        if (partners != null && !partners.isEmpty()) {
            for (User u : partners) {
                String iconPath = (u.getProfileImage() != null)
                    ? ctx + "/profile_images/" + u.getProfileImage()
                    : ctx + "/images/default_icon.jpg";
                boolean active = (partner != null && u.getUserId() == partner.getUserId());
    %>
        <li>
          <a class="dm-partner-item <%= active ? "active" : "" %>"
             href="DM.action?to=<%= u.getUserId() %>">
            <span class="dm-partner-item-icon"
                  style="background-image:url('<%= iconPath %>');"></span>
            <span>
              <span class="dm-partner-item-name"><%= u.getUsername() %></span><br>
              <span class="dm-partner-item-handle">@<%= u.getHandle() %></span>
            </span>
          </a>
        </li>
    <%
            }
        } else {
    %>
        <li style="padding:20px; text-align:center; color:#666;">
            まだDMのやり取りはありません。
        </li>
    <%
        }
    %>
    </ul>
</div>

<!-- 右側: 選択中相手とのチャット -->
<div class="dm-chat-panel">
  <div class="dm-chat-header">
    <%
      if (partner != null) {
    %>
        <h3><%= partner.getUsername() %></h3>
        <div style="color:#666;font-size:13px;">@<%= partner.getHandle() %></div>
    <%
      } else {
    %>
        <h3>DM相手を選択</h3>
    <%
      }
    %>
  </div>

  <div class="dm-chat-messages" id="dmChatMessages">
    <%
      if (partner != null) {
          if (messages != null && !messages.isEmpty()) {
              for (Message m : messages) {
                  boolean isMe = (m.getFromUserId() == me.getUserId());
    %>
        <div class="dm-msg-row <%= isMe ? "dm-msg-me" : "dm-msg-other" %>">
          <div class="dm-msg-bubble"><%= m.getContent() %></div>
          <div class="dm-msg-meta"><%= m.getSentAt() %></div>
        </div>
    <%
              }
          } else {
    %>
        <p style="color:#666;">まだメッセージがありません。</p>
    <%
          }
      } else {
    %>
        <p style="color:#666;">左のリストから相手を選択してください。</p>
    <%
      }
    %>
  </div>

  <div class="dm-chat-form">
    <%
      if (partner != null) {
    %>
    <div class="hint">Enterで送信 / Shift+Enterで改行</div>
    <form id="dmChatForm" action="DM.action" method="post" accept-charset="UTF-8">
        <input type="hidden" name="toId" value="<%= partner.getUserId() %>">
        <textarea id="dmChatTextarea" name="content" rows="3" required></textarea><br>
        <button type="submit">送信</button>
    </form>
    <%
      } else {
    %>
      <p style="font-size:13px;color:#aaa;">（相手を選択すると入力できます）</p>
    <%
      }
    %>
  </div>
</div>

<!-- 新しいDM モーダル -->
<div id="newDmModal">
  <div class="new-dm-modal-content" id="newDmModalContent">
    <h3>新しいDM</h3>
    <input type="text" id="dmSearchInput" placeholder="ユーザー名または @handle で検索">
    <div id="dmSearchResult"></div>
    <button type="button" onclick="closeNewDmModal()">閉じる</button>
  </div>
</div>

<script>
/* ======== ALL USERS (for modal search) ======== */
const allUsers = [
<%
if (allUsers != null) {
    for (int i = 0; i < allUsers.size(); i++) {
        User u = allUsers.get(i);
        // escape
        String uname  = u.getUsername().replace("\\","\\\\").replace("\"","\\\"");
        String handle = u.getHandle().replace("\\","\\\\").replace("\"","\\\"");
        String icon   = (u.getProfileImage() != null)
                        ? (ctx + "/profile_images/" + u.getProfileImage())
                        : (ctx + "/images/default_icon.jpg");
        icon = icon.replace("\\","\\\\").replace("\"","\\\"");
%>  {userId:<%=u.getUserId()%>, username:"<%=uname%>", handle:"<%=handle%>", icon:"<%=icon%>"}<%= (i < allUsers.size()-1) ? "," : "" %>
<%
    }
}
%>
];

/* ======== Modal Search Rendering ======== */
function renderSearchResult(keyword) {
    const box = document.getElementById('dmSearchResult');
    box.innerHTML = "";
    if (!keyword) return;

    const kw = keyword.toLowerCase();
    const hits = allUsers.filter(u =>
        u.username.toLowerCase().includes(kw) ||
        u.handle.toLowerCase().includes(kw)
    );

    hits.forEach(u => {
        const div = document.createElement('div');
        div.className = 'new-dm-user-item';
        div.onclick = () => {
            closeNewDmModal();
            window.location = "DM.action?to=" + u.userId;
        };

        const icon = document.createElement('span');
        icon.className = 'new-dm-user-item-icon';
        icon.style.backgroundImage = "url('" + u.icon + "')";

        const txt = document.createElement('span');
        txt.className = 'new-dm-user-item-text';
        txt.innerHTML = '<span class="nm">' + escapeHtml(u.username) + '</span> <span class="hd">@' + escapeHtml(u.handle) + '</span>';

        div.appendChild(icon);
        div.appendChild(txt);
        box.appendChild(div);
    });
}

/* simple html escape */
function escapeHtml(s){
  return s.replace(/[&<>"']/g, function(c){
    return ({
      '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'
    })[c];
  });
}

/* ======== Modal open/close ======== */
const modal = document.getElementById('newDmModal');
const modalContent = document.getElementById('newDmModalContent');
document.getElementById('openNewDmModal').onclick = (e) => {
    e.preventDefault();
    modal.style.display = 'flex';
    setTimeout(() => document.getElementById('dmSearchInput').focus(), 0);
};
function closeNewDmModal() {
    modal.style.display = 'none';
    const inp = document.getElementById('dmSearchInput');
    const res = document.getElementById('dmSearchResult');
    if (inp) inp.value = "";
    if (res) res.innerHTML = "";
}

/* click outside modal content */
modal.addEventListener('click', (e)=>{
  if(e.target === modal) {
    closeNewDmModal();
  }
});

/* ESC closes modal */
document.addEventListener('keydown', (e)=>{
  if(e.key === 'Escape'){
    closeNewDmModal();
  }
});

/* live search */
document.getElementById('dmSearchInput').addEventListener('input', e => {
    renderSearchResult(e.target.value);
});

/* ======== DM Chat: Enter to Send ======== */
(function(){
  const form = document.getElementById('dmChatForm');
  const ta   = document.getElementById('dmChatTextarea');
  if(!form || !ta) return;
  ta.addEventListener('keydown', function(e){
    if(e.key === 'Enter' && !e.shiftKey){
      e.preventDefault();
      if(ta.value.trim() !== ""){
        form.submit();
      }
    }
  });
})();

/* ======== Scroll chat to bottom ======== */
(function(){
  var box = document.getElementById('dmChatMessages');
  if (box) box.scrollTop = box.scrollHeight;
})();
</script>

</body>
</html>
