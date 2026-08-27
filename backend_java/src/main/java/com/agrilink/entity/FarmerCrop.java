package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "farmer_crop")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class FarmerCrop {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "farmer_crop_id")
    private UUID farmerCropId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farm_id", nullable = false)
    private Farm farm;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "crop_id", nullable = false)
    private Crop crop;

    @Column(name = "variety", length = 100)
    private String variety;

    @Column(name = "sowing_date")
    private LocalDate sowingDate;

    @Column(name = "expected_harvest_date")
    private LocalDate expectedHarvestDate;

    /** Fully Organic | Partially Organic | Conventional */
    @Column(name = "organic_level", length = 50)
    private String organicLevel;

    /** A | B | C */
    @Column(name = "grade", length = 10)
    private String grade;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = ZonedDateTime.now(); }
}
