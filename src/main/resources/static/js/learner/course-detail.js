// Course Detail JavaScript

class CourseDetail {
    constructor() {
        this.courseId = null;
        this.courseData = null;
        this.initialize();
    }

    initialize() {
        console.log('CourseDetail initialized');
        this.getCourseIdFromURL();
        this.attachEventListeners();
        this.loadCourseData();
    }

    getCourseIdFromURL() {
        const urlParams = new URLSearchParams(window.location.search);
        this.courseId = urlParams.get('id');
        console.log(`Course ID: ${this.courseId}`);
    }

    attachEventListeners() {
        // Start course button
        const startBtn = document.querySelector('.btn-primary.large');
        if (startBtn) {
            startBtn.addEventListener('click', (e) => {
                e.preventDefault();
                this.startCourse();
            });
        }

        // Module headers (collapsible)
        const moduleHeaders = document.querySelectorAll('.module-header');
        moduleHeaders.forEach(header => {
            header.addEventListener('click', () => {
                const module = header.closest('.module');
                this.toggleModule(module);
            });
        });

        // Lesson clicks
        const lessons = document.querySelectorAll('.lesson');
        lessons.forEach(lesson => {
            if (!lesson.classList.contains('locked')) {
                lesson.addEventListener('click', (e) => {
                    const lessonId = lesson.getAttribute('data-lesson-id');
                    if (lessonId) {
                        this.openLesson(lessonId);
                    }
                });
            }
        });

        // Download button
        const downloadBtn = document.getElementById('downloadMaterialBtn');
        if (downloadBtn) {
            downloadBtn.addEventListener('click', () => this.downloadMaterials());
        }
    }

    loadCourseData() {
        console.log(`Loading course data for course ${this.courseId}`);

        // TODO: Fetch course details from API
        // fetch(`/api/courses/${this.courseId}`)
        //     .then(response => response.json())
        //     .then(data => {
        //         this.courseData = data;
        //         this.renderCourseDetails(data);
        //     })
        //     .catch(error => console.error('Error loading course:', error));
    }

    renderCourseDetails(course) {
        // Update course title
        const courseTitle = document.getElementById('courseTitle');
        if (courseTitle) {
            courseTitle.textContent = course.title;
        }

        // Update instructor info
        const instructorName = document.getElementById('instructorName');
        if (instructorName) {
            instructorName.textContent = `Giảng viên: ${course.instructor}`;
        }

        // Update description
        const courseDesc = document.getElementById('courseDescription');
        if (courseDesc) {
            courseDesc.textContent = course.description;
        }

        // Update progress
        this.updateProgress(course.completedLessons, course.totalLessons);

        // Render curriculum
        this.renderCurriculum(course.modules);
    }

    updateProgress(completed, total) {
        const percentage = (completed / total) * 100;
        const progressFill = document.querySelector('.progress-fill');
        const progressText = document.querySelector('.progress-detail');

        if (progressFill) {
            progressFill.style.strokeDashoffset = (251.2 * (100 - percentage)) / 100;
        }

        if (progressText) {
            progressText.textContent = `${completed} / ${total} bài học hoàn thành`;
        }
    }

    renderCurriculum(modules) {
        const curriculum = document.querySelector('.curriculum');
        curriculum.innerHTML = '';

        modules.forEach((module, moduleIndex) => {
            const moduleDiv = document.createElement('div');
            moduleDiv.className = 'module';
            moduleDiv.setAttribute('data-module-id', module.id);

            let lessonsHTML = '';
            module.lessons.forEach((lesson) => {
                const isCompleted = lesson.completed ? 'completed' : '';
                const isLocked = lesson.locked ? 'locked' : '';
                const icon = lesson.completed ? '✓' : lesson.locked ? '🔒' : '▶';

                lessonsHTML += `
                    <li class="lesson ${isCompleted} ${isLocked}" data-lesson-id="${lesson.id}">
                        <span class="icon">${icon}</span>
                        <span class="title">${lesson.title}</span>
                        <span class="duration">${lesson.duration} phút</span>
                    </li>
                `;
            });

            let progressText = `${module.completedLessons} / ${module.totalLessons} bài`;

            moduleDiv.innerHTML = `
                <div class="module-header">
                    <h3>${module.title}</h3>
                    <span class="module-progress">${progressText}</span>
                </div>
                <ul class="lesson-list">
                    ${lessonsHTML}
                </ul>
            `;

            curriculum.appendChild(moduleDiv);
        });

        // Re-attach event listeners after rendering
        this.attachEventListeners();
    }

    toggleModule(module) {
        const lessonList = module.querySelector('.lesson-list');
        if (lessonList) {
            lessonList.style.display = lessonList.style.display === 'none' ? 'block' : 'none';
        }
    }

    startCourse() {
        if (!this.courseData || !this.courseData.firstLessonId) {
            alert('Không thể bắt đầu khóa học. Vui lòng thử lại sau.');
            return;
        }

        // Navigate to first lesson
        window.location.href = `/course-learning/lesson-view?lessonId=${this.courseData.firstLessonId}`;
    }

    openLesson(lessonId) {
        window.location.href = `/course-learning/lesson-view?lessonId=${lessonId}`;
    }

    downloadMaterials() {
        if (!this.courseData) {
            alert('Không thể tải tài liệu. Vui lòng thử lại sau.');
            return;
        }

        console.log('Downloading course materials...');

        // TODO: Implement actual download functionality
        // could be a zip file with all course materials

        alert('Đang tải tài liệu khóa học...');
    }

    calculateStats() {
        if (!this.courseData) return;

        const stats = {
            totalHours: this.courseData.totalDuration / 60,
            totalLessons: this.courseData.totalLessons,
            studentCount: this.courseData.enrolledCount,
            difficulty: this.courseData.difficulty
        };

        return stats;
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    window.courseDetail = new CourseDetail();
});

