package com.agrilink.controller;

import com.agrilink.entity.Delivery;
import com.agrilink.service.DeliveryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/deliveries")
@RequiredArgsConstructor
@Tag(name = "Deliveries", description = "Delivery tracking APIs")
public class DeliveryController {

    private final DeliveryService deliveryService;

    @GetMapping("/{deliveryId}")
    @Operation(summary = "Get delivery by ID")
    public ResponseEntity<Delivery> getDelivery(@PathVariable UUID deliveryId) {
        return ResponseEntity.ok(deliveryService.findById(deliveryId));
    }

    @GetMapping("/order/{orderId}")
    @Operation(summary = "Get delivery for an order")
    public ResponseEntity<Delivery> getDeliveryByOrder(@PathVariable UUID orderId) {
        return ResponseEntity.ok(deliveryService.findByOrderId(orderId));
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "Get all deliveries by status (admin/partner)")
    public ResponseEntity<List<Delivery>> getDeliveriesByStatus(@PathVariable String status) {
        return ResponseEntity.ok(deliveryService.findByStatus(status));
    }

    @PatchMapping("/{deliveryId}/status")
    @Operation(summary = "Update delivery status")
    public ResponseEntity<Delivery> updateStatus(
            @PathVariable UUID deliveryId,
            @RequestBody Map<String, String> request) {
        return ResponseEntity.ok(deliveryService.updateStatus(deliveryId, request.get("status")));
    }
}
