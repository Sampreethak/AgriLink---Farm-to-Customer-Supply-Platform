-- ============================================================
-- 16_notification.sql
-- Real-time notification system and delivery tracking
-- Tables: notification, notification_status
-- Depends on: 04_user.sql (users)
-- ============================================================

-- 1. NOTIFICATION
-- Core notification record for any system or business event.
-- Supports push (Firebase), SMS, and email channels.
-- Business rules:
--  - is_read and is_delivered are char flags for SQL simplicity
--  - type field categorizes: 'ORDER', 'PAYMENT', 'DELIVERY', 'PROMO', 'SYSTEM'
CREATE TABLE IF NOT EXISTS notification (
    notification_id     UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title               VARCHAR(150) NOT NULL,
    message             TEXT        NOT NULL,
    type                VARCHAR(30) DEFAULT 'SYSTEM',   -- ORDER, PAYMENT, DELIVERY, PROMO, SYSTEM
    reference_id        UUID,       -- Optional FK to relevant entity (order_id, payment_id, etc.)
    reference_type      VARCHAR(50),    -- 'ORDER', 'PAYMENT', 'DELIVERY', etc.
    is_read             VARCHAR(1)  DEFAULT 'N' CHECK (is_read IN ('Y', 'N')),
    is_delivered        VARCHAR(1)  DEFAULT 'N' CHECK (is_delivered IN ('Y', 'N')),
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- 2. NOTIFICATION_STATUS
-- Per-device delivery status for multi-device notification tracking.
-- A notification can be sent to multiple devices (mobile + web).
CREATE TABLE IF NOT EXISTS notification_status (
    status_id           UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id     UUID        NOT NULL REFERENCES notification(notification_id) ON DELETE CASCADE,
    device_id           VARCHAR(255),   -- FCM token or device identifier
    channel             VARCHAR(20) DEFAULT 'PUSH',    -- 'PUSH', 'SMS', 'EMAIL'
    read_at             TIMESTAMPTZ,
    status              VARCHAR(20) CHECK (status IN ('Sent', 'Delivered', 'Read', 'Failed')),
    failure_reason      TEXT,
    sent_at             TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- INDEXES for notification tables
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_notification_user_id ON notification(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_is_read ON notification(is_read);
CREATE INDEX IF NOT EXISTS idx_notification_type ON notification(type);
CREATE INDEX IF NOT EXISTS idx_notification_created_at ON notification(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_ref ON notification(reference_type, reference_id);
-- Partial index: only unread notifications (most common query)
CREATE INDEX IF NOT EXISTS idx_notification_unread ON notification(user_id, created_at DESC)
    WHERE is_read = 'N';
CREATE INDEX IF NOT EXISTS idx_notif_status_notification_id ON notification_status(notification_id);
CREATE INDEX IF NOT EXISTS idx_notif_status_status ON notification_status(status);
