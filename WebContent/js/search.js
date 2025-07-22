// const SEARCH_MAIN_HISTORY = [...] は除外
// 以降のコードを移す

// ただし、変数はDOMContentLoaded内で取得し、
// SEARCH_MAIN_HISTORYはグローバル変数として使う想定でOK

document.addEventListener('DOMContentLoaded', () => {
  const smInput  = document.getElementById('searchMainInput');
  const smForm   = document.getElementById('searchMainForm');
  const smDD     = document.getElementById('searchMainHistoryDropdown');
  const smItems  = document.getElementById('searchMainHistoryItems');
  const smClrAll = document.getElementById('searchMainHistoryClearAll');

  function buildSearchMainHistory(filterText=""){
    const ft = filterText.trim().toLowerCase();
    if (!smItems) return;
    smItems.innerHTML = "";
    SEARCH_MAIN_HISTORY.forEach(kw=>{
      if(ft && !kw.toLowerCase().includes(ft)) return;
      const li  = document.createElement('li');
      li.dataset.keyword = kw;

      const wordBtn = document.createElement('button');
      wordBtn.type = "button";
      wordBtn.className = "search-history-word";
      wordBtn.textContent = kw;
      wordBtn.dataset.keyword = kw;

      const delBtn = document.createElement('button');
      delBtn.type = "button";
      delBtn.className = "search-history-delete-btn";
      delBtn.textContent = "×";
      delBtn.title = "この履歴を削除";
      delBtn.dataset.keyword = kw;

      li.appendChild(wordBtn);
      li.appendChild(delBtn);
      smItems.appendChild(li);
    });
  }

  function showSearchMainHistory(){
    if(!smDD) return;
    if(SEARCH_MAIN_HISTORY.length === 0) return;
    smDD.style.display = 'block';
  }
  function hideSearchMainHistory(){
    if(!smDD) return;
    smDD.style.display = 'none';
  }

  if (smInput) {
    smInput.addEventListener('focus', () => {
      buildSearchMainHistory(smInput.value);
      showSearchMainHistory();
    });
    smInput.addEventListener('input', () => {
      buildSearchMainHistory(smInput.value);
      showSearchMainHistory();
    });
    smInput.addEventListener('blur', () => {
      setTimeout(hideSearchMainHistory, 150);
    });
    // Enter → 通常 submit
    smInput.addEventListener('keydown', e=>{
      if(e.key === 'Enter' && !e.isComposing){
        // submit デフォルト
      }
    });
  }

  if (smItems) {
    smItems.addEventListener('click', e=>{
      const wordBtn = e.target.closest('.search-history-word');
      if(wordBtn){
        smInput.value = wordBtn.dataset.keyword || "";
        smForm.submit();
        return;
      }
      const delBtn = e.target.closest('.search-history-delete-btn');
      if(delBtn){
        deleteSearchHistoryOne(delBtn.dataset.keyword || "", delBtn.closest('li'));
      }
    });
  }

  if (smClrAll) {
    smClrAll.addEventListener('click', ()=>{
      if(!confirm('履歴をすべて削除しますか？')) return;
      clearSearchHistoryAll();
    });
  }

  function deleteSearchHistoryOne(keyword, liElem){
    if(liElem) liElem.remove();
    const idx = SEARCH_MAIN_HISTORY.indexOf(keyword);
    if(idx>=0) SEARCH_MAIN_HISTORY.splice(idx,1);
    postSearchHistory('deleteOne', keyword);
  }
  function clearSearchHistoryAll(){
    SEARCH_MAIN_HISTORY.splice(0, SEARCH_MAIN_HISTORY.length);
    if(smItems) smItems.innerHTML = "";
    hideSearchMainHistory();
    postSearchHistory('clearHistory', '');
  }
  function postSearchHistory(op, keyword){
    const form = document.createElement('form');
    form.method = 'post';
    form.action = 'Search.action';

    const opIn = document.createElement('input');
    opIn.type = 'hidden'; opIn.name = 'op'; opIn.value = op;
    form.appendChild(opIn);

    if(keyword){
      const kwIn = document.createElement('input');
      kwIn.type = 'hidden'; kwIn.name = 'keyword'; kwIn.value = keyword;
      form.appendChild(kwIn);
    }

    document.body.appendChild(form);
    form.submit();
  }

  // ======== コメントモーダル (既存ロジック) ========
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
    if(!ov) return;
    ov.style.display = 'none';
    const content = document.getElementById('commentModalContent');
    if(content) content.innerHTML = '';
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
  document.addEventListener('keydown', e=>{
    if(e.key === 'Escape') closeCommentModal();
  });
  const commentModalOverlay = document.getElementById('commentModalOverlay');
  if(commentModalOverlay){
    commentModalOverlay.addEventListener('click', e=>{
      if(e.target === commentModalOverlay) closeCommentModal();
    });
  }
});