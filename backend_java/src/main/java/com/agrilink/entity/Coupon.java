package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "coupon")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Coupon {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "coupon_id", updatable = false, nullable = false)
    private UUID couponId;

    @Column(name = "coupon_code", nullable = false, unique = true, length = 30)
    private String couponCode;

    @Column(name = "discount_type", length = 20)
    private String discountType; // 'Fixed' or 'Percent'

    @Column(name = "discount_value", nullable = false, precision = 10, scale = 2)
    private BigDecimal discountValue;

    @Column(name = "min_order_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal minOrderAmount = BigDecimal.ZERO;

    @Column(name = "max_discount_amount", precision = 10, scale = 2)
    private BigDecimal maxDiscountAmount;

    @Column(name = "usage_limit")
    private Integer usageLimit;

    @Column(name = "used_count")
    @Builder.Default
    private Integer usedCount = 0;

    @Column(name = "valid_from")
    private OffsetDateTime validFrom;

    @Column(name = "valid_to")
    private OffsetDateTime validTo;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;
}
