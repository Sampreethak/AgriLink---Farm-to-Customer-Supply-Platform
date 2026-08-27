package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "delivery_assignment")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class DeliveryAssignment {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "assignment_id")
    private UUID assignmentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "delivery_id", nullable = false)
    private Delivery delivery;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "delivery_partner_id", nullable = false)
    private DeliveryPartner deliveryPartner;

    @Column(name = "assigned_at")
    private ZonedDateTime assignedAt;

    /** Assigned | Accepted | PickedUp | InTransit | Delivered */
    @Column(name = "status", length = 20)
    private String status = "Assigned";

    @Column(name = "actual_delivery_time")
    private ZonedDateTime actualDeliveryTime;

    @Column(name = "earning_amount", precision = 10, scale = 2)
    private BigDecimal earningAmount = BigDecimal.ZERO;

    @PrePersist
    protected void onCreate() { if (assignedAt == null) assignedAt = ZonedDateTime.now(); }
}
