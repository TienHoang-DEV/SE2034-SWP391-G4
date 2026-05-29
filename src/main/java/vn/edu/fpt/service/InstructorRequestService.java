package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.InstructorRequest;
import vn.edu.fpt.repository.InstructorRequestRepository;
@Service
@Transactional
public class InstructorRequestService extends AbstractCrudService<InstructorRequest, Integer> {
    public InstructorRequestService(InstructorRequestRepository instructorRequestRepository) {
        super(instructorRequestRepository);
    }
}
