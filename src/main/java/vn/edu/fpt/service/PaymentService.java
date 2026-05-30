package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Payment;
import vn.edu.fpt.repository.PaymentRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class PaymentService {
    private final PaymentRepository repository;

    public PaymentService(PaymentRepository paymentRepository) {
        this.repository = paymentRepository;
    }

    public List<Payment> findAll() { return repository.findAll(); }
    public Optional<Payment> findById(Integer id) { return repository.findById(id); }
    public Payment save(Payment entity) { return repository.save(entity); }
    public void deleteById(Integer id) { repository.deleteById(id); }
    public boolean existsById(Integer id) { return repository.existsById(id); }
}
