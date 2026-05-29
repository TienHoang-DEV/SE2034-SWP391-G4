package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.CourseSection;
import vn.edu.fpt.repository.CourseSectionRepository;
@Service
@Transactional
public class CourseSectionService extends AbstractCrudService<CourseSection, Integer> {
    public CourseSectionService(CourseSectionRepository courseSectionRepository) {
        super(courseSectionRepository);
    }
}
