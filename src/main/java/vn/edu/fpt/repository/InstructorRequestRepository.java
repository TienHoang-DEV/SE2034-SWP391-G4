package vn.edu.fpt.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.edu.fpt.entity.InstructorRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

@Repository
public interface InstructorRequestRepository extends JpaRepository<InstructorRequest, Integer> {

       @Query("SELECT r FROM InstructorRequest r WHERE " +
                     "(:status IS NULL OR :status = '' OR r.status = :status) AND " +
                     "(:keyword IS NULL OR :keyword = '' OR " +
                     "LOWER(r.user.email) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
                     "LOWER(r.user.firstName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
                     "LOWER(r.user.lastName) LIKE LOWER(CONCAT('%', :keyword, '%')))")
       Page<InstructorRequest> searchAndFilter(@Param("keyword") String keyword,
                     @Param("status") String status,
                     Pageable pageable);
}
