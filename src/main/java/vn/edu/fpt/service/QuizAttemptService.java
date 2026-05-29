package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.QuizAttempt;
import vn.edu.fpt.repository.QuizAttemptRepository;
@Service
@Transactional
public class QuizAttemptService extends AbstractCrudService<QuizAttempt, Integer> {
    public QuizAttemptService(QuizAttemptRepository quizAttemptRepository) {
        super(quizAttemptRepository);
    }
}
