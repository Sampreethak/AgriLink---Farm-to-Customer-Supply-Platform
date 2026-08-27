package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "delivery")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Delivery {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "delivery_id")
    private UUID deliveryId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false, unique = true)
    private Order order;

    /** Pickup | Drop | OnTheWay */
    @Column(name = "delivery_type", length = 20)
    private String deliveryType;

    @Column(name = "delivery_status", length = 30)
    private String deliveryStatus = "Pending";

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pickup_address_id")
    private Location pickupAddress;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "delivery_address_id")
    private CustomerAddress deliveryAddress;

    @Column(name = "scheduled_delivery_date")
    private ZonedDateTime scheduledDeliveryDate;

    @Column(name = "actual_delivery_date")
    private ZonedDateTime actualDeliveryDate;

    @Column(name = "delivery_charge", precision = 10, scale = 2)
    private BigDecimal deliveryCharge = BigDecimal.ZERO;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;

    @PrePersist
    protected void onCreate() { createdAt = updatedAt = ZonedDateTime.now(); }

    @PreUpdate
    protected void onUpdate() { updatedAt = ZonedDateTime.now(); }
}
