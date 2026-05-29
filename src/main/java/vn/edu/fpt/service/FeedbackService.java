package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Feedback;
import vn.edu.fpt.repository.FeedbackRepository;
@Service
@Transactional
public class FeedbackService extends AbstractCrudService<Feedback, Integer> {
    public FeedbackService(FeedbackRepository feedbackRepository) {
        super(feedbackRepository);
    }
}
