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
                    window.location.href = `courses.html?search=${encodeURIComponent(query)}`;
                }
            }
        });
    }
}

// Shopping Cart Actions
function initializeCartButtons() {
    const cartButtons = document.querySelectorAll(".btn-cart");
    
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
            
            // Get course title
            const card = btn.closest(".card");
            const title = card.querySelector(".course-card-title").textContent.trim();
            
            // Show Success Toast
            showToast(title);
        });
    });
}

function showToast(courseTitle) {
    const toastContainer = document.querySelector(".toast-container");
    
    // Toast Element
    const toastId = "toast-" + Date.now();
    const toastHtml = `
        <div id="${toastId}" class="toast align-items-center text-white bg-success border-0 shadow-lg" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body d-flex align-items-center gap-2">
                    <i data-lucide="check-circle" style="width: 18px; height: 18px;"></i>
                    <span>Đã thêm <strong>${courseTitle}</strong> vào giỏ hàng thành công!</span>
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
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
        delay: 3500
    });
    bsToast.show();
    
    // Remove from DOM after hidden
    toastElement.addEventListener("hidden.bs.toast", () => {
        toastElement.remove();
    });
}
