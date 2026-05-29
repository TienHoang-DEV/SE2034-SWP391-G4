IF DB_ID('ElearningPlatform') IS NOT NULL
BEGIN
    ALTER DATABASE ElearningPlatform
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE ElearningPlatform;
END
GO

CREATE DATABASE ElearningPlatform;
GO

USE ElearningPlatform;
GO
-- =========================
-- ROLES
-- =========================
CREATE TABLE roles (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50) UNIQUE NOT NULL,
    description NVARCHAR(255) NULL,
    created_at DATETIME DEFAULT GETDATE()
);

-- Seed roles
INSERT INTO roles (name, description)
VALUES
('admin', N'Quản trị hệ thống'),
('manager', N'Quản lý nội dung'),
('instructor', N'Giảng viên'),
('learner', N'Học viên');
-- =========================
-- USERS
-- =========================
CREATE TABLE users (
    id INT PRIMARY KEY IDENTITY(1,1),
	role_id INT NOT NULL,
    first_name NVARCHAR(255) NOT NULL,
    last_name Nvarchar(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone Varchar(20) Unique Not Null,
    password_hash VARCHAR(255) NULL,
    avatar_url VARCHAR(500) NULL,
    google_id VARCHAR(255) NULL,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('active', 'banned', 'pending')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL
	    CONSTRAINT FK_users_role
        FOREIGN KEY (role_id) REFERENCES roles(id)

);

-- =========================
-- PASSWORD RESET TOKENS
-- =========================
CREATE TABLE password_reset_tokens (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    expired_at DATETIME NOT NULL,
    is_used BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_reset_tokens_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================
-- SYSTEM LOGS
-- =========================
CREATE TABLE system_logs (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    action VARCHAR(255),
    target_type VARCHAR(100),
    target_id VARCHAR(100),
    meta NVARCHAR(MAX) NULL,
    created_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_system_logs_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================
-- INSTRUCTOR REQUESTS
-- =========================
-- =========================
-- INSTRUCTOR REQUESTS
-- =========================
CREATE TABLE instructor_requests (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    cv_url VARCHAR(500) NULL,
    certificate_url VARCHAR(500) NULL,
    description NVARCHAR(MAX) NULL,
    status VARCHAR(20) NOT NULL
        CHECK (status IN ('pending', 'approved', 'rejected', 'blocked')),
    reject_reason NVARCHAR(1000) NULL,
    reviewed_by INT NULL,
    reviewed_at DATETIME NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    CONSTRAINT FK_instructor_requests_user
        FOREIGN KEY (user_id) REFERENCES users(id),

    CONSTRAINT FK_instructor_requests_reviewed_by
        FOREIGN KEY (reviewed_by) REFERENCES users(id)
);

-- =========================
-- CATEGORIES
-- =========================
CREATE TABLE categories (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    parent_id INT NULL,
    status VARCHAR(20)
        CHECK (status IN ('active', 'inactive')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_categories_parent
        FOREIGN KEY (parent_id) REFERENCES categories(id)
);

-- =========================
-- COURSES
-- =========================
CREATE TABLE courses (
    id INT PRIMARY KEY IDENTITY(1,1),
    instructor_id INT NOT NULL,
    category_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    thumbnail_url VARCHAR(500) NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    level VARCHAR(20)
        CHECK (level IN ('beginner', 'intermediate', 'advanced')),
    status VARCHAR(20)
        CHECK (status IN ('draft', 'pending', 'published', 'rejected', 'hidden')),
    approved_by INT NULL,
    approved_at DATETIME NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_courses_instructor
        FOREIGN KEY (instructor_id) REFERENCES users(id),
    CONSTRAINT FK_courses_category
        FOREIGN KEY (category_id) REFERENCES categories(id),
    CONSTRAINT FK_courses_approved_by
        FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- =========================
-- COURSE SECTIONS
-- =========================
CREATE TABLE course_sections (
    id INT PRIMARY KEY IDENTITY(1,1),
    course_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    position INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_sections_course
        FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- =========================
-- LESSONS
-- =========================
CREATE TABLE lessons (
    id INT PRIMARY KEY IDENTITY(1,1),
    section_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    video_url VARCHAR(500) NULL,
    duration_seconds INT NULL CHECK (duration_seconds > 0),
    position INT NULL,
    is_published BIT DEFAULT 0,
    moderation_status VARCHAR(20) DEFAULT 'pending'
        CHECK (moderation_status IN ('pending', 'auto_flagged', 'clean', 'approved', 'rejected')), -- Trạng thái kiểm duyệt Azure & Manager
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_lessons_section
        FOREIGN KEY (section_id) REFERENCES course_sections(id)
);

-- =========================
-- VIDEO MODERATION FLAGS (MỚI - LƯU VẾT VI PHẠM AZURE AI PHÁT HIỆN THEO PHÚT/GIÂY)
-- =========================
CREATE TABLE video_moderation_flags (
    id INT PRIMARY KEY IDENTITY(1,1),
    lesson_id INT NOT NULL,
    flagged_at_second INT NOT NULL CHECK (flagged_at_second >= 0), -- Giây thứ bao nhiêu trong video bị phát hiện nhạy cảm
    category VARCHAR(100) NOT NULL, -- Thể loại nhạy cảm (bạo lực, khỏa thân, từ ngữ kích động...)
    confidence_score DECIMAL(5,2) NOT NULL CHECK (confidence_score BETWEEN 0.00 AND 100.00), -- Độ tin cậy (%) từ Azure AI
    description NVARCHAR(500) NULL, -- Mô tả chi tiết lỗi phát hiện
    created_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_moderation_flags_lesson
        FOREIGN KEY (lesson_id) REFERENCES lessons(id)
);

-- =========================
-- LESSON MATERIALS
-- =========================
CREATE TABLE lesson_materials (
    id INT PRIMARY KEY IDENTITY(1,1),
    instructor_id INT NOT NULL,
    course_id INT NULL,
    lesson_id INT NULL,
    file_name NVARCHAR(255) NULL,
    file_url VARCHAR(500) NULL,
    file_type VARCHAR(50) NULL,
    file_size BIGINT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_materials_instructor
        FOREIGN KEY (instructor_id) REFERENCES users(id),
    CONSTRAINT FK_materials_course
        FOREIGN KEY (course_id) REFERENCES courses(id),
    CONSTRAINT FK_materials_lesson
        FOREIGN KEY (lesson_id) REFERENCES lessons(id)
);

-- =========================
-- QUIZZES
-- =========================
CREATE TABLE quizzes (
    id INT PRIMARY KEY IDENTITY(1,1),
    lesson_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    pass_score INT NOT NULL CHECK (pass_score >= 0),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_quizzes_lesson
        FOREIGN KEY (lesson_id) REFERENCES lessons(id)
);

-- =========================
-- QUIZ QUESTIONS
-- =========================
CREATE TABLE quiz_questions (
    id INT PRIMARY KEY IDENTITY(1,1),
    quiz_id INT NOT NULL,
    question_text NVARCHAR(MAX) NOT NULL,
    question_type VARCHAR(20)
        CHECK (question_type IN ('single', 'multiple')),
    points INT DEFAULT 1,
    position INT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_questions_quiz
        FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

-- =========================
-- QUIZ ANSWERS
-- =========================
CREATE TABLE quiz_answers (
    id INT PRIMARY KEY IDENTITY(1,1),
    question_id INT NOT NULL,
    answer_text NVARCHAR(MAX) NOT NULL,
    is_correct BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_answers_question
        FOREIGN KEY (question_id) REFERENCES quiz_questions(id)
);

-- =========================
-- QUIZ ATTEMPTS
-- =========================
CREATE TABLE quiz_attempts (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    quiz_id INT NOT NULL,
    score DECIMAL(5,2) NULL,
    is_passed BIT NULL,
    started_at DATETIME DEFAULT GETDATE(),
    submitted_at DATETIME NULL,

    CONSTRAINT FK_attempts_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT FK_attempts_quiz
        FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

-- =========================
-- COUPONS
-- =========================
CREATE TABLE coupons (
    id INT PRIMARY KEY IDENTITY(1,1),
    instructor_id INT NOT NULL,
    code VARCHAR(100) UNIQUE NOT NULL,
    discount_type VARCHAR(20)
        CHECK (discount_type IN ('percent', 'fixed')),
    discount_value DECIMAL(10,2) NOT NULL CHECK (discount_value > 0),
    usage_limit INT NULL CHECK (usage_limit >= 1),
    used_count INT DEFAULT 0 CHECK (used_count >= 0),
    expired_at DATETIME NULL,
    status VARCHAR(20)
        CHECK (status IN ('active', 'inactive')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_coupons_instructor
        FOREIGN KEY (instructor_id) REFERENCES users(id)
);

-- =========================
-- CARTS
-- =========================
CREATE TABLE carts (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT UNIQUE NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_carts_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================
-- CART ITEMS
-- =========================
CREATE TABLE cart_items (
    id INT PRIMARY KEY IDENTITY(1,1),
    cart_id INT NOT NULL,
    course_id INT NOT NULL,
    added_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_cart_items_cart
        FOREIGN KEY (cart_id) REFERENCES carts(id),

    CONSTRAINT FK_cart_items_course
        FOREIGN KEY (course_id) REFERENCES courses(id),

    CONSTRAINT UQ_cart_course UNIQUE(cart_id, course_id)
);

CREATE TABLE cart_instructor_coupons (
    id INT PRIMARY KEY IDENTITY(1,1),

    cart_id INT NOT NULL,
    instructor_id INT NOT NULL,
    coupon_id INT NOT NULL,

    applied_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_cart_coupon_cart
        FOREIGN KEY (cart_id) REFERENCES carts(id),

    CONSTRAINT FK_cart_coupon_instructor
        FOREIGN KEY (instructor_id) REFERENCES users(id),

    CONSTRAINT FK_cart_coupon_coupon
        FOREIGN KEY (coupon_id) REFERENCES coupons(id),

    CONSTRAINT UQ_cart_instructor UNIQUE(cart_id, instructor_id)
);


-- =========================
-- ORDERS
-- =========================
CREATE TABLE orders (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    discount_amount DECIMAL(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
    status VARCHAR(20)
        CHECK (status IN ('pending', 'paid', 'completed', 'cancelled', 'expired')), -- Thêm completed và expired
    payment_method VARCHAR(50) NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_orders_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================
-- ORDER ITEMS
-- =========================
CREATE TABLE order_items (
    id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT NOT NULL,
    course_id INT NOT NULL,
    coupon_id INT NULL,
    price_snapshot DECIMAL(10,2) NOT NULL CHECK (price_snapshot >= 0),
    discount_amount DECIMAL(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
    final_price DECIMAL(10,2) NOT NULL CHECK (final_price >= 0),
    course_title_snapshot NVARCHAR(255) NULL,

    CONSTRAINT FK_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT FK_order_items_course
        FOREIGN KEY (course_id) REFERENCES courses(id),
    CONSTRAINT FK_order_items_coupon
        FOREIGN KEY (coupon_id) REFERENCES coupons(id)
);

-- =========================
-- PAYMENTS
-- =========================
CREATE TABLE payments (
    id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT NOT NULL,
    transaction_code VARCHAR(255) NULL,
    gateway VARCHAR(50) NULL, -- 'MOMO', 'VNPAY', etc.
    gateway_tx_id VARCHAR(255) NULL, -- transId từ MoMo
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    qr_code_url VARCHAR(500) NULL, -- Mới bổ sung để lưu mã QR thanh toán động MoMo
    status VARCHAR(20)
        CHECK (status IN ('success', 'failed', 'pending')),
    paid_at DATETIME NULL,
    created_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- =========================
-- COUPON USAGES
-- =========================
CREATE TABLE coupon_usages (
    id INT PRIMARY KEY IDENTITY(1,1),
    coupon_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    used_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_coupon_usages_coupon
        FOREIGN KEY (coupon_id) REFERENCES coupons(id),
    CONSTRAINT FK_coupon_usages_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT FK_coupon_usages_order
        FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- =========================
-- ENROLLMENTS
-- =========================
CREATE TABLE enrollments (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    progress_percent DECIMAL(5,2) DEFAULT 0,
    enrolled_at DATETIME DEFAULT GETDATE(),
    completed_at DATETIME NULL,

    CONSTRAINT UQ_enrollment UNIQUE (user_id, course_id),
    CONSTRAINT FK_enrollments_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT FK_enrollments_course
        FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- =========================
-- LESSON PROGRESS
-- =========================
CREATE TABLE lesson_progress (
    id INT PRIMARY KEY IDENTITY(1,1),
    enrollment_id INT NOT NULL,
    lesson_id INT NOT NULL,
    is_completed BIT DEFAULT 0,
    last_accessed DATETIME NULL,

    CONSTRAINT UQ_lesson_progress UNIQUE (enrollment_id, lesson_id),
    CONSTRAINT FK_lesson_progress_enrollment
        FOREIGN KEY (enrollment_id) REFERENCES enrollments(id),
    CONSTRAINT FK_lesson_progress_lesson
        FOREIGN KEY (lesson_id) REFERENCES lessons(id)
);

-- =========================
-- FEEDBACKS
-- =========================
CREATE TABLE feedbacks (
    id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment NVARCHAR(MAX) NULL,
    status VARCHAR(20)
        CHECK (status IN ('visible', 'hidden', 'violation')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_feedbacks_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT FK_feedbacks_course
        FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- =========================
-- FEEDBACK REPORTS
-- =========================
CREATE TABLE feedback_reports (
    id INT PRIMARY KEY IDENTITY(1,1),
    feedback_id INT NOT NULL,
    reporter_id INT NOT NULL,
    reason NVARCHAR(MAX) NULL,
    status VARCHAR(20)
        CHECK (status IN ('pending', 'resolved')),
    resolved_by INT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,

    CONSTRAINT FK_reports_feedback
        FOREIGN KEY (feedback_id) REFERENCES feedbacks(id),
    CONSTRAINT FK_reports_reporter
        FOREIGN KEY (reporter_id) REFERENCES users(id),
    CONSTRAINT FK_reports_resolved_by
        FOREIGN KEY (resolved_by) REFERENCES users(id)
);

-- ==========================================
-- PERFORMANCE INDEXES (MỚI - TỐI ƯU HÓA TRUY VẤN)
-- ==========================================
CREATE INDEX IX_courses_instructor ON courses(instructor_id);
CREATE INDEX IX_courses_category ON courses(category_id);
CREATE INDEX IX_course_sections_course ON course_sections(course_id);
CREATE INDEX IX_lessons_section ON lessons(section_id);
CREATE INDEX IX_quiz_attempts_user_quiz ON quiz_attempts(user_id, quiz_id);
CREATE INDEX IX_lesson_progress_lookup ON lesson_progress(enrollment_id, lesson_id);
CREATE INDEX IX_video_moderation_lookup ON video_moderation_flags(lesson_id); -- Tối ưu hiển thị dòng thời gian nhạy cảm của video cho Manager
CREATE INDEX IX_orders_user ON orders(user_id);
CREATE INDEX IX_order_items_order ON order_items(order_id);
CREATE INDEX IX_payments_order ON payments(order_id);
CREATE INDEX IX_enrollments_lookup ON enrollments(user_id, course_id);
GO

-- Mẫu chèn khóa học
-- =========================
-- USER (INSTRUCTOR)
-- =========================
INSERT INTO users (
    role_id,
    first_name,
    last_name,
    email,
    phone,
    password_hash,
    status
)
VALUES (
    3, -- instructor
    N'28',
    N'Tech',
    '28tech@gmail.com',
    '0909999999',
    '123456',
    'active'
);

-- =========================
-- CATEGORY
-- =========================
INSERT INTO categories (
    name,
    description,
    parent_id,
    status
)
VALUES (
    N'Lập trình',
    N'Các khóa học lập trình',
    NULL,
    'active'
);

-- =========================
-- COURSE
-- =========================
INSERT INTO courses (
    instructor_id,
    category_id,
    title,
    description,
    thumbnail_url,
    price,
    level,
    status
)
VALUES (
    1,
    1,
    N'Lập Trình C Cơ Bản - 28Tech',
    N'Khóa học lập trình C cơ bản',
    'course-thumbnails/2aOboQZWp6Ov5iGTAZLOlCgmiOhOKsGgeQU1cI0O.jpg',
    0,
    'beginner',
    'published'
);

-- =========================
-- SECTION
-- =========================
INSERT INTO course_sections (
    course_id,
    title,
    position
)
VALUES (
    1,
    N'Giới thiệu',
    1
);

-- =========================
-- LESSON
-- =========================
INSERT INTO lessons (
    section_id,
    title,
    video_url,
    duration_seconds,
    position,
    is_published,
    moderation_status
)
VALUES (
    1,
    N'Bài 1 - Giới thiệu ngôn ngữ C',
    'videos/Recording 2026-05-28 212131.mp4',
    600,
    1,
    1,
    'approved'
);

USE ElearningPlatform;
GO

-- =========================================================
-- LESSON 2
-- =========================================================
INSERT INTO lessons (
    section_id,
    title,
    video_url,
    duration_seconds,
    position,
    is_published,
    moderation_status
)
VALUES (
    1,
    N'Bài 2 - Kiểu dữ liệu và khai báo biến trong C',

    'videos/L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2002.%20Ki%E1%BB%83u%20d%E1%BB%AF%20li%E1%BB%87u%20v%C3%A0%20c%C3%A1ch%20khai%20b%C3%A1o%20bi%E1%BA%BFn%20trong%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C-C++.mp4',

    900,
    2,
    1,
    'approved'
);

DECLARE @Lesson2Id INT = SCOPE_IDENTITY();

-- QUIZ LESSON 2
INSERT INTO quizzes (
    lesson_id,
    title,
    pass_score
)
VALUES (
    @Lesson2Id,
    N'Quiz - Kiểu dữ liệu và biến',
    70
);

DECLARE @Quiz2Id INT = SCOPE_IDENTITY();

-- QUESTION 1
INSERT INTO quiz_questions (
    quiz_id,
    question_text,
    question_type,
    points,
    position
)
VALUES (
    @Quiz2Id,
    N'Kiểu dữ liệu nào dùng để lưu số nguyên trong C?',
    'single',
    1,
    1
);

DECLARE @Q1Id INT = SCOPE_IDENTITY();

INSERT INTO quiz_answers (
    question_id,
    answer_text,
    is_correct
)
VALUES
(@Q1Id, N'int', 1),
(@Q1Id, N'float', 0),
(@Q1Id, N'double', 0),
(@Q1Id, N'char', 0);

-- QUESTION 2
INSERT INTO quiz_questions (
    quiz_id,
    question_text,
    question_type,
    points,
    position
)
VALUES (
    @Quiz2Id,
    N'Từ khóa nào dùng để khai báo biến số thực?',
    'single',
    1,
    2
);

DECLARE @Q2Id INT = SCOPE_IDENTITY();

INSERT INTO quiz_answers (
    question_id,
    answer_text,
    is_correct
)
VALUES
(@Q2Id, N'float', 1),
(@Q2Id, N'int', 0),
(@Q2Id, N'char', 0),
(@Q2Id, N'void', 0);

-- =========================================================
-- LESSON 3
-- =========================================================
INSERT INTO lessons (
    section_id,
    title,
    video_url,
    duration_seconds,
    position,
    is_published,
    moderation_status
)
VALUES (
    1,
    N'Bài 3 - Xuất dữ liệu với printf',

    'videos/L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2003.%20C%C3%A1ch%20xu%E1%BA%A5t%20d%E1%BB%AF%20li%E1%BB%87u%20ra%20m%C3%A0n%20h%C3%ACnh%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20H%C3%A0m%20printf%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C.mp4',

    850,
    3,
    1,
    'approved'
);

DECLARE @Lesson3Id INT = SCOPE_IDENTITY();

-- QUIZ LESSON 3
INSERT INTO quizzes (
    lesson_id,
    title,
    pass_score
)
VALUES (
    @Lesson3Id,
    N'Quiz - Hàm printf',
    70
);

DECLARE @Quiz3Id INT = SCOPE_IDENTITY();

-- QUESTION 1
INSERT INTO quiz_questions (
    quiz_id,
    question_text,
    question_type,
    points,
    position
)
VALUES (
    @Quiz3Id,
    N'Hàm nào dùng để xuất dữ liệu ra màn hình?',
    'single',
    1,
    1
);

DECLARE @Q3Id INT = SCOPE_IDENTITY();

INSERT INTO quiz_answers (
    question_id,
    answer_text,
    is_correct
)
VALUES
(@Q3Id, N'printf', 1),
(@Q3Id, N'scanf', 0),
(@Q3Id, N'gets', 0),
(@Q3Id, N'cin', 0);

-- QUESTION 2
INSERT INTO quiz_questions (
    quiz_id,
    question_text,
    question_type,
    points,
    position
)
VALUES (
    @Quiz3Id,
    N'%d trong printf dùng để in kiểu dữ liệu nào?',
    'single',
    1,
    2
);

DECLARE @Q4Id INT = SCOPE_IDENTITY();

INSERT INTO quiz_answers (
    question_id,
    answer_text,
    is_correct
)
VALUES
(@Q4Id, N'Số nguyên', 1),
(@Q4Id, N'Số thực', 0),
(@Q4Id, N'Ký tự', 0),
(@Q4Id, N'Chuỗi', 0);

-- =========================================================
-- LESSON 4
-- =========================================================
INSERT INTO lessons (
    section_id,
    title,
    video_url,
    duration_seconds,
    position,
    is_published,
    moderation_status
)
VALUES (
    1,
    N'Bài 4 - Nhập dữ liệu với scanf',

    'videos/L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2004.%20C%C3%A1ch%20nh%E1%BA%ADp%20d%E1%BB%AF%20li%E1%BB%87u%20t%E1%BB%AB%20b%C3%A0n%20ph%C3%ADm%20trong%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C.mp4',

    920,
    4,
    1,
    'approved'
);

DECLARE @Lesson4Id INT = SCOPE_IDENTITY();

-- QUIZ LESSON 4
INSERT INTO quizzes (
    lesson_id,
    title,
    pass_score
)
VALUES (
    @Lesson4Id,
    N'Quiz - Hàm scanf',
    70
);

DECLARE @Quiz4Id INT = SCOPE_IDENTITY();

-- QUESTION 1
INSERT INTO quiz_questions (
    quiz_id,
    question_text,
    question_type,
    points,
    position
)
VALUES (
    @Quiz4Id,
    N'Hàm nào dùng để nhập dữ liệu từ bàn phím?',
    'single',
    1,
    1
);

DECLARE @Q5Id INT = SCOPE_IDENTITY();

INSERT INTO quiz_answers (
    question_id,
    answer_text,
    is_correct
)
VALUES
(@Q5Id, N'scanf', 1),
(@Q5Id, N'printf', 0),
(@Q5Id, N'puts', 0),
(@Q5Id, N'cout', 0);

-- QUESTION 2
INSERT INTO quiz_questions (
    quiz_id,
    question_text,
    question_type,
    points,
    position
)
VALUES (
    @Quiz4Id,
    N'Dấu & trong scanf có tác dụng gì?',
    'single',
    1,
    2
);

DECLARE @Q6Id INT = SCOPE_IDENTITY();

INSERT INTO quiz_answers (
    question_id,
    answer_text,
    is_correct
)
VALUES
(@Q6Id, N'Lấy địa chỉ biến', 1),
(@Q6Id, N'Kết thúc lệnh', 0),
(@Q6Id, N'Nối chuỗi', 0),
(@Q6Id, N'Xuất dữ liệu', 0);

PRINT N'Đã thêm lesson 2, 3, 4 và quiz thành công!';
GO
