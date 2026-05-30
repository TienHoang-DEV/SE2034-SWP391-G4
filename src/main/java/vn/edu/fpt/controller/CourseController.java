package vn.edu.fpt.controller;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CourseController {

    @GetMapping("/coursemanager")
    public String getall(){
        return "instructor_course/course_manager";
    }
}
