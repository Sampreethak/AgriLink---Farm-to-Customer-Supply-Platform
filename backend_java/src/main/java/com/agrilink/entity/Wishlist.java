package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "wishlist", uniqueConstraints = {
    @UniqueConstraint(name = "uq_wishlist_customer_crop", columnNames = {"customer_id", "crop_id"})
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Wishlist {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "wishlist_id", updatable = false, nullable = false)
    private UUID wishlistId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "crop_id", nullable = false)
    private Crop crop;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
