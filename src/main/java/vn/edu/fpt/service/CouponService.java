package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Coupon;
import vn.edu.fpt.repository.CouponRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CouponService {
    private final CouponRepository repository;

    public CouponService(CouponRepository couponRepository) {
        this.repository = couponRepository;
    }

    public List<Coupon> findAll() { return repository.findAll(); }
    public Optional<Coupon> findById(Integer id) { return repository.findById(id); }
    public Coupon save(Coupon entity) { return repository.save(entity); }
    public void deleteById(Integer id) { repository.deleteById(id); }
    public boolean existsById(Integer id) { return repository.existsById(id); }
}
