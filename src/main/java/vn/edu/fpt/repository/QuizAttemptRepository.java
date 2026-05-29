package vn.edu.fpt.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.QuizAttempt;
@Repository
public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, Integer> {
}
