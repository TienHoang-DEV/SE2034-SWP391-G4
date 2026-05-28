document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize Lucide Icons
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

    // 2. Change Avatar Simulation
    const btnChangeAvatar = document.getElementById('btn-change-avatar');
    const userAvatars = document.querySelectorAll('.user-avatar, .student-avatar-wrapper img');

    if (btnChangeAvatar) {
        btnChangeAvatar.addEventListener('click', () => {
            const newImgUrl = prompt('Nhập URL ảnh đại diện mới để cập nhật (hoặc để trống để sử dụng avatar mặc định):');
            if (newImgUrl !== null) {
                const finalUrl = newImgUrl.trim() !== '' ? newImgUrl.trim() : '../../image/student2.png';
                userAvatars.forEach(img => {
                    img.src = finalUrl;
                });
                alert('Ảnh đại diện của học viên đã được cập nhật thành công!');
            }
        });
    }

    // 3. Simulated Menu Links Action
    const menuOptions = {
        'opt-info': 'Thông tin cá nhân',
        'opt-certificates': 'Đang tải danh sách 5 chứng chỉ hoàn thành...',
        'opt-settings': 'Đang mở bảng Cài đặt tài khoản...',
        'opt-help': 'Đang kết nối tới Trung tâm Trợ giúp khách hàng...'
    };

    Object.entries(menuOptions).forEach(([id, message]) => {
        const element = document.getElementById(id);
        if (element) {
            element.addEventListener('click', (e) => {
                e.preventDefault();
                alert(`[Giả lập] ${message}`);
            });
        }
    });

    // 4. Search bar enter key redirect
    const searchInput = document.getElementById('search-input');
    if (searchInput) {
        searchInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                const query = searchInput.value.trim();
                if (query) {
                    window.location.href = `courses.html?search=${encodeURIComponent(query)}`;
                }
            }
        });
    }
});
