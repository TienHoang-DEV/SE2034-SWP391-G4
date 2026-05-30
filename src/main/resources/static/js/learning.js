// Course Player JS

document.addEventListener("DOMContentLoaded", () => {
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

    initializeTabs();
    initializeVideoPlayer();
    initializeMaterial();
    initializeLessonDocumentLinks();
    initializeQuizOptions();
    initializeSidebarToggle();
});

// 1. Tab Panels Switching
function initializeTabs() {
    const tabs = {
        'tab-overview-btn': 'panel-overview',
        'tab-quiz-btn': 'panel-quiz',
        'tab-document-btn': 'panel-document'
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

function initializeMaterial() {
    const frame = document.getElementById("lesson-document-frame");
    const openLink = document.getElementById("btn-open-lesson-document");
    const downloadLink = document.getElementById("btn-download-lesson-document");

    fetch("/temp/material/first-course-first-lesson/url").then(response => {
        if (!response.ok) throw new Error("Khong the lay du lieu");
        return response.text();
    }).then(sasUrl => {
       frame.src = sasUrl;
    }).catch(err => console.error("Loi tai tai lieu:", err));
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
            return response.text();
        })
        .then((videoUrl) => {
            if (!videoUrl) {
                throw new Error("Khong nhan duoc video URL");
            }

            videoEl.src = videoUrl;
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



// 4. Open document tab from lesson list links
function initializeLessonDocumentLinks() {
    const documentLinks = document.querySelectorAll(".lesson-document-link");
    const documentTab = document.getElementById("tab-document-btn");

    if (!documentTab) return;

    documentLinks.forEach(link => {
        link.addEventListener("click", (event) => {
            event.preventDefault();
            documentTab.click();
            document.getElementById("player-tab-content")?.scrollIntoView({
                behavior: "smooth",
                block: "start"
            });
        });
    });
}

// 5. Quiz selections toggle styles
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

// 6. Sidebar toggling
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
