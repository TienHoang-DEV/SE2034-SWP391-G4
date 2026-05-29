package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.FeedbackReport;
import vn.edu.fpt.repository.FeedbackReportRepository;
@Service
@Transactional
public class FeedbackReportService extends AbstractCrudService<FeedbackReport, Integer> {
    public FeedbackReportService(FeedbackReportRepository feedbackReportRepository) {
        super(feedbackReportRepository);
    }
}
