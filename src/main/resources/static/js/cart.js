// Shopping Cart JS Logic
document.addEventListener("DOMContentLoaded", () => {
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
    
    loadCartStateFromDOM();
    initializeCheckboxes();
    initializeRemoveButtons();
    initializeInstructorVouchers();
    initializeCheckoutButton();
    
    // Initial calculation
    updateInvoice();
});

// Mock Prices State (Initialized from DOM dynamically)
let cartState = {
    items: [],
    instructorCoupons: {
        "Thanh": { code: "THANH10", rate: 0.10, applied: false },
        "Hoang": { code: "HOANG15", rate: 0.15, applied: false }
    }
};

// 0. Parse cart rows from Thymeleaf-rendered DOM
function loadCartStateFromDOM() {
    const itemRows = document.querySelectorAll(".cart-item-row");
    cartState.items = [];
    itemRows.forEach(row => {
        const id = row.getAttribute("id");
        const price = Math.round(parseFloat(row.getAttribute("data-price"))) || 0;
        const discount = Math.round(parseFloat(row.getAttribute("data-discount"))) || 0;
        const instructor = row.getAttribute("data-instructor");
        const checkbox = row.querySelector(".item-checkbox");
        const selected = checkbox ? checkbox.checked : true;
        
        cartState.items.push({ id, price, discount, instructor, selected });
        
        if (instructor && !cartState.instructorCoupons[instructor]) {
            cartState.instructorCoupons[instructor] = {
                code: instructor.toUpperCase() + "10",
                rate: 0.10,
                applied: false
            };
        }
    });
}

// 1. Checkbox Interaction Logic (Multi-level Synchronization)
function initializeCheckboxes() {
    const globalCheckbox = document.getElementById("select-all-checkout");
    const instructorCheckboxes = document.querySelectorAll(".instructor-checkbox");
    const itemCheckboxes = document.querySelectorAll(".item-checkbox");

    if (!globalCheckbox) return;

    // A. Global Checkbox Event
    globalCheckbox.addEventListener("change", (e) => {
        const checkedStatus = e.target.checked;
        
        // Update all items in state
        cartState.items.forEach(item => {
            item.selected = checkedStatus;
        });

        // Update all checkbox elements in DOM
        itemCheckboxes.forEach(cb => {
            cb.checked = checkedStatus;
        });

        instructorCheckboxes.forEach(cb => {
            cb.checked = checkedStatus;
        });

        updateInvoice();
    });

    // B. Instructor Group Checkbox Event
    instructorCheckboxes.forEach(instCb => {
        instCb.addEventListener("change", (e) => {
            const instructor = instCb.getAttribute("data-instructor");
            const checkedStatus = e.target.checked;

            // Update all items of this instructor in state
            cartState.items.forEach(item => {
                if (item.instructor === instructor) {
                    item.selected = checkedStatus;
                }
            });

            // Update corresponding item checkboxes in DOM
            const siblingItemCbs = document.querySelectorAll(`.item-checkbox[data-instructor="${instructor}"]`);
            siblingItemCbs.forEach(cb => {
                cb.checked = checkedStatus;
            });

            // Sync global checkbox
            syncGlobalCheckbox();
            updateInvoice();
        });
    });

    // C. Individual Item Checkbox Event
    itemCheckboxes.forEach(itemCb => {
        itemCb.addEventListener("change", (e) => {
            const itemId = itemCb.getAttribute("data-id");
            const instructor = itemCb.getAttribute("data-instructor");
            const checkedStatus = e.target.checked;

            // Update individual item in state
            const targetItem = cartState.items.find(item => item.id === itemId);
            if (targetItem) {
                targetItem.selected = checkedStatus;
            }

            // Sync instructor checkbox
            syncInstructorCheckbox(instructor);
            
            // Sync global checkbox
            syncGlobalCheckbox();
            
            updateInvoice();
        });
    });

    // Helper: Sync single instructor checkbox based on its courses
    function syncInstructorCheckbox(instructor) {
        const instructorCb = document.querySelector(`.instructor-checkbox[data-instructor="${instructor}"]`);
        if (!instructorCb) return;

        const instructorItems = cartState.items.filter(item => item.instructor === instructor);
        const allChecked = instructorItems.every(item => item.selected);
        const noneChecked = instructorItems.every(item => !item.selected);

        if (allChecked) {
            instructorCb.checked = true;
            instructorCb.indeterminate = false;
        } else if (noneChecked) {
            instructorCb.checked = false;
            instructorCb.indeterminate = false;
        } else {
            instructorCb.checked = false;
            instructorCb.indeterminate = true; // partial state
        }
    }

    // Helper: Sync global checkbox based on all items in cart
    function syncGlobalCheckbox() {
        const allItemsSelected = cartState.items.every(item => item.selected);
        const noItemsSelected = cartState.items.every(item => !item.selected);

        if (allItemsSelected) {
            globalCheckbox.checked = true;
            globalCheckbox.indeterminate = false;
        } else if (noItemsSelected) {
            globalCheckbox.checked = false;
            globalCheckbox.indeterminate = false;
        } else {
            globalCheckbox.checked = false;
            globalCheckbox.indeterminate = true;
        }
    }
}

