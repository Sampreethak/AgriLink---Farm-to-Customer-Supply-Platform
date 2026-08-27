package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "price_history")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PriceHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "price_history_id", updatable = false, nullable = false)
    private UUID priceHistoryId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "crop_id", nullable = false)
    private Crop crop;

    @Column(name = "old_price", precision = 10, scale = 2)
    private BigDecimal oldPrice;

    @Column(name = "new_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal newPrice;

    @Column(name = "source", length = 30)
    private String source; // 'Manual', 'Market', 'Demand', 'Prediction'

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "changed_by")
    private User changedBy;

    @Column(name = "effective_from")
    private OffsetDateTime effectiveFrom;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
