package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.Course;
import java.util.List;

@Repository
public interface CourseRepository extends JpaRepository<Course, Integer> {
    
    // Tìm danh sách các khóa học theo trạng thái
    List<Course> findByStatus(String status);

    // Tìm các khóa học có tên chứa từ khóa tìm kiếm (không phân biệt hoa thường)
    List<Course> findByTitleContainingIgnoreCase(String title);
}
