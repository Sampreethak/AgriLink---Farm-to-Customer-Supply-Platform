package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "aggregator_inventory")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class AggregatorInventory {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "inventory_batch_id")
    private UUID inventoryBatchId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false)
    private Warehouse warehouse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aggregator_id")
    private Aggregator aggregator;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_id")
    private Farmer farmer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_crop_id")
    private FarmerCrop farmerCrop;

    @Column(name = "batch_no", nullable = false, unique = true, length = 50)
    private String batchNo;

    @Column(name = "quantity_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantityKg;

    @Column(name = "unit_cost_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitCostPrice;

    @Column(name = "available_quantity_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal availableQuantityKg;

    @Column(name = "reserved_quantity_kg", precision = 10, scale = 2)
    private BigDecimal reservedQuantityKg = BigDecimal.ZERO;

    /** Passed | Failed | Pending */
    @Column(name = "quality_status", length = 20)
    private String qualityStatus = "Passed";

    @Column(name = "expiry_date")
    private ZonedDateTime expiryDate;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = ZonedDateTime.now(); }
}
