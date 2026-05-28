// Quiz Engine JavaScript

class QuizEngine {
    constructor() {
        this.currentQuestion = 1;
        this.totalQuestions = 10;
        this.answers = {};
        this.timeLeft = 3600; // 60 minutes
        this.isSubmitted = false;
        this.initialize();
    }

    initialize() {
        console.log('QuizEngine initialized');
        this.attachEventListeners();
        this.startTimer();
        this.loadQuizData();
    }

    attachEventListeners() {
        // Question navigation
        const prevBtn = document.getElementById('prevBtn');
        const nextBtn = document.getElementById('nextBtn');
        const submitBtn = document.getElementById('submitBtn');
        const pauseBtn = document.getElementById('pauseBtn');

        if (prevBtn) prevBtn.addEventListener('click', () => this.previousQuestion());
        if (nextBtn) nextBtn.addEventListener('click', () => this.nextQuestion());
        if (submitBtn) submitBtn.addEventListener('click', () => this.openSubmitModal());
        if (pauseBtn) pauseBtn.addEventListener('click', () => this.pauseQuiz());

        // Submit confirmation
        const confirmSubmit = document.getElementById('confirmSubmit');
        const cancelSubmit = document.getElementById('cancelSubmit');

        if (confirmSubmit) confirmSubmit.addEventListener('click', () => this.submitQuiz());
        if (cancelSubmit) cancelSubmit.addEventListener('click', () => this.closeSubmitModal());

        // Question grid
        const questionBtns = document.querySelectorAll('.question-btn');
        questionBtns.forEach((btn, index) => {
            btn.addEventListener('click', () => this.jumpToQuestion(index + 1));
        });

        // Answer selection
        const answerOptions = document.querySelectorAll('.answer-option input[type="radio"]');
        answerOptions.forEach(option => {
            option.addEventListener('change', () => this.saveAnswer());
        });
    }

    loadQuizData() {
        const urlParams = new URLSearchParams(window.location.search);
        const quizId = urlParams.get('quizId') || 1;

        console.log(`Loading quiz data for quiz ${quizId}`);

        // TODO: Fetch quiz questions from API
        // fetch(`/api/quizzes/${quizId}/questions`)
        //     .then(response => response.json())
        //     .then(data => this.renderQuestion(data[0]))
        //     .catch(error => console.error('Error loading quiz:', error));
    }

    renderQuestion(question) {
        const questionText = document.getElementById('questionText');
        const options = document.querySelectorAll('.answer-option');

        if (questionText) {
            questionText.textContent = `Câu ${this.currentQuestion}: ${question.text}`;
        }

        // Render options
        if (options.length >= 4) {
            const choices = ['A', 'B', 'C', 'D'];
            choices.forEach((choice, index) => {
                const optionLabel = options[index]?.querySelector('.option-label');
                const radio = options[index]?.querySelector('input[type="radio"]');

                if (optionLabel && radio) {
                    optionLabel.textContent = `${choice}) ${question.options[index]}`;
                    radio.value = choice;

                    // Check if this answer was previously saved
                    if (this.answers[this.currentQuestion] === choice) {
                        radio.checked = true;
                    }
                }
            });
        }

        this.updateProgress();
        this.updateQuestionGrid();
    }

    saveAnswer() {
        const selected = document.querySelector('input[name="answer"]:checked');
        if (selected) {
            this.answers[this.currentQuestion] = selected.value;
            console.log(`Question ${this.currentQuestion}: ${selected.value}`);
        }
    }

    nextQuestion() {
        if (this.currentQuestion < this.totalQuestions) {
            this.saveAnswer();
            this.currentQuestion++;
            this.loadQuestion(this.currentQuestion);
        } else {
            alert('Đã hết câu hỏi. Vui lòng nộp bài!');
        }
    }

    previousQuestion() {
        if (this.currentQuestion > 1) {
            this.saveAnswer();
            this.currentQuestion--;
            this.loadQuestion(this.currentQuestion);
        }
    }

    jumpToQuestion(questionNumber) {
        this.saveAnswer();
        this.currentQuestion = questionNumber;
        this.loadQuestion(questionNumber);
    }

    loadQuestion(questionNumber) {
        console.log(`Loading question ${questionNumber}`);
        const questionCounter = document.getElementById('questionCounter');
        if (questionCounter) {
            questionCounter.textContent = `Câu ${questionNumber} / ${this.totalQuestions}`;
        }

        // TODO: Fetch specific question from API or cache
        // Placeholder: this.renderQuestion(questions[questionNumber - 1]);
    }

    startTimer() {
        const timerInterval = setInterval(() => {
            if (this.timeLeft <= 0) {
                clearInterval(timerInterval);
                this.autoSubmit();
                return;
            }

            this.timeLeft--;
            this.updateTimerDisplay();
        }, 1000);
    }

    updateTimerDisplay() {
        const minutes = Math.floor(this.timeLeft / 60);
        const seconds = this.timeLeft % 60;
        const timerValue = document.querySelector('.timer-value');

        if (timerValue) {
            timerValue.textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`;
        }

        // Warning when time is running out
        if (this.timeLeft < 60) {
            timerValue?.classList.add('warning');
        }
    }

    updateProgress() {
        const answeredCount = Object.keys(this.answers).length;
        const progressPercentage = (this.currentQuestion / this.totalQuestions) * 100;

        const progressFill = document.getElementById('progressFill');
        if (progressFill) {
            progressFill.style.width = progressPercentage + '%';
        }
    }

    updateQuestionGrid() {
        const questionBtns = document.querySelectorAll('.question-btn');
        questionBtns.forEach((btn, index) => {
            const questionNum = index + 1;
            btn.classList.remove('active', 'skipped');

            if (questionNum === this.currentQuestion) {
                btn.classList.add('active');
            } else if (!this.answers[questionNum]) {
                btn.classList.add('skipped');
            }
        });
    }

    openSubmitModal() {
        const modal = document.getElementById('submitModal');
        if (modal) {
            modal.classList.remove('hidden');
        }
    }

    closeSubmitModal() {
        const modal = document.getElementById('submitModal');
        if (modal) {
            modal.classList.add('hidden');
        }
    }

    submitQuiz() {
        this.saveAnswer();
        console.log('Submitting quiz with answers:', this.answers);

        // TODO: Send quiz answers to backend
        // fetch('/api/quizzes/submit', {
        //     method: 'POST',
        //     body: JSON.stringify({ answers: this.answers })
        // })
        // .then(response => response.json())
        // .then(data => {
        //     alert(`Điểm số của bạn: ${data.score}/${this.totalQuestions}`);
        //     window.location.href = '/course-learning/dashboard';
        // })
        // .catch(error => console.error('Error submitting quiz:', error));

        alert('Bài thi đã được nộp thành công!');
        this.isSubmitted = true;
        this.closeSubmitModal();

        // Redirect after 2 seconds
        setTimeout(() => {
            window.location.href = '/course-learning/dashboard';
        }, 2000);
    }

    pauseQuiz() {
        alert('Bài thi đã tạm dừng. Bạn có thể quay lại bất kỳ lúc nào.');
        // TODO: Save quiz state and allow resume
    }

    autoSubmit() {
        console.log('Time\'s up! Auto-submitting quiz...');
        this.submitQuiz();
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    window.quizEngine = new QuizEngine();
});

