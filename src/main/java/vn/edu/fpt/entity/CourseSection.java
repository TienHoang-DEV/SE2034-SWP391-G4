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
@Table(name = "course_sections")
public class CourseSection extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(columnDefinition = "NVARCHAR(255)", nullable = false)
    private String title;

    @Column(nullable = false)
    private Integer position;
}

