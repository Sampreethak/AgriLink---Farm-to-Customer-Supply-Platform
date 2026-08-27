package com.agrilink.repository;

import com.agrilink.entity.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    Page<Notification> findByUser_UserId(UUID userId, Pageable pageable);

    @Query("SELECT n FROM Notification n WHERE n.user.userId = :userId AND n.isRead = 'N'")
    Page<Notification> findUnreadByUserId(@Param("userId") UUID userId, Pageable pageable);

    @Query("SELECT COUNT(n) FROM Notification n WHERE n.user.userId = :userId AND n.isRead = 'N'")
    long countUnreadByUserId(@Param("userId") UUID userId);

    @Modifying
    @Query("UPDATE Notification n SET n.isRead = 'Y' WHERE n.user.userId = :userId")
    int markAllReadForUser(@Param("userId") UUID userId);
}
