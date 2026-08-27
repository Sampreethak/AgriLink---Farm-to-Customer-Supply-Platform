package com.agrilink.service;

import com.agrilink.entity.Notification;
import com.agrilink.entity.User;
import com.agrilink.exception.ResourceNotFoundException;
import com.agrilink.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserService userService;

    @Transactional
    public Notification createNotification(UUID userId, String title, String message, String type, UUID referenceId, String referenceType) {
        User user = userService.findById(userId);
        Notification notification = Notification.builder()
                .user(user)
                .title(title)
                .message(message)
                .type(type)
                .referenceId(referenceId)
                .referenceType(referenceType)
                .build();
        return notificationRepository.save(notification);
    }

    @Transactional(readOnly = true)
    public Page<Notification> getUserNotifications(UUID userId, Pageable pageable) {
        return notificationRepository.findByUser_UserId(userId, pageable);
    }

    @Transactional(readOnly = true)
    public Page<Notification> getUnreadNotifications(UUID userId, Pageable pageable) {
        return notificationRepository.findUnreadByUserId(userId, pageable);
    }

    @Transactional(readOnly = true)
    public long getUnreadCount(UUID userId) {
        return notificationRepository.countUnreadByUserId(userId);
    }

    @Transactional
    public Notification markAsRead(UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification not found: " + notificationId));
        notification.setIsRead("Y");
        return notificationRepository.save(notification);
    }

    @Transactional
    public int markAllRead(UUID userId) {
        return notificationRepository.markAllReadForUser(userId);
    }
}
