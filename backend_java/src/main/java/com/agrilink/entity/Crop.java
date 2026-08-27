package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "crop")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Crop {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "crop_id")
    private UUID cropId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private CropCategory category;

    @Column(name = "crop_name", nullable = false, length = 150)
    private String cropName;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    /** Unit of measurement: kg, dozen, litre, bunch */
    @Column(name = "unit", nullable = false, length = 20)
    private String unit;

    @Column(name = "is_perishable")
    private Boolean isPerishable = true;

    @Column(name = "is_active")
    private Boolean isActive = true;
}
