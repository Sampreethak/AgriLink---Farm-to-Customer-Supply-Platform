package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "review")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "review_id", updatable = false, nullable = false)
    private UUID reviewId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "crop_id", nullable = false)
    private Crop crop;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farmer_id")
    private Farmer farmer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aggregator_id")
    private Aggregator aggregator;

    @Column(name = "rating", nullable = false)
    private Integer rating;

    @Column(name = "review_text", columnDefinition = "TEXT")
    private String reviewText;

    @CreationTimestamp
    @Column(name = "review_date", updatable = false)
    private OffsetDateTime reviewDate;
}
