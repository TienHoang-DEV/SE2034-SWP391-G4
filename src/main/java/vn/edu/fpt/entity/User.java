package vn.edu.fpt.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "users")
public class User extends BaseEntity{

    @ManyToOne
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;

    @Column(columnDefinition = "Nvarchar(255)", nullable = false)
    private String firstName;

    @Column(columnDefinition = "Nvarchar(255)", nullable = false)
    private String lastName;

    @Column(length= 255, nullable = false, unique = true)
    private String email;

    @Column(length = 20, unique = true, nullable = true)
    private String phone;

    @Column(length = 255, nullable = true)
    private String passwordHash;

    @Column(length = 500, nullable = true)
    private String avatarUrl;

    private String googleId;

    @Column(length = 20, nullable = false)
    private String status;

    @Builder.Default
    @OneToMany(mappedBy = "instructor", fetch = FetchType.LAZY)
    private Set<Course> courses = new HashSet<>();

    @Builder.Default
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private Set<Order> orders = new HashSet<>();

    @Builder.Default
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private Set<Enrollment> enrollments = new HashSet<>();

    public void addCourse(Course course) {
        courses.add(course);
        course.setInstructor(this);
    }

    public void removeCourse(Course course) {
        courses.remove(course);
        course.setInstructor(null);
    }

    public void addOrder(Order order) {
        orders.add(order);
        order.setUser(this);
    }

    public void removeOrder(Order order) {
        orders.remove(order);
        order.setUser(null);
    }

    public void addEnrollment(Enrollment enrollment) {
        enrollments.add(enrollment);
        enrollment.setUser(this);
    }

    public void removeEnrollment(Enrollment enrollment) {
        enrollments.remove(enrollment);
        enrollment.setUser(null);
    }
}
