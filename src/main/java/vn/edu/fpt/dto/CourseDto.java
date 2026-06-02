package vn.edu.fpt.dto;

import lombok.*;
import java.math.BigDecimal;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CourseDto {
    private Integer id;
    private UserDto instructor;
    private CategoryDto category;
    private String title;
    private String description;
    private String thumbnailUrl;
    private BigDecimal price;
    private String level;
    private String status;
    private Set<CourseSectionDto> sections;
    private Set<FeedbackDto> feedbacks;

    private double averageRating;
    private int ratingCount;
    private int totalLessonsCount;
    private String firstLessonVideoUrl;
    private Integer firstLessonId;
    private String thumbnailPath;
    private java.time.LocalDateTime createdAt;
    private java.time.LocalDateTime updatedAt;
}
