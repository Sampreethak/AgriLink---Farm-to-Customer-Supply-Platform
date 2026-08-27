package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "customer_address")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CustomerAddress {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "address_id")
    private UUID addressId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id", nullable = false)
    private Location location;

    /** Home | Work | Other */
    @Column(name = "address_type", nullable = false, length = 20)
    private String addressType;

    @Column(name = "address_line1", nullable = false, length = 255)
    private String addressLine1;

    @Column(name = "address_line2", length = 255)
    private String addressLine2;

    @Column(name = "landmark", length = 150)
    private String landmark;

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

    @Column(name = "is_default")
    private Boolean isDefault = false;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;

    @PrePersist
    protected void onCreate() { createdAt = updatedAt = ZonedDateTime.now(); }

    @PreUpdate
    protected void onUpdate() { updatedAt = ZonedDateTime.now(); }
}
