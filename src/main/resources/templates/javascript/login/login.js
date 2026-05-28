document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize Lucide Icons
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

    // 2. Switch between Login and Register Forms
    const loginWrapper = document.getElementById('login-form-wrapper');
    const registerWrapper = document.getElementById('register-form-wrapper');
    
    const btnSwitchToRegister = document.getElementById('btn-switch-to-register');
    const btnSwitchToLogin = document.getElementById('btn-switch-to-login');
    const headerRegisterBtn = document.getElementById('header-register-btn');

    function showRegisterForm(e) {
        if (e) e.preventDefault();
        loginWrapper.style.display = 'none';
        registerWrapper.style.display = 'block';
        // Reinitialize icons in case register form was hidden
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
    }

    function showLoginForm(e) {
        if (e) e.preventDefault();
        registerWrapper.style.display = 'none';
        loginWrapper.style.display = 'block';
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
    }

    if (btnSwitchToRegister) btnSwitchToRegister.addEventListener('click', showRegisterForm);
    if (btnSwitchToLogin) btnSwitchToLogin.addEventListener('click', showLoginForm);
    if (headerRegisterBtn) headerRegisterBtn.addEventListener('click', showRegisterForm);

    // 3. Login Form Submission (Simulate Auth and redirect to home_logged_in.html)
    const loginForm = document.getElementById('login-form');
    if (loginForm) {
        loginForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const emailInput = document.getElementById('login-email');
            alert(`Đăng nhập thành công với tài khoản: ${emailInput.value}! Đang chuyển hướng bạn tới trang chủ...`);
            window.location.href = 'home_logged_in.html';
        });
    }

    // 4. Google Login Button Action (Simulate Auth and redirect)
    const btnLoginGoogle = document.getElementById('btn-login-google');
    if (btnLoginGoogle) {
        btnLoginGoogle.addEventListener('click', (e) => {
            e.preventDefault();
            alert('Đăng nhập bằng Google thành công! Đang chuyển hướng bạn tới trang chủ...');
            window.location.href = 'home_logged_in.html';
        });
    }

    // 5. Register Form Submission
    const registerForm = document.getElementById('register-form');
    if (registerForm) {
        registerForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const password = document.getElementById('reg-password').value;
            const confirmPassword = document.getElementById('reg-password-confirm').value;

            if (password !== confirmPassword) {
                alert('Mật khẩu xác nhận không khớp! Vui lòng kiểm tra lại.');
                return;
            }

            const email = document.getElementById('reg-email').value;
            alert(`Đăng ký tài khoản thành công với email: ${email}! Đang tự động đăng nhập và chuyển hướng...`);
            window.location.href = 'home_logged_in.html';
        });
    }

    // 6. Forgot Password Click
    const btnForgotPassword = document.getElementById('btn-forgot-password');
    if (btnForgotPassword) {
        btnForgotPassword.addEventListener('click', (e) => {
            e.preventDefault();
            const email = prompt('Nhập địa chỉ email của bạn để nhận liên kết đặt lại mật khẩu:');
            if (email !== null && email.trim() !== '') {
                alert(`Liên kết đặt lại mật khẩu đã được gửi tới email: ${email}`);
            }
        });
    }
});
