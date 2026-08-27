package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "delivery_proof")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class DeliveryProof {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "proof_id")
    private UUID proofId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "delivery_id", nullable = false)
    private Delivery delivery;

    /** Signature | OTP | Image */
    @Column(name = "proof_type", length = 20)
    private String proofType;

    /** Y | N */
    @Column(name = "otp_verified", length = 1)
    private String otpVerified = "N";

    @Column(name = "image_url", columnDefinition = "TEXT")
    private String imageUrl;

    @Column(name = "gps_latitude", precision = 10, scale = 8)
    private BigDecimal gpsLatitude;

    @Column(name = "gps_longitude", precision = 11, scale = 8)
    private BigDecimal gpsLongitude;

    @Column(name = "remarks", columnDefinition = "TEXT")
    private String remarks;

    @Column(name = "captured_at")
    private ZonedDateTime capturedAt;

    @PrePersist
    protected void onCreate() { if (capturedAt == null) capturedAt = ZonedDateTime.now(); }
}
