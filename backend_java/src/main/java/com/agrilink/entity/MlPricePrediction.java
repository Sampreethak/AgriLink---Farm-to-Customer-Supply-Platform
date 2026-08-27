package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "ml_price_prediction")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MlPricePrediction {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "prediction_id", updatable = false, nullable = false)
    private UUID predictionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "crop_id", nullable = false)
    private Crop crop;

    @Column(name = "predicted_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal predictedPrice;

    @Column(name = "predicted_demand_kg", precision = 12, scale = 2)
    private BigDecimal predictedDemandKg;

    @Column(name = "factors", columnDefinition = "TEXT")
    private String factors;

    @Column(name = "confidence_score", precision = 5, scale = 4)
    private BigDecimal confidenceScore;

    @Column(name = "model_version", length = 20)
    private String modelVersion;

    @Column(name = "effective_from", nullable = false)
    private OffsetDateTime effectiveFrom;

    @Column(name = "effective_to", nullable = false)
    private OffsetDateTime effectiveTo;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
