package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.VideoModerationFlag;
import vn.edu.fpt.repository.VideoModerationFlagRepository;
@Service
@Transactional
public class VideoModerationFlagService extends AbstractCrudService<VideoModerationFlag, Integer> {
    public VideoModerationFlagService(VideoModerationFlagRepository videoModerationFlagRepository) {
        super(videoModerationFlagRepository);
    }
}
