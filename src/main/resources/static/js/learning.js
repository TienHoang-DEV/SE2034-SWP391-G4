// Course Player JS

document.addEventListener("DOMContentLoaded", () => {
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

    initializeTabs();
    initializeVideoPlayer();
    initializeReviewsSelector();
    initializeQuizOptions();
    initializeSidebarToggle();
});

// 1. Tab Panels Switching
function initializeTabs() {
    const tabs = {
        'tab-overview-btn': 'panel-overview',
        'tab-reviews-btn': 'panel-reviews',
        'tab-quiz-btn': 'panel-quiz'
    };

    const tabBtns = document.querySelectorAll(".player-nav-tabs .nav-link");
    const panels = document.querySelectorAll(".tab-panel-item");

    tabBtns.forEach(btn => {
        btn.addEventListener("click", () => {
            const targetPanelId = tabs[btn.id];
            if (!targetPanelId) return;

            // Remove active classes
            tabBtns.forEach(b => b.classList.remove("active"));
            panels.forEach(p => p.classList.add("d-none"));

            // Activate current
            btn.classList.add("active");
            document.getElementById(targetPanelId).classList.remove("d-none");
        });
    });
}

// 2. Load real lesson video from temporary backend endpoint
function initializeVideoPlayer() {
    const videoEl = document.getElementById("lesson-video");
    const statusEl = document.getElementById("lesson-video-status");

    if (!videoEl) {
        return;
    }

    if (statusEl) {
        statusEl.textContent = "Dang tai video...";
    }

    fetch("/temp/video/first-course-first-lesson/url")
        .then((response) => {
            if (!response.ok) {
                throw new Error("Khong the lay URL video");
            }
            return response.json();
        })
        .then((data) => {
            if (!data.videoUrl) {
                throw new Error("Phan hoi khong co videoUrl");
            }

            videoEl.src = data.videoUrl;
            videoEl.load();

            if (statusEl) {
                statusEl.textContent = "Da nap video";
                setTimeout(() => {
                    statusEl.textContent = "";
                }, 2000);
            }
        })
        .catch((error) => {
            if (statusEl) {
                statusEl.textContent = "Khong tai duoc video";
            }
            console.error(error);
        });
}

// 3. Satisfying Reviews Stars selector
function initializeReviewsSelector() {
    const stars = document.querySelectorAll(".star-selector-btn");
    const btnSubmit = document.getElementById("btn-submit-review");
    const textarea = document.getElementById("feedback-textarea");
    let currentRating = 0;

    stars.forEach(star => {
        star.addEventListener("click", () => {
            const val = parseInt(star.getAttribute("data-value"));
            currentRating = val;
            
            // Color stars up to val
            stars.forEach((s, idx) => {
                if (idx < val) {
                    s.classList.add("star-active", "text-warning");
                    s.classList.remove("text-muted-light");
                } else {
                    s.classList.remove("star-active", "text-warning");
                    s.classList.add("text-muted-light");
                }
            });
        });
    });

    if (btnSubmit) {
        btnSubmit.addEventListener("click", () => {
            if (currentRating === 0) {
                alert("Vui lòng chọn mức độ hài lòng của bạn bằng cách click vào các ngôi sao!");
                return;
            }
            
            const comment = textarea.value.trim();
            if (!comment) {
                alert("Vui lòng viết phản hồi/nhận xét trước khi gửi!");
                return;
            }

            // Show simulated success toast
            alert(`Cảm ơn phản hồi của bạn! Đã ghi nhận đánh giá ${currentRating} sao thành công.`);
            
            // Reset form
            currentRating = 0;
            stars.forEach(s => {
                s.classList.remove("star-active", "text-warning");
                s.classList.add("text-muted-light");
            });
            textarea.value = "";
        });
    }
}

