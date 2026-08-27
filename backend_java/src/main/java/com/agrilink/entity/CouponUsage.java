package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "coupon_usage", uniqueConstraints = {
    @UniqueConstraint(name = "uq_coupon_order", columnNames = {"coupon_id", "order_id"})
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class CouponUsage {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "usage_id", updatable = false, nullable = false)
    private UUID usageId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id", nullable = false)
    private Coupon coupon;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id")
    private Customer customer;

    @CreationTimestamp
    @Column(name = "used_at", updatable = false)
    private OffsetDateTime usedAt;

    @Column(name = "discount_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal discountAmount;
}
