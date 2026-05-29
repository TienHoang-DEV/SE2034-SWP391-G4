package vn.edu.fpt.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@Entity
@Table(name = "roles")
public class Role extends BaseEntity{

    @Column(name = "name", nullable = false, unique = true, length = 50)
    private String name;

    @Column(length = 255)
    private String description;

    @Builder.Default
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL ,mappedBy = "role")
    private Set<User> users = new HashSet<>();

    public void addUser(User user) {
        users.add(user);
        user.setRole(this);
    }

    public void removeUser(User user) {
        users.remove(user);
        user.setRole(null);
    }

}
