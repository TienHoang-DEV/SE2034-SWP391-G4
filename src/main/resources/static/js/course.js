// Global State for Pagination, Sorting, and Filtering
let currentPage = 1;
const itemsPerPage = 4;
let selectedCategoryId = null;

// Initialize Lucide Icons and components
document.addEventListener("DOMContentLoaded", () => {
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
    
    initializeFilters();
    initializeSorting();
    initializeCartButtons();
    initializeSearch();
    
    // Initial load: sort, filter and paginate without showing loading animation
    updateCourses(false);
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
    const ratingCheckboxes = document.querySelectorAll(".filter-rating-checkbox");
    const priceCheckboxes = document.querySelectorAll(".filter-price-checkbox");
    const categoryLinks = document.querySelectorAll(".filter-category-link");

    // Attach change event listeners to checkboxes
    ratingCheckboxes.forEach(cb => {
        cb.addEventListener("change", () => {
            currentPage = 1; // Reset to page 1 on filter change
            updateCourses(true);
        });
    });

    priceCheckboxes.forEach(cb => {
        cb.addEventListener("change", () => {
            currentPage = 1; // Reset to page 1 on filter change
            updateCourses(true);
        });
    });

    // Category links interaction
    categoryLinks.forEach(link => {
        link.addEventListener("click", (e) => {
            e.preventDefault();
            
            const catId = parseInt(link.getAttribute("data-category-id"));
            
            if (link.classList.contains("active-category")) {
                link.classList.remove("active-category");
                link.classList.add("text-muted");
                selectedCategoryId = null;
            } else {
                categoryLinks.forEach(l => {
                    l.classList.remove("active-category");
                    l.classList.add("text-muted");
                });
                link.classList.add("active-category");
                link.classList.remove("text-muted");
                selectedCategoryId = catId;
            }
            
            currentPage = 1; // Reset to page 1 on category change
            updateCourses(true);
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
    const cartBadge = document.getElementById("cart-badge-count");

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
                        
                        // Visual bounce animation for the badge
                        cartBadge.style.transform = 'scale(1.4)';
                        setTimeout(() => {
                            cartBadge.style.transform = '';
                        }, 300);
                    }

                    // Get course title
                    const itemRow = btn.closest(".course-list-item");
                    const title = itemRow ? itemRow.querySelector(".course-item-title").textContent.trim() : "Khóa học";
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

// Sorting event listener initialization
function initializeSorting() {
    const sortSelect = document.getElementById("sort-select");
    if (!sortSelect) return;
    sortSelect.addEventListener("change", () => {
        currentPage = 1; // Reset to page 1 on sorting change
        updateCourses(true);
    });
}

// Global Core Logic: Unified Sorting, Filtering, and Pagination
function updateCourses(runLoading = true) {
    const sortSelect = document.getElementById("sort-select");
    const courseContainer = document.querySelector("section.col-lg-9 > .d-flex.flex-column");
    if (!courseContainer) return;

    const courseItems = Array.from(document.querySelectorAll(".course-list-item"));
    const ratingCheckboxes = document.querySelectorAll(".filter-rating-checkbox");
    const priceCheckboxes = document.querySelectorAll(".filter-price-checkbox");
    const resultCountSpan = document.querySelector(".search-result-title + span");

    // 1. Client-Side Sorting
    const sortBy = sortSelect ? sortSelect.value : "newest";
    courseItems.sort((a, b) => {
        if (sortBy === "newest") {
            const idA = parseInt(a.getAttribute("data-course-id")) || 0;
            const idB = parseInt(b.getAttribute("data-course-id")) || 0;
            return idB - idA;
        } else if (sortBy === "rating") {
            const ratingA = parseFloat(a.getAttribute("data-rating")) || 0.0;
            const ratingB = parseFloat(b.getAttribute("data-rating")) || 0.0;
            return ratingB - ratingA;
        } else if (sortBy === "price-asc") {
            const priceA = parseFloat(a.getAttribute("data-price")) || 0.0;
            const priceB = parseFloat(b.getAttribute("data-price")) || 0.0;
            return priceA - priceB;
        } else if (sortBy === "price-desc") {
            const priceA = parseFloat(a.getAttribute("data-price")) || 0.0;
            const priceB = parseFloat(b.getAttribute("data-price")) || 0.0;
            return priceB - priceA;
        }
        return 0;
    });

    // Re-append DOM nodes in sorted order
    courseItems.forEach(item => {
        courseContainer.appendChild(item);
    });

    // 2. Client-Side Filtering
    const checkedRatings = Array.from(ratingCheckboxes)
        .filter(cb => cb.checked)
        .map(cb => parseInt(cb.value));

    const checkedPrices = Array.from(priceCheckboxes)
        .filter(cb => cb.checked)
        .map(cb => {
            const parts = cb.value.split("-");
            return {
                min: parseFloat(parts[0]),
                max: parseFloat(parts[1])
            };
        });

    let matchedItems = [];

    courseItems.forEach(item => {
        const rating = parseFloat(item.getAttribute("data-rating")) || 0.0;
        const price = parseFloat(item.getAttribute("data-price")) || 0.0;
        const categoryId = parseInt(item.getAttribute("data-category-id")) || null;

        // Rating Filter Match
        let ratingMatch = true;
        if (checkedRatings.length > 0) {
            ratingMatch = checkedRatings.some(r => {
                if (r === 5) return rating >= 5.0;
                return rating >= r && rating < r + 1;
            });
        }

        // Price Filter Match
        let priceMatch = true;
        if (checkedPrices.length > 0) {
            priceMatch = checkedPrices.some(range => {
                return price >= range.min && price <= range.max;
            });
        }

        // Category Filter Match
        let categoryMatch = true;
        if (selectedCategoryId !== null) {
            categoryMatch = (categoryId === selectedCategoryId);
        }

        // Set layout visibility
        if (ratingMatch && priceMatch && categoryMatch) {
            matchedItems.push(item);
        } else {
            item.style.setProperty("display", "none", "important");
        }
    });

    // Update result count text
    if (resultCountSpan) {
        resultCountSpan.textContent = `${matchedItems.length} khóa học`;
    }

    // 3. Client-Side Pagination (5 courses per page)
    const totalMatches = matchedItems.length;
    const totalPages = Math.ceil(totalMatches / itemsPerPage) || 1;

    // Safety checks for current page bounds
    if (currentPage > totalPages) {
        currentPage = totalPages;
    }
    if (currentPage < 1) {
        currentPage = 1;
    }

    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;

    matchedItems.forEach((item, index) => {
        if (index >= startIndex && index < endIndex) {
            item.style.setProperty("display", "flex", "important");
        } else {
            item.style.setProperty("display", "none", "important");
        }
    });

    // Trigger overlay fade animation
    if (runLoading) {
        simulateLoading();
    }

    // 4. Dynamically Render Pagination UI
    renderPagination(totalPages);
}

// Render dynamic pagination controls
function renderPagination(totalPages) {
    const paginationContainer = document.querySelector(".pagination");
    if (!paginationContainer) return;

    // Clear old static items
    paginationContainer.innerHTML = "";

    if (totalPages <= 1) {
        // Render single active page 1
        const li = document.createElement("li");
        li.className = "page-item active";
        li.innerHTML = `<a class="page-link rounded-circle d-flex align-items-center justify-content-center p-0 fw-bold page-num-btn text-white" href="#">1</a>`;
        paginationContainer.appendChild(li);
        li.querySelector("a").addEventListener("click", (e) => e.preventDefault());
        return;
    }

    const pageNumbers = [];
    if (totalPages <= 7) {
        for (let i = 1; i <= totalPages; i++) {
            pageNumbers.push(i);
        }
    } else {
        // Page 1
        pageNumbers.push(1);

        if (currentPage > 3) {
            pageNumbers.push("...");
        }

        // Neighbors around active page
        const start = Math.max(2, currentPage - 1);
        const end = Math.min(totalPages - 1, currentPage + 1);

        for (let i = start; i <= end; i++) {
            if (!pageNumbers.includes(i)) {
                pageNumbers.push(i);
            }
        }

        if (currentPage < totalPages - 2) {
            pageNumbers.push("...");
        }

        // Last page
        if (!pageNumbers.includes(totalPages)) {
            pageNumbers.push(totalPages);
        }
    }

    // Generate elements & bind click event listeners
    pageNumbers.forEach(page => {
        const li = document.createElement("li");
        if (page === "...") {
            li.className = "page-item disabled";
            li.innerHTML = `<span class="page-link rounded-circle d-flex align-items-center justify-content-center p-0 border-0 bg-transparent text-muted fw-semibold" style="width: 38px; height: 38px;">...</span>`;
        } else if (page === currentPage) {
            li.className = "page-item active";
            li.innerHTML = `<a class="page-link rounded-circle d-flex align-items-center justify-content-center p-0 fw-bold page-num-btn text-white" href="#">${page}</a>`;
            li.querySelector("a").addEventListener("click", (e) => e.preventDefault());
        } else {
            li.className = "page-item";
            li.innerHTML = `<a class="page-link rounded-circle d-flex align-items-center justify-content-center p-0 fw-semibold page-num-btn text-dark" href="#">${page}</a>`;
            li.querySelector("a").addEventListener("click", (e) => {
                e.preventDefault();
                currentPage = page;
                updateCourses(true);
                
                // Smooth scroll to top of list
                const header = document.querySelector(".search-result-title");
                if (header) {
                    header.scrollIntoView({ behavior: "smooth" });
                }
            });
        }
        paginationContainer.appendChild(li);
    });
}
