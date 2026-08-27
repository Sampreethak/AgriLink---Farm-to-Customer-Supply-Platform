package com.agrilink.repository;

import com.agrilink.entity.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CouponRepository extends JpaRepository<Coupon, UUID> {

    Optional<Coupon> findByCouponCode(String couponCode);

    @Query("SELECT c FROM Coupon c WHERE c.couponCode = :code AND c.isActive = true AND c.validFrom <= :now AND (c.validTo IS NULL OR c.validTo >= :now)")
    Optional<Coupon> findValidCoupon(@Param("code") String code, @Param("now") OffsetDateTime now);
}
