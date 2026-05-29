package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.CartInstructorCoupon;
import vn.edu.fpt.repository.CartInstructorCouponRepository;
@Service
@Transactional
public class CartInstructorCouponService extends AbstractCrudService<CartInstructorCoupon, Integer> {
    public CartInstructorCouponService(CartInstructorCouponRepository cartInstructorCouponRepository) {
        super(cartInstructorCouponRepository);
    }
}
