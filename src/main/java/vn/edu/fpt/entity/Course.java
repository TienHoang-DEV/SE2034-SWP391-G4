package vn.edu.fpt.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "courses")
public class Course extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "instructor_id", nullable = false)
    private User instructor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(columnDefinition = "NVARCHAR(255)", nullable = false)
    private String title;

    
    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Column(name = "thumbnail_url", length = 500)
    private String thumbnailUrl;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(length = 20)
    private String level;

    @Column(length = 20)
    private String status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approved_by")
    private User approvedBy;

    @Column(name = "approved_at")
    private LocalDateTime approvedAt;

    @Builder.Default
    @OneToMany(mappedBy = "course", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<CourseSection> sections = new HashSet<>();

    @Builder.Default
    @OneToMany(mappedBy = "course", fetch = FetchType.LAZY)
    private Set<Enrollment> enrollments = new HashSet<>();

    @Builder.Default
    @OneToMany(mappedBy = "course", fetch = FetchType.LAZY)
    private Set<Feedback> feedbacks = new HashSet<>();

    public void addSection(CourseSection section) {
        sections.add(section);
        section.setCourse(this);
    }

    public void removeSection(CourseSection section) {
        sections.remove(section);
        section.setCourse(null);
    }

    public void addEnrollment(Enrollment enrollment) {
        enrollments.add(enrollment);
        enrollment.setCourse(this);
    }

    public void removeEnrollment(Enrollment enrollment) {
        enrollments.remove(enrollment);
        enrollment.setCourse(null);
    }

    public void addFeedback(Feedback feedback) {
        feedbacks.add(feedback);
        feedback.setCourse(this);
    }

    public void removeFeedback(Feedback feedback) {
        feedbacks.remove(feedback);
        feedback.setCourse(null);
    }
}