// 2. Remove Items and Groups Logic
function initializeRemoveButtons() {
    const removeBtns = document.querySelectorAll(".btn-remove-item");
    
    removeBtns.forEach(btn => {
        btn.addEventListener("click", () => {
            const cartItemId = btn.getAttribute("data-item-id");
            if (!cartItemId) {
                console.error("Cart item database ID is missing.");
                return;
            }

            btn.disabled = true;

            fetch(`/api/cart/remove?cartItemId=${cartItemId}`, {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                btn.disabled = false;
                if (data.success) {
                    const targetId = btn.getAttribute("data-target");
                    const targetElement = document.getElementById(targetId);
                    
                    if (targetElement) {
                        // Add fade out animation to the item row
                        targetElement.classList.add("fade-out-item");
                        
                        // Wait for item row animation to finish
                        setTimeout(() => {
                            const targetItem = cartState.items.find(item => item.id === targetId);
                            const instructor = targetItem ? targetItem.instructor : null;
                            
                            if (targetElement.parentNode) {
                                targetElement.remove();
                            }
                            
                            // Update state
                            cartState.items = cartState.items.filter(item => item.id !== targetId);
                            
                            // Check if there are any courses left under this instructor
                            if (instructor) {
                                const remainingInstructorItems = cartState.items.filter(item => item.instructor === instructor);
                                const groupCard = document.getElementById(`group-${instructor}`);
                                
                                if (remainingInstructorItems.length === 0 && groupCard) {
                                    // Fade out the entire instructor card if no items left
                                    groupCard.classList.add("fade-out-item");
                                    setTimeout(() => {
                                        groupCard.remove();
                                        updateInvoice();
                                    }, 400);
                                    return;
                                } else if (groupCard) {
                                    // Update items count text in instructor header
                                    const countText = groupCard.querySelector(".group-items-count");
                                    if (countText) {
                                        countText.textContent = `${remainingInstructorItems.length} khóa học`;
                                    }
                                }
                            }
                            
                            // Recalculate bill
                            updateInvoice();
                        }, 400);
                    }
                } else {
                    alert(data.message || 'Không thể xóa khóa học.');
                }
            })
            .catch(err => {
                btn.disabled = false;
                console.error('Error removing item:', err);
                alert('Có lỗi xảy ra khi xóa khóa học.');
            });
        });
    });
}

// Helper function to animate text changes on prices
function updateTextWithAnimation(element, newText) {
    if (!element) return;
    if (element.textContent !== newText) {
        element.textContent = newText;
        element.classList.remove("animate-price-change");
        void element.offsetWidth; // Force reflow to re-trigger CSS keyframes
        element.classList.add("animate-price-change");
    }
}

