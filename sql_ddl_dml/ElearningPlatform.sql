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
IF NOT EXISTS (SELECT 1 FROM roles WHERE name = 'admin')
    INSERT INTO roles (name, description) VALUES ('admin', N'Quản trị hệ thống');

IF NOT EXISTS (SELECT 1 FROM roles WHERE name = 'manager')
    INSERT INTO roles (name, description) VALUES ('manager', N'Quản lý nội dung');

IF NOT EXISTS (SELECT 1 FROM roles WHERE name = 'instructor')
    INSERT INTO roles (name, description) VALUES ('instructor', N'Giảng viên');

IF NOT EXISTS (SELECT 1 FROM roles WHERE name = 'learner')
    INSERT INTO roles (name, description) VALUES ('learner', N'Học viên');

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

    created_at DATETIME DEFAULT GETDATE(),
     

    updated_at DATETIME NULL, 

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

    updated_at DATETIME NULL, 

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

    'videos/L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2003.%20C%C3%A1ch%20xu%E1%BA%A5t%20d%E1%BB%AF%20li%E1%BB%87u%20ra%20m%C3%A0n%20h%C3%ICnh%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20H%C3%A0m%20printf%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C.mp4',

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
-- EXTRA SECTIONS FOR COURSE ID = 1
-- =========================
DECLARE @Section2Id INT;
INSERT INTO course_sections (course_id, title, position)
VALUES (1, N'Câu lệnh điều kiện và vòng lặp', 2);
SET @Section2Id = SCOPE_IDENTITY();

INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status)
VALUES (@Section2Id, N'Bài 5 - Câu lệnh if else', 'videos/Recording 2026-05-28 212131.mp4', 780, 1, 1, 'approved');
DECLARE @Lesson5Id INT = SCOPE_IDENTITY();
INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@Lesson5Id, N'Quiz - Câu lệnh if else', 70);
DECLARE @Quiz5Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz5Id, N'Câu lệnh nào dùng để rẽ nhánh trong C?', 'single', 1, 1);
DECLARE @Q51Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q51Id, N'if else', 1), (@Q51Id, N'switch case', 0), (@Q51Id, N'for', 0), (@Q51Id, N'while', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz5Id, N'Điều kiện trong if thường có kiểu dữ liệu gì?', 'single', 1, 2);
DECLARE @Q52Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q52Id, N'Boolean', 1), (@Q52Id, N'String', 0), (@Q52Id, N'Char', 0), (@Q52Id, N'Float', 0);

INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status)
VALUES (@Section2Id, N'Bài 6 - Câu lệnh switch case', 'videos/Recording 2026-05-28 212131.mp4', 840, 2, 1, 'approved');
DECLARE @Lesson6Id INT = SCOPE_IDENTITY();
INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@Lesson6Id, N'Quiz - Câu lệnh switch case', 70);
DECLARE @Quiz6Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz6Id, N'Switch case thường dùng để làm gì?', 'single', 1, 1);
DECLARE @Q61Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q61Id, N'Chọn một nhánh theo giá trị', 1), (@Q61Id, N'Lặp vô hạn', 0), (@Q61Id, N'Khai báo biến', 0), (@Q61Id, N'Tạo hàm', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz6Id, N'Từ khóa nào dùng để thoát khỏi case?', 'single', 1, 2);
DECLARE @Q62Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q62Id, N'break', 1), (@Q62Id, N'continue', 0), (@Q62Id, N'return', 0), (@Q62Id, N'exit', 0);

INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status)
VALUES (@Section2Id, N'Bài 7 - Vòng lặp for và while', 'videos/Recording 2026-05-28 212131.mp4', 900, 3, 1, 'approved');
DECLARE @Lesson7Id INT = SCOPE_IDENTITY();
INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@Lesson7Id, N'Quiz - Vòng lặp for và while', 70);
DECLARE @Quiz7Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz7Id, N'Vòng lặp nào thường biết trước số lần lặp?', 'single', 1, 1);
DECLARE @Q71Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q71Id, N'for', 1), (@Q71Id, N'while', 0), (@Q71Id, N'do while', 0), (@Q71Id, N'switch', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz7Id, N'Câu lệnh nào kiểm tra điều kiện trước khi lặp?', 'single', 1, 2);
DECLARE @Q72Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q72Id, N'while', 1), (@Q72Id, N'if', 0), (@Q72Id, N'switch', 0), (@Q72Id, N'goto', 0);

DECLARE @Section3Id INT;
INSERT INTO course_sections (course_id, title, position)
VALUES (1, N'Mảng và chuỗi', 3);
SET @Section3Id = SCOPE_IDENTITY();

INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status)
VALUES (@Section3Id, N'Bài 8 - Khai báo và truy cập mảng', 'videos/Recording 2026-05-28 212131.mp4', 870, 1, 1, 'approved');
DECLARE @Lesson8Id INT = SCOPE_IDENTITY();
INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@Lesson8Id, N'Quiz - Mảng trong C', 70);
DECLARE @Quiz8Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz8Id, N'Chỉ số phần tử đầu tiên của mảng trong C là gì?', 'single', 1, 1);
DECLARE @Q81Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q81Id, N'0', 1), (@Q81Id, N'1', 0), (@Q81Id, N'-1', 0), (@Q81Id, N'Kích thước mảng', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz8Id, N'Mảng trong C có đặc điểm nào?', 'single', 1, 2);
DECLARE @Q82Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q82Id, N'Lưu các phần tử cùng kiểu dữ liệu', 1), (@Q82Id, N'Lưu mọi kiểu dữ liệu', 0), (@Q82Id, N'Không có kích thước', 0), (@Q82Id, N'Chỉ lưu chuỗi', 0);

INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status)
VALUES (@Section3Id, N'Bài 9 - Duyệt mảng với vòng lặp', 'videos/Recording 2026-05-28 212131.mp4', 930, 2, 1, 'approved');
DECLARE @Lesson9Id INT = SCOPE_IDENTITY();
INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@Lesson9Id, N'Quiz - Duyệt mảng', 70);
DECLARE @Quiz9Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz9Id, N'Vòng lặp nào thường dùng để duyệt mảng?', 'single', 1, 1);
DECLARE @Q91Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q91Id, N'for', 1), (@Q91Id, N'switch', 0), (@Q91Id, N'goto', 0), (@Q91Id, N'break', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz9Id, N'Độ dài mảng tĩnh trong C được xác định khi nào?', 'single', 1, 2);
DECLARE @Q92Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q92Id, N'Khi khai báo', 1), (@Q92Id, N'Khi chạy chương trình', 0), (@Q92Id, N'Khi in ra', 0), (@Q92Id, N'Khi kết thúc', 0);

INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status)
VALUES (@Section3Id, N'Bài 10 - Xử lý chuỗi trong C', 'videos/Recording 2026-05-28 212131.mp4', 960, 3, 1, 'approved');
DECLARE @Lesson10Id INT = SCOPE_IDENTITY();
INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@Lesson10Id, N'Quiz - Xử lý chuỗi', 70);
DECLARE @Quiz10Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz10Id, N'Chuỗi trong C kết thúc bằng ký tự nào?', 'single', 1, 1);
DECLARE @Q101Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q101Id, N'\\0', 1), (@Q101Id, N'\n', 0), (@Q101Id, N'space', 0), (@Q101Id, N'#', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz10Id, N'Hàm nào thường dùng để đo độ dài chuỗi?', 'single', 1, 2);
DECLARE @Q102Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q102Id, N'strlen', 1), (@Q102Id, N'strcpy', 0), (@Q102Id, N'printf', 0), (@Q102Id, N'scanf', 0);

DECLARE @Section4Id INT;
INSERT INTO course_sections (course_id, title, position)
VALUES (1, N'Hàm và con trỏ', 4);
SET @Section4Id = SCOPE_IDENTITY();

INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status)
VALUES (@Section4Id, N'Bài 11 - Hàm trong C', 'videos/Recording 2026-05-28 212131.mp4', 840, 1, 1, 'approved');
DECLARE @Lesson11Id INT = SCOPE_IDENTITY();
INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@Lesson11Id, N'Quiz - Hàm trong C', 70);
DECLARE @Quiz11Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz11Id, N'Mục đích của hàm trong C là gì?', 'single', 1, 1);
DECLARE @Q111Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q111Id, N'Tái sử dụng và tổ chức code', 1), (@Q111Id, N'Tăng dung lượng RAM', 0), (@Q111Id, N'Xóa biến toàn cục', 0), (@Q111Id, N'Thay thế vòng lặp', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz11Id, N'Từ khóa nào thường dùng để khai báo hàm trả về số nguyên?', 'single', 1, 2);
DECLARE @Q112Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q112Id, N'int', 1), (@Q112Id, N'void', 0), (@Q112Id, N'char', 0), (@Q112Id, N'float', 0);

INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status)
VALUES (@Section4Id, N'Bài 12 - Tham số và giá trị trả về', 'videos/Recording 2026-05-28 212131.mp4', 900, 2, 1, 'approved');
DECLARE @Lesson12Id INT = SCOPE_IDENTITY();
INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@Lesson12Id, N'Quiz - Tham số và giá trị trả về', 70);
DECLARE @Quiz12Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz12Id, N'Tham số hàm được truyền vào khi nào?', 'single', 1, 1);
DECLARE @Q121Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q121Id, N'Khi gọi hàm', 1), (@Q121Id, N'Khi biên dịch', 0), (@Q121Id, N'Khi import file', 0), (@Q121Id, N'Khi kết thúc hàm', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz12Id, N'Giá trị trả về của hàm được khai báo bằng gì?', 'single', 1, 2);
DECLARE @Q122Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q122Id, N'Kiểu dữ liệu trả về', 1), (@Q122Id, N'Tên hàm', 0), (@Q122Id, N'Số tham số', 0), (@Q122Id, N'Tên biến cục bộ', 0);

INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status)
VALUES (@Section4Id, N'Bài 13 - Con trỏ cơ bản', 'videos/Recording 2026-05-28 212131.mp4', 980, 3, 1, 'approved');
DECLARE @Lesson13Id INT = SCOPE_IDENTITY();
INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@Lesson13Id, N'Quiz - Con trỏ cơ bản', 70);
DECLARE @Quiz13Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz13Id, N'Con trỏ lưu gì?', 'single', 1, 1);
DECLARE @Q131Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q131Id, N'Địa chỉ bộ nhớ', 1), (@Q131Id, N'Giá trị chuỗi', 0), (@Q131Id, N'Tên biến', 0), (@Q131Id, N'Kết quả hàm', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@Quiz13Id, N'Toán tử nào dùng để lấy địa chỉ biến?', 'single', 1, 2);
DECLARE @Q132Id INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct)
VALUES (@Q132Id, N'&', 1), (@Q132Id, N'*', 0), (@Q132Id, N'%', 0), (@Q132Id, N'#', 0);

-- =========================
-- LESSON MATERIALS
-- =========================
INSERT INTO lesson_materials (instructor_id, course_id, lesson_id, file_name, file_url, file_type, created_at)
VALUES (
           1,  -- instructor_id (thay bằng ID giảng viên thực tế)
           1,  -- course_id (khóa học 1)
           1,  -- lesson_id (bài học 1)
           '[28Tech] BUOI 1.pdf',  -- file_name
           '%5B28Tech%5D.%20BUOI%201.pdf',  -- file_url
           'pdf',  -- file_type
           GETDATE()  -- created_at
       );

-- =========================
-- SAMPLE DATA COMPLETE
-- =========================
GO

-- =========================
-- ADDITIONAL COURSES (Course 2,3,4) - mirror structure of Course 1
-- =========================

-- COURSE 2
DECLARE @Course2Id INT;
INSERT INTO courses (instructor_id, category_id, title, description, thumbnail_url, price, level, status)
VALUES (1, 1, N'Lập Trình C Nâng Cao - 28Tech', N'Khóa học nâng cao lập trình C', 'course-thumbnails/2aOboQZWp6Ov5iGTAZLOlCgmiOhOKsGgeQU1cI0O.jpg', 0, 'intermediate', 'published');
SET @Course2Id = SCOPE_IDENTITY();

-- Sections and lessons for Course 2
DECLARE @C2S1 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course2Id, N'Giới thiệu', 1); SET @C2S1 = SCOPE_IDENTITY();
DECLARE @C2L1 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S1, N'Bài 1 - Giới thiệu ngôn ngữ C', 'videos/Recording 2026-05-28 212131.mp4', 600, 1, 1, 'approved'); SET @C2L1 = SCOPE_IDENTITY();
DECLARE @C2L2 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S1, N'Bài 2 - Kiểu dữ liệu và khai báo biến trong C', 'videos/L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2002.%20Ki%E1%BB%83u%20d%E1%BB%AF%20li%E1%BB%87u%20v%C3%A0%20c%C3%A1ch%20khai%20b%C3%A1o%20bi%E1%BA%BFn%20trong%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C-C++.mp4', 900, 2, 1, 'approved'); SET @C2L2 = SCOPE_IDENTITY();
DECLARE @C2L3 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S1, N'Bài 3 - Xuất dữ liệu với printf', 'videos/L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2003.%20C%C3%A1ch%20xu%E1%BA%A5t%20d%E1%BB%AF%20li%E1%BB%87u%20ra%20m%C3%A0n%20h%C3%ACnh%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20H%C3%A0m%20printf%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C.mp4', 850, 3, 1, 'approved'); SET @C2L3 = SCOPE_IDENTITY();

-- Seed quizzes for C2 lessons s1
-- For brevity, add one quiz with two simple questions per lesson
INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@C2L1, N'Quiz - Giới thiệu', 70); DECLARE @C2Q1 INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@C2Q1, N'Giới thiệu C chủ yếu dùng cho gì?', 'single', 1, 1); DECLARE @C2Q11 INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@C2Q11, N'Lập trình hệ thống', 1), (@C2Q11, N'Trình duyệt', 0), (@C2Q11, N'Office', 0), (@C2Q11, N'Khác', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@C2Q1, N'C có bước biên dịch hay thông dịch?', 'single', 1, 2); DECLARE @C2Q12 INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@C2Q12, N'Biên dịch', 1), (@C2Q12, N'Thông dịch', 0), (@C2Q12, N'Cả hai', 0), (@C2Q12, N'Không rõ', 0);

INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@C2L2, N'Quiz - Kiểu dữ liệu', 70); DECLARE @C2Q2 INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@C2Q2, N'Kiểu dữ liệu nào lưu số nguyên?', 'single', 1, 1); DECLARE @C2Q21 INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@C2Q21, N'int', 1), (@C2Q21, N'float', 0), (@C2Q21, N'double', 0), (@C2Q21, N'char', 0);
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@C2Q2, N'Kiểu để lưu ký tự?', 'single', 1, 2); DECLARE @C2Q22 INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@C2Q22, N'char', 1), (@C2Q22, N'string', 0), (@C2Q22, N'int', 0), (@C2Q22, N'float', 0);

INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@C2L3, N'Quiz - printf', 70); DECLARE @C2Q3 INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@C2Q3, N'Hàm printf dùng để?', 'single', 1, 1); DECLARE @C2Q31 INT = SCOPE_IDENTITY();
INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@C2Q31, N'Xuất dữ liệu', 1), (@C2Q31, N'Nhập dữ liệu', 0), (@C2Q31, N'Thực thi', 0), (@C2Q31, N'Khác', 0);

-- create more sections for course 2 (positions 2..4) and lessons/quizzes
DECLARE @C2S2 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course2Id, N'Cấu trúc điều khiển', 2); SET @C2S2 = SCOPE_IDENTITY();
DECLARE @C2S3 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course2Id, N'Mảng và chuỗi', 3); SET @C2S3 = SCOPE_IDENTITY();
DECLARE @C2S4 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course2Id, N'Hàm và con trỏ', 4); SET @C2S4 = SCOPE_IDENTITY();

-- For each of these sections, insert 3 lessons and a quiz (use same video file)
-- Section 2 lessons
DECLARE @c2l4 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S2, N'Bài 5 - Câu lệnh if else', 'videos/Recording 2026-05-28 212131.mp4', 780, 1, 1, 'approved'); SET @c2l4 = SCOPE_IDENTITY();
DECLARE @c2l5 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S2, N'Bài 6 - Câu lệnh switch case', 'videos/Recording 2026-05-28 212131.mp4', 840, 2, 1, 'approved'); SET @c2l5 = SCOPE_IDENTITY();
DECLARE @c2l6 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S2, N'Bài 7 - Vòng lặp for và while', 'videos/Recording 2026-05-28 212131.mp4', 900, 3, 1, 'approved'); SET @c2l6 = SCOPE_IDENTITY();

INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@c2l4, N'Quiz - If else', 70); DECLARE @c2q4 INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@c2q4, N'If else để làm gì?', 'single', 1, 1); DECLARE @c2q41 INT = SCOPE_IDENTITY(); INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@c2q41, N'Rẽ nhánh',1),(@c2q41,N'Lặp',0),(@c2q41,N'Khai báo',0),(@c2q41,N'Khác',0);

INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@c2l5, N'Quiz - Switch', 70); DECLARE @c2q5 INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@c2q5, N'Switch dùng để?', 'single', 1, 1); DECLARE @c2q51 INT = SCOPE_IDENTITY(); INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@c2q51, N'Chọn nhánh theo giá trị',1),(@c2q51,N'Lặp',0),(@c2q51,N'Khai báo',0),(@c2q51,N'Khác',0);

INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@c2l6, N'Quiz - Vòng lặp', 70); DECLARE @c2q6 INT = SCOPE_IDENTITY();
INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@c2q6, N'Vòng lặp for dùng khi?', 'single', 1, 1); DECLARE @c2q61 INT = SCOPE_IDENTITY(); INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@c2q61, N'Biết trước số lần lặp',1),(@c2q61,N'Không biết trước',0),(@c2q61,N'Khai báo',0),(@c2q61,N'Khác',0);

-- Section 3 lessons (array/string)
DECLARE @c2l7 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S3, N'Bài 8 - Khai báo mảng', 'videos/Recording 2026-05-28 212131.mp4', 870, 1, 1, 'approved'); SET @c2l7 = SCOPE_IDENTITY();
DECLARE @c2l8 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S3, N'Bài 9 - Duyệt mảng', 'videos/Recording 2026-05-28 212131.mp4', 930, 2, 1, 'approved'); SET @c2l8 = SCOPE_IDENTITY();
DECLARE @c2l9 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S3, N'Bài 10 - Chuỗi', 'videos/Recording 2026-05-28 212131.mp4', 960, 3, 1, 'approved'); SET @c2l9 = SCOPE_IDENTITY();

INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@c2l7, N'Quiz - Mảng', 70); DECLARE @c2q7 INT = SCOPE_IDENTITY(); INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@c2q7, N'Chỉ số bắt đầu của mảng?', 'single', 1, 1); DECLARE @c2q71 INT = SCOPE_IDENTITY(); INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@c2q71, N'0',1),(@c2q71,N'1',0),(@c2q71,N'-1',0),(@c2q71,N'Khác',0);

INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@c2l8, N'Quiz - Duyệt mảng', 70); DECLARE @c2q8 INT = SCOPE_IDENTITY(); INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@c2q8, N'Vòng lặp hay dùng để duyệt mảng?', 'single', 1, 1); DECLARE @c2q81 INT = SCOPE_IDENTITY(); INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@c2q81, N'for',1),(@c2q81,N'while',0),(@c2q81,N'switch',0),(@c2q81,N'Khác',0);

INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@c2l9, N'Quiz - Chuỗi', 70); DECLARE @c2q9 INT = SCOPE_IDENTITY(); INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@c2q9, N'Chuỗi kết thúc bằng gì?', 'single', 1, 1); DECLARE @c2q91 INT = SCOPE_IDENTITY(); INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@c2q91, N'\0',1),(@c2q91,N'\n',0),(@c2q91,N'space',0),(@c2q91,N'Khác',0);

-- Section 4 lessons (functions/pointers)
DECLARE @c2l10 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S4, N'Bài 11 - Hàm', 'videos/Recording 2026-05-28 212131.mp4', 840, 1, 1, 'approved'); SET @c2l10 = SCOPE_IDENTITY();
DECLARE @c2l11 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S4, N'Bài 12 - Tham số', 'videos/Recording 2026-05-28 212131.mp4', 900, 2, 1, 'approved'); SET @c2l11 = SCOPE_IDENTITY();
DECLARE @c2l12 INT; INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C2S4, N'Bài 13 - Con trỏ', 'videos/Recording 2026-05-28 212131.mp4', 980, 3, 1, 'approved'); SET @c2l12 = SCOPE_IDENTITY();

INSERT INTO quizzes (lesson_id, title, pass_score) VALUES (@c2l12, N'Quiz - Con trỏ', 70); DECLARE @c2q12 INT = SCOPE_IDENTITY(); INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position) VALUES (@c2q12, N'Con trỏ lưu gì?', 'single', 1, 1); DECLARE @c2q121 INT = SCOPE_IDENTITY(); INSERT INTO quiz_answers (question_id, answer_text, is_correct) VALUES (@c2q121, N'Địa chỉ bộ nhớ',1),(@c2q121,N'Giá trị',0),(@c2q121,N'Tên biến',0),(@c2q121,N'Khác',0);

-- lesson material for one of course2 lessons
INSERT INTO lesson_materials (instructor_id, course_id, lesson_id, file_name, file_url, file_type, created_at)
VALUES (1, @Course2Id, @c2l12, N'[28Tech] COURSE2_LESSON13.pdf', '%5BCOURSE2%5D.%20LESSON13.pdf', 'pdf', GETDATE());

-- COURSE 3 (mirror structure)
DECLARE @Course3Id INT;
INSERT INTO courses (instructor_id, category_id, title, description, thumbnail_url, price, level, status)
VALUES (1,1,N'Lập Trình C Thực Hành - 28Tech', N'Bài tập thực hành và project nhỏ với C','course-thumbnails/2aOboQZWp6Ov5iGTAZLOlCgmiOhOKsGgeQU1cI0O.jpg',0,'beginner','published');
SET @Course3Id = SCOPE_IDENTITY();

-- Use same pattern: create 4 sections with 3 lessons each; to save space, reuse Recording video for all lessons
DECLARE @C3S1 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course3Id, N'Giới thiệu',1); SET @C3S1 = SCOPE_IDENTITY();
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S1, N'Bài 1 - Giới thiệu', 'videos/Recording 2026-05-28 212131.mp4',600,1,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S1, N'Bài 2 - Kiểu dữ liệu', 'videos/Recording 2026-05-28 212131.mp4',900,2,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S1, N'Bài 3 - printf', 'videos/Recording 2026-05-28 212131.mp4',850,3,1,'approved');
DECLARE @C3S2 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course3Id, N'Cấu trúc điều khiển',2); SET @C3S2 = SCOPE_IDENTITY();
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S2, N'Bài 4', 'videos/Recording 2026-05-28 212131.mp4',780,1,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S2, N'Bài 5', 'videos/Recording 2026-05-28 212131.mp4',840,2,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S2, N'Bài 6', 'videos/Recording 2026-05-28 212131.mp4',900,3,1,'approved');
DECLARE @C3S3 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course3Id, N'Mảng và chuỗi',3); SET @C3S3 = SCOPE_IDENTITY();
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S3, N'Bài 7', 'videos/Recording 2026-05-28 212131.mp4',870,1,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S3, N'Bài 8', 'videos/Recording 2026-05-28 212131.mp4',930,2,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S3, N'Bài 9', 'videos/Recording 2026-05-28 212131.mp4',960,3,1,'approved');
DECLARE @C3S4 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course3Id, N'Hàm và con trỏ',4); SET @C3S4 = SCOPE_IDENTITY();
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S4, N'Bài 10', 'videos/Recording 2026-05-28 212131.mp4',840,1,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S4, N'Bài 11', 'videos/Recording 2026-05-28 212131.mp4',900,2,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C3S4, N'Bài 12', 'videos/Recording 2026-05-28 212131.mp4',980,3,1,'approved');

