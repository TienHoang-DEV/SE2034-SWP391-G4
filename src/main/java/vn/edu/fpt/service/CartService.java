package vn.edu.fpt.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Cart;
import vn.edu.fpt.entity.User;
import vn.edu.fpt.repository.CartRepository;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CartService {
    private final CartRepository repository;

    public CartService(CartRepository cartRepository) {
        this.repository = cartRepository;
    }

    public Cart getOrCreateCartForUser(User user) {
        return repository.findByUser(user)
                .orElseGet(() -> repository.save(Cart.builder().user(user).build()));
    }

    public List<Cart> findAll() { return repository.findAll(); }
    public Optional<Cart> findById(Integer id) { return repository.findById(id); }
    public Cart save(Cart entity) { return repository.save(entity); }
    public void deleteById(Integer id) { repository.deleteById(id); }
    public boolean existsById(Integer id) { return repository.existsById(id); }
}
