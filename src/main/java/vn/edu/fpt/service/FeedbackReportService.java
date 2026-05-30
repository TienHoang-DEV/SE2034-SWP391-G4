package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.FeedbackReport;
import vn.edu.fpt.repository.FeedbackReportRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class FeedbackReportService {
    private final FeedbackReportRepository repository;

    public FeedbackReportService(FeedbackReportRepository feedbackReportRepository) {
        this.repository = feedbackReportRepository;
    }

    public List<FeedbackReport> findAll() { return repository.findAll(); }
    public Optional<FeedbackReport> findById(Integer id) { return repository.findById(id); }
    public FeedbackReport save(FeedbackReport entity) { return repository.save(entity); }
    public void deleteById(Integer id) { repository.deleteById(id); }
    public boolean existsById(Integer id) { return repository.existsById(id); }
}
