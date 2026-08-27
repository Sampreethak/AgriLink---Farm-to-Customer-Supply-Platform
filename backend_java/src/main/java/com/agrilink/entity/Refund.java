package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "refund")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Refund {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "refund_id", updatable = false, nullable = false)
    private UUID refundId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "return_id", nullable = false, unique = true)
    private Return returnRequest;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payment_id")
    private Payment payment;

    @Column(name = "amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    @Column(name = "refund_method", length = 30)
    private String refundMethod;

    @Column(name = "gateway_refund_id", length = 100)
    private String gatewayRefundId;

    @Column(name = "status", length = 20)
    @Builder.Default
    private String status = "Pending"; // 'Pending', 'Processed', 'Failed'

    @Column(name = "refund_date")
    private OffsetDateTime refundDate;

    @Column(name = "transaction_id", length = 100)
    private String transactionId;

    @Column(name = "failure_reason", columnDefinition = "TEXT")
    private String failureReason;
}
