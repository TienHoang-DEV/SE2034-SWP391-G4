package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.LessonMaterial;
import vn.edu.fpt.repository.LessonMaterialRepository;
@Service
@Transactional
public class LessonMaterialService extends AbstractCrudService<LessonMaterial, Integer> {
    public LessonMaterialService(LessonMaterialRepository lessonMaterialRepository) {
        super(lessonMaterialRepository);
    }
}
