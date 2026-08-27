package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "returns")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Return {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "return_id", updatable = false, nullable = false)
    private UUID returnId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id")
    private Customer customer;

    @CreationTimestamp
    @Column(name = "return_date", updatable = false)
    private OffsetDateTime returnDate;

    @Column(name = "reason", nullable = false, columnDefinition = "TEXT")
    private String reason;

    @Column(name = "status", length = 20)
    @Builder.Default
    private String status = "Requested"; // 'Requested', 'Approved', 'Rejected', 'Completed'

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewed_by")
    private User reviewedBy;

    @Column(name = "reviewed_at")
    private OffsetDateTime reviewedAt;

    @OneToMany(mappedBy = "returnRequest", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<ReturnItem> returnItems = new ArrayList<>();

    @OneToOne(mappedBy = "returnRequest", cascade = CascadeType.ALL)
    private Refund refund;
}
