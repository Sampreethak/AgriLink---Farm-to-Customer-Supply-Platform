package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "location")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Location {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "location_id")
    private UUID locationId;

    @Column(name = "address_line1", nullable = false, length = 255)
    private String addressLine1;

    @Column(name = "address_line2", length = 255)
    private String addressLine2;

    @Column(name = "city", nullable = false, length = 100)
    private String city;

    @Column(name = "state", nullable = false, length = 100)
    private String state;

    @Column(name = "pincode", nullable = false, length = 20)
    private String pincode;

    @Column(name = "country", length = 100)
    private String country = "India";

    @Column(name = "latitude", precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private BigDecimal longitude;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = ZonedDateTime.now(); }
}
