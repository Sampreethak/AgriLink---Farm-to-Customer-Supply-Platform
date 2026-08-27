package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "procurement")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Procurement {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "procurement_id")
    private UUID procurementId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_id", nullable = false)
    private Farmer farmer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aggregator_id", nullable = false)
    private Aggregator aggregator;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_crop_id", nullable = false)
    private FarmerCrop farmerCrop;

    @Column(name = "quantity_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantityKg;

    @Column(name = "unit_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "total_price", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalPrice;

    @Column(name = "procurement_date")
    private ZonedDateTime procurementDate;

    /** Pending | Passed | Failed */
    @Column(name = "quality_status", length = 20)
    private String qualityStatus = "Pending";

    /** Pending | Paid | Failed */
    @Column(name = "payment_status", length = 20)
    private String paymentStatus = "Pending";

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = ZonedDateTime.now();
        if (procurementDate == null) procurementDate = ZonedDateTime.now();
    }
}
