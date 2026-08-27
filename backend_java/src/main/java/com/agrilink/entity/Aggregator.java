package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "aggregator")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Aggregator {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "aggregator_id")
    private UUID aggregatorId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "party_id", nullable = false, unique = true)
    private Party party;

    @Column(name = "aggregator_code", nullable = false, unique = true, length = 50)
    private String aggregatorCode;

    @Column(name = "business_name", nullable = false, length = 150)
    private String businessName;

    @Column(name = "gstin", unique = true, length = 15)
    private String gstin;

    /** Pending | Approved | Rejected */
    @Column(name = "kyc_status", length = 20)
    private String kycStatus = "Pending";

    @Column(name = "bank_account_id", length = 100)
    private String bankAccountId;

    @Column(name = "is_verified")
    private Boolean isVerified = false;

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = ZonedDateTime.now(); }
}
