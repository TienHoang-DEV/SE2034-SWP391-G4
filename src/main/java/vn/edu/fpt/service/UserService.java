package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.User;
import vn.edu.fpt.repository.UserRepository;
@Service
@Transactional
public class UserService extends AbstractCrudService<User, Integer> {
    public UserService(UserRepository userRepository) {
        super(userRepository);
    }
}