// 3. Invoice Calculator & UI Updater
function updateInvoice() {
    const subtotalText = document.getElementById("summary-subtotal");
    const discountsText = document.getElementById("summary-discounts");
    const instructorDiscountsRow = document.getElementById("instructor-discounts-row");
    const instructorDiscountsText = document.getElementById("summary-instructor-discounts");
    const totalText = document.getElementById("summary-total");
    
    const cartCountBadges = document.querySelectorAll(".cart-count-badge");
    const cartCountBadgeInline = document.querySelector(".cart-count-badge-inline");
    const cartCountText = document.querySelector(".cart-count-text");
    const cartContainer = document.getElementById("cart-items-container");
    const selectAllBar = document.querySelector(".select-all-bar");
    const emptyState = document.getElementById("empty-cart-state");
    const rightSummaryPanel = document.querySelector(".col-lg-4");
    const selectedItemsCountSpan = document.querySelector(".selected-items-count");

    const totalItemCount = cartState.items.length;
    const selectedItems = cartState.items.filter(item => item.selected);
    const selectedItemCount = selectedItems.length;

    // A. Check absolute empty state (0 items in cart)
    if (totalItemCount === 0) {
        if (cartContainer) cartContainer.classList.add("d-none");
        if (selectAllBar) selectAllBar.classList.add("d-none");
        if (emptyState) emptyState.classList.remove("d-none");
        if (rightSummaryPanel) rightSummaryPanel.classList.add("d-none");
        if (cartCountText) cartCountText.textContent = "(0 khóa học)";
        cartCountBadges.forEach(b => b.classList.add("d-none"));
        return;
    }

    // B. Calculate original subtotal & initial course discounts
    let subtotal = 0;
    let courseDiscounts = 0;
    
    selectedItems.forEach(item => {
        subtotal += item.price;
        courseDiscounts += item.discount;
    });

    // C. Calculate Instructor-specific Vouchers (applied per group)
    let totalInstructorDiscount = 0;
    
    // Group selected items by instructor
    const selectedByInstructor = {};
    selectedItems.forEach(item => {
        if (!selectedByInstructor[item.instructor]) {
            selectedByInstructor[item.instructor] = [];
        }
        selectedByInstructor[item.instructor].push(item);
    });

    // Apply instructor rates
    Object.keys(cartState.instructorCoupons).forEach(inst => {
        const coupon = cartState.instructorCoupons[inst];
        const instSelectedItems = selectedByInstructor[inst] || [];

        if (coupon.applied && instSelectedItems.length > 0) {
            // Instructor discount is applied on the subtotal after the course's initial discount
            let instSubtotalAfterDiscount = 0;
            instSelectedItems.forEach(item => {
                instSubtotalAfterDiscount += (item.price - item.discount);
            });

            const instDiscountAmount = Math.round(instSubtotalAfterDiscount * coupon.rate);
            totalInstructorDiscount += instDiscountAmount;

            // Show voucher indicator in group card footer if it exists
            const msgContainer = document.getElementById(`voucher-msg-container-${inst}`);
            const msgElement = document.getElementById(`voucher-msg-${inst}`);
            if (msgContainer && msgElement) {
                msgContainer.classList.remove("d-none");
                msgElement.className = "fs-8 text-success fw-medium";
                msgElement.innerHTML = `<i data-lucide="check" class="d-inline-block me-1" style="width:12px;height:12px;"></i> Áp dụng thành công: Giảm thêm ${formatMoney(instDiscountAmount)} (-${coupon.rate * 100}%)`;
                if (typeof lucide !== 'undefined') {
                    lucide.createIcons();
                }
            }
        } else {
            const msgContainer = document.getElementById(`voucher-msg-container-${inst}`);
            if (msgContainer && instSelectedItems.length === 0) {
                msgContainer.classList.add("d-none");
            }
        }
    });

    // D. Calculate Final Checkout Price
    let total = subtotal - courseDiscounts - totalInstructorDiscount;
    if (total < 0) total = 0;

    // E. Update Right Summary texts with animations
    updateTextWithAnimation(subtotalText, formatMoney(subtotal));
    updateTextWithAnimation(discountsText, `-${formatMoney(courseDiscounts)}`);
    
    if (totalInstructorDiscount > 0) {
        if (instructorDiscountsRow) instructorDiscountsRow.classList.remove("d-none");
        updateTextWithAnimation(instructorDiscountsText, `-${formatMoney(totalInstructorDiscount)}`);
    } else {
        if (instructorDiscountsRow) instructorDiscountsRow.classList.add("d-none");
    }

    updateTextWithAnimation(totalText, formatMoney(total));
    
    // F. Update header count badges & selected counts
    cartCountBadges.forEach(b => {
        b.textContent = totalItemCount;
        b.classList.remove("d-none");
    });
    if (cartCountBadgeInline) cartCountBadgeInline.textContent = totalItemCount;
    if (cartCountText) cartCountText.textContent = `(${totalItemCount} khóa học)`;
    if (selectedItemsCountSpan) selectedItemsCountSpan.textContent = selectedItemCount;

    // Keep checkout button disabled/enabled based on selections
    const checkoutBtn = document.getElementById("btn-checkout");
    if (checkoutBtn) {
        if (selectedItemCount === 0) {
            checkoutBtn.setAttribute("disabled", "true");
            checkoutBtn.classList.add("opacity-50");
            checkoutBtn.style.cursor = "not-allowed";
        } else {
            checkoutBtn.removeAttribute("disabled");
            checkoutBtn.classList.remove("opacity-50");
            checkoutBtn.style.cursor = "pointer";
        }
    }
}

