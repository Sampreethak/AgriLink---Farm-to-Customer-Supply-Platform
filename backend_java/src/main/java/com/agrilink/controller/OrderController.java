package com.agrilink.controller;

import com.agrilink.entity.Order;
import com.agrilink.entity.OrderItem;
import com.agrilink.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
@Tag(name = "Orders", description = "Order management APIs")
public class OrderController {

    private final OrderService orderService;

    @GetMapping("/{orderId}")
    @Operation(summary = "Get order by ID")
    public ResponseEntity<Order> getOrder(@PathVariable UUID orderId) {
        return ResponseEntity.ok(orderService.findById(orderId));
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get all orders for a customer")
    public ResponseEntity<Page<Order>> getCustomerOrders(
            @PathVariable UUID customerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<Order> orders = orderService.getCustomerOrders(customerId,
                PageRequest.of(page, size, Sort.by("createdAt").descending()));
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/{orderId}/items")
    @Operation(summary = "Get items in an order")
    public ResponseEntity<List<OrderItem>> getOrderItems(@PathVariable UUID orderId) {
        return ResponseEntity.ok(orderService.getOrderItems(orderId));
    }

    @PatchMapping("/{orderId}/status")
    @Operation(summary = "Update order status")
    public ResponseEntity<Order> updateStatus(
            @PathVariable UUID orderId,
            @RequestBody Map<String, String> request) {
        String newStatus = request.get("status");
        return ResponseEntity.ok(orderService.updateStatus(orderId, newStatus));
    }

    @PatchMapping("/{orderId}/cancel")
    @Operation(summary = "Cancel an order")
    public ResponseEntity<Order> cancelOrder(@PathVariable UUID orderId) {
        return ResponseEntity.ok(orderService.cancelOrder(orderId));
    }
}
