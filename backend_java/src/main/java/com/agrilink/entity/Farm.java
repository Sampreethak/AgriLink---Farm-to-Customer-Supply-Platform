package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "farm")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Farm {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "farm_id")
    private UUID farmId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_id", nullable = false)
    private Farmer farmer;

    @Column(name = "farm_name", nullable = false, length = 150)
    private String farmName;

    /** Total land area in acres */
    @Column(name = "total_area", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalArea;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id", nullable = false)
    private Location location;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "organic_certified")
    private Boolean organicCertified = false;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = ZonedDateTime.now(); }
}
