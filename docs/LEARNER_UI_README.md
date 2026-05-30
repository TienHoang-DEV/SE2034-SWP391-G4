# Learner UI - E-Learning Platform

## 📁 Cấu Trúc Thư Mục

```
src/main/resources/
├── templates/course-learning/          # Thymeleaf templates cho learner
│   ├── dashboard.html                  # Dashboard chính của học viên
│   ├── lesson-view.html               # Xem bài học, video player
│   ├── course-detail.html             # Chi tiết khóa học, curriculum
│   ├── quiz-attempt.html              # Giao diện làm bài test
│   └── helloworld.html                # (Placeholder cũ)
│
├── static/css/learner/                 # CSS cho giao diện learner
│   ├── dashboard.css                  # Styles cho dashboard
│   ├── lesson.css                     # Styles cho lesson player
│   ├── quiz.css                       # Styles cho quiz engine
│   └── course-detail.css              # Styles cho course detail
│
├── static/js/learner/                  # JavaScript cho learner UI
│   ├── dashboard.js                   # Logic dashboard
│   ├── lesson-player.js               # Class LessonPlayer (video, navigation)
│   ├── quiz-engine.js                 # Class QuizEngine (timer, questions)
│   └── course-detail.js               # Class CourseDetail (curriculum, progress)
│
└── static/images/learner/              # Images và assets cho learner
    ├── placeholder-course.jpg         # Hình placeholder khóa học
    ├── course-banner.jpg              # Banner khóa học
    ├── icons/                         # Icons (star, lock, etc)
    └── backgrounds/                   # Background images
```

## 🎯 Trang Chính

### 1. **Dashboard** (`/course-learning/dashboard`)
- **File:** `templates/course-learning/dashboard.html`
- **CSS:** `static/css/learner/dashboard.css`
- **JS:** `static/js/learner/dashboard.js`
- **Chức năng:**
  - Hiển thị danh sách khóa học của học viên
  - Thống kê tiến độ (số giờ học, số khóa học, chứng chỉ)
  - Card khóa học với progress bar
  - Khôi phục bài học gần nhất

### 2. **Lesson View** (`/course-learning/lesson-view`)
- **File:** `templates/course-learning/lesson-view.html`
- **CSS:** `static/css/learner/lesson.css`
- **JS:** `static/js/learner/lesson-player.js` (Class: `LessonPlayer`)
- **Chức năng:**
  - Video player (HTML5 `<video>`)
  - Điều hướng bài học (Previous/Next)
  - Danh sách bài học sidebar
  - Tài liệu tải về
  - Thảo luận (comments)
  - Đánh dấu bài hoàn thành
  - Auto-save progress

### 3. **Course Detail** (`/course-learning/course-detail`)
- **File:** `templates/course-learning/course-detail.html`
- **CSS:** `static/css/learner/course-detail.css`
- **JS:** `static/js/learner/course-detail.js` (Class: `CourseDetail`)
- **Chức năng:**
  - Hiển thị course header (banner, rating, học viên)
  - Sidebar thông tin (thời lượng, progress circle, badges)
  - Mô tả khóa học
  - Curriculum (modules + lessons)
  - Progress tracking (percent)
  - Nhận xét từ học viên
  - Nút "Bắt đầu học"

### 4. **Quiz Attempt** (`/course-learning/quiz-attempt`)
- **File:** `templates/course-learning/quiz-attempt.html`
- **CSS:** `static/css/learner/quiz.css`
- **JS:** `static/js/learner/quiz-engine.js` (Class: `QuizEngine`)
- **Chức năng:**
  - Timer countdown (60 phút)
  - Hiển thị câu hỏi từng câu
  - 4 lựa chọn (A, B, C, D)
  - Question grid (review + skip)
  - Confirm submit modal
  - Auto-submit khi hết thời gian
  - Lưu đáp án tự động

## 🔧 Hướng Dẫn Phát Triển

### Cấu Trúc Thymeleaf + Spring Boot
- Tất cả templates dùng `xmlns:th="http://www.thymeleaf.org"`
- Dùng `th:href="@{/path}"` để reference CSS/JS/images
- Dynamic data: `th:text="${variable}"`, `th:each`, `th:if`

### Ví dụ Tạo Mới Trang Learner
1. **Tạo HTML template** → `src/main/resources/templates/course-learning/my-template.html`
2. **Tạo CSS file** → `src/main/resources/static/css/learner/my-template.css`
3. **Tạo JS file** → `src/main/resources/static/js/learner/my-template.js`
4. **Tạo Controller** → `src/main/java/vn/edu/fpt/controller/CourseController.java`
   ```java
   @GetMapping("/my-template")
   public String myTemplate(Model model) {
       // Load data
       return "course-learning/my-template";
   }
   ```

### API Integration TODO
Chỉnh sửa các function TODO trong JS files để kết nối với backend:

**Ví dụ - Dashboard:**
```javascript
fetch('/api/courses/my-courses')
    .then(response => response.json())
    .then(data => renderCourses(data))
```

**Ví dụ - Lesson Player:**
```javascript
fetch(`/api/lessons/${lessonId}`)
    .then(response => response.json())
    .then(data => this.renderLesson(data))
```

**Ví dụ - Quiz:**
```javascript
fetch('/api/quizzes/submit', {
    method: 'POST',
    body: JSON.stringify({ answers: this.answers })
})
```

## 📱 Responsive Design
- Mobile-first approach
- Breakpoints: 768px, 1024px, 1200px
- Sidebar collapse trên mobile
- Grid → single column trên mobile

## 🎨 Color & Theme
```css
--primary-color: #007bff       (Blue)
--secondary-color: #6c757d    (Gray)
--success-color: #28a745      (Green)
--danger-color: #dc3545       (Red)
--light-bg: #f8f9fa           (Light Gray)
--text-dark: #212529          (Dark)
--text-muted: #6c757d         (Muted Gray)
```

## 🚀 Tiếp Theo
- [ ] Tạo API endpoints cho khóa học, bài học, quiz
- [ ] Implement authentication/authorization
- [ ] Kết nối database (courses, lessons, lessons_progress)
- [ ] Real-time discussion (WebSocket)
- [ ] Video streaming optimization (HLS/DASH)
- [ ] Download materials (ZIP)
- [ ] Certificate generation
- [ ] Analytics & progress tracking

## 📝 Git Workflow
- Branch: `feature/learner-ui`
- Commit: `Add learner UI templates, CSS, and JS starters`
- Push: `git push -u origin feature/learner-ui`
- PR: Merge vào `main` sau review

---

**Tác giả:** Development Team  
**Ngày tạo:** 2026-05-29  
**Version:** 1.0.0

