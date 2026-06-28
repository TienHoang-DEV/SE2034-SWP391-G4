package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.VideoModerationFlag;
import vn.edu.fpt.repository.VideoModerationFlagRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class    VideoModerationFlagService {
    private final VideoModerationFlagRepository repository;

    public VideoModerationFlagService(VideoModerationFlagRepository videoModerationFlagRepository) {
        this.repository = videoModerationFlagRepository;
    }

    public List<VideoModerationFlag> findAll() { return repository.findAll(); }
    public Optional<VideoModerationFlag> findById(Integer id) { return repository.findById(id); }
    public VideoModerationFlag save(VideoModerationFlag entity) { return repository.save(entity); }
    public void deleteById(Integer id) { repository.deleteById(id); }
    public boolean existsById(Integer id) { return repository.existsById(id); }
}
