package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.PasswordResetToken;
import vn.edu.fpt.repository.PasswordResetTokenRepository;
@Service
@Transactional
public class PasswordResetTokenService extends AbstractCrudService<PasswordResetToken, Integer> {
    public PasswordResetTokenService(PasswordResetTokenRepository passwordResetTokenRepository) {
        super(passwordResetTokenRepository);
    }
}
