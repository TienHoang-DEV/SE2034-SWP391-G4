document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize Lucide Icons
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

    initializeCourseReviewForm();

    // 2. Cart Logic & Bootstrap Toast Trigger
    const btnAddToCart = document.getElementById('btn-add-to-cart');
    const cartBadge = document.getElementById('cart-badge-count');
    const toastElement = document.getElementById('cartToast');
    
    if (btnAddToCart && cartBadge && toastElement) {
        // Initialize Bootstrap Toast instance
        const cartToast = new bootstrap.Toast(toastElement, {
            delay: 3000
        });

        btnAddToCart.addEventListener('click', () => {
            // Increment cart count
            let count = parseInt(cartBadge.textContent) || 0;
            count += 1;
            cartBadge.textContent = count;

            // Visual bounce animation for the badge
            cartBadge.style.transform = 'scale(1.4)';
            setTimeout(() => {
                cartBadge.style.transform = '';
            }, 300);

            // Show Bootstrap Toast
            cartToast.show();
        });
    }

    // 3. Lucide Icons re-render when Bootstrap Collapse / Tabs / Modal are triggered
    // This ensures icons inside dynamically updated elements render correctly
    const modalEl = document.getElementById('videoModal');
    if (modalEl) {
        modalEl.addEventListener('shown.bs.modal', () => {
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
        });
    }
});

function initializeCourseReviewForm() {
    const reviewForm = document.getElementById('course-review-form');
    if (!reviewForm) return;

    const stars = reviewForm.querySelectorAll('.course-review-star');
    const commentInput = document.getElementById('course-review-comment');
    const alertBox = document.getElementById('course-review-alert');
    let selectedRating = 0;

    const updateStars = (rating) => {
        stars.forEach((star, index) => {
            star.classList.toggle('is-selected', index < rating);
            star.classList.toggle('text-muted', index >= rating);
        });
    };

    stars.forEach(star => {
        star.addEventListener('click', () => {
            selectedRating = Number(star.dataset.rating) || 0;
            updateStars(selectedRating);
            if (alertBox) {
                alertBox.classList.add('d-none');
            }
        });
    });

    reviewForm.addEventListener('submit', (event) => {
        event.preventDefault();

        if (selectedRating === 0) {
            alert('Vui lòng chọn số sao đánh giá.');
            return;
        }

        if (!commentInput.value.trim()) {
            alert('Vui lòng nhập nhận xét trước khi gửi đánh giá.');
            commentInput.focus();
            return;
        }

        if (alertBox) {
            alertBox.classList.remove('d-none');
        }

        selectedRating = 0;
        updateStars(selectedRating);
        commentInput.value = '';
    });
}
