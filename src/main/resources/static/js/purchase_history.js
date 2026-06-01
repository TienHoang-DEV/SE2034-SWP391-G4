// Purchase History JavaScript

document.addEventListener("DOMContentLoaded", () => {
    // Initialize Lucide Icons
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
    
    initializeCollapseListeners();
    initializeSearchRedirect();
});

// Listener to change button text & icon when collapse events occur
function initializeCollapseListeners() {
    const collapsibleElements = document.querySelectorAll('.collapse');
    
    collapsibleElements.forEach(collapseEl => {
        const id = collapseEl.getAttribute('id');
        const button = document.querySelector(`[data-bs-target="#${id}"]`);
        
        if (button) {
            // Event when collapse element has finished showing
            collapseEl.addEventListener('show.bs.collapse', () => {
                const label = button.querySelector('span');
                if (label) label.textContent = 'Ẩn chi tiết';
                
                // Update icon with Lucide
                updateIcon(button, 'chevron-up');
            });
            
            // Event when collapse element has finished hiding
            collapseEl.addEventListener('hide.bs.collapse', () => {
                const label = button.querySelector('span');
                if (label) label.textContent = 'Xem chi tiết';
                
                // Update icon with Lucide
                updateIcon(button, 'chevron-down');
            });
        }
    });
}

// Function to dynamically replace lucide icon
function updateIcon(button, iconName) {
    const iconContainer = button.querySelector('.toggle-icon');
    if (iconContainer) {
        // Create new replacement tag
        const newIcon = document.createElement('i');
        newIcon.setAttribute('data-lucide', iconName);
        newIcon.className = 'toggle-icon';
        newIcon.style.width = '14px';
        newIcon.style.height = '14px';
        
        iconContainer.parentNode.replaceChild(newIcon, iconContainer);
        
        // Re-execute Lucide render on this element
        if (typeof lucide !== 'undefined') {
            lucide.createIcons({
                attrs: {
                    class: 'toggle-icon'
                },
                nameAttr: 'data-lucide',
                node: button
            });
        }
    }
}

// Search bar input handling
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
