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
    const ratingCheckboxes = document.querySelectorAll(".filter-rating-checkbox");
    const priceCheckboxes = document.querySelectorAll(".filter-price-checkbox");
    const courseItems = document.querySelectorAll(".course-list-item");
    const resultCountSpan = document.querySelector(".search-result-title + span"); // The "128 khóa học" text
    const tagLinks = document.querySelectorAll(".filter-tag-link");

    function filterCourses() {
        // Collect checked ratings
        const checkedRatings = Array.from(ratingCheckboxes)
            .filter(cb => cb.checked)
            .map(cb => parseInt(cb.value));

        // Collect checked price ranges
        const checkedPrices = Array.from(priceCheckboxes)
            .filter(cb => cb.checked)
            .map(cb => {
                const parts = cb.value.split("-");
                return {
                    min: parseFloat(parts[0]),
                    max: parseFloat(parts[1])
                };
            });

        let visibleCount = 0;

        courseItems.forEach(item => {
            const rating = parseFloat(item.getAttribute("data-rating")) || 0.0;
            const price = parseFloat(item.getAttribute("data-price")) || 0.0;

            // Rating Filter Match
            // Match rating ranges: R star checkbox matches rating in [R, R+1) (or >= 5.0 for 5 star)
            let ratingMatch = true;
            if (checkedRatings.length > 0) {
                ratingMatch = checkedRatings.some(r => {
                    if (r === 5) {
                        return rating >= 5.0;
                    }
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

            // Apply visibility
            if (ratingMatch && priceMatch) {
                item.style.setProperty("display", "flex", "important");
                visibleCount++;
            } else {
                item.style.setProperty("display", "none", "important");
            }
        });

        // Update the count in the header
        if (resultCountSpan) {
            resultCountSpan.textContent = `${visibleCount} khóa học`;
        }
    }

    // Attach change event listeners to checkboxes
    ratingCheckboxes.forEach(cb => {
        cb.addEventListener("change", () => {
            simulateLoading();
            filterCourses();
        });
    });

    priceCheckboxes.forEach(cb => {
        cb.addEventListener("change", () => {
            simulateLoading();
            filterCourses();
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

    // Run initial filter (just in case browser remembers checkbox state on reload)
    filterCourses();
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

                    // Show Success Toast with custom backend message
                    showToast(data.message);
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
        <div id="${toastId}" class="toast align-items-center text-white bg-success border-0 shadow-lg" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body d-flex align-items-center gap-2">
                    <i data-lucide="check-circle" style="width: 18px; height: 18px;"></i>
                    <span>${message}</span>
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
