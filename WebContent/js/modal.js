document.addEventListener('DOMContentLoaded', () => {
  const loginBtn = document.getElementById('loginBtn');
  const registerBtn = document.getElementById('registerBtn');
  const loginModal = document.getElementById('loginModal');
  const registerModal = document.getElementById('registerModal');

  loginBtn.addEventListener('click', () => {
    loginModal.style.display = 'flex';
  });

  registerBtn.addEventListener('click', () => {
    registerModal.style.display = 'flex';
  });

  document.querySelectorAll('.btn-close').forEach(btn => {
    btn.addEventListener('click', e => {
      const targetId = e.target.getAttribute('data-close');
      document.getElementById(targetId).style.display = 'none';
    });
  });

  // JSPから渡されたフラグ(loginErrorFlag, registerErrorFlag)でモーダルを自動表示
  if (typeof loginErrorFlag !== 'undefined' && loginErrorFlag === "1") {
    loginModal.style.display = 'flex';
  }
  if (typeof registerErrorFlag !== 'undefined' && registerErrorFlag === "1") {
    registerModal.style.display = 'flex';
  }
});