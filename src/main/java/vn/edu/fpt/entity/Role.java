package vn.edu.fpt.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.*;
import lombok.experimental.SuperBuilder;

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

}
