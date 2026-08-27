package com.agrilink.service;

import com.agrilink.entity.Coupon;
import com.agrilink.exception.BadRequestException;
import com.agrilink.exception.ResourceNotFoundException;
import com.agrilink.repository.CouponRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class CouponService {

    private final CouponRepository couponRepository;

    @Transactional(readOnly = true)
    public Coupon findById(UUID couponId) {
        return couponRepository.findById(couponId)
                .orElseThrow(() -> new ResourceNotFoundException("Coupon not found: " + couponId));
    }

    @Transactional(readOnly = true)
    public Coupon validateAndGetCoupon(String code) {
        return couponRepository.findValidCoupon(code, OffsetDateTime.now())
                .orElseThrow(() -> new BadRequestException("Coupon '" + code + "' is invalid or expired"));
    }

    @Transactional
    public Coupon save(Coupon coupon) {
        return couponRepository.save(coupon);
    }

    @Transactional
    public void incrementUsage(UUID couponId) {
        Coupon coupon = findById(couponId);
        coupon.setUsedCount(coupon.getUsedCount() + 1);
        if (coupon.getUsageLimit() != null && coupon.getUsedCount() >= coupon.getUsageLimit()) {
            coupon.setIsActive(false);
            log.info("Coupon {} deactivated after reaching usage limit", couponId);
        }
        couponRepository.save(coupon);
    }
}
