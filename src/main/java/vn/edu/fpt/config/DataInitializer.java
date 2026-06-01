package vn.edu.fpt.config;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.jspecify.annotations.NonNull;
import vn.edu.fpt.entity.*;
import vn.edu.fpt.repository.*;

import java.math.BigDecimal;
import java.util.Set;

@Component
@RequiredArgsConstructor // tự động sinh constructor với tất cả các field final nên không cần gán @Autowired cho từng repository
@Transactional
public class DataInitializer implements CommandLineRunner {

    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final CourseRepository courseRepository;
    private final CourseSectionRepository courseSectionRepository;
    private final LessonRepository lessonRepository;
    private final QuizRepository quizRepository;
    private final QuizQuestionRepository quizQuestionRepository;
    private final QuizAnswerRepository quizAnswerRepository;
    private final LessonMaterialRepository lessonMaterialRepository;
    private final EnrollmentRepository enrollmentRepository;

    @Override
    public void run(String @NonNull... args) {
        // Ensure default roles exist
        Role adminRole = roleRepository.findByName("admin").orElse(null);
        if (adminRole == null) {
            roleRepository.save(Role.builder()
                    .name("admin")
                    .description("Quản trị hệ thống")
                    .build());
        }

        Role managerRole = roleRepository.findByName("manager").orElse(null);
        if (managerRole == null) {
            roleRepository.save(Role.builder()
                    .name("manager")
                    .description("Quản lý nội dung")
                    .build());
        }

        Role instructorRole = roleRepository.findByName("instructor").orElse(null);
        if (instructorRole == null) {
            instructorRole = roleRepository.save(Role.builder()
                    .name("instructor")
                    .description("Giảng viên")
                    .build());
        }

        Role learnerRole = roleRepository.findByName("learner").orElse(null);
        if (learnerRole == null) {
            learnerRole = roleRepository.save(Role.builder()
                    .name("learner")
                    .description("Học viên")
                    .build());
        }

        User instructor = userRepository.findByEmail("28tech@gmail.com").orElse(null);
        if (instructor == null) {
            instructor = userRepository.save(User.builder()
                    .roles(Set.of(instructorRole))
                    .firstName("28")
                    .lastName("Tech")
                    .email("28tech@gmail.com")
                    .phone("0909999999")
                    .passwordHash("123456")
                    .status("active")
                    .build());
        }

        Category category = categoryRepository.save(Category.builder()
                .name("Lập trình")
                .description("Các khóa học lập trình")
                .status("active")
                .build());

        Course course = courseRepository.save(Course.builder()
                .instructor(instructor)
                .category(category)
                .title("Lập Trình C Cơ Bản - 28Tech")
                .description("Khóa học lập trình C cơ bản")
                .thumbnailUrl("2aOboQZWp6Ov5iGTAZLOlCgmiOhOKsGgeQU1cI0O.jpg")
                .price(BigDecimal.ZERO)
                .level("beginner")
                .status("published")
                .build());

        // Create 3 more courses similar to the first one
        Course course2 = courseRepository.save(Course.builder()
                .instructor(instructor)
                .category(category)
                .title("Lập Trình C Nâng Cao - 28Tech")
                .description("Khóa học nâng cao lập trình C")
                .thumbnailUrl("2aOboQZWp6Ov5iGTAZLOlCgmiOhOKsGgeQU1cI0O.jpg")
                .price(BigDecimal.ZERO)
                .level("intermediate")
                .status("published")
                .build());

        Course course3 = courseRepository.save(Course.builder()
                .instructor(instructor)
                .category(category)
                .title("Lập Trình C Thực Hành - 28Tech")
                .description("Bài tập thực hành và project nhỏ với C")
                .thumbnailUrl("2aOboQZWp6Ov5iGTAZLOlCgmiOhOKsGgeQU1cI0O.jpg")
                .price(BigDecimal.ZERO)
                .level("beginner")
                .status("published")
                .build());

        Course course4 = courseRepository.save(Course.builder()
                .instructor(instructor)
                .category(category)
                .title("Thuật Toán C với 28Tech")
                .description("Giải thuật và cấu trúc dữ liệu cơ bản bằng C")
                .thumbnailUrl("2aOboQZWp6Ov5iGTAZLOlCgmiOhOKsGgeQU1cI0O.jpg")
                .price(BigDecimal.ZERO)
                .level("advanced")
                .status("published")
                .build());

        CourseSection section = courseSectionRepository.save(CourseSection.builder()
                .course(course)
                .title("Giới thiệu")
                .position(1)
                .build());

        lessonRepository.save(Lesson.builder()
                .courseSection(section)
                .title("Bài 1 - Giới thiệu ngôn ngữ C")
                .videoUrl("Recording 2026-05-28 212131.mp4")
                .durationSeconds(600)
                .position(1)
                .published(true)
                .moderationStatus("approved")
                .build());

        Lesson lesson2 = lessonRepository.save(Lesson.builder()
                .courseSection(section)
                .title("Bài 2 - Kiểu dữ liệu và khai báo biến trong C")
                .videoUrl("L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2002.%20Ki%E1%BB%83u%20d%E1%BB%AF%20li%E1%BB%87u%20v%C3%A0%20c%C3%A1ch%20khai%20b%C3%A1o%20bi%E1%BA%BFn%20trong%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C-C++.mp4")
                .durationSeconds(900)
                .position(2)
                .published(true)
                .moderationStatus("approved")
                .build());

        Lesson lesson3 = lessonRepository.save(Lesson.builder()
                .courseSection(section)
                .title("Bài 3 - Xuất dữ liệu với printf")
                .videoUrl("L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2003.%20C%C3%A1ch%20xu%E1%BA%A5t%20d%E1%BB%AF%20li%E1%BB%87u%20ra%20m%C3%A0n%20h%C3%ACnh%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20H%C3%A0m%20printf%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C.mp4")
                .durationSeconds(850)
                .position(3)
                .published(true)
                .moderationStatus("approved")
                .build());

        Lesson lesson4 = lessonRepository.save(Lesson.builder()
                .courseSection(section)
                .title("Bài 4 - Nhập dữ liệu với scanf")
                .videoUrl("L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2004.%20C%C3%A1ch%20nh%E1%BA%ADp%20d%E1%BB%AF%20li%E1%BB%87u%20t%E1%BB%AB%20b%C3%A0n%20ph%C3%ADm%20trong%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C.mp4")
                .durationSeconds(920)
                .position(4)
                .published(true)
                .moderationStatus("approved")
                .build());

        seedQuizForLesson2(lesson2);
        seedQuizForLesson3(lesson3);
        seedQuizForLesson4(lesson4);

        CourseSection section2 = createSection(course, "Cấu trúc điều khiển", 2);
        Lesson lesson5 = createLesson(section2, "Bài 5 - Câu lệnh if else", "Recording 2026-05-28 212131.mp4", 780, 1);
        Lesson lesson6 = createLesson(section2, "Bài 6 - Câu lệnh switch case", "Recording 2026-05-28 212131.mp4", 840, 2);
        Lesson lesson7 = createLesson(section2, "Bài 7 - Vòng lặp for và while", "Recording 2026-05-28 212131.mp4", 900, 3);
        seedQuizWithTwoQuestions(lesson5,
                "Quiz - Câu lệnh if else",
                "Câu lệnh nào dùng để rẽ nhánh trong C?",
                "if else",
                new String[]{"switch case", "for", "while"},
                "Điều kiện trong if thường có kiểu dữ liệu gì?",
                "Boolean",
                new String[]{"String", "Char", "Float"});
        seedQuizWithTwoQuestions(lesson6,
                "Quiz - Câu lệnh switch case",
                "Switch case thường dùng để làm gì?",
                "Chọn một nhánh theo giá trị",
                new String[]{"Lặp vô hạn", "Khai báo biến", "Tạo hàm"},
                "Từ khóa nào dùng để thoát khỏi case?",
                "break",
                new String[]{"continue", "return", "exit"});
        seedQuizWithTwoQuestions(lesson7,
                "Quiz - Vòng lặp for và while",
                "Vòng lặp nào thường biết trước số lần lặp?",
                "for",
                new String[]{"while", "do while", "switch"},
                "Câu lệnh nào kiểm tra điều kiện trước khi lặp?",
                "while",
                new String[]{"if", "switch", "goto"});

        CourseSection section3 = createSection(course, "Mảng và chuỗi", 3);
        Lesson lesson8 = createLesson(section3, "Bài 8 - Khai báo và truy cập mảng", "Recording 2026-05-28 212131.mp4", 870, 1);
        Lesson lesson9 = createLesson(section3, "Bài 9 - Duyệt mảng với vòng lặp", "Recording 2026-05-28 212131.mp4", 930, 2);
        Lesson lesson10 = createLesson(section3, "Bài 10 - Xử lý chuỗi trong C", "Recording 2026-05-28 212131.mp4", 960, 3);
        seedQuizWithTwoQuestions(lesson8,
                "Quiz - Mảng trong C",
                "Chỉ số phần tử đầu tiên của mảng trong C là gì?",
                "0",
                new String[]{"1", "-1", "Kích thước mảng"},
                "Mảng trong C có đặc điểm nào?",
                "Lưu các phần tử cùng kiểu dữ liệu",
                new String[]{"Lưu mọi kiểu dữ liệu", "Không có kích thước", "Chỉ lưu chuỗi"});
        seedQuizWithTwoQuestions(lesson9,
                "Quiz - Duyệt mảng",
                "Vòng lặp nào thường dùng để duyệt mảng?",
                "for",
                new String[]{"switch", "goto", "break"},
                "Độ dài mảng tĩnh trong C được xác định khi nào?",
                "Khi khai báo",
                new String[]{"Khi chạy chương trình", "Khi in ra", "Khi kết thúc"});
        seedQuizWithTwoQuestions(lesson10,
                "Quiz - Xử lý chuỗi",
                "Chuỗi trong C kết thúc bằng ký tự nào?",
                "\\0",
                new String[]{"\n", "space", "#"},
                "Hàm nào thường dùng để đo độ dài chuỗi?",
                "strlen",
                new String[]{"strcpy", "printf", "scanf"});

        CourseSection section4 = createSection(course, "Hàm và con trỏ", 4);
        Lesson lesson11 = createLesson(section4, "Bài 11 - Hàm trong C", "Recording 2026-05-28 212131.mp4", 840, 1);
        Lesson lesson12 = createLesson(section4, "Bài 12 - Tham số và giá trị trả về", "Recording 2026-05-28 212131.mp4", 900, 2);
        Lesson lesson13 = createLesson(section4, "Bài 13 - Con trỏ cơ bản", "Recording 2026-05-28 212131.mp4", 980, 3);
        seedQuizWithTwoQuestions(lesson11,
                "Quiz - Hàm trong C",
                "Mục đích của hàm trong C là gì?",
                "Tái sử dụng và tổ chức code",
                new String[]{"Tăng dung lượng RAM", "Xóa biến toàn cục", "Thay thế vòng lặp"},
                "Từ khóa nào thường dùng để khai báo hàm trả về số nguyên?",
                "int",
                new String[]{"void", "char", "float"});
        seedQuizWithTwoQuestions(lesson12,
                "Quiz - Tham số và giá trị trả về",
                "Tham số hàm được truyền vào khi nào?",
                "Khi gọi hàm",
                new String[]{"Khi biên dịch", "Khi import file", "Khi kết thúc hàm"},
                "Giá trị trả về của hàm được khai báo bằng gì?",
                "Kiểu dữ liệu trả về",
                new String[]{"Tên hàm", "Số tham số", "Tên biến cục bộ"});
        seedQuizWithTwoQuestions(lesson13,
                "Quiz - Con trỏ cơ bản",
                "Con trỏ lưu gì?",
                "Địa chỉ bộ nhớ",
                new String[]{"Giá trị chuỗi", "Tên biến", "Kết quả hàm"},
                "Toán tử nào dùng để lấy địa chỉ biến?",
                "&",
                new String[]{"*", "%", "#"});

        seedLessonMaterials(instructor, course, lesson4);

        // Seed same structure for additional courses
        seedCourseContent(course2, instructor);
        seedCourseContent(course3, instructor);
        seedCourseContent(course4, instructor);

        // Seed 10 more courses (course 5 -> course 14)
        String[][] extraCourseConfigs = {
                {"Lập Trình C Chuyên Đề 5 - 28Tech", "Khóa học chuyên đề C số 5", "beginner"},
                {"Lập Trình C Chuyên Đề 6 - 28Tech", "Khóa học chuyên đề C số 6", "intermediate"},
                {"Lập Trình C Chuyên Đề 7 - 28Tech", "Khóa học chuyên đề C số 7", "advanced"},
                {"Lập Trình C Chuyên Đề 8 - 28Tech", "Khóa học chuyên đề C số 8", "beginner"},
                {"Lập Trình C Chuyên Đề 9 - 28Tech", "Khóa học chuyên đề C số 9", "intermediate"},
                {"Lập Trình C Chuyên Đề 10 - 28Tech", "Khóa học chuyên đề C số 10", "advanced"},
                {"Lập Trình C Chuyên Đề 11 - 28Tech", "Khóa học chuyên đề C số 11", "beginner"},
                {"Lập Trình C Chuyên Đề 12 - 28Tech", "Khóa học chuyên đề C số 12", "intermediate"},
                {"Lập Trình C Chuyên Đề 13 - 28Tech", "Khóa học chuyên đề C số 13", "advanced"},
                {"Lập Trình C Chuyên Đề 14 - 28Tech", "Khóa học chuyên đề C số 14", "intermediate"}
        };
        for (String[] cfg : extraCourseConfigs) {
            createAndSeedCourse(instructor, category, cfg[0], cfg[1], cfg[2]);
        }

        // Seed test learner user 'Do Thanh' and enroll to course id=1
        User learner = userRepository.findByEmail("dothanh2572005@gmail.com").orElse(null);
        if (learner == null) {
            learner = userRepository.save(User.builder()
                    .roles(Set.of(learnerRole))
                    .firstName("Do")
                    .lastName("Thanh")
                    .email("dothanh2572005@gmail.com")
                    .phone(null)
                    .passwordHash("123")
                    .status("active")
                    .build());
        }

        // Enroll into course id=1 if exists and not already enrolled
        final User finalLearner = learner;
        courseRepository.findById(1).ifPresent(c -> {
            boolean already = enrollmentRepository.findAll().stream()
                    .anyMatch(en -> en.getUser().getId().equals(finalLearner.getId()) && en.getCourse().getId().equals(c.getId()));
            if (!already) {
                enrollmentRepository.save(Enrollment.builder()
                        .user(finalLearner)
                        .course(c)
                        .progressPercent(BigDecimal.ZERO)
                        .build());
            }
        });

    }


