package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "notification")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "notification_id", updatable = false, nullable = false)
    private UUID notificationId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "title", nullable = false, length = 150)
    private String title;

    @Column(name = "message", nullable = false, columnDefinition = "TEXT")
    private String message;

    @Column(name = "type", length = 30)
    @Builder.Default
    private String type = "SYSTEM";

    @Column(name = "reference_id")
    private UUID referenceId;

    @Column(name = "reference_type", length = 50)
    private String referenceType;

    @Column(name = "is_read", length = 1)
    @Builder.Default
    private String isRead = "N"; // 'Y' or 'N'

    @Column(name = "is_delivered", length = 1)
    @Builder.Default
    private String isDelivered = "N"; // 'Y' or 'N'

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
