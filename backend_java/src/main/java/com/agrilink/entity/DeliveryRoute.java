package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "delivery_route")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class DeliveryRoute {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "route_id")
    private UUID routeId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "delivery_id", nullable = false)
    private Delivery delivery;

    @Column(name = "sequence_no", nullable = false)
    private Integer sequenceNo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stop_location_id", nullable = false)
    private Location stopLocation;

    /** Pickup | Drop */
    @Column(name = "stop_type", length = 20)
    private String stopType;

    @Column(name = "estimated_time", length = 50)
    private String estimatedTime;

    @Column(name = "actual_time")
    private ZonedDateTime actualTime;
}
