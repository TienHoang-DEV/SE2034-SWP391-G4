package vn.edu.fpt.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Course;
@Repository
public interface CourseRepository extends JpaRepository<Course, Integer> {
}
