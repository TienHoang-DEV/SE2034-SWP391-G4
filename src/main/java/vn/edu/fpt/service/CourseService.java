package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Course;
import vn.edu.fpt.repository.CourseRepository;
@Service
@Transactional
public class CourseService extends AbstractCrudService<Course, Integer> {
    public CourseService(CourseRepository courseRepository) {
        super(courseRepository);
    }
}
