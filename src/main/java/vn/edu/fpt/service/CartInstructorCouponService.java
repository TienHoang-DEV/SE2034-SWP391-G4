package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.CartInstructorCoupon;
import vn.edu.fpt.repository.CartInstructorCouponRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CartInstructorCouponService {
    private final CartInstructorCouponRepository repository;

    public CartInstructorCouponService(CartInstructorCouponRepository cartInstructorCouponRepository) {
        this.repository = cartInstructorCouponRepository;
    }

    public List<CartInstructorCoupon> findAll() {
        return repository.findAll();
    }

    public Optional<CartInstructorCoupon> findById(Integer id) {
        return repository.findById(id);
    }

    public CartInstructorCoupon save(CartInstructorCoupon entity) {
        return repository.save(entity);
    }

    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    public boolean existsById(Integer id) {
        return repository.existsById(id);
    }
}
