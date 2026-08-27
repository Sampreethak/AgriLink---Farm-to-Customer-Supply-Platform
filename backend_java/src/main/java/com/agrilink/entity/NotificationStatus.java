package com.agrilink.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "notification_status")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class NotificationStatus {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "status_id", updatable = false, nullable = false)
    private UUID statusId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "notification_id", nullable = false)
    private Notification notification;

    @Column(name = "device_id", length = 255)
    private String deviceId;

    @Column(name = "channel", length = 20)
    @Builder.Default
    private String channel = "PUSH";

    @Column(name = "read_at")
    private OffsetDateTime readAt;

    @Column(name = "status", length = 20)
    private String status; // 'Sent', 'Delivered', 'Read', 'Failed'

    @Column(name = "failure_reason", columnDefinition = "TEXT")
    private String failureReason;

    @CreationTimestamp
    @Column(name = "sent_at", updatable = false)
    private OffsetDateTime sentAt;
}
