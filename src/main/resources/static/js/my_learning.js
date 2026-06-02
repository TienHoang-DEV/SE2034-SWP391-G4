// Initialize Lucide Icons
document.addEventListener("DOMContentLoaded", () => {
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
    
    initializeFilters();
    initializePagination();
    initializeExploreCard();
    initializeSearchRedirect();
    initializeCourseCardClicks();
});

function initializeCourseCardClicks() {
    const wrappers = document.querySelectorAll(".course-card-wrapper");
    wrappers.forEach(wrapper => {
        const card = wrapper.querySelector(".course-card");
        const courseId = wrapper.getAttribute("data-course-id");
        if (card && courseId) {
            card.style.cursor = "pointer";
            card.addEventListener("click", (e) => {
                // If user clicks a link inside the card, don't trigger wrapper click
                if (e.target.closest("a") || e.target.closest("button")) {
                    return;
                }
                window.location.href = `/course/${courseId}`;
            });
        }
    });
}

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

// Filter Functionality
function initializeFilters() {
    const btnFilterAll = document.getElementById("btn-filter-all");
    const btnFilterIncomplete = document.getElementById("btn-filter-incomplete");
    const courseCards = document.querySelectorAll(".course-card-wrapper");
    const exploreCard = document.querySelector(".explore-card-wrapper");
    const totalBadge = document.querySelector(".total-courses-badge");

    if (!btnFilterAll || !btnFilterIncomplete) return;

    btnFilterAll.addEventListener("click", () => {
        // Toggle active button states
        btnFilterAll.className = "btn btn-primary rounded-pill px-4 py-2 fs-7 fw-semibold active-filter";
        btnFilterIncomplete.className = "btn btn-outline-secondary rounded-pill px-4 py-2 fs-7 fw-semibold text-dark outline-filter";
        
        // Show all courses and explore card
        courseCards.forEach(card => card.style.display = "block");
        if (exploreCard) exploreCard.style.display = "block";
        
        // Update stats badge
        if (totalBadge) totalBadge.textContent = `Tổng: ${courseCards.length} khóa học`;
    });

    btnFilterIncomplete.addEventListener("click", () => {
        // Toggle active button states
        btnFilterIncomplete.className = "btn btn-primary rounded-pill px-4 py-2 fs-7 fw-semibold active-filter";
        btnFilterAll.className = "btn btn-outline-secondary rounded-pill px-4 py-2 fs-7 fw-semibold text-dark outline-filter";
        
        // Filter courses: hide completed ones (none in this demo, but let's hide the explore card to make the view change)
        let visibleCount = 0;
        courseCards.forEach(card => {
            const isCompleted = card.getAttribute("data-completed") === "true";
            if (!isCompleted) {
                card.style.display = "block";
                visibleCount++;
            } else {
                card.style.display = "none";
            }
        });
        
        // Let's hide the explore card in the incomplete tab for a cleaner layout
        if (exploreCard) exploreCard.style.display = "none";
        
        // Update stats badge
        if (totalBadge) totalBadge.textContent = `Tổng: ${visibleCount} khóa học`;
    });
}

// Pagination Controls Mock
function initializePagination() {
    const pageItems = document.querySelectorAll(".pagination .page-item");
    
    pageItems.forEach((item, index) => {
        const link = item.querySelector("a");
        if (!link) return;
        
        link.addEventListener("click", (e) => {
            e.preventDefault();
            
            // Check if it's prev or next or numbers
            const isPrev = item.querySelector("[aria-label='Previous']");
            const isNext = item.querySelector("[aria-label='Next']");
            const isNumber = !isPrev && !isNext;
            
            if (isNumber) {
                // Deactivate all page numbers
                pageItems.forEach(pi => {
                    if (!pi.querySelector("[aria-label='Previous']") && !pi.querySelector("[aria-label='Next']")) {
                        pi.classList.remove("active");
                        const a = pi.querySelector("a");
                        if (a) {
                            a.className = "page-link rounded-circle d-flex align-items-center justify-content-center p-0 fw-semibold page-num-btn text-dark";
                        }
                    }
                });
                
                // Activate clicked page number
                item.classList.add("active");
                link.className = "page-link rounded-circle d-flex align-items-center justify-content-center p-0 fw-bold page-num-btn text-white";
            }
        });
    });
}

// Explore Card interaction
function initializeExploreCard() {
    const exploreCard = document.querySelector(".explore-card");
    if (exploreCard) {
        exploreCard.addEventListener("click", (e) => {
            e.preventDefault();
            window.location.href = "/courses";
        });
    }
}
