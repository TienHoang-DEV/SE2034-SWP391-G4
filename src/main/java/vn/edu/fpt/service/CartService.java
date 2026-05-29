package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Cart;
import vn.edu.fpt.repository.CartRepository;
@Service
@Transactional
public class CartService extends AbstractCrudService<Cart, Integer> {
    public CartService(CartRepository cartRepository) {
        super(cartRepository);
    }
}
