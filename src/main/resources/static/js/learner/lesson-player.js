// Lesson Player JavaScript

class LessonPlayer {
    constructor() {
        this.currentLesson = 1;
        this.totalLessons = 0;
        this.videoElement = document.getElementById('lessonVideo');
        this.initialize();
    }

    initialize() {
        console.log('LessonPlayer initialized');
        this.attachEventListeners();
        this.loadLessonData();
    }

    attachEventListeners() {
        // Lesson navigation
        const prevBtn = document.getElementById('prevLessonBtn');
        const nextBtn = document.getElementById('nextLessonBtn');
        const markCompleteBtn = document.getElementById('markCompleteBtn');

        if (prevBtn) prevBtn.addEventListener('click', () => this.previousLesson());
        if (nextBtn) nextBtn.addEventListener('click', () => this.nextLesson());
        if (markCompleteBtn) markCompleteBtn.addEventListener('click', () => this.markAsComplete());

        // Video events
        if (this.videoElement) {
            this.videoElement.addEventListener('ended', () => this.onVideoEnded());
            this.videoElement.addEventListener('timeupdate', () => this.saveProgress());
        }

        // Sidebar lesson clicks
        const lessonItems = document.querySelectorAll('.lesson-item');
        lessonItems.forEach((item, index) => {
            item.addEventListener('click', () => this.switchLesson(index + 1));
        });

        // Discussion form
        const form = document.querySelector('.discussion-form');
        if (form) {
            const submitBtn = form.querySelector('button');
            if (submitBtn) {
                submitBtn.addEventListener('click', (e) => this.submitDiscussionComment(e));
            }
        }
    }

    loadLessonData() {
        const urlParams = new URLSearchParams(window.location.search);
        const lessonId = urlParams.get('lessonId') || 1;

        console.log(`Loading lesson data for lesson ${lessonId}`);

        // TODO: Fetch lesson data from API
        // fetch(`/api/lessons/${lessonId}`)
        //     .then(response => response.json())
        //     .then(data => this.renderLesson(data))
        //     .catch(error => console.error('Error loading lesson:', error));
    }

    nextLesson() {
        if (this.currentLesson < this.totalLessons) {
            this.switchLesson(this.currentLesson + 1);
        }
    }

    previousLesson() {
        if (this.currentLesson > 1) {
            this.switchLesson(this.currentLesson - 1);
        }
    }

    switchLesson(lessonNumber) {
        console.log(`Switching to lesson ${lessonNumber}`);
        this.currentLesson = lessonNumber;

        // Mark current lesson as active
        const lessonItems = document.querySelectorAll('.lesson-item');
        lessonItems.forEach(item => item.classList.remove('active'));
        if (lessonItems[lessonNumber - 1]) {
            lessonItems[lessonNumber - 1].classList.add('active');
        }

        // Load new lesson
        window.location.href = `/course-learning/lesson-view?lessonId=${lessonNumber}`;
    }

    markAsComplete() {
        console.log(`Marking lesson ${this.currentLesson} as complete`);

        // TODO: Send completion to backend
        // fetch(`/api/lessons/${this.currentLesson}/complete`, {
        //     method: 'POST'
        // })
        // .then(response => response.json())
        // .then(data => {
        //     alert('Bài học đã được đánh dấu hoàn thành!');
        //     this.nextLesson();
        // })
        // .catch(error => console.error('Error marking complete:', error));

        alert('Bài học đã được đánh dấu hoàn thành!');
    }

    saveProgress() {
        if (!this.videoElement) return;

        const currentTime = this.videoElement.currentTime;
        const duration = this.videoElement.duration;

        // Auto-save progress every 30 seconds
        if (currentTime % 30 < 1) {
            console.log(`Saving progress: ${currentTime.toFixed(0)}s / ${duration.toFixed(0)}s`);

            // TODO: Send progress to backend
            // fetch(`/api/lessons/${this.currentLesson}/progress`, {
            //     method: 'POST',
            //     body: JSON.stringify({ currentTime, duration })
            // }).catch(error => console.error('Error saving progress:', error));
        }
    }

    onVideoEnded() {
        console.log('Video ended');
        alert('Bạn đã xem xong bài học này. Chuyển sang bài tiếp theo?');
        this.markAsComplete();
    }

    submitDiscussionComment(event) {
        event.preventDefault();

        const textarea = document.querySelector('.discussion-form textarea');
        const comment = textarea.value.trim();

        if (!comment) {
            alert('Vui lòng nhập nhận xét của bạn');
            return;
        }

        console.log('Submitting comment:', comment);

        // TODO: Submit comment to backend
        // fetch(`/api/lessons/${this.currentLesson}/comments`, {
        //     method: 'POST',
        //     body: JSON.stringify({ content: comment })
        // })
        // .then(response => response.json())
        // .then(data => {
        //     textarea.value = '';
        //     this.loadDiscussionComments();
        // })
        // .catch(error => console.error('Error submitting comment:', error));

        textarea.value = '';
        alert('Nhận xét của bạn đã được gửi!');
    }

    loadDiscussionComments() {
        console.log('Loading discussion comments...');

        // TODO: Fetch comments from API
        // fetch(`/api/lessons/${this.currentLesson}/comments`)
        //     .then(response => response.json())
        //     .then(data => this.renderComments(data))
        //     .catch(error => console.error('Error loading comments:', error));
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    window.lessonPlayer = new LessonPlayer();
});

