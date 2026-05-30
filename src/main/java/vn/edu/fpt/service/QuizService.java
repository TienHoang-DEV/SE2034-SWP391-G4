package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Quiz;
import vn.edu.fpt.repository.QuizRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class QuizService {
    private final QuizRepository repository;

    public QuizService(QuizRepository quizRepository) {
        this.repository = quizRepository;
    }

    public List<Quiz> findAll() { return repository.findAll(); }
    public Optional<Quiz> findById(Integer id) { return repository.findById(id); }
    public Quiz save(Quiz entity) { return repository.save(entity); }
    public void deleteById(Integer id) { repository.deleteById(id); }
    public boolean existsById(Integer id) { return repository.existsById(id); }
}
