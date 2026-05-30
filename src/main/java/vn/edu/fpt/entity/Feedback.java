package vn.edu.fpt.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "feedbacks")
public class Feedback extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column
    private Integer rating;

    
    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String comment;

    @Column(length = 20)
    private String status;

    @Builder.Default
    @OneToMany(mappedBy = "feedback", fetch = FetchType.LAZY)
    private Set<FeedbackReport> reports = new HashSet<>();

    public void addReport(FeedbackReport report) {
        reports.add(report);
        report.setFeedback(this);
    }

    public void removeReport(FeedbackReport report) {
        reports.remove(report);
        report.setFeedback(null);
    }
}

