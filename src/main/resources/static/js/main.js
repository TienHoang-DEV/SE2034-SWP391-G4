document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize Lucide Icons
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

    initializeCourseReviewForm();

    // 2. Cart Logic & Bootstrap Toast Trigger
    const btnAddToCart = document.getElementById('btn-add-to-cart');
    const cartBadge = document.getElementById('cart-badge-count');

    // Fetch initial cart count from DB on page load
    if (cartBadge) {
        fetch('/api/cart/count')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    cartBadge.textContent = data.cartSize;
                }
            })
            .catch(err => console.error('Error fetching cart count:', err));
    }
    
    if (btnAddToCart && cartBadge) {
        btnAddToCart.addEventListener('click', () => {
            const courseId = btnAddToCart.getAttribute('data-course-id');
            if (!courseId) {
                console.error("Course ID is missing on the button.");
                return;
            }

            btnAddToCart.disabled = true;

            fetch(`/api/cart/add?courseId=${courseId}`, {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                btnAddToCart.disabled = false;
                if (data.success) {
                    // Update cart count
                    cartBadge.textContent = data.cartSize;

                    // Visual bounce animation for the badge
                    cartBadge.style.transform = 'scale(1.4)';
                    setTimeout(() => {
                        cartBadge.style.transform = '';
                    }, 300);

                    // Show dynamic Success Toast
                    showSuccessToast(data.message);
                } else {
                    alert(data.message || 'Không thể thêm vào giỏ hàng.');
                }
            })
            .catch(err => {
                btnAddToCart.disabled = false;
                console.error('Error adding course to cart:', err);
                alert('Có lỗi xảy ra khi thêm vào giỏ hàng.');
            });
        });
    }

    function showSuccessToast(message) {
        let toastContainer = document.querySelector(".toast-container");
        if (!toastContainer) {
            toastContainer = document.createElement("div");
            toastContainer.className = "toast-container position-fixed bottom-0 end-0 p-3";
            toastContainer.style.zIndex = "1100";
            document.body.appendChild(toastContainer);
        }

        const toastId = "toast-" + Date.now();
        const toastHtml = `
            <div id="${toastId}" class="toast border-0 rounded-3 shadow-lg" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-body d-flex align-items-center gap-3 p-3 rounded-3" style="background-color: #d1e7dd; border: 1px solid #a3cfbb; border-left: 5px solid #0f5132;">
                    <i data-lucide="check-circle" style="color: #0f5132; width: 24px; height: 24px;"></i>
                    <div class="toast-content flex-grow-1">
                        <p class="toast-title fw-bold m-0 fs-7" style="color: #0f5132;">Thành công!</p>
                        <p class="toast-message m-0 fs-8" style="color: #0f5132; font-weight: 500;">${message}</p>
                    </div>
                    <button type="button" class="btn-close btn-close-sm shadow-none" data-bs-dismiss="toast" aria-label="Close" style="filter: invert(20%) sepia(20%) saturate(1000%) hue-rotate(90deg) brightness(30%);"></button>
                </div>
            </div>
        `;
        
        toastContainer.insertAdjacentHTML("beforeend", toastHtml);
        const toastElement = document.getElementById(toastId);
        
        if (typeof lucide !== 'undefined') {
            lucide.createIcons({
                attrs: { class: 'lucide-icon' },
                nameAttr: 'data-lucide',
                node: toastElement
            });
        }

        const bsToast = new bootstrap.Toast(toastElement, { delay: 3000 });
        bsToast.show();
        
        toastElement.addEventListener("hidden.bs.toast", () => {
            toastElement.remove();
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
