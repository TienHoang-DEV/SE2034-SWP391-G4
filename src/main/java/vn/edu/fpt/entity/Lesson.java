package vn.edu.fpt.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "lessons")
public class Lesson extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "section_id", nullable = false)
    private CourseSection courseSection;

    @Column(columnDefinition = "NVARCHAR(255)", nullable = false)
    private String title;

    @Column(name = "video_url", length = 500)
    private String videoUrl;

    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    @Column
    private Integer position;

    @Builder.Default
    @Column(name = "is_published")
    private Boolean published = false;

    @Column(name = "moderation_status", length = 20)
    private String moderationStatus;
}

