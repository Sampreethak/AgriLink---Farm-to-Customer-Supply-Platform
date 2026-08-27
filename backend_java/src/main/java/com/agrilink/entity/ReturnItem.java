package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "return_item")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ReturnItem {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "return_item_id", updatable = false, nullable = false)
    private UUID returnItemId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "return_id", nullable = false)
    private Return returnRequest;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_item_id", nullable = false)
    private OrderItem orderItem;

    @Column(name = "quantity", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantity;

    @Column(name = "refund_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal refundAmount;

    @Column(name = "condition", length = 30)
    private String condition;

    @Column(name = "image_url", columnDefinition = "TEXT")
    private String imageUrl;
}
