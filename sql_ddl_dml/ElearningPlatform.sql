USE master
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
-- Bảng lưu các vai trò hệ thống (tách riêng để dễ mở rộng)
CREATE TABLE roles (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh vai trò

    name VARCHAR(50) UNIQUE NOT NULL,
    -- Tên vai trò: 'admin', 'manager', 'instructor', 'learner'

    description NVARCHAR(255) NULL,
    -- Mô tả chi tiết vai trò

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo vai trò
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất
);

-- Seed dữ liệu vai trò mặc định
INSERT INTO roles (name, description)
VALUES
('admin', N'Quản trị hệ thống'),
('manager', N'Quản lý nội dung'),
('instructor', N'Giảng viên'),
('learner', N'Học viên');

GO

-- =========================
-- USERS
-- =========================
CREATE TABLE users (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh duy nhất, tự động tăng

    role_id INT NOT NULL,
    -- Tham chiếu đến bảng roles, vai trò của user

    first_name NVARCHAR(255) NOT NULL,
    -- Họ của người dùng

    last_name NVARCHAR(255) NOT NULL,
    -- Tên của người dùng

    email VARCHAR(255) UNIQUE NOT NULL,
    -- Email duy nhất dùng cho đăng nhập local, phải unique

    phone VARCHAR(20) UNIQUE NULL,
    -- Số điện thoại (tuỳ chọn), duy nhất nếu có giá trị

    password_hash VARCHAR(255) NULL,
    -- Hash mật khẩu (BCrypt/Argon2). NULL nếu user chỉ login via Google

    avatar_url VARCHAR(500) NULL,
    -- URL ảnh đại diện (lưu link từ Azure Blob Storage)

    google_id VARCHAR(255) NULL,
    -- Google ID nếu user authenticate via OAuth Google

    status VARCHAR(20) NOT NULL
        CHECK (status IN ('active', 'banned', 'pending')),
    -- Trạng thái: active (hoạt động), banned (cấm), pending (chờ xác thực)

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo tài khoản (mặc định là thời chạy lệnh CREATE)

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_users_role
        FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- =========================
-- PASSWORD RESET TOKENS
-- =========================
CREATE TABLE password_reset_tokens (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh token reset

    user_id INT NOT NULL,
    -- Tham chiếu đến bảng users, người dùng yêu cầu reset password

    token VARCHAR(255) NOT NULL,
    -- Token ngẫu nhiên được gửi qua email (dùng cho link reset)

    expired_at DATETIME NOT NULL,
    -- Thời gian token hết hiệu lực (thường 1 giờ sau khi tạo)

    is_used BIT DEFAULT 0,
    -- Cờ đánh dấu token đã được sử dụng (reset password thành công) hay chưa

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian token được tạo
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_reset_tokens_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================
-- SYSTEM LOGS
-- =========================
CREATE TABLE system_logs (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh log

    user_id INT NOT NULL,
    -- Tham chiếu đến bảng users, người dùng thực hiện hành động

    action VARCHAR(255),
    -- Hành động thực hiện (ví dụ: 'create_course', 'upload_video', 'edit_course', 'delete_lesson')

    target_type VARCHAR(100),
    -- Loại đối tượng bị tác động (ví dụ: 'course', 'lesson', 'quiz', 'user')

    target_id VARCHAR(100),
    -- ID của đối tượng bị tác động (để trace được)

    meta NVARCHAR(MAX) NULL,
    -- Dữ liệu bổ sung dạng JSON (ví dụ chi tiết thay đổi, thông tin cũ/mới)

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian ghi log
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_system_logs_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================
-- INSTRUCTOR REQUESTS
-- =========================
CREATE TABLE instructor_requests (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh yêu cầu

    user_id INT NOT NULL,
    -- Tham chiếu đến bảng users, người dùng yêu cầu trở thành giáo viên

    cv_url VARCHAR(500) NULL,
    -- URL file CV (lưu link từ Azure Blob Storage)

    certificate_url VARCHAR(500) NULL,
    -- URL file chứng chỉ/bằng cấp (lưu link từ Azure Blob Storage)

    description NVARCHAR(MAX) NULL,
    -- Mô tả kinh nghiệm, lý do muốn trở thành giáo viên

    status VARCHAR(20) NOT NULL
        CHECK (status IN ('pending', 'approved', 'rejected', 'blocked')),
    -- Trạng thái: pending (chờ duyệt), approved (phê duyệt), rejected (từ chối), blocked (chặn vĩnh viễn)

    reviewed_by INT NULL,
    -- Tham chiếu đến manager/admin đã review yêu cầu này

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo yêu cầu

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất (khi được review)

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
    -- Mã định danh danh mục

    name NVARCHAR(255) NOT NULL,
    -- Tên danh mục (ví dụ: 'Lập trình', 'Thiết kế', 'Kinh doanh')

    description NVARCHAR(MAX) NULL,
    -- Mô tả chi tiết về danh mục

    parent_id INT NULL,
    -- ID danh mục cha (cho phép phân cấp danh mục: Lập trình -> Web Development -> Frontend)

    status VARCHAR(20)
        CHECK (status IN ('active', 'inactive')),
    -- Trạng thái: active (hiển thị), inactive (ẩn)

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo danh mục

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_categories_parent
        FOREIGN KEY (parent_id) REFERENCES categories(id)
);

-- =========================
-- COURSES
-- =========================
CREATE TABLE courses (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh khóa học

    instructor_id INT NOT NULL,
    -- Tham chiếu đến bảng users (role='instructor'), giáo viên tạo khóa học

    category_id INT NOT NULL,
    -- Tham chiếu đến bảng categories, danh mục khóa học

    title NVARCHAR(255) NOT NULL,
    -- Tên khóa học (ví dụ: 'Lập trình C Cơ bản')

    description NVARCHAR(MAX) NULL,
    -- Mô tả chi tiết nội dung, mục tiêu khóa học

    thumbnail_url VARCHAR(500) NULL,
    -- URL ảnh bìa khóa học (lưu link từ Azure Blob Storage)

    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    -- Giá khóa học (0 = miễn phí)

    level VARCHAR(20)
        CHECK (level IN ('beginner', 'intermediate', 'advanced')),
    -- Mức độ: beginner (cơ bản), intermediate (trung cấp), advanced (nâng cao)

    status VARCHAR(20)
        CHECK (status IN ('draft', 'pending', 'published', 'rejected', 'hidden')),
    -- Trạng thái: draft (nháp), pending (chờ duyệt), published (đã xuất bản), rejected (từ chối), hidden (ẩn)

    approved_by INT NULL,
    -- Tham chiếu đến manager/admin đã phê duyệt khóa học

    approved_at DATETIME NULL,
    -- Thời gian phê duyệt

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo khóa học

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

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
    -- Mã định danh section (chương)

    course_id INT NOT NULL,
    -- Tham chiếu đến bảng courses, khóa học mà section này thuộc về

    title NVARCHAR(255) NOT NULL,
    -- Tên section (ví dụ: 'Chương 1: Nhập môn', 'Chương 2: Cú pháp cơ bản')

    position INT NOT NULL,
    -- Thứ tự hiển thị section trong khóa học (1, 2, 3, ...)

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo section

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_sections_course
        FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- =========================
-- LESSONS
-- =========================
CREATE TABLE lessons (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh bài học

    section_id INT NOT NULL,
    -- Tham chiếu đến bảng course_sections, bài học này thuộc section nào

    title NVARCHAR(255) NOT NULL,
    -- Tên bài học (ví dụ: 'Bài 1: Giới thiệu ngôn ngữ C')

    video_url VARCHAR(500) NULL,
    -- URL video bài học (lưu link từ Azure Blob Storage)

    duration_seconds INT NULL CHECK (duration_seconds > 0),
    -- Thời lượng video (giây), kiểm tra phải > 0 nếu có giá trị

    position INT NULL,
    -- Thứ tự hiển thị bài trong section (1, 2, 3, ...)

    is_published BIT DEFAULT 0,
    -- Cờ đánh dấu bài học đã xuất bản cho học viên hay chưa

    moderation_status VARCHAR(20) DEFAULT 'pending'
        CHECK (moderation_status IN ('pending', 'auto_flagged', 'clean', 'approved', 'rejected')),
    -- Trạng thái kiểm duyệt video bởi Azure AI:
    -- pending (chờ), auto_flagged (AI phát hiện vấn đề), clean (không vấn đề),
    -- approved (manager phê duyệt), rejected (manager từ chối)

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo bài học

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_lessons_section
        FOREIGN KEY (section_id) REFERENCES course_sections(id)
);

-- =========================
-- VIDEO MODERATION FLAGS
-- =========================
-- Bảng lưu các dấu hiệu vi phạm được phát hiện bởi Azure AI cho từng video
-- Giups manager dễ dàng review những vị trí nhạy cảm trong video
CREATE TABLE video_moderation_flags (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh cờ (flag)

    lesson_id INT NOT NULL,
    -- Tham chiếu đến bảng lessons, video bị phát hiện vấn đề

    flagged_at_second INT NOT NULL CHECK (flagged_at_second >= 0),
    -- Vị trí giây thứ bao nhiêu trong video bị phát hiện (dùng cho skip trực tiếp)

    category VARCHAR(100) NOT NULL,
    -- Thể loại vấn đề: 'violence' (bạo lực), 'nudity' (khỏa thân), 'offensive_language' (từ ngữ kích động), ...

    confidence_score DECIMAL(5,2) NOT NULL CHECK (confidence_score BETWEEN 0.00 AND 100.00),
    -- Độ tin cậy của phát hiện Azure AI (0.00-100.00%)

    description NVARCHAR(500) NULL,
    -- Mô tả chi tiết về lỗi phát hiện bởi AI

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian phát hiện
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_moderation_flags_lesson
        FOREIGN KEY (lesson_id) REFERENCES lessons(id)
);

-- =========================
-- LESSON MATERIALS
-- =========================
CREATE TABLE lesson_materials (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh tài liệu

    instructor_id INT NOT NULL,
    -- Tham chiếu đến bảng users (role='instructor'), giáo viên upload tài liệu

    course_id INT NULL,
    -- Tham chiếu đến bảng courses (tài liệu cho cả khóa học nếu có)

    lesson_id INT NULL,
    -- Tham chiếu đến bảng lessons (tài liệu cho bài học cụ thể)

    file_name NVARCHAR(255) NULL,
    -- Tên file gốc

    file_url VARCHAR(500) NULL,
    -- URL file (lưu link từ Azure Blob Storage)

    file_type VARCHAR(50) NULL,
    -- Loại file: 'pdf', 'docx', 'pptx', 'zip', 'txt', ...

    file_size BIGINT NULL,
    -- Kích thước file (bytes)

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian upload tài liệu

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

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
    -- Mã định danh bài quiz

    lesson_id INT NOT NULL,
    -- Tham chiếu đến bảng lessons, quiz nằm trong bài học nào

    title NVARCHAR(255) NOT NULL,
    -- Tên bài quiz (ví dụ: 'Quiz: Kiểu dữ liệu và biến')

    pass_score INT NOT NULL CHECK (pass_score >= 0),
    -- Điểm tối thiểu để pass quiz (ví dụ: 70)

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo quiz

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_quizzes_lesson
        FOREIGN KEY (lesson_id) REFERENCES lessons(id)
);

-- =========================
-- QUIZ QUESTIONS
-- =========================
CREATE TABLE quiz_questions (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh câu hỏi

    quiz_id INT NOT NULL,
    -- Tham chiếu đến bảng quizzes, câu hỏi này thuộc quiz nào

    question_text NVARCHAR(MAX) NOT NULL,
    -- Nội dung câu hỏi

    question_type VARCHAR(20)
        CHECK (question_type IN ('single', 'multiple')),
    -- Loại câu hỏi: single (1 đáp án đúng), multiple (nhiều đáp án đúng)

    points INT DEFAULT 1,
    -- Điểm thưởng nếu trả lời đúng (mặc định 1)

    position INT NULL,
    -- Thứ tự câu hỏi trong quiz

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo câu hỏi

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_questions_quiz
        FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

-- =========================
-- QUIZ ANSWERS
-- =========================
CREATE TABLE quiz_answers (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh đáp án

    question_id INT NOT NULL,
    -- Tham chiếu đến bảng quiz_questions, đáp án thuộc câu hỏi nào

    answer_text NVARCHAR(MAX) NOT NULL,
    -- Nội dung đáp án

    is_correct BIT DEFAULT 0,
    -- Cờ đánh dấu đáp án đúng hay sai (1 = đúng, 0 = sai)

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo đáp án
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_answers_question
        FOREIGN KEY (question_id) REFERENCES quiz_questions(id)
);

-- =========================
-- QUIZ ATTEMPTS
-- =========================
CREATE TABLE quiz_attempts (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh lần làm quiz

    user_id INT NOT NULL,
    -- Tham chiếu đến bảng users, học viên làm quiz

    quiz_id INT NOT NULL,
    -- Tham chiếu đến bảng quizzes, quiz nào được làm

    score DECIMAL(5,2) NULL,
    -- Điểm đạt được (NULL nếu còn đang làm)

    is_passed BIT NULL,
    -- Cờ đánh dấu pass hay fail (NULL nếu chưa submit, 1 = pass, 0 = fail)

    started_at DATETIME DEFAULT GETDATE(),
    -- Thời gian bắt đầu làm quiz
    submitted_at DATETIME NULL,
    -- Thời gian submit quiz (NULL nếu chưa submit)
    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo bản ghi
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

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
    -- Mã định danh mã giảm giá

    instructor_id INT NOT NULL,
    -- Tham chiếu đến bảng users (role='instructor'), giáo viên tạo coupon cho khóa học của họ

    code VARCHAR(100) UNIQUE NOT NULL,
    -- Mã code coupon (ví dụ: 'SUMMER50', 'NEWYEAR2024'), phải unique

    discount_type VARCHAR(20)
        CHECK (discount_type IN ('percent', 'fixed')),
    -- Loại giảm giá: percent (giảm theo %), fixed (giảm số tiền cố định)

    discount_value DECIMAL(10,2) NOT NULL CHECK (discount_value > 0),
    -- Giá trị giảm (ví dụ: 50 cho percent, 100000 cho fixed)

    usage_limit INT NULL CHECK (usage_limit >= 1),
    -- Giới hạn số lần sử dụng coupon (NULL = không giới hạn)

    used_count INT DEFAULT 0 CHECK (used_count >= 0),
    -- Số lần coupon đã được sử dụng

    expired_at DATETIME NULL,
    -- Thời gian hết hiệu lực coupon (NULL = không có hạn)

    status VARCHAR(20)
        CHECK (status IN ('active', 'inactive')),
    -- Trạng thái: active (đang hoạt động), inactive (không hoạt động)

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo coupon

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_coupons_instructor
        FOREIGN KEY (instructor_id) REFERENCES users(id)
);

-- =========================
-- CARTS
-- =========================
CREATE TABLE carts (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh giỏ hàng

    user_id INT UNIQUE NOT NULL,
    -- Tham chiếu đến bảng users, mỗi user có 1 giỏ hàng duy nhất

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo giỏ hàng

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_carts_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================
-- CART ITEMS
-- =========================
CREATE TABLE cart_items (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh item trong giỏ

    cart_id INT NOT NULL,
    -- Tham chiếu đến bảng carts, item này thuộc giỏ nào

    course_id INT NOT NULL,
    -- Tham chiếu đến bảng courses, khóa học nào được thêm vào giỏ

    added_at DATETIME DEFAULT GETDATE(),
    -- Thời gian thêm vào giỏ
    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo bản ghi
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_cart_items_cart
        FOREIGN KEY (cart_id) REFERENCES carts(id),

    CONSTRAINT FK_cart_items_course
        FOREIGN KEY (course_id) REFERENCES courses(id),

    -- Constraint unique để tránh thêm cùng khóa học 2 lần vào giỏ
    CONSTRAINT UQ_cart_course UNIQUE(cart_id, course_id)
);

-- =========================
-- CART INSTRUCTOR COUPONS
-- =========================
CREATE TABLE cart_instructor_coupons (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh mối quan hệ

    cart_id INT NOT NULL,
    -- Tham chiếu đến bảng carts, giỏ nào áp dụng coupon

    instructor_id INT NOT NULL,
    -- Tham chiếu đến bảng users, coupon của giáo viên nào

    coupon_id INT NOT NULL,
    -- Tham chiếu đến bảng coupons, coupon nào được áp dụng

    applied_at DATETIME DEFAULT GETDATE(),
    -- Thời gian áp dụng coupon
    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo bản ghi
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_cart_coupon_cart
        FOREIGN KEY (cart_id) REFERENCES carts(id),

    CONSTRAINT FK_cart_coupon_instructor
        FOREIGN KEY (instructor_id) REFERENCES users(id),

    CONSTRAINT FK_cart_coupon_coupon
        FOREIGN KEY (coupon_id) REFERENCES coupons(id),

    -- Constraint unique để tránh áp dụng coupon cùng giáo viên 2 lần
    CONSTRAINT UQ_cart_instructor UNIQUE(cart_id, instructor_id)
);


-- =========================
-- ORDERS
-- =========================
CREATE TABLE orders (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh đơn hàng

    user_id INT NOT NULL,
    -- Tham chiếu đến bảng users, học viên tạo đơn hàng

    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    -- Tổng tiền trước khi giảm giá

    discount_amount DECIMAL(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
    -- Tổng tiền giảm từ tất cả coupons

    status VARCHAR(20)
        CHECK (status IN ('pending', 'paid', 'completed', 'cancelled', 'expired')),
    -- Trạng thái đơn hàng:
    -- pending (chờ thanh toán), paid (đã thanh toán), completed (hoàn tất),
    -- cancelled (hủy), expired (hết hạn thanh toán)

    payment_method VARCHAR(50) NULL,
    -- Phương thức thanh toán (ví dụ: 'MOMO', 'VNPAY', 'CARD')

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo đơn hàng

    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

    CONSTRAINT FK_orders_user
        FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================
-- ORDER ITEMS
-- =========================
CREATE TABLE order_items (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh item trong đơn hàng

    order_id INT NOT NULL,
    -- Tham chiếu đến bảng orders, item này thuộc đơn hàng nào

    course_id INT NOT NULL,
    -- Tham chiếu đến bảng courses, khóa học nào được thanh toán

    coupon_id INT NULL,
    -- Tham chiếu đến bảng coupons, coupon được áp dụng cho item này (nếu có)

    price_snapshot DECIMAL(10,2) NOT NULL CHECK (price_snapshot >= 0),
    -- Giá gốc khóa học tại thời điểm tạo đơn (snapshot)

    discount_amount DECIMAL(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
    -- Tiền giảm từ coupon (nếu có)

    final_price DECIMAL(10,2) NOT NULL CHECK (final_price >= 0),
    -- Giá cuối cùng = price_snapshot - discount_amount

    course_title_snapshot NVARCHAR(255) NULL,
    -- Tên khóa học tại thời điểm tạo đơn (snapshot, dùng cho lịch sử)

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
    -- Mã định danh ghi nhận thanh toán

    order_id INT NOT NULL,
    -- Tham chiếu đến bảng orders, thanh toán cho đơn hàng nào

    transaction_code VARCHAR(255) NULL,
    -- Mã giao dịch nội bộ

    gateway VARCHAR(50) NULL,
    -- Cổng thanh toán: 'MOMO', 'VNPAY', 'CARD', ...

    gateway_tx_id VARCHAR(255) NULL,
    -- Transaction ID từ gateway MOMO, VNPAY, ... (để trace)

    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    -- Số tiền thanh toán

    qr_code_url VARCHAR(500) NULL,
    -- URL mã QR động từ MOMO (để check QR trên điện thoại)

    status VARCHAR(20)
        CHECK (status IN ('success', 'failed', 'pending')),
    -- Trạng thái thanh toán: success (thành công), failed (thất bại), pending (chờ xác nhận)

    paid_at DATETIME NULL,
    -- Thời gian thanh toán thành công

    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo bản ghi thanh toán

    CONSTRAINT FK_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- =========================
-- COUPON USAGES
-- =========================
CREATE TABLE coupon_usages (
    id INT PRIMARY KEY IDENTITY(1,1),
    -- Mã định danh lần sử dụng coupon

    coupon_id INT NOT NULL,
    -- Tham chiếu đến bảng coupons, coupon nào được sử dụng

    user_id INT NOT NULL,
    -- Tham chiếu đến bảng users, người dùng nào sử dụng

    order_id INT NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    used_at DATETIME DEFAULT GETDATE(),
    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo bản ghi
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

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
    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo bản ghi
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

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
    created_at DATETIME DEFAULT GETDATE(),
    -- Thời gian tạo bản ghi
    updated_at DATETIME NULL,
    -- Thời gian cập nhật gần nhất

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

-- =========================
-- INSTRUCTOR USER (SAMPLE)
-- =========================
-- Tạo một giáo viên mẫu (role_id = 3 : instructor)
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
    3,
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

-- =========================
-- SAMPLE LESSON 2
-- =========================
-- Bài học 2: Kiểu dữ liệu và khai báo biến
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

-- ==========
-- QUIZ 2
-- ==========
-- Quiz cho bài học 2: Kiểu dữ liệu và biến
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

-- ==========
-- QUIZ 2 - QUESTION 1
-- ==========
-- Câu hỏi 1: Kiểu dữ liệu cho số nguyên
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

-- Đáp án cho Q1
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

-- ==========
-- QUIZ 2 - QUESTION 2
-- ==========
-- Câu hỏi 2: Từ khóa cho số thực
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

-- Đáp án cho Q2
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

-- =========================
-- SAMPLE LESSON 3
-- =========================
-- Bài học 3: Xuất dữ liệu với printf
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

-- ==========
-- QUIZ 3
-- ==========
-- Quiz cho bài học 3: Hàm printf
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

-- ==========
-- QUIZ 3 - QUESTION 1
-- ==========
-- Câu hỏi 1: Hàm xuất dữ liệu
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

-- ==========
-- QUIZ 3 - QUESTION 2
-- ==========
-- Câu hỏi 2: %d trong printf
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

-- =========================
-- SAMPLE LESSON 4
-- =========================
-- Bài học 4: Nhập dữ liệu với scanf
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

-- ==========
-- QUIZ 4
-- ==========
-- Quiz cho bài học 4: Hàm scanf
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

-- ==========
-- QUIZ 4 - QUESTION 1
-- ==========
-- Câu hỏi 1: Hàm nhập dữ liệu
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

-- ==========
-- QUIZ 4 - QUESTION 2
-- ==========
-- Câu hỏi 2: Dấu & trong scanf
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

-- =========================
-- SAMPLE DATA COMPLETE
-- =========================
GO