// 4. Quiz selections toggle styles
function initializeQuizOptions() {
    const options = document.querySelectorAll(".quiz-option");
    
    options.forEach(opt => {
        const radio = opt.querySelector("input[type='radio']");
        if (!radio) return;

        opt.addEventListener("click", () => {
            // Find sibling options for the same question name
            const name = radio.getAttribute("name");
            const siblings = document.querySelectorAll(`input[name='${name}']`);

            siblings.forEach(sib => {
                const parent = sib.closest(".quiz-option");
                if (parent) parent.classList.remove("active-option");
            });

            // Active current
            opt.classList.add("active-option");
            radio.checked = true;
        });
    });

    const submitQuizBtn = document.getElementById("btn-submit-quiz");
    if (submitQuizBtn) {
        submitQuizBtn.addEventListener("click", () => {
            // Mock answer key database
            const correctAnswers = {
                q1: 'a',
                q2: 'c',
                q3: 'b'
            };

            let score = 0;
            const totalQuestions = Object.keys(correctAnswers).length;
            let answeredCount = 0;

            for (const qName of Object.keys(correctAnswers)) {
                const selectedOption = document.querySelector(`input[name='${qName}']:checked`);
                if (selectedOption) {
                    answeredCount++;
                }
            }

            if (answeredCount < totalQuestions) {
                alert(`Bạn chưa trả lời hết các câu hỏi! Vui lòng hoàn thành tất cả ${totalQuestions} câu hỏi trước khi nộp bài.`);
                return;
            }

            // Remove previous validation styles
            document.querySelectorAll(".quiz-option").forEach(opt => {
                opt.classList.remove("correct-option", "incorrect-option", "active-option");
            });

            // Highlight results
            for (const [qName, correctVal] of Object.entries(correctAnswers)) {
                const selectedOption = document.querySelector(`input[name='${qName}']:checked`);
                const correctOptionInput = document.querySelector(`input[name='${qName}'][value='${correctVal}']`);
                
                // Color correct option in green
                if (correctOptionInput) {
                    const correctLabel = correctOptionInput.closest(".quiz-option");
                    if (correctLabel) correctLabel.classList.add("correct-option");
                }

                // If selected option is wrong, color it in red
                if (selectedOption && selectedOption.value !== correctVal) {
                    const incorrectLabel = selectedOption.closest(".quiz-option");
                    if (incorrectLabel) incorrectLabel.classList.add("incorrect-option");
                } else if (selectedOption && selectedOption.value === correctVal) {
                    score++;
                }
            }

            // Display score banner above Question 1
            const quizPanel = document.getElementById("panel-quiz");
            const firstQuestionBox = quizPanel.querySelector(".quiz-question-box");
            
            let banner = document.querySelector(".quiz-result-banner");
            if (banner) {
                banner.remove();
            }

            banner = document.createElement("div");
            banner.className = "alert alert-success d-flex align-items-center gap-2 mb-4 quiz-result-banner shadow-sm";
            banner.innerHTML = `
                <i data-lucide="check-circle-2" style="width: 18px; height: 18px; color: #15803d; fill: #dcfce7;"></i>
                <span class="fs-7" style="color: #15803d; font-weight: 600;">Kết quả bài ôn tập: Bạn đã trả lời đúng ${score}/${totalQuestions} câu hỏi.</span>
            `;

            firstQuestionBox.parentNode.insertBefore(banner, firstQuestionBox);

            if (typeof lucide !== 'undefined') {
                lucide.createIcons({
                    attrs: { class: 'lucide-icon' },
                    node: banner
                });
            }

            // Scroll to banner smoothly
            banner.scrollIntoView({ behavior: 'smooth', block: 'center' });
        });
    }
}

// 5. Sidebar toggling
function initializeSidebarToggle() {
    const toggleBtn = document.getElementById("btn-sidebar-toggle");
    const sidebar = document.querySelector(".sidebar-curriculum-container");
    const mainContent = document.querySelector(".main-player-content");

    if (toggleBtn && sidebar && mainContent) {
        toggleBtn.addEventListener("click", () => {
            sidebar.classList.toggle("d-none");
            
            // Adjust left side width class
            if (sidebar.classList.contains("d-none")) {
                mainContent.className = "col-12 main-player-content";
            } else {
                mainContent.className = "col-lg-8 col-12 main-player-content";
            }
        });
    }
}
