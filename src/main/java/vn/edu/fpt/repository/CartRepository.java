package vn.edu.fpt.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Cart;
@Repository
public interface CartRepository extends JpaRepository<Cart, Integer> {
}
