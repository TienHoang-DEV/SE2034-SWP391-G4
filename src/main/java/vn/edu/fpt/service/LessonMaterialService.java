package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.LessonMaterial;
import vn.edu.fpt.repository.LessonMaterialRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class LessonMaterialService {
    private final LessonMaterialRepository repository;

    public LessonMaterialService(LessonMaterialRepository lessonMaterialRepository) {
        this.repository = lessonMaterialRepository;
    }

    public List<LessonMaterial> findAll() { return repository.findAll(); }
    public Optional<LessonMaterial> findById(Integer id) { return repository.findById(id); }
    public LessonMaterial save(LessonMaterial entity) { return repository.save(entity); }
    public void deleteById(Integer id) { repository.deleteById(id); }
    public boolean existsById(Integer id) { return repository.existsById(id); }
}
