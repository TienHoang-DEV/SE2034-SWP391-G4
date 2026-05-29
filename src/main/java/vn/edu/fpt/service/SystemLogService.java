package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.SystemLog;
import vn.edu.fpt.repository.SystemLogRepository;
@Service
@Transactional
public class SystemLogService extends AbstractCrudService<SystemLog, Integer> {
    public SystemLogService(SystemLogRepository systemLogRepository) {
        super(systemLogRepository);
    }
}
