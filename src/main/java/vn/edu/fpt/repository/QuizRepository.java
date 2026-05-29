package vn.edu.fpt.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Quiz;
@Repository
public interface QuizRepository extends JpaRepository<Quiz, Integer> {
}
