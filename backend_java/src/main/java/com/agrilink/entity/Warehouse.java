package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "warehouse")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Warehouse {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "warehouse_id")
    private UUID warehouseId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aggregator_id", nullable = false)
    private Aggregator aggregator;

    @Column(name = "warehouse_name", nullable = false, length = 150)
    private String warehouseName;

    /** Cold Room | Dry Warehouse | Mixed */
    @Column(name = "warehouse_type", length = 50)
    private String warehouseType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id", nullable = false)
    private Location location;

    @Column(name = "total_capacity_kg", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalCapacityKg;

    @Column(name = "occupied_capacity_kg", precision = 12, scale = 2)
    private BigDecimal occupiedCapacityKg = BigDecimal.ZERO;

    @Column(name = "cold_storage")
    private Boolean coldStorage = false;

    /** Min temperature in Celsius for cold storage */
    @Column(name = "temperature_min", precision = 5, scale = 2)
    private BigDecimal temperatureMin;

    /** Max temperature in Celsius for cold storage */
    @Column(name = "temperature_max", precision = 5, scale = 2)
    private BigDecimal temperatureMax;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = ZonedDateTime.now(); }
}
