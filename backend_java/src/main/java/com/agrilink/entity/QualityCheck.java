package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "quality_check")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class QualityCheck {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "qc_id")
    private UUID qcId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inventory_batch_id", nullable = false)
    private AggregatorInventory inventoryBatch;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "checked_by")
    private User checkedBy;

    /** A | B | C */
    @Column(name = "quality_grade", length = 10)
    private String qualityGrade;

    /** Passed | Failed */
    @Column(name = "qc_status", length = 20)
    private String qcStatus = "Passed";

    @Column(name = "moisture_level_pct", precision = 5, scale = 2)
    private BigDecimal moistureLevelPct;

    @Column(name = "temperature_at_check", precision = 5, scale = 2)
    private BigDecimal temperatureAtCheck;

    @Column(name = "remarks", columnDefinition = "TEXT")
    private String remarks;

    @Column(name = "inspected_at")
    private ZonedDateTime inspectedAt;

    @PrePersist
    protected void onCreate() { if (inspectedAt == null) inspectedAt = ZonedDateTime.now(); }
}
