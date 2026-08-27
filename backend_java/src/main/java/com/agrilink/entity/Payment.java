package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "payment")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "payment_id")
    private UUID paymentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    /** COD | UPI | Card | NetBanking | Wallet */
    @Column(name = "payment_method", length = 30)
    private String paymentMethod;

    @Column(name = "gateway_name", length = 50)
    private String gatewayName;

    @Column(name = "transaction_id", length = 100)
    private String transactionId;

    @Column(name = "razorpay_order_id", unique = true, length = 100)
    private String razorpayOrderId;

    @Column(name = "razorpay_payment_id", unique = true, length = 100)
    private String razorpayPaymentId;

    @Column(name = "razorpay_signature", columnDefinition = "TEXT")
    private String razorpaySignature;

    @Column(name = "payment_date")
    private ZonedDateTime paymentDate;

    /** Success | Failed | Pending | Refunded */
    @Column(name = "payment_status", length = 20)
    private String paymentStatus = "Pending";

    @PrePersist
    protected void onCreate() { if (paymentDate == null) paymentDate = ZonedDateTime.now(); }
}
