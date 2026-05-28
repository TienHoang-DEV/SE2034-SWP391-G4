// Initialize Lucide Icons
document.addEventListener("DOMContentLoaded", () => {
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
    
    initializeFilters();
    initializeCartButtons();
    initializePagination();
    initializeSearch();
});

// Search input interaction
function initializeSearch() {
    const searchInput = document.getElementById("search-input");
    if (!searchInput) return;
    
    searchInput.addEventListener("keypress", (e) => {
        if (e.key === "Enter") {
            const query = searchInput.value.trim();
            if (query) {
                const headerTitle = document.querySelector(".search-result-title");
                if (headerTitle) {
                    headerTitle.textContent = `Kết quả cho "${query}"`;
                }
                simulateLoading();
            }
        }
    });
}

// Sidebar filter actions simulation
function initializeFilters() {
    const checkboxes = document.querySelectorAll(".sidebar-filters input[type='checkbox']");
    const tagLinks = document.querySelectorAll(".filter-tag-link");
    const courseListItems = document.querySelectorAll(".course-list-item");
    
    // Checkboxes toggle simulation
    checkboxes.forEach(box => {
        box.addEventListener("change", () => {
            simulateLoading();
        });
    });

    // Tag links toggle simulation
    tagLinks.forEach(link => {
        link.addEventListener("click", (e) => {
            e.preventDefault();
            
            // Toggle active classes
            tagLinks.forEach(l => {
                l.className = "filter-tag-link text-decoration-none d-block text-muted";
            });
            link.className = "filter-tag-link text-decoration-none d-block active-tag";
            
            simulateLoading();
        });
    });
}

function simulateLoading() {
    const courseListContainer = document.querySelector("section.col-lg-9 > .d-flex.flex-column");
    if (!courseListContainer) return;
    
    // Add opacity transition
    courseListContainer.style.transition = "opacity 0.25s ease";
    courseListContainer.style.opacity = "0.4";
    
    setTimeout(() => {
        courseListContainer.style.opacity = "1";
    }, 300);
}

// Shopping Cart Actions
function initializeCartButtons() {
    const cartButtons = document.querySelectorAll(".btn-add-to-cart");
    
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
            const listItem = btn.closest(".course-list-item");
            const title = listItem.querySelector(".course-item-title").textContent.trim();
            
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

// Mock Pagination Numbers Click
function initializePagination() {
    const paginationItems = document.querySelectorAll(".pagination .page-item");
    
    paginationItems.forEach(item => {
        const link = item.querySelector("a");
        if (!link) return;
        
        link.addEventListener("click", (e) => {
            e.preventDefault();
            
            paginationItems.forEach(pi => {
                pi.classList.remove("active");
                const a = pi.querySelector("a");
                if (a) {
                    a.className = "page-link rounded-circle d-flex align-items-center justify-content-center p-0 fw-semibold page-num-btn text-dark";
                }
            });
            
            item.classList.add("active");
            link.className = "page-link rounded-circle d-flex align-items-center justify-content-center p-0 fw-bold page-num-btn text-white";
            
            simulateLoading();
        });
    });
}
