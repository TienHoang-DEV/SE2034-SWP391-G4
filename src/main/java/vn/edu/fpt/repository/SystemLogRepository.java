package vn.edu.fpt.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.SystemLog;
@Repository
public interface SystemLogRepository extends JpaRepository<SystemLog, Integer> {
}
