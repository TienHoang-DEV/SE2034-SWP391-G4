package vn.edu.fpt.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.view.RedirectView;
import org.springframework.web.server.ResponseStatusException;
import vn.edu.fpt.entity.Course;
import vn.edu.fpt.entity.CourseSection;
import vn.edu.fpt.entity.Lesson;
import vn.edu.fpt.repository.CourseRepository;
import vn.edu.fpt.repository.CourseSectionRepository;
import vn.edu.fpt.repository.LessonRepository;
import vn.edu.fpt.service.AzureBlobService;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/temp/video")
public class TempVideoController {

    private final CourseRepository courseRepository;
    private final CourseSectionRepository courseSectionRepository;
    private final LessonRepository lessonRepository;
    private final AzureBlobService azureBlobService;

    public TempVideoController(CourseRepository courseRepository,
                               CourseSectionRepository courseSectionRepository,
                               LessonRepository lessonRepository,
                               AzureBlobService azureBlobService) {
        this.courseRepository = courseRepository;
        this.courseSectionRepository = courseSectionRepository;
        this.lessonRepository = lessonRepository;
        this.azureBlobService = azureBlobService;
    }

    @GetMapping("/first-course-first-lesson/url")
    @ResponseBody
    public String getFirstCourseFirstLessonVideoUrl() {
        return resolveFirstCourseFirstLessonVideoUrl();
    }

    @GetMapping("/first-course-first-lesson/play")
    public RedirectView playFirstCourseFirstLesson() {
        try {
            String videoUrl = resolveFirstCourseFirstLessonVideoUrl();
            return new RedirectView(videoUrl);
        } catch (IllegalStateException ex) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, ex.getMessage(), ex);
        }
    }

    private String resolveFirstCourseFirstLessonVideoUrl() {
        Course firstCourse = courseRepository.findFirstByOrderByIdAsc()
                .orElseThrow(() -> new IllegalStateException("Khong tim thay khoa hoc nao."));

        CourseSection firstSection = courseSectionRepository
                .findFirstByCourse_IdOrderByPositionAscIdAsc(firstCourse.getId())
                .orElseThrow(() -> new IllegalStateException("Khong tim thay section cho khoa hoc dau tien."));

        Lesson firstLesson = lessonRepository
                .findFirstByCourseSection_IdOrderByPositionAscIdAsc(firstSection.getId())
                .orElseThrow(() -> new IllegalStateException("Khong tim thay lesson dau tien."));

        String rawVideoUrl = firstLesson.getVideoUrl();
        if (rawVideoUrl == null || rawVideoUrl.isBlank()) {
            throw new IllegalStateException("Lesson dau tien chua co video_url.");
        }

        if (rawVideoUrl.startsWith("http://") || rawVideoUrl.startsWith("https://")) {
            return rawVideoUrl;
        }

        String normalized = rawVideoUrl.startsWith("/") ? rawVideoUrl.substring(1) : rawVideoUrl;

        String containerName = System.getProperty("AZURE_STORAGE_VIDEO_CONTAINER", "videos");
        String blobName = normalized;

        int slashIndex = normalized.indexOf('/');
        if (slashIndex > 0 && slashIndex < normalized.length() - 1) {
            containerName = normalized.substring(0, slashIndex);
            blobName = normalized.substring(slashIndex + 1);
        }

        return azureBlobService.generateSasUrl(containerName, blobName);
    }
}

