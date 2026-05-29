package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Lesson;
import vn.edu.fpt.repository.LessonRepository;
@Service
@Transactional
public class LessonService extends AbstractCrudService<Lesson, Integer> {
    public LessonService(LessonRepository lessonRepository) {
        super(lessonRepository);
    }
}
