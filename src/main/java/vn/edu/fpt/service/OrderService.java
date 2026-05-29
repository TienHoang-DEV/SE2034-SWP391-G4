package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Order;
import vn.edu.fpt.repository.OrderRepository;
@Service
@Transactional
public class OrderService extends AbstractCrudService<Order, Integer> {
    public OrderService(OrderRepository orderRepository) {
        super(orderRepository);
    }
}
