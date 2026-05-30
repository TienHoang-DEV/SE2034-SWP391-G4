package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.InstructorRequest;
import vn.edu.fpt.repository.InstructorRequestRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class InstructorRequestService {
    private final InstructorRequestRepository repository;

    public InstructorRequestService(InstructorRequestRepository instructorRequestRepository) {
        this.repository = instructorRequestRepository;
    }

    public List<InstructorRequest> findAll() { return repository.findAll(); }
    public Optional<InstructorRequest> findById(Integer id) { return repository.findById(id); }
    public InstructorRequest save(InstructorRequest entity) { return repository.save(entity); }
    public void deleteById(Integer id) { repository.deleteById(id); }
    public boolean existsById(Integer id) { return repository.existsById(id); }
}
