package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "vehicle")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "vehicle_id")
    private UUID vehicleId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "delivery_partner_id", nullable = false)
    private DeliveryPartner deliveryPartner;

    /** Motorcycle | Mini Truck | Tempo | Refrigerator Van */
    @Column(name = "vehicle_type", nullable = false, length = 50)
    private String vehicleType;

    @Column(name = "vehicle_no", nullable = false, unique = true, length = 20)
    private String vehicleNo;

    @Column(name = "capacity_kg", precision = 10, scale = 2)
    private BigDecimal capacityKg;

    @Column(name = "current_load_kg", precision = 10, scale = 2)
    private BigDecimal currentLoadKg = BigDecimal.ZERO;

    @Column(name = "registration_no", unique = true, length = 30)
    private String registrationNo;

    @Column(name = "is_active")
    private Boolean isActive = true;
}
