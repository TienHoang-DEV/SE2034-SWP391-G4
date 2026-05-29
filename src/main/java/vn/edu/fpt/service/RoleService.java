package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Role;
import vn.edu.fpt.repository.RoleRepository;
@Service
@Transactional
public class RoleService extends AbstractCrudService<Role, Integer> {
    public RoleService(RoleRepository roleRepository) {
        super(roleRepository);
    }
}
