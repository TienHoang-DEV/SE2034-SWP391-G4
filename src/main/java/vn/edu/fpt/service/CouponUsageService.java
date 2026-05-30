package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.CouponUsage;
import vn.edu.fpt.repository.CouponUsageRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CouponUsageService {
    private final CouponUsageRepository repository;

    public CouponUsageService(CouponUsageRepository couponUsageRepository) {
        this.repository = couponUsageRepository;
    }

    public List<CouponUsage> findAll() { return repository.findAll(); }
    public Optional<CouponUsage> findById(Integer id) { return repository.findById(id); }
    public CouponUsage save(CouponUsage entity) { return repository.save(entity); }
    public void deleteById(Integer id) { repository.deleteById(id); }
    public boolean existsById(Integer id) { return repository.existsById(id); }
}
