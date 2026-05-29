package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.QuizAnswer;
import vn.edu.fpt.repository.QuizAnswerRepository;
@Service
@Transactional
public class QuizAnswerService extends AbstractCrudService<QuizAnswer, Integer> {
    public QuizAnswerService(QuizAnswerRepository quizAnswerRepository) {
        super(quizAnswerRepository);
    }
}
