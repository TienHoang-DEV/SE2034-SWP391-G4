package vn.edu.fpt.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.VideoModerationFlag;
@Repository
public interface VideoModerationFlagRepository extends JpaRepository<VideoModerationFlag, Integer> {
}
