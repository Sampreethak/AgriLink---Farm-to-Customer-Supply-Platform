package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "cart_item", uniqueConstraints = {
    @UniqueConstraint(name = "uq_cart_crop", columnNames = {"cart_id", "crop_id"})
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class CartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "cart_item_id", updatable = false, nullable = false)
    private UUID cartItemId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cart_id", nullable = false)
    private Cart cart;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "crop_id", nullable = false)
    private Crop crop;

    @Column(name = "quantity", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantity;

    @Column(name = "unit_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @CreationTimestamp
    @Column(name = "added_at", updatable = false)
    private OffsetDateTime addedAt;
}