INSERT INTO lesson_materials (instructor_id, course_id, lesson_id, file_name, file_url, file_type, created_at) VALUES (1, @Course3Id, (SELECT TOP 1 id FROM lessons WHERE section_id = @C3S4 ORDER BY position DESC), N'[28Tech] COURSE3_LESSON.pdf', '%5BCOURSE3%5D.%20LESSON.pdf', 'pdf', GETDATE());

-- COURSE 4 (mirror structure)
DECLARE @Course4Id INT;
INSERT INTO courses (instructor_id, category_id, title, description, thumbnail_url, price, level, status)
VALUES (1,1,N'Thuật Toán C với 28Tech', N'Giải thuật và cấu trúc dữ liệu cơ bản bằng C','course-thumbnails/2aOboQZWp6Ov5iGTAZLOlCgmiOhOKsGgeQU1cI0O.jpg',0,'advanced','published');
SET @Course4Id = SCOPE_IDENTITY();

-- create four sections and three lessons each using same recording
DECLARE @C4S1 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course4Id, N'Giới thiệu',1); SET @C4S1 = SCOPE_IDENTITY();
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S1, N'Bài 1', 'videos/Recording 2026-05-28 212131.mp4',600,1,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S1, N'Bài 2', 'videos/Recording 2026-05-28 212131.mp4',900,2,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S1, N'Bài 3', 'videos/Recording 2026-05-28 212131.mp4',850,3,1,'approved');
DECLARE @C4S2 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course4Id, N'Cơ sở giải thuật',2); SET @C4S2 = SCOPE_IDENTITY();
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S2, N'Bài 4', 'videos/Recording 2026-05-28 212131.mp4',780,1,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S2, N'Bài 5', 'videos/Recording 2026-05-28 212131.mp4',840,2,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S2, N'Bài 6', 'videos/Recording 2026-05-28 212131.mp4',900,3,1,'approved');
DECLARE @C4S3 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course4Id, N'Cấu trúc dữ liệu',3); SET @C4S3 = SCOPE_IDENTITY();
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S3, N'Bài 7', 'videos/Recording 2026-05-28 212131.mp4',870,1,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S3, N'Bài 8', 'videos/Recording 2026-05-28 212131.mp4',930,2,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S3, N'Bài 9', 'videos/Recording 2026-05-28 212131.mp4',960,3,1,'approved');
DECLARE @C4S4 INT; INSERT INTO course_sections (course_id, title, position) VALUES (@Course4Id, N'Hàm và tối ưu',4); SET @C4S4 = SCOPE_IDENTITY();
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S4, N'Bài 10', 'videos/Recording 2026-05-28 212131.mp4',840,1,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S4, N'Bài 11', 'videos/Recording 2026-05-28 212131.mp4',900,2,1,'approved');
INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status) VALUES (@C4S4, N'Bài 12', 'videos/Recording 2026-05-28 212131.mp4',980,3,1,'approved');

INSERT INTO lesson_materials (instructor_id, course_id, lesson_id, file_name, file_url, file_type, created_at) VALUES (1, @Course4Id, (SELECT TOP 1 id FROM lessons WHERE section_id = @C4S4 ORDER BY position DESC), N'[28Tech] COURSE4_LESSON.pdf', '%5BCOURSE4%5D.%20LESSON.pdf', 'pdf', GETDATE());

-- =========================
-- ADDITIONAL COURSES (Course 5 -> Course 14)
-- 4 sections/course, 3 lessons/section, quiz per lesson (2 questions)
-- =========================
DECLARE @CourseIndex INT = 5;
DECLARE @NewCourseId INT;
DECLARE @SectionPos INT;
DECLARE @SectionId INT;
DECLARE @SectionTitle NVARCHAR(255);
DECLARE @LessonPos INT;
DECLARE @LessonId INT;
DECLARE @LessonGlobalPos INT;
DECLARE @QuizId INT;
DECLARE @QuestionId1 INT;
DECLARE @QuestionId2 INT;
DECLARE @LastLessonId INT;

