package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.LessonProgress;
import vn.edu.fpt.repository.LessonProgressRepository;
@Service
@Transactional
public class LessonProgressService extends AbstractCrudService<LessonProgress, Integer> {
    public LessonProgressService(LessonProgressRepository lessonProgressRepository) {
        super(lessonProgressRepository);
    }
}
