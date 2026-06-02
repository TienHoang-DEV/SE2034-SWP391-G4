// Initialize Lucide Icons
document.addEventListener("DOMContentLoaded", () => {
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
    
    initializeCartButtons();
    initializeSearchRedirect();
});

function initializeSearchRedirect() {
    const searchInput = document.getElementById('search-input');
    if (searchInput) {
        searchInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                const query = searchInput.value.trim();
                if (query) {
                    window.location.href = `/courses?search=${encodeURIComponent(query)}`;
                }
            }
        });
    }
}

// Shopping Cart Actions
function initializeCartButtons() {
    const cartButtons = document.querySelectorAll(".btn-cart");
    const cartBadge = document.querySelector(".cart-count-badge");
    
    // Create a Toast container if it doesn't exist
    let toastContainer = document.querySelector(".toast-container");
    if (!toastContainer) {
        toastContainer = document.createElement("div");
        toastContainer.className = "toast-container position-fixed bottom-0 end-0 p-3";
        toastContainer.style.zIndex = "1100";
        document.body.appendChild(toastContainer);
    }

    cartButtons.forEach(btn => {
        btn.addEventListener("click", (e) => {
            e.preventDefault();
            e.stopPropagation();
            
            const courseId = btn.getAttribute("data-course-id");
            if (!courseId) {
                console.error("Course ID is missing on the button.");
                return;
            }

            btn.disabled = true;

            fetch(`/api/cart/add?courseId=${courseId}`, {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                btn.disabled = false;
                if (data.success) {
                    // Update cart count
                    if (cartBadge) {
                        cartBadge.textContent = data.cartSize;
                        cartBadge.classList.remove("d-none");
                        
                        // Visual bounce animation for the badge
                        cartBadge.style.transform = 'scale(1.4)';
                        setTimeout(() => {
                            cartBadge.style.transform = '';
                        }, 300);
                    }

                    // Get course title
                    const card = btn.closest(".card");
                    const title = card ? card.querySelector(".course-card-title").textContent.trim() : "Khóa học";
                    if (data.message && data.message.includes("có sẵn")) {
                        showToast(data.message);
                    } else {
                        showToast(`Đã thêm khóa học "${title}" vào giỏ hàng thành công!`);
                    }
                } else {
                    alert(data.message || 'Không thể thêm vào giỏ hàng.');
                }
            })
            .catch(err => {
                btn.disabled = false;
                console.error('Error adding course to cart:', err);
                alert('Có lỗi xảy ra khi thêm vào giỏ hàng.');
            });
        });
    });
}

function showToast(message) {
    const toastContainer = document.querySelector(".toast-container");
    
    // Toast Element
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
    
    // Initialize Lucide icon inside the new toast
    if (typeof lucide !== 'undefined') {
        lucide.createIcons({
            attrs: {
                class: 'lucide-icon'
            },
            nameAttr: 'data-lucide',
            node: toastElement
        });
    }

    // Initialize Bootstrap Toast
    const bsToast = new bootstrap.Toast(toastElement, {
        delay: 3000
    });
    bsToast.show();
    
    // Remove from DOM after hidden
    toastElement.addEventListener("hidden.bs.toast", () => {
        toastElement.remove();
    });
}
