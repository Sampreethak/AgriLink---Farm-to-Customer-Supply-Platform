package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "farmer")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Farmer {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "farmer_id")
    private UUID farmerId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "party_id", nullable = false, unique = true)
    private Party party;

    @Column(name = "farmer_code", nullable = false, unique = true, length = 50)
    private String farmerCode;

    @Column(name = "bio", columnDefinition = "TEXT")
    private String bio;

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
