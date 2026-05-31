package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Course;

import java.util.Optional;

@Repository
public interface CourseRepository extends JpaRepository<Course, Integer> {
	Optional<Course> findFirstByOrderByIdAsc();
}
