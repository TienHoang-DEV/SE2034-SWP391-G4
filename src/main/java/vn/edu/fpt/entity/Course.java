package vn.edu.fpt.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "courses")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Course {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "instructor_id", nullable = false)
    private Integer instructorId;

    @Column(name = "category_id", nullable = false)
    private Integer categoryId;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Column(name = "thumbnail_url")
    private String thumbnailUrl;

    @Column(nullable = false)
    private BigDecimal price;

    private String level;

    private String status;

    @Column(name = "approved_by")
    private Integer approvedBy;

    @Column(name = "approved_at")
    private LocalDateTime approvedAt;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
