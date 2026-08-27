package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "crop_category")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CropCategory {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "category_id")
    private UUID categoryId;

    @Column(name = "category_name", nullable = false, unique = true, length = 100)
    private String categoryName;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_active")
    private Boolean isActive = true;
}
