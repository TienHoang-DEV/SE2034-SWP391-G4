package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Course;

import java.util.Optional;

@Repository
public interface CourseRepository extends JpaRepository<Course, Integer> {
    Optional<Course> findFirstByOrderByIdAsc();

    @Query("""
            select c from Course c where c.id = :id
            """)
    Optional<Course> findByIdJoinFetch(@Param("id") Integer id);
}
