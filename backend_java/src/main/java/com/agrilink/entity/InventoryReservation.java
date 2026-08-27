package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "inventory_reservation")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class InventoryReservation {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "reservation_id")
    private UUID reservationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inventory_batch_id", nullable = false)
    private AggregatorInventory inventoryBatch;

    /** References order_item — stored as UUID to avoid circular dependency */
    @Column(name = "order_item_id")
    private UUID orderItemId;

    @Column(name = "reserved_quantity_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal reservedQuantityKg;

    @Column(name = "reserved_until", nullable = false)
    private ZonedDateTime reservedUntil;

    /** Active | Expired | Used */
    @Column(name = "status", length = 20)
    private String status = "Active";

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = ZonedDateTime.now(); }
}
