package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "orders")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "order_id")
    private UUID orderId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(name = "order_date")
    private ZonedDateTime orderDate;

    /** Placed | Confirmed | Processing | OutForDelivery | Delivered | Cancelled */
    @Column(name = "order_status", length = 30)
    private String orderStatus = "Placed";

    @Column(name = "total_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "delivery_address_id")
    private CustomerAddress deliveryAddress;

    /** Pending | Paid | Failed | Refunded */
    @Column(name = "payment_status", length = 20)
    private String paymentStatus = "Pending";

    @Column(name = "special_instructions", columnDefinition = "TEXT")
    private String specialInstructions;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = updatedAt = ZonedDateTime.now();
        if (orderDate == null) orderDate = ZonedDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() { updatedAt = ZonedDateTime.now(); }
}