// 4. Instructor Vouchers Application Logic
function initializeInstructorVouchers() {
    const applyBtns = document.querySelectorAll(".btn-apply-instructor-voucher");

    applyBtns.forEach(btn => {
        btn.addEventListener("click", () => {
            const instructor = btn.getAttribute("data-instructor");
            const inputField = document.getElementById(`voucher-input-${instructor}`);
            const msgContainer = document.getElementById(`voucher-msg-container-${instructor}`);
            const msgElement = document.getElementById(`voucher-msg-${instructor}`);
            const successIcon = document.getElementById(`voucher-success-icon-${instructor}`);

            if (!inputField || !msgContainer || !msgElement) return;

            const code = inputField.value.trim().toUpperCase();
            const couponConfig = cartState.instructorCoupons[instructor];

            if (code === "") {
                showMsg(instructor, "Vui lòng nhập mã giảm giá giảng viên!", "text-danger");
                if (successIcon) successIcon.classList.add("d-none");
                return;
            }

            if (code === couponConfig.code) {
                // Check if any course of this instructor is selected in cart
                const hasSelectedItems = cartState.items.some(item => item.instructor === instructor && item.selected);
                
                if (!hasSelectedItems) {
                    showMsg(instructor, `Chọn ít nhất một khóa học của giảng viên ${instructor} để áp dụng!`, "text-warning");
                    if (successIcon) successIcon.classList.add("d-none");
                    return;
                }

                couponConfig.applied = true;
                if (successIcon) {
                    successIcon.classList.remove("d-none");
                    // Trigger popup bounce animation for the success green checkmark
                    successIcon.classList.remove("animate-voucher-success");
                    void successIcon.offsetWidth; // Force reflow
                    successIcon.classList.add("animate-voucher-success");
                }
                updateInvoice(); // This will render success details automatically inside updateInvoice
            } else {
                couponConfig.applied = false;
                if (successIcon) successIcon.classList.add("d-none");
                showMsg(instructor, "Mã giảm giá giảng viên không hợp lệ!", "text-danger");
                updateInvoice();
            }
        });
    });

    function showMsg(instructor, text, className) {
        const msgContainer = document.getElementById(`voucher-msg-container-${instructor}`);
        const msgElement = document.getElementById(`voucher-msg-${instructor}`);
        if (msgContainer && msgElement) {
            msgContainer.classList.remove("d-none");
            msgElement.className = `fs-8 fw-medium ${className}`;
            msgElement.innerHTML = text;
        }
    }
}

// 5. Checkout Button Trigger
function initializeCheckoutButton() {
    const checkoutBtn = document.getElementById("btn-checkout");
    if (checkoutBtn) {
        checkoutBtn.addEventListener("click", () => {
            const selectedItems = cartState.items.filter(item => item.selected);
            if (selectedItems.length === 0) return;

            checkoutBtn.disabled = true;

            fetch("/api/cart/checkout", {
                method: "POST"
            })
            .then(response => response.json())
            .then(data => {
                checkoutBtn.disabled = false;
                if (data.success) {
                    alert(data.message);
                    
                    // Clear cart entirely (or just selected items)
                    cartState.items = cartState.items.filter(item => !item.selected);
                    
                    // Reset instructor coupon applied states
                    Object.keys(cartState.instructorCoupons).forEach(inst => {
                        cartState.instructorCoupons[inst].applied = false;
                        const input = document.getElementById(`voucher-input-${inst}`);
                        if (input) input.value = "";
                        const successIcon = document.getElementById(`voucher-success-icon-${inst}`);
                        if (successIcon) successIcon.classList.add("d-none");
                        const msgContainer = document.getElementById(`voucher-msg-container-${inst}`);
                        if (msgContainer) msgContainer.classList.add("d-none");
                    });

                    // Reset DOM elements of removed groups completely
                    const instructorCards = document.querySelectorAll(".instructor-group-card");
                    instructorCards.forEach(card => {
                        const inst = card.getAttribute("data-instructor");
                        const remainingItems = cartState.items.filter(item => item.instructor === inst);
                        if (remainingItems.length === 0) {
                            card.remove();
                        } else {
                            // Remove checked courses from DOM
                            const checkedCbs = card.querySelectorAll(".item-checkbox:checked");
                            checkedCbs.forEach(cb => {
                                const row = cb.closest(".cart-item-row");
                                if (row) row.remove();
                            });
                            // Reset group items count header text
                            const countText = card.querySelector(".group-items-count");
                            if (countText) {
                                countText.textContent = `${remainingItems.length} khóa học`;
                            }
                            // Reset instructor checkbox status
                            const instCb = card.querySelector(".instructor-checkbox");
                            if (instCb) {
                                instCb.checked = false;
                                instCb.indeterminate = false;
                            }
                        }
                    });

                    // Reset Select All Checkout bar checkbox
                    const globalCheckbox = document.getElementById("select-all-checkout");
                    if (globalCheckbox) {
                        globalCheckbox.checked = false;
                        globalCheckbox.indeterminate = false;
                    }

                    updateInvoice();
                } else {
                    alert(data.message || "Thanh toán thất bại.");
                }
            })
            .catch(err => {
                checkoutBtn.disabled = false;
                console.error("Checkout error:", err);
                alert("Có lỗi xảy ra khi xử lý thanh toán.");
            });
        });
    }
}

// Utility Money Format
function formatMoney(amount) {
    return amount.toLocaleString('vi-VN') + " VNĐ";
}
