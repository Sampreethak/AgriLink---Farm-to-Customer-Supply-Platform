-- ============================================================
-- 15_notification_tables.sql
-- Real-time notifications and delivery tracking
-- Tables: notification, notification_status
-- ============================================================

CREATE TABLE IF NOT EXISTS notification (
    notification_id     UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title               VARCHAR(150) NOT NULL,
    message             TEXT        NOT NULL,
    type                VARCHAR(30) DEFAULT 'SYSTEM',
    reference_id        UUID,
    reference_type      VARCHAR(50),
    is_read             VARCHAR(1)  DEFAULT 'N' CHECK (is_read IN ('Y', 'N')),
    is_delivered        VARCHAR(1)  DEFAULT 'N' CHECK (is_delivered IN ('Y', 'N')),
    created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS notification_status (
    status_id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id     UUID        NOT NULL REFERENCES notification(notification_id) ON DELETE CASCADE,
    device_id           VARCHAR(255),
    channel             VARCHAR(20) DEFAULT 'PUSH',
    read_at             TIMESTAMPTZ,
    status              VARCHAR(20) CHECK (status IN ('Sent', 'Delivered', 'Read', 'Failed')),
    failure_reason      TEXT,
    sent_at             TIMESTAMPTZ DEFAULT NOW()
);
