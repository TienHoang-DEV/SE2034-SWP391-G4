package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.CouponUsage;
import vn.edu.fpt.repository.CouponUsageRepository;
@Service
@Transactional
public class CouponUsageService extends AbstractCrudService<CouponUsage, Integer> {
    public CouponUsageService(CouponUsageRepository couponUsageRepository) {
        super(couponUsageRepository);
    }
}
