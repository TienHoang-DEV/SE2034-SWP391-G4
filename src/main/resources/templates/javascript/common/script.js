document.addEventListener('DOMContentLoaded', () => {
    // 1. Initialize Lucide Icons
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

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