    private void seedQuizForLesson2(Lesson lesson2) {
        Quiz quiz = Quiz.builder()
                .lesson(lesson2)
                .title("Quiz - Kiểu dữ liệu và biến")
                .passScore(70)
                .build();
        quiz = quizRepository.save(quiz);

        QuizQuestion q1 = QuizQuestion.builder()
                .quiz(quiz)
                .questionText("Kiểu dữ liệu nào dùng để lưu số nguyên trong C?")
                .questionType("single")
                .points(1)
                .position(1)
                .build();
        q1 = quizQuestionRepository.save(q1);
        persistAnswer(q1, "int", true);
        persistAnswer(q1, "float", false);
        persistAnswer(q1, "double", false);
        persistAnswer(q1, "char", false);

        QuizQuestion q2 = QuizQuestion.builder()
                .quiz(quiz)
                .questionText("Từ khóa nào dùng để khai báo biến số thực?")
                .questionType("single")
                .points(1)
                .position(2)
                .build();
        q2 = quizQuestionRepository.save(q2);
        persistAnswer(q2, "float", true);
        persistAnswer(q2, "int", false);
        persistAnswer(q2, "char", false);
        persistAnswer(q2, "void", false);
    }

    private void seedQuizForLesson3(Lesson lesson3) {
        Quiz quiz = Quiz.builder()
                .lesson(lesson3)
                .title("Quiz - Hàm printf")
                .passScore(70)
                .build();
        quiz = quizRepository.save(quiz);

        QuizQuestion q1 = QuizQuestion.builder()
                .quiz(quiz)
                .questionText("Hàm nào dùng để xuất dữ liệu ra màn hình?")
                .questionType("single")
                .points(1)
                .position(1)
                .build();
        q1 = quizQuestionRepository.save(q1);
        persistAnswer(q1, "printf", true);
        persistAnswer(q1, "scanf", false);
        persistAnswer(q1, "gets", false);
        persistAnswer(q1, "cin", false);

        QuizQuestion q2 = QuizQuestion.builder()
                .quiz(quiz)
                .questionText("%d trong printf dùng để in kiểu dữ liệu nào?")
                .questionType("single")
                .points(1)
                .position(2)
                .build();
        q2 = quizQuestionRepository.save(q2);
        persistAnswer(q2, "Số nguyên", true);
        persistAnswer(q2, "Số thực", false);
        persistAnswer(q2, "Ký tự", false);
        persistAnswer(q2, "Chuỗi", false);
    }

