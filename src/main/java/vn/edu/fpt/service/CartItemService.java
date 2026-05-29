package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.CartItem;
import vn.edu.fpt.repository.CartItemRepository;
@Service
@Transactional
public class CartItemService extends AbstractCrudService<CartItem, Integer> {
    public CartItemService(CartItemRepository cartItemRepository) {
        super(cartItemRepository);
    }
}
