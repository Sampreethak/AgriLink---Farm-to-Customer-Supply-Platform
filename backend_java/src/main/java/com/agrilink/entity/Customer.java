package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "customer")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "customer_id")
    private UUID customerId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "party_id", nullable = false, unique = true)
    private Party party;

    @Column(name = "loyalty_points")
    private Integer loyaltyPoints = 0;

    /** FK set after CustomerAddress table exists (handled via @JoinColumn + nullable) */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "default_address_id")
    private CustomerAddress defaultAddress;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;

    @PrePersist
    protected void onCreate() { createdAt = updatedAt = ZonedDateTime.now(); }

    @PreUpdate
    protected void onUpdate() { updatedAt = ZonedDateTime.now(); }
}
