package vn.edu.fpt.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Coupon;
@Repository
public interface CouponRepository extends JpaRepository<Coupon, Integer> {
}