WHILE @CourseIndex <= 14
    BEGIN
        INSERT INTO courses (instructor_id, category_id, title, description, thumbnail_url, price, level, status)
        VALUES (
                   1,
                   1,
                   CONCAT(N'Lập Trình C Chuyên Đề ', @CourseIndex, N' - 28Tech'),
                   CONCAT(N'Khóa học chuyên đề C số ', @CourseIndex),
                   'course-thumbnails/2aOboQZWp6Ov5iGTAZLOlCgmiOhOKsGgeQU1cI0O.jpg',
                   0,
                   CASE
                       WHEN @CourseIndex % 3 = 2 THEN 'beginner'
                       WHEN @CourseIndex % 3 = 0 THEN 'intermediate'
                       ELSE 'advanced'
                       END,
                   'published'
               );
        SET @NewCourseId = SCOPE_IDENTITY();

        SET @SectionPos = 1;
        WHILE @SectionPos <= 4
            BEGIN
                SET @SectionTitle = CASE @SectionPos
                                        WHEN 1 THEN N'Giới thiệu'
                                        WHEN 2 THEN N'Cấu trúc điều khiển'
                                        WHEN 3 THEN N'Mảng và chuỗi'
                                        ELSE N'Hàm và con trỏ'
                    END;

                INSERT INTO course_sections (course_id, title, position)
                VALUES (@NewCourseId, @SectionTitle, @SectionPos);
                SET @SectionId = SCOPE_IDENTITY();

                SET @LessonPos = 1;
                WHILE @LessonPos <= 3
                    BEGIN
                        SET @LessonGlobalPos = ((@SectionPos - 1) * 3) + @LessonPos;

                        INSERT INTO lessons (section_id, title, video_url, duration_seconds, position, is_published, moderation_status)
                        VALUES (
                                   @SectionId,
                                   CONCAT(N'Bài ', @LessonGlobalPos, N' - Chuyên đề ', @CourseIndex),
                                   'videos/Recording 2026-05-28 212131.mp4',
                                   600 + (@LessonGlobalPos * 35),
                                   @LessonPos,
                                   1,
                                   'approved'
                               );
                        SET @LessonId = SCOPE_IDENTITY();

                        INSERT INTO quizzes (lesson_id, title, pass_score)
                        VALUES (@LessonId, CONCAT(N'Quiz - Bài ', @LessonGlobalPos, N' - Khóa ', @CourseIndex), 70);
                        SET @QuizId = SCOPE_IDENTITY();

                        INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position)
                        VALUES (@QuizId, CONCAT(N'Bài ', @LessonGlobalPos, N' thuộc section nào?'), 'single', 1, 1);
                        SET @QuestionId1 = SCOPE_IDENTITY();
                        INSERT INTO quiz_answers (question_id, answer_text, is_correct)
                        VALUES (@QuestionId1, CONCAT(N'Section ', @SectionPos), 1),
                               (@QuestionId1, N'Section 5', 0),
                               (@QuestionId1, N'Section 6', 0),
                               (@QuestionId1, N'Section 7', 0);

                        INSERT INTO quiz_questions (quiz_id, question_text, question_type, points, position)
                        VALUES (@QuizId, CONCAT(N'Khóa học chuyên đề số mấy? (Bài ', @LessonGlobalPos, N')'), 'single', 1, 2);
                        SET @QuestionId2 = SCOPE_IDENTITY();
                        INSERT INTO quiz_answers (question_id, answer_text, is_correct)
                        VALUES (@QuestionId2, CAST(@CourseIndex AS NVARCHAR(10)), 1),
                               (@QuestionId2, N'1', 0),
                               (@QuestionId2, N'2', 0),
                               (@QuestionId2, N'3', 0);

                        SET @LessonPos = @LessonPos + 1;
                    END

                SET @SectionPos = @SectionPos + 1;
            END

        SET @LastLessonId = NULL;
        SELECT TOP 1 @LastLessonId = l.id
        FROM lessons l
                 INNER JOIN course_sections s ON l.section_id = s.id
        WHERE s.course_id = @NewCourseId
        ORDER BY s.position DESC, l.position DESC;

        INSERT INTO lesson_materials (instructor_id, course_id, lesson_id, file_name, file_url, file_type, created_at)
        VALUES (
                   1,
                   @NewCourseId,
                   @LastLessonId,
                   CONCAT(N'[28Tech] COURSE', @CourseIndex, N'_LESSON.pdf'),
                   CONCAT('%5BCOURSE', @CourseIndex, '%5D.%20LESSON.pdf'),
                   'pdf',
                   GETDATE()
               );

        SET @CourseIndex = @CourseIndex + 1;
    END


-- =========================
-- ADMIN USER
-- =========================
INSERT INTO users (
    role_id,
    first_name,
    last_name,
    email,
    phone,
    password_hash,
    avatar_url,
    status
)
VALUES (
    1,
    N'Đặng',
    N'Minh Quân',
    'admin@elearning.com',
    '0901234567',
    'admin123',
    NULL,
    'active'
);

