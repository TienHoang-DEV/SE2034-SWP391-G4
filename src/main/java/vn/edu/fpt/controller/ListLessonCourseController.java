package vn.edu.fpt.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import vn.edu.fpt.entity.Course;
import vn.edu.fpt.entity.CourseSection;
import vn.edu.fpt.entity.Lesson;
import vn.edu.fpt.entity.User;
import vn.edu.fpt.service.CourseService;

import java.util.Set;

@Controller
public class ListLessonCourseController {

    @Autowired
    CourseService courseService;

    @GetMapping("/course/list-lessons/{id}")
    public String listLesson(HttpSession session, @PathVariable("id") Integer id) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:temp/material/first-course-first-lesson/url";
        }
        Course course = courseService.findById(id).orElse(null);
        Set<CourseSection> courseSections = course.getSections();
        for (CourseSection s : courseSections) {
            Set<Lesson> lessons = s.getLessons();
            System.out.println(lessons.size());
            for (Lesson l : lessons) {
                System.out.println(l.getVideoUrl());
            }
        }

        return "redirect:/login";
    }

}
