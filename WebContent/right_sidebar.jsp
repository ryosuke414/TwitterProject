<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%
    String kw = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";

    @SuppressWarnings("unchecked")
    List<String> history = (List<String>) request.getAttribute("history");

    if (history == null) {
        @SuppressWarnings("unchecked")
        List<String> sessHist = (List<String>) session.getAttribute("searchHistory");
        history = sessHist;
    }
    if (history == null) {
        history = Collections.emptyList();
    }

    StringBuilder histJson = new StringBuilder();
    for (int i=0; i<history.size(); i++) {
        String h = history.get(i);
        String esc = h.replace("\\","\\\\")
                      .replace("\"","\\\"")
                      .replace("\r","\\r")
                      .replace("\n","\\n");
        if (i>0) histJson.append(',');
        histJson.append('"').append(esc).append('"');
    }
%>

<div class="rightbar">
    <h3 class="rightbar-title">検索</h3>
    <form id="globalSearchForm" method="get" action="Search.action" autocomplete="off" class="search-form">
        <div class="search-box-wrapper">
            <input
                id="globalSearchInput"
                type="text"
                name="keyword"
                value="<%= kw %>"
                placeholder="キーワードを入力"
                required
            >
            <button type="submit" class="hidden-submit" aria-hidden="true">検索</button>

            <div id="globalHistoryDropdown" class="search-history-dropdown" role="listbox" aria-label="検索履歴候補" style="display:none;">
                <div class="search-history-clearall">
                    <button type="button" id="globalHistoryClearAll">履歴をすべて削除</button>
                </div>
                <ul id="globalHistoryItems"></ul>
            </div>
        </div>
    </form>
</div>

<script>
// ===== 履歴配列 (サーバー -> JS) =====
const GLOBAL_SEARCH_HISTORY = [<%= histJson.toString() %>];

// ===== DOM =====
const gSearchInput  = document.getElementById('globalSearchInput');
const gSearchForm   = document.getElementById('globalSearchForm');
const gHistDD       = document.getElementById('globalHistoryDropdown');
const gHistList     = document.getElementById('globalHistoryItems');
const gHistClearAll = document.getElementById('globalHistoryClearAll');

// ===== 描画 =====
function buildGlobalHistoryList(filterText=""){
  const ft = filterText.trim().toLowerCase();
  gHistList.innerHTML = "";
  GLOBAL_SEARCH_HISTORY.forEach(kw=>{
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
    gHistList.appendChild(li);
  });
}

function showGlobalHistory(){
  if(GLOBAL_SEARCH_HISTORY.length === 0) return;
  gHistDD.style.display = 'block';
}
function hideGlobalHistory(){
  gHistDD.style.display = 'none';
}

// ===== Events =====
if (gSearchInput) {
  gSearchInput.addEventListener('focus', () => {
    buildGlobalHistoryList(gSearchInput.value);
    showGlobalHistory();
  });
  gSearchInput.addEventListener('input', () => {
    buildGlobalHistoryList(gSearchInput.value);
    showGlobalHistory();
  });
  gSearchInput.addEventListener('blur', () => {
    setTimeout(hideGlobalHistory, 150);
  });
  // Enter で通常送信
}

// 履歴リストクリック
gHistList.addEventListener('click', e=>{
  const wordBtn = e.target.closest('.search-history-word');
  if(wordBtn){
    gSearchInput.value = wordBtn.dataset.keyword || "";
    gSearchForm.submit();
    return;
  }
  const delBtn = e.target.closest('.search-history-delete-btn');
  if(delBtn){
    deleteHistoryOne(delBtn.dataset.keyword || "", delBtn.closest('li'));
  }
});

// 全削除
if(gHistClearAll){
  gHistClearAll.addEventListener('click', ()=>{
    if(!confirm('履歴をすべて削除しますか？')) return;
    clearHistoryAll();
  });
}

// ===== 履歴削除 (1件) =====
function deleteHistoryOne(keyword, liElem){
  if(liElem) liElem.remove();
  const idx = GLOBAL_SEARCH_HISTORY.indexOf(keyword);
  if(idx>=0) GLOBAL_SEARCH_HISTORY.splice(idx,1);
  postSearchHistory('deleteOne', keyword);
}

// ===== 履歴全削除 =====
function clearHistoryAll(){
  GLOBAL_SEARCH_HISTORY.splice(0, GLOBAL_SEARCH_HISTORY.length);
  gHistList.innerHTML = "";
  hideGlobalHistory();
  postSearchHistory('clearHistory', '');
}

// ===== サーバー通知 =====
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
</script>
