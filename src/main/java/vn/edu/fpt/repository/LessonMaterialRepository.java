package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.LessonMaterial;

import java.util.List;
import java.util.Optional;

@Repository
public interface LessonMaterialRepository extends JpaRepository<LessonMaterial, Integer> {

    // Dùng trong LessonDetail để lấy material đầu tiên của bài
    Optional<LessonMaterial> findFirstByLesson_IdOrderByIdAsc(Integer lessonId);

    // Lấy toàn bộ material của một instructor (Thư viện)
    @Query("SELECT m FROM LessonMaterial m WHERE m.instructor.id = :instructorId ORDER BY m.createdAt DESC")
    List<LessonMaterial> findByInstructorId(@Param("instructorId") Integer instructorId);

    // Filter thư viện theo khóa học
    @Query("SELECT m FROM LessonMaterial m WHERE m.instructor.id = :instructorId AND m.course.id = :courseId ORDER BY m.createdAt DESC")
    List<LessonMaterial> findByInstructorIdAndCourseId(
            @Param("instructorId") Integer instructorId,
            @Param("courseId") Integer courseId);

    // Lấy material gắn với một Lesson cụ thể
    List<LessonMaterial> findByLesson_IdOrderByCreatedAtDesc(Integer lessonId);
}