-- ==========================================
-- INSTRUCTOR SAMPLE DATA
-- ==========================================
-------------STEP 1 : register as a Student---------------
INSERT INTO users
(
    role_id,
    first_name,
    last_name,
    email,
    phone,
    password_hash,
    status
)
VALUES
(4,N'Nguyễn Văn',N'An','nguyenvanan@gmail.com','0900000001','12345678','active'),
(4,N'Trần Minh',N'Bình','tranminhbinh@gmail.com','0900000002','12345678','active'),
(4,N'Lê Quốc',N'Cường','lequoccuong@gmail.com','0900000003','12345678','active'),
(4,N'Phạm Đức',N'Dũng','phamducdung@gmail.com','0900000004','12345678','active'),
(4,N'Hoàng Thu',N'Giang','hoangthugiang@gmail.com','0900000005','12345678','active'),
(4,N'Vũ Thanh',N'Hải','vuthanhhai@gmail.com','0900000006','12345678','active'),
(4,N'Đỗ Khánh',N'Huy','dokhanhhuy@gmail.com','0900000007','12345678','active'),
(4,N'Bùi Anh',N'Khoa','buianhkhoa@gmail.com','0900000008','12345678','active'),
(4,N'Đặng Quang',N'Long','dangquanglong@gmail.com','0900000009','12345678','active'),
(4,N'Phan Minh',N'Nam','phanminhnam@gmail.com','0900000010','12345678','active');

---------STEP 2 : Send request to become a instructor and manager approved
INSERT INTO instructor_requests
(
    user_id,
    cv_url,
    certificate_url,
    description,
    status,
    reviewed_by
)
VALUES
    (1,'https://blob/cv1.pdf','https://blob/cert1.pdf',N'5 năm kinh nghiệm Java Backend','approved',11),
    (2,'https://blob/cv2.pdf','https://blob/cert2.pdf',N'Chuyên gia Spring Boot','approved',11),
    (3,'https://blob/cv3.pdf','https://blob/cert3.pdf',N'Giảng viên SQL Server','approved',11),
    (4,'https://blob/cv4.pdf','https://blob/cert4.pdf',N'Giảng viên ReactJS','approved',11),
    (5,'https://blob/cv5.pdf','https://blob/cert5.pdf',N'Giảng viên Flutter','approved',11),
    (6,'https://blob/cv6.pdf','https://blob/cert6.pdf',N'Chuyên gia Azure Cloud','approved',11),
    (7,'https://blob/cv7.pdf','https://blob/cert7.pdf',N'Giảng viên Python Data Science','approved',11),
    (8,'https://blob/cv8.pdf','https://blob/cert8.pdf',N'Giảng viên DevOps','approved',11),
    (9,'https://blob/cv9.pdf','https://blob/cert9.pdf',N'Giảng viên Machine Learning','approved',11),
    (10,'https://blob/cv10.pdf','https://blob/cert10.pdf',N'Giảng viên UI/UX Design','approved',11);

--Manager cấp tiến hành cấp role
UPDATE users
SET role_id = 3,
    updated_at = GETDATE()
WHERE id BETWEEN 1 AND 10;
----*NOTE : coi như có 1 manager có user id là 11 và người này là người duyệt đơn



-- =========================
-- MANAGER USER
-- =========================
INSERT INTO users (
    role_id,
    first_name,
    last_name,
    email,
    phone,
    password_hash,
    avatar_url,
    status
)
VALUES (
    2,
    N'Lê',
    N'Thị Mai',
    'manager@elearning.com',
    '0912345678',
    'manager123',
    NULL,
    'active'
);


-- Seed test learner user Do Thanh and enroll into course id=1
IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'dothanh2572005@gmail.com')
    BEGIN
        DECLARE @learnerRoleId INT;
        SELECT @learnerRoleId = id FROM roles WHERE name = 'learner';
        IF @learnerRoleId IS NULL
            BEGIN
                INSERT INTO roles (name, description) VALUES ('learner', N'Học viên');
                SET @learnerRoleId = SCOPE_IDENTITY();
            END

        INSERT INTO users (role_id, first_name, last_name, email, phone, password_hash, avatar_url, google_id, status)
        VALUES (@learnerRoleId, N'Do', N'Thanh', 'dothanh2572005@gmail.com', NULL, '123', NULL, NULL, 'active');
    END

-- Enroll user into course id = 1 if course exists and enrollment not present
DECLARE @userId INT;
SELECT @userId = id FROM users WHERE email = 'dothanh2572005@gmail.com';
IF EXISTS (SELECT 1 FROM courses WHERE id = 1)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM enrollments WHERE user_id = @userId AND course_id = 1)
            BEGIN
                INSERT INTO enrollments (user_id, course_id, progress_percent)
                VALUES (@userId, 1, 0);
            END
    END
GO

