package vn.edu.fpt.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import vn.edu.fpt.entity.Course;
import vn.edu.fpt.entity.CourseSection;
import vn.edu.fpt.entity.Lesson;
import vn.edu.fpt.exception.CourseNotFoundException;
import vn.edu.fpt.service.AzureBlobService;
import vn.edu.fpt.service.CourseService;
import vn.edu.fpt.service.LessonService;
import vn.edu.fpt.util.AppConstants;

import java.util.Iterator;
import java.util.Set;

@Controller
public class ListLessonCourseController {

    @Autowired
    CourseService courseService;

    @Autowired
    LessonService lessonService;

    @Autowired
    AzureBlobService azureBlobService;

    @GetMapping("/course/{courseId}")
    public String listSection(@PathVariable Integer courseId) {
        Course course = courseService.findById(courseId)
                .orElseThrow(() -> new CourseNotFoundException("Khóa học không tìm thấy"));

        if (course.getSections() == null || course.getSections().isEmpty()) {
            throw new CourseNotFoundException("Khóa học không có section nào");
        }

        Iterator<CourseSection> iterator = course.getSections().iterator();
        CourseSection courseSection = iterator.next();

        if (courseSection.getLessons() == null || courseSection.getLessons().isEmpty()) {
            throw new CourseNotFoundException("Section không có bài học nào");
        }

        Integer firstLessonId = courseSection.getLessons().iterator().next().getId();
        return String.format("redirect:/course/%d/section/%d/lesson/%d", courseId, courseSection.getId(), firstLessonId);
    }

    @GetMapping("/course/{courseId}/section/{sectionId}/lesson/{lessonId}")
    public String viewLesson(Model model, @PathVariable Integer courseId, @PathVariable Integer sectionId, @PathVariable Integer lessonId) {
        Course course = courseService.findById(courseId)
                .orElseThrow(() -> new CourseNotFoundException("Khóa học không tìm thấy"));

        Lesson lesson = lessonService.findByIdWithMaterials(lessonId)
                .orElseThrow(() -> new CourseNotFoundException("Bài học không tìm thấy"));

        Set<CourseSection> sections = course.getSections();
        model.addAttribute("course", course);
        model.addAttribute("courseSections", sections);
        model.addAttribute("lesson", lesson);
        model.addAttribute("materials", lesson.getMaterials());

        String thumbnailUrl = course.getThumbnailUrl();
        if (thumbnailUrl != null && !thumbnailUrl.isEmpty()) {
            model.addAttribute("posterUrl", System.getProperty("AZURE_STORAGE_BASE_URL") + "/" + System.getProperty("AZURE_STORAGE_CONTAINER_COURSE_THUMBNAILS") + "/" + thumbnailUrl);
        }

        return "learning/learning";
    }

    @GetMapping("/lesson/{lessonId}")
    @ResponseBody
    public String lessonView(@PathVariable("lessonId") Integer lessonId) {
        Lesson lesson = lessonService.findById(lessonId).orElse(null);
        if (lesson == null) {
            return null;
        }
        return azureBlobService.generateSasUrl(AppConstants.AZURE_STORAGE_CONTAINER_VIDEOS, lesson.getVideoUrl());
    }

}
