package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.OrderItem;
import vn.edu.fpt.repository.OrderItemRepository;
@Service
@Transactional
public class OrderItemService extends AbstractCrudService<OrderItem, Integer> {
    public OrderItemService(OrderItemRepository orderItemRepository) {
        super(orderItemRepository);
    }
}
