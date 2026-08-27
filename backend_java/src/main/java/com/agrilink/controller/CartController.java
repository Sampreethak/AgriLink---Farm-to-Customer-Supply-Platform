package com.agrilink.controller;

import com.agrilink.entity.Cart;
import com.agrilink.service.CartService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/cart")
@RequiredArgsConstructor
@Tag(name = "Cart", description = "Shopping cart management APIs")
public class CartController {

    private final CartService cartService;

    @GetMapping("/{customerId}")
    @Operation(summary = "Get cart for a customer")
    public ResponseEntity<Cart> getCart(@PathVariable UUID customerId) {
        Cart cart = cartService.getOrCreateCart(customerId);
        return ResponseEntity.ok(cart);
    }

    @PostMapping("/{customerId}/items")
    @Operation(summary = "Add or update an item in the cart")
    public ResponseEntity<?> addOrUpdateItem(
            @PathVariable UUID customerId,
            @RequestBody Map<String, Object> request) {
        UUID cropId = UUID.fromString(request.get("cropId").toString());
        BigDecimal quantity = new BigDecimal(request.get("quantity").toString());
        return ResponseEntity.ok(cartService.addOrUpdateItem(customerId, cropId, quantity));
    }

    @DeleteMapping("/{customerId}/items/{cropId}")
    @Operation(summary = "Remove an item from the cart")
    public ResponseEntity<Void> removeItem(
            @PathVariable UUID customerId,
            @PathVariable UUID cropId) {
        cartService.removeItem(customerId, cropId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{customerId}/clear")
    @Operation(summary = "Clear entire cart")
    public ResponseEntity<Void> clearCart(@PathVariable UUID customerId) {
        cartService.clearCart(customerId);
        return ResponseEntity.noContent().build();
    }
}
