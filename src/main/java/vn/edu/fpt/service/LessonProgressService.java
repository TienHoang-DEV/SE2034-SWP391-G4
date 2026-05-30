package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.LessonProgress;
import vn.edu.fpt.repository.LessonProgressRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class LessonProgressService {
    private final LessonProgressRepository repository;

    public LessonProgressService(LessonProgressRepository lessonProgressRepository) {
        this.repository = lessonProgressRepository;
    }

    public List<LessonProgress> findAll() { return repository.findAll(); }
    public Optional<LessonProgress> findById(Integer id) { return repository.findById(id); }
    public LessonProgress save(LessonProgress entity) { return repository.save(entity); }
    public void deleteById(Integer id) { repository.deleteById(id); }
    public boolean existsById(Integer id) { return repository.existsById(id); }
}
