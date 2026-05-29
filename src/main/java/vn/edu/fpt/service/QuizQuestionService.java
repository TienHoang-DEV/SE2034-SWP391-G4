package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.QuizQuestion;
import vn.edu.fpt.repository.QuizQuestionRepository;
@Service
@Transactional
public class QuizQuestionService extends AbstractCrudService<QuizQuestion, Integer> {
    public QuizQuestionService(QuizQuestionRepository quizQuestionRepository) {
        super(quizQuestionRepository);
    }
}
