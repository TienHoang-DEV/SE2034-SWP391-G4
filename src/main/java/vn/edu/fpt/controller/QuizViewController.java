package vn.edu.fpt.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import vn.edu.fpt.entity.Lesson;
import vn.edu.fpt.service.LessonService;

@Controller
public class QuizViewController {

    @Autowired
    LessonService lessonService;

    @GetMapping("/quiz/lesson/{lessonId}")
    public String viewQuiz(@PathVariable("lessonId") Integer lessonId, Model model) {
        Lesson lesson = lessonService.findById(lessonId).orElse(null);
        model.addAttribute("lesson", lesson);
        return "quiz/lesson-quiz";
    }
}
