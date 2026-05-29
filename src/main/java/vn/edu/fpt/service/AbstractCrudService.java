package vn.edu.fpt.service;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
public abstract class AbstractCrudService<T, ID> {
    protected final JpaRepository<T, ID> repository;
    protected AbstractCrudService(JpaRepository<T, ID> repository) {
        this.repository = repository;
    }
    public List<T> findAll() {
        return repository.findAll();
    }
    public Optional<T> findById(ID id) {
        return repository.findById(id);
    }
    public T save(T entity) {
        return repository.save(entity);
    }
    public void deleteById(ID id) {
        repository.deleteById(id);
    }
    public boolean existsById(ID id) {
        return repository.existsById(id);
    }
}