    private void seedQuizForLesson4(Lesson lesson4) {
        seedQuizWithTwoQuestions(lesson4,
                "Quiz - Hàm scanf",
                "Hàm nào dùng để nhập dữ liệu từ bàn phím?",
                "scanf",
                new String[]{"printf", "puts", "cout"},
                "Dấu & trong scanf có tác dụng gì?",
                "Lấy địa chỉ biến",
                new String[]{"Kết thúc lệnh", "Nối chuỗi", "Xuất dữ liệu"});
    }

    private CourseSection createSection(Course course, String title, int position) {
        return courseSectionRepository.save(CourseSection.builder()
                .course(course)
                .title(title)
                .position(position)
                .build());
    }

    private Lesson createLesson(CourseSection section, String title, String videoUrl, int durationSeconds, int position) {
        return lessonRepository.save(Lesson.builder()
                .courseSection(section)
                .title(title)
                .videoUrl(videoUrl)
                .durationSeconds(durationSeconds)
                .position(position)
                .published(true)
                .moderationStatus("approved")
                .build());
    }

    private void seedQuizWithTwoQuestions(Lesson lesson,
                                          String quizTitle,
                                          String q1Text,
                                          String q1Correct,
                                          String[] q1WrongAnswers,
                                          String q2Text,
                                          String q2Correct,
                                          String[] q2WrongAnswers) {
        Quiz quiz = quizRepository.save(Quiz.builder()
                .lesson(lesson)
                .title(quizTitle)
                .passScore(70)
                .build());

        QuizQuestion q1 = quizQuestionRepository.save(QuizQuestion.builder()
                .quiz(quiz)
                .questionText(q1Text)
                .questionType("single")
                .points(1)
                .position(1)
                .build());
        persistAnswer(q1, q1Correct, true);
        for (String wrongAnswer : q1WrongAnswers) {
            persistAnswer(q1, wrongAnswer, false);
        }

        QuizQuestion q2 = quizQuestionRepository.save(QuizQuestion.builder()
                .quiz(quiz)
                .questionText(q2Text)
                .questionType("single")
                .points(1)
                .position(2)
                .build());
        persistAnswer(q2, q2Correct, true);
        for (String wrongAnswer : q2WrongAnswers) {
            persistAnswer(q2, wrongAnswer, false);
        }
    }

