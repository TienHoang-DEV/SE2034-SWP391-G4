package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Payment;
import vn.edu.fpt.repository.PaymentRepository;
@Service
@Transactional
public class PaymentService extends AbstractCrudService<Payment, Integer> {
    public PaymentService(PaymentRepository paymentRepository) {
        super(paymentRepository);
    }
}
