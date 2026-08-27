package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "settlement")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Settlement {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "settlement_id")
    private UUID settlementId;

    @Column(name = "settlement_type", length = 50)
    private String settlementType;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "payment_id", nullable = false)
    private Payment payment;

    /** Pending | Processed | Failed */
    @Column(name = "status", length = 20)
    private String status = "Pending";

    @Column(name = "settlement_date")
    private ZonedDateTime settlementDate;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = ZonedDateTime.now(); }
}