    private void persistAnswer(QuizQuestion question, String text, boolean correct) {
        QuizAnswer answer = QuizAnswer.builder()
                .question(question)
                .answerText(text)
                .correct(correct)
                .build();
        quizAnswerRepository.save(answer);
    }

    private void seedLessonMaterials(User instructor, Course course, Lesson lesson) {
        LessonMaterial material = LessonMaterial.builder()
                .instructor(instructor)
                .course(course)
                .lesson(lesson)
                .fileName("[28Tech] BUOI 1.pdf")
                .fileUrl("%5B28Tech%5D.%20BUOI%201.pdf")
                .fileType("pdf")
                .build();
        lessonMaterialRepository.save(material);
    }

    private void seedCourseContent(Course course, User instructor) {
        // create a section and some lessons + quizzes similar to the first course
        CourseSection s1 = createSection(course, "Giới thiệu", 1);
        createLesson(s1, "Bài 1 - Giới thiệu ngôn ngữ C", "Recording 2026-05-28 212131.mp4", 600, 1);
        Lesson l2 = createLesson(s1, "Bài 2 - Kiểu dữ liệu và khai báo biến trong C", "L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2002.%20Ki%E1%BB%83u%20d%E1%BB%AF%20li%E1%BB%87u%20v%C3%A0%20c%C3%A1ch%20khai%20b%C3%A1o%20bi%E1%BA%BFn%20trong%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C-C++.mp4", 900, 2);
        Lesson l3 = createLesson(s1, "Bài 3 - Xuất dữ liệu với printf", "L%E1%BA%ADp%20tr%C3%ACnh%20C%20-%2003.%20C%C3%A1ch%20xu%E1%BA%A5t%20d%E1%BB%AF%20li%E1%BB%87u%20ra%20m%C3%A0n%20h%C3%ACnh%20l%E1%BA%ADp%20tr%C3%ACnh%20C%20-%20H%C3%A0m%20printf%20-%20T%E1%BB%B1%20h%E1%BB%8Dc%20l%E1%BA%ADp%20tr%C3%ACnh%20C.mp4", 850, 3);
        seedQuizForLesson2(l2);
        seedQuizForLesson3(l3);

        CourseSection s2 = createSection(course, "Cấu trúc điều khiển", 2);
        Lesson la = createLesson(s2, "Bài A - Ví dụ", "Recording 2026-05-28 212131.mp4", 700, 1);
        createLesson(s2, "Bài B - Ví dụ", "Recording 2026-05-28 212131.mp4", 700, 2);
        createLesson(s2, "Bài C - Ví dụ", "Recording 2026-05-28 212131.mp4", 700, 3);
        seedQuizWithTwoQuestions(la, "Quiz - Ví dụ A", "Câu 1?", "Đáp án", new String[]{"a","b","c"}, "Câu 2?", "Đáp", new String[]{"x","y","z"});

        CourseSection s3 = createSection(course, "Mảng và chuỗi", 3);
        createLesson(s3, "Bài X - Mảng", "Recording 2026-05-28 212131.mp4", 800, 1);
        createLesson(s3, "Bài Y - Chuỗi", "Recording 2026-05-28 212131.mp4", 800, 2);
        createLesson(s3, "Bài Z - Ứng dụng", "Recording 2026-05-28 212131.mp4", 800, 3);

        CourseSection s4 = createSection(course, "Hàm và con trỏ", 4);
        createLesson(s4, "Bài P - Hàm cơ bản", "Recording 2026-05-28 212131.mp4", 840, 1);
        createLesson(s4, "Bài Q - Tham số", "Recording 2026-05-28 212131.mp4", 900, 2);
        Lesson lLast = createLesson(s4, "Bài R - Con trỏ cơ bản", "Recording 2026-05-28 212131.mp4", 980, 3);
        seedQuizForLesson4(lLast);

        // add a lesson material for one lesson in this course
        seedLessonMaterials(instructor, course, lLast);
    }

    private void createAndSeedCourse(User instructor, Category category, String title, String description, String level) {
        Course newCourse = courseRepository.save(Course.builder()
                .instructor(instructor)
                .category(category)
                .title(title)
                .description(description)
                .thumbnailUrl("2aOboQZWp6Ov5iGTAZLOlCgmiOhOKsGgeQU1cI0O.jpg")
                .price(BigDecimal.ZERO)
                .level(level)
                .status("published")
                .build());
        seedCourseContent(newCourse, instructor);
    }
}
