package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "order_tracking")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class OrderTracking {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "tracking_id")
    private UUID trackingId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "status", nullable = false, length = 30)
    private String status;

    @Column(name = "status_updated_at")
    private ZonedDateTime statusUpdatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id")
    private Location location;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private User updatedBy;

    @Column(name = "remarks", columnDefinition = "TEXT")
    private String remarks;

    @PrePersist
    protected void onCreate() { if (statusUpdatedAt == null) statusUpdatedAt = ZonedDateTime.now(); }
}
