package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Coupon;
import vn.edu.fpt.repository.CouponRepository;
@Service
@Transactional
public class CouponService extends AbstractCrudService<Coupon, Integer> {
    public CouponService(CouponRepository couponRepository) {
        super(couponRepository);
    }
}
