package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Enrollment;
import vn.edu.fpt.repository.EnrollmentRepository;
@Service
@Transactional
public class EnrollmentService extends AbstractCrudService<Enrollment, Integer> {
    public EnrollmentService(EnrollmentRepository enrollmentRepository) {
        super(enrollmentRepository);
    }
}
