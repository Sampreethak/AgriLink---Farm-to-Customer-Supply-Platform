package com.agrilink.controller;

import com.agrilink.entity.Coupon;
import com.agrilink.service.CouponService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/coupons")
@RequiredArgsConstructor
@Tag(name = "Coupons", description = "Coupon and discount management APIs")
public class CouponController {

    private final CouponService couponService;

    @GetMapping("/{couponId}")
    @Operation(summary = "Get coupon by ID")
    public ResponseEntity<Coupon> getCoupon(@PathVariable UUID couponId) {
        return ResponseEntity.ok(couponService.findById(couponId));
    }

    @GetMapping("/validate")
    @Operation(summary = "Validate a coupon code")
    public ResponseEntity<Coupon> validateCoupon(@RequestParam String code) {
        return ResponseEntity.ok(couponService.validateAndGetCoupon(code));
    }

    @PostMapping
    @Operation(summary = "Create a new coupon (admin)")
    public ResponseEntity<Coupon> createCoupon(@RequestBody Coupon coupon) {
        return ResponseEntity.ok(couponService.save(coupon));
    }
}
