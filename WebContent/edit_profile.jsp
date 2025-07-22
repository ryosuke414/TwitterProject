<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 表示用クロップ後
    String croppedPath = (user.getProfileImage() != null)
        ? request.getContextPath() + "/profile_images/" + user.getProfileImage()
        : request.getContextPath() + "/images/default_icon.jpg";

    // 編集用オリジナル
    String originalImgPath = (user.getOriginalImage() != null)
        ? request.getContextPath() + "/profile_images/original/" + user.getOriginalImage()
        : null; // まだオリジナルなし

    boolean hasUploadedImage = (originalImgPath != null); // 一度でもアップロード済か
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>プロフィール編集</title>
<link rel="stylesheet" href="css/style.css">

</head>
<body>
<jsp:include page="sidebar.jsp" />

<div class="main profile-edit-container">
    <!-- 戻るボタン -->
    <button type="button" class="back-btn" onclick="history.back();">← 戻る</button>
    <h2>プロフィール編集</h2>

    <% if (hasUploadedImage) { %>
        <!-- 既に画像あり：トリミングUIを表示 -->
        <div class="drag-container" id="dragContainer">
            <div class="circle-guide"></div>
            <img
                src="<%= originalImgPath %>"
                id="profileImagePreview"
                alt="プレビュー"
                draggable="false">
        </div>

        <div class="profile-edit-controls" id="scaleControls">
            <label for="sizeSlider">拡大（短辺基準）:</label><br>
            <input type="range" id="sizeSlider" value="300">
            <span id="sizeValue">300px</span>
            <div class="hint">ドラッグで位置調整できます。</div>
        </div>
    <% } else { %>
        <!-- まだ画像なし：デフォルトのみ表示（丸） -->
        <div class="default-icon-wrapper"
             style="background-image:url('<%= croppedPath %>')"></div>
        <p class="hint">
            まだプロフィール画像が設定されていません。<br>
            画像を選択するとトリミング用の編集枠が表示されます。
        </p>
    <% } %>

    <form action="EditProfile.action" method="post" enctype="multipart/form-data" id="profileForm">
        <!-- hidden（画像あり時のみ使用。最初は空でOK） -->
        <input type="hidden" name="iconWidth"      id="iconWidth">
        <input type="hidden" name="iconHeight"     id="iconHeight">
        <input type="hidden" name="iconX"          id="iconX">
        <input type="hidden" name="iconY"          id="iconY">
        <input type="hidden" name="displayWidth"   id="displayWidth">
        <input type="hidden" name="displayHeight"  id="displayHeight">

        <label>画像を選択:</label><br>
        <input type="file" name="profileImage" id="profileImageFile" accept="image/*"><br><br>

        <label>ユーザー名:</label><br>
        <input type="text" name="username" value="<%= user.getUsername() %>" required><br><br>

        <label>自己紹介（bio）:</label><br>
        <textarea name="bio" rows="4" cols="50"><%= user.getBio() != null ? user.getBio() : "" %></textarea><br><br>

        <button type="submit">保存</button>
    </form>
</div>

