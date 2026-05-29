package vn.edu.fpt.service;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.entity.Category;
import vn.edu.fpt.repository.CategoryRepository;
@Service
@Transactional
public class CategoryService extends AbstractCrudService<Category, Integer> {
    public CategoryService(CategoryRepository categoryRepository) {
        super(categoryRepository);
    }
}
