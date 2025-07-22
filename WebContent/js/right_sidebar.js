/**
 *
 */
(function(){
    const input  = document.getElementById('globalSearchInput');
    if(!input) return;
    const form   = document.getElementById('globalSearchForm');
    const dd     = document.getElementById('globalHistoryDropdown');
    const items  = document.getElementById('globalHistoryItems');

    input.addEventListener('keydown', e=>{
        if (e.key === 'Enter' && e.isComposing) e.preventDefault();
    });

    input.addEventListener('focus', ()=>{ if (dd) dd.style.display = 'block'; });

    input.addEventListener('input', ()=>{
        if(!items) return;
        const q = input.value.toLowerCase();
        [...items.querySelectorAll('li')].forEach(li=>{
            li.style.display = (li.dataset.keyword.toLowerCase().includes(q)) ? '' : 'none';
        });
    });

    input.addEventListener('blur', ()=>{ if (dd) setTimeout(()=> dd.style.display='none', 160); });

    if(items){
        items.addEventListener('click', e=>{
            const btn = e.target.closest('.search-history-word');
            if(!btn) return;
            const li = btn.closest('li');
            input.value = li.dataset.keyword || '';
            form.submit();
        });
    }
})();
