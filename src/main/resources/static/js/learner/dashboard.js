// Dashboard JavaScript

document.addEventListener('DOMContentLoaded', function() {
    // Initialize dashboard
    initializeDashboard();
});

function initializeDashboard() {
    console.log('Dashboard initialized');

    // Add click handlers to course cards
    const courseCards = document.querySelectorAll('.course-card');
    courseCards.forEach(card => {
        card.addEventListener('click', function() {
            const courseId = this.getAttribute('data-course-id');
            if (courseId) {
                navigateToCourse(courseId);
            }
        });
    });

    // Load user courses via API
    loadUserCourses();
}

function loadUserCourses() {
    // TODO: Implement API call to fetch user courses
    // fetch('/api/courses/my-courses')
    //     .then(response => response.json())
    //     .then(data => {
    //         renderCourses(data);
    //     })
    //     .catch(error => console.error('Error loading courses:', error));

    console.log('Loading user courses...');
}

function navigateToCourse(courseId) {
    window.location.href = `/course-learning/course-detail?id=${courseId}`;
}

function renderCourses(courses) {
    const coursesGrid = document.querySelector('.courses-grid');

    courses.forEach(course => {
        const courseCard = createCourseCard(course);
        coursesGrid.appendChild(courseCard);
    });
}

function createCourseCard(course) {
    const card = document.createElement('div');
    card.className = 'course-card';
    card.setAttribute('data-course-id', course.id);

    const progress = (course.completedLessons / course.totalLessons) * 100;

    card.innerHTML = `
        <div class="course-image">
            <img src="${course.imageUrl || '/images/learner/placeholder-course.jpg'}" alt="${course.title}">
        </div>
        <div class="course-info">
            <h3>${course.title}</h3>
            <p class="instructor">Giảng viên: ${course.instructor}</p>
            <div class="progress-bar">
                <div class="progress-fill" style="width: ${progress}%;"></div>
            </div>
            <p class="progress-text">${Math.round(progress)}% hoàn thành</p>
            <a href="/course-learning/lesson-view?courseId=${course.id}" class="btn-primary">Tiếp tục học</a>
        </div>
    `;

    return card;
}

// Update progress bars
function updateProgressBars() {
    // TODO: Fetch latest progress and update UI
    console.log('Updating progress bars...');
}

// Export functions for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { initializeDashboard, loadUserCourses, navigateToCourse };
}

