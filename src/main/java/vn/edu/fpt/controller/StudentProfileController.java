package vn.edu.fpt.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import vn.edu.fpt.entity.User;
import vn.edu.fpt.entity.Enrollment;
import vn.edu.fpt.entity.Order;
import vn.edu.fpt.entity.Course;
import vn.edu.fpt.repository.UserRepository;
import vn.edu.fpt.repository.OrderRepository;
import vn.edu.fpt.repository.EnrollmentRepository;
import vn.edu.fpt.repository.CourseRepository;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Controller
public class StudentProfileController {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final CourseRepository courseRepository;

    public StudentProfileController(UserRepository userRepository,
                                    OrderRepository orderRepository,
                                    EnrollmentRepository enrollmentRepository,
                                    CourseRepository courseRepository) {
        this.userRepository = userRepository;
        this.orderRepository = orderRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.courseRepository = courseRepository;
    }

    private User getSessionUser() {
        try {
            HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
            HttpSession session = request.getSession(false);
            if (session != null) {
                User sessionUser = (User) session.getAttribute("user");
                if (sessionUser != null) {
                    return userRepository.findById(sessionUser.getId()).orElse(sessionUser);
                }
            }
        } catch (Exception ignored) {
        }
        return userRepository.findByEmail("28tech@gmail.com")
                .orElseGet(() -> userRepository.findAll().stream().findFirst()
                        .orElseThrow(() -> new IllegalStateException("Không tìm thấy người dùng nào trong DB để giả lập.")));
    }

    @GetMapping("/")
    public String showHomePage(Model model) {
        // Chỉ đơn giản trả về giao diện trang chủ đã đăng nhập
        return "home/home_logged_in";
    }

    @GetMapping("/student/profile")
    public String showStudentProfile(Model model) {
        User user = getSessionUser();
        
        // Tính toán các thống kê của học viên từ DB
        int enrollmentsCount = user.getEnrollments().size();
        
        // Đếm số chứng chỉ (khóa học đã học xong 100%)
        long certificatesCount = user.getEnrollments().stream()
                .filter(e -> e.getProgressPercent() != null && e.getProgressPercent().doubleValue() >= 100)
                .count();
                
        // Tính toán giờ học giả lập: mỗi khóa học đã đăng ký đóng góp 2-8 giờ tùy tiến độ
        int totalHours = 0;
        for (Enrollment en : user.getEnrollments()) {
            double pct = en.getProgressPercent() != null ? en.getProgressPercent().doubleValue() : 0.0;
            totalHours += (int) (pct * 8.0 / 100.0);
        }
        if (totalHours == 0 && enrollmentsCount > 0) {
            totalHours = 2; // tối thiểu 2 giờ nếu đã đăng ký học
        }

        model.addAttribute("currentUser", user);
        model.addAttribute("enrollmentsCount", enrollmentsCount);
        model.addAttribute("certificatesCount", certificatesCount);
        model.addAttribute("studyHours", totalHours);
        
        return "student_profile/student_profile";
    }

    @GetMapping("/student/my-learning")
    public String showMyLearning(Model model) {
        User user = getSessionUser();
        List<Enrollment> enrollments = enrollmentRepository.findByUser(user);
        
        model.addAttribute("currentUser", user);
        model.addAttribute("enrollments", enrollments);
        model.addAttribute("enrollmentsCount", enrollments.size());
        
        return "my_learning/my_learning";
    }

    @GetMapping("/student/purchase-history")
    public String showPurchaseHistory(Model model) {
        User user = getSessionUser();
        List<Order> orders = orderRepository.findByUser(user);
        
        model.addAttribute("currentUser", user);
        model.addAttribute("orders", orders);
        
        return "purchase_history/purchase_history";
    }

    @GetMapping("/student/recommendations")
    public String showRecommendations(Model model) {
        User user = getSessionUser();
        
        // Lấy danh sách ID các khóa học đã đăng ký
        Set<Integer> enrolledCourseIds = user.getEnrollments().stream()
                .map(e -> e.getCourse().getId())
                .collect(Collectors.toSet());
                
        // Lấy các khóa học chưa đăng ký để đề xuất
        List<Course> recommendedCourses = courseRepository.findAll().stream()
                .filter(c -> !enrolledCourseIds.contains(c.getId()))
                .collect(Collectors.toList());
                
        model.addAttribute("currentUser", user);
        model.addAttribute("recommendedCourses", recommendedCourses);
        
        return "recommendations/recommendations";
    }
}

