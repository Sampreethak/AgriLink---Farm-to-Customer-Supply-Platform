package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "party")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class Party {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "party_id")
    private UUID partyId;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    /** Customer | Farmer | Aggregator | Delivery Partner | Admin */
    @Column(name = "party_type", nullable = false, length = 30)
    private String partyType;

    @Column(name = "gstin", unique = true, length = 15)
    private String gstin;

    /** Pending | Approved | Rejected */
    @Column(name = "kyc_status", length = 20)
    private String kycStatus = "Pending";

    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;

    @PrePersist
    protected void onCreate() { createdAt = updatedAt = ZonedDateTime.now(); }

    @PreUpdate
    protected void onUpdate() { updatedAt = ZonedDateTime.now(); }
}
