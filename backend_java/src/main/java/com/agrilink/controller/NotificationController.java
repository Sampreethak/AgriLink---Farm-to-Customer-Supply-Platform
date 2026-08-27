package com.agrilink.controller;

import com.agrilink.entity.Notification;
import com.agrilink.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "Notification management APIs")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get all notifications for a user")
    public ResponseEntity<Page<Notification>> getUserNotifications(
            @PathVariable UUID userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(notificationService.getUserNotifications(userId,
                PageRequest.of(page, size, Sort.by("createdAt").descending())));
    }

    @GetMapping("/user/{userId}/unread")
    @Operation(summary = "Get unread notifications count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(@PathVariable UUID userId) {
        return ResponseEntity.ok(Map.of("unreadCount", notificationService.getUnreadCount(userId)));
    }

    @PatchMapping("/{notificationId}/read")
    @Operation(summary = "Mark a notification as read")
    public ResponseEntity<Notification> markAsRead(@PathVariable UUID notificationId) {
        return ResponseEntity.ok(notificationService.markAsRead(notificationId));
    }

    @PatchMapping("/user/{userId}/read-all")
    @Operation(summary = "Mark all notifications as read for a user")
    public ResponseEntity<Map<String, Integer>> markAllRead(@PathVariable UUID userId) {
        int count = notificationService.markAllRead(userId);
        return ResponseEntity.ok(Map.of("markedRead", count));
    }
}
