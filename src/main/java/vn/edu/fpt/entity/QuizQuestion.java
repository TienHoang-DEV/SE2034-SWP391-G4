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
@Table(name = "quiz_questions")
public class QuizQuestion extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id", nullable = false)
    private Quiz quiz;

    @Lob
    @Column(name = "question_text", columnDefinition = "NVARCHAR(MAX)", nullable = false)
    private String questionText;

    @Column(name = "question_type", length = 20)
    private String questionType;

    @Column
    private Integer points;

    @Column
    private Integer position;
}

