// ドロップダウンメニュー制御
function toggleMenu(elem) {
    document.querySelectorAll('.dropdown-menu').forEach(m => {
        if (m !== elem.nextElementSibling) m.style.display = 'none';
    });
    const menu = elem.nextElementSibling;
    menu.style.display = (menu.style.display === 'block') ? 'none' : 'block';
}
document.addEventListener('click', e => {
    if (!e.target.closest('.tweet-menu') && !e.target.closest('.dropdown-menu')) {
        document.querySelectorAll('.dropdown-menu').forEach(m => m.style.display = 'none');
    }
});

// コメントモーダル制御
document.addEventListener('click', function (e) {
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
        .then(r => {
            if (!r.ok) throw new Error('通信エラー');
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
    document.getElementById('commentModalOverlay').style.display = 'none';
    document.getElementById('commentModalContent').innerHTML = '';
}

function setupCommentFormAjax(triggerBtn) {
    const form = document.querySelector('#commentModalContent form.comment-form');
    if (!form) return;
    form.addEventListener('submit', function (e) {
        e.preventDefault();
        const fd = new FormData(form);
        fetch(form.action, { method: 'POST', body: fd })
            .then(r => r.json())
            .then(data => {
                if (data.status === 'ok') {
                    if (triggerBtn) {
                        const countSpan = triggerBtn.querySelector('[data-role="comment-count"]');
                        if (countSpan) countSpan.textContent = data.newCount;
                    }
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

// 編集モーダル
function openEditModal(tweetId, contentHtmlEscaped) {
    const tmp = document.createElement('textarea');
    tmp.innerHTML = contentHtmlEscaped;
    const decoded = tmp.value;

    document.getElementById('editTweetId').value = tweetId;
    document.getElementById('editContent').value = decoded;
    document.getElementById('editPostModalOverlay').style.display = 'flex';
}
function closeEditModal() {
    document.getElementById('editPostModalOverlay').style.display = 'none';
}

// ESCで閉じる
document.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
        closeCommentModal();
        closeEditModal();
    }
});

// オーバーレイクリックで閉じる
document.getElementById('commentModalOverlay').addEventListener('click', e => {
    if (e.target.id === 'commentModalOverlay') closeCommentModal();
});
document.getElementById('editPostModalOverlay').addEventListener('click', e => {
    if (e.target.id === 'editPostModalOverlay') closeEditModal();
});