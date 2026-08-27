package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "delivery_partner")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class DeliveryPartner {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "delivery_partner_id")
    private UUID deliveryPartnerId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "party_id", nullable = false, unique = true)
    private Party party;

    @Column(name = "partner_code", nullable = false, unique = true, length = 50)
    private String partnerCode;

    @Column(name = "rating", precision = 3, scale = 2)
    private BigDecimal rating = BigDecimal.ZERO;

    /** Pending | Approved | Rejected */
    @Column(name = "kyc_status", length = 20)
    private String kycStatus = "Pending";

    @Column(name = "bank_account_id", length = 100)
    private String bankAccountId;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = ZonedDateTime.now(); }
}
