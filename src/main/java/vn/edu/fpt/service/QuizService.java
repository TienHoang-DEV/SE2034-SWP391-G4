package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Quiz;
import vn.edu.fpt.repository.QuizRepository;
@Service
@Transactional
public class QuizService extends AbstractCrudService<Quiz, Integer> {
    public QuizService(QuizRepository quizRepository) {
        super(quizRepository);
    }
}
