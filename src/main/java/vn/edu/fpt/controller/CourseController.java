package vn.edu.fpt.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.fpt.repository.CourseRepository;
import vn.edu.fpt.entity.Course;
import java.util.List;

@Controller
public class CourseController {

    @Autowired
    private CourseRepository courseRepository;

    @GetMapping("/courses")
    public String showCourseList(
            @RequestParam(value = "search", required = false) String search,
            Model model) {
        
        List<Course> courses;
        
        if (search != null && !search.trim().isEmpty()) {
            // Lấy danh sách khóa học khớp với từ khóa tìm kiếm
            courses = courseRepository.findByTitleContainingIgnoreCase(search.trim());
        } else {
            // Nếu không tìm kiếm, lấy toàn bộ khóa học
            courses = courseRepository.findAll();
        }
        
        // Đưa danh sách khóa học vào Model với key là "courses" để Thymeleaf render
        model.addAttribute("courses", courses);
        // Đưa từ khóa tìm kiếm vào Model để hiển thị lại trên thanh tìm kiếm và tiêu đề
        model.addAttribute("search", search);
        
        // Trả về template course/list.html
        return "course/list";
    }

    @GetMapping("/coursemanager")
    public String getall(){
        return "instructor_course/course_manager";
    }

    @GetMapping("/course/detail")
    public String showCourseDetail(@RequestParam("id") Integer id, Model model) {
        Course course = courseRepository.findById(id)
                .orElseThrow(() -> new org.springframework.web.server.ResponseStatusException(
                        org.springframework.http.HttpStatus.NOT_FOUND, "Không tìm thấy khóa học"));
        model.addAttribute("course", course);
        return "course/detail";
    }
}