<script>
(function() {
    const hasImageInitially = <%= hasUploadedImage %>;

    const FRAME_SIZE = 300;

    // 要素取得（存在しない場合があるので都度チェック）
    const container = document.getElementById('dragContainer');
    const fileInput = document.getElementById('profileImageFile');
    const slider    = document.getElementById('sizeSlider');
    const sizeValue = document.getElementById('sizeValue');

    const hW  = document.getElementById('iconWidth');
    const hH  = document.getElementById('iconHeight');
    const hX  = document.getElementById('iconX');
    const hY  = document.getElementById('iconY');
    const hDW = document.getElementById('displayWidth');
    const hDH = document.getElementById('displayHeight');

    let img; // 動的にも作り直す
    let naturalW = 0, naturalH = 0;
    let currentScale = 1;
    let dragging = false;
    let startX=0, startY=0, startLeft=0, startTop=0;

    if (hasImageInitially) {
        img = document.getElementById('profileImagePreview');
        if (img && img.complete) initAfterLoad();
        else if (img) img.onload = initAfterLoad;
    }

    // 新規に画像を選択した時（初回アップロード or 差し替え）
    fileInput.addEventListener('change', function() {
        const file = this.files && this.files[0];
        if (!file) return;
        if (!file.type.startsWith('image/')) {
            alert('画像ファイルを選択してください');
            this.value = '';
            return;
        }

        // まだ編集枠がない（=初回画像設定）の場合は DOM を生成
        if (!document.getElementById('dragContainer')) {
            createEditorArea();
        }

        const reader = new FileReader();
        reader.onload = e => {
            img.onload = () => initAfterLoad();
            img.src = e.target.result;
        };
        reader.readAsDataURL(file);
    });

    function createEditorArea() {
        const main = document.querySelector('.profile-edit-container');

        // 既存の default アイコン表示部分はそのまま下に残っても良いので削除するならここで remove
        const oldWrapper = document.querySelector('.default-icon-wrapper');
        if (oldWrapper) oldWrapper.remove();
        const oldHint = document.querySelector('.hint');
        if (oldHint) oldHint.remove();

        // 編集枠挿入位置（フォームの前あたり）
        const form = document.getElementById('profileForm');

        // 枠
        const dragDiv = document.createElement('div');
        dragDiv.className = 'drag-container';
        dragDiv.id = 'dragContainer';

        const guide = document.createElement('div');
        guide.className = 'circle-guide';
        dragDiv.appendChild(guide);

        img = document.createElement('img');
        img.id = 'profileImagePreview';
        img.alt = 'プレビュー';
        img.draggable = false;
        dragDiv.appendChild(img);

        form.parentNode.insertBefore(dragDiv, form);

        // コントロール
        const controls = document.createElement('div');
        controls.className = 'profile-edit-controls';
        controls.id = 'scaleControls';
        controls.innerHTML = `
            <label for="sizeSlider">拡大（短辺基準）:</label><br>
            <input type="range" id="sizeSlider">
            <span id="sizeValue"></span>
            <div class="hint">ドラッグで位置調整できます。</div>
        `;
        form.parentNode.insertBefore(controls, form);

        // 再取得
        slider = document.getElementById('sizeSlider');
        sizeValue = document.getElementById('sizeValue');

        // イベント再バインド
        slider.addEventListener('input', onSliderInput);
        enableDrag();
    }

    function initAfterLoad() {
        naturalW = img.naturalWidth;
        naturalH = img.naturalHeight;
        if (!naturalW || !naturalH) return;

        // 短辺を 300 に
        const shortSide = Math.min(naturalW, naturalH);
        const minScale = FRAME_SIZE / shortSide;
        currentScale = minScale;

        setupSlider(shortSide);
        applyScaleCenter();
        updateHidden();
        enableDrag();
    }

    function setupSlider(shortSide) {
        if (!slider) return;
        slider.min = FRAME_SIZE;
        slider.max = FRAME_SIZE * 4;
        slider.step = 1;
        slider.value = FRAME_SIZE;
        sizeValue.textContent = slider.value + 'px';
    }

    function onSliderInput() {
        const shortNatural = Math.min(naturalW, naturalH);
        const targetShort = parseInt(slider.value, 10);
        currentScale = targetShort / shortNatural;
        applyScaleCenter();
        clampPosition();
        sizeValue.textContent = targetShort + 'px';
        updateHidden();
    }

    function applyScaleCenter() {
        const scaledW = naturalW * currentScale;
        const scaledH = naturalH * currentScale;
        img.style.width  = scaledW + 'px';
        img.style.height = scaledH + 'px';

        // 中央配置
        let left = -(scaledW - FRAME_SIZE) / 2;
        let top  = -(scaledH - FRAME_SIZE) / 2;
        img.style.left = Math.round(left) + 'px';
        img.style.top  = Math.round(top)  + 'px';
    }

    function enableDrag() {
        if (!img) return;
        img.addEventListener('mousedown', startDrag);
        document.addEventListener('mousemove', onDrag);
        document.addEventListener('mouseup', endDrag);
    }

    function startDrag(e) {
        dragging = true;
        startX = e.clientX;
        startY = e.clientY;
        startLeft = parseInt(img.style.left, 10) || 0;
        startTop  = parseInt(img.style.top, 10)  || 0;
        e.preventDefault();
    }

    function onDrag(e) {
        if (!dragging) return;
        const dx = e.clientX - startX;
        const dy = e.clientY - startY;
        img.style.left = (startLeft + dx) + 'px';
        img.style.top  = (startTop  + dy) + 'px';
        clampPosition();
        updateHidden();
    }

    function endDrag() {
        dragging = false;
    }

    function clampPosition() {
        if (!img) return;
        const w = parseFloat(img.style.width);
        const h = parseFloat(img.style.height);
        let left = parseInt(img.style.left, 10) || 0;
        let top  = parseInt(img.style.top, 10)  || 0;

        const minLeft = -(w - FRAME_SIZE);
        const minTop  = -(h - FRAME_SIZE);
        if (left < minLeft) left = minLeft;
        if (left > 0) left = 0;
        if (top < minTop) top = minTop;
        if (top > 0) top = 0;

        img.style.left = Math.round(left) + 'px';
        img.style.top  = Math.round(top)  + 'px';
    }

    function updateHidden() {
        if (!img) return;
        const w = parseFloat(img.style.width);
        const h = parseFloat(img.style.height);
        const left = parseInt(img.style.left, 10) || 0;
        const top  = parseInt(img.style.top, 10)  || 0;

        hW.value  = Math.round(w);
        hH.value  = Math.round(h);
        hX.value  = Math.round(left);
        hY.value  = Math.round(top);
        hDW.value = Math.round(w);
        hDH.value = Math.round(h);
    }

    // スライダーイベント（初期画像ありの場合）
    if (hasImageInitially && slider) {
        slider.addEventListener('input', onSliderInput);
    }
})();
</script>
</body>
</html>
