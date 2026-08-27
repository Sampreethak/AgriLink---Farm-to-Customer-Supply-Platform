package com.agrilink.service;

import com.agrilink.entity.Cart;
import com.agrilink.entity.CartItem;
import com.agrilink.entity.Crop;
import com.agrilink.entity.Customer;
import com.agrilink.exception.BadRequestException;
import com.agrilink.exception.ResourceNotFoundException;
import com.agrilink.repository.CartItemRepository;
import com.agrilink.repository.CartRepository;
import com.agrilink.repository.CropRepository;
import com.agrilink.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final CustomerRepository customerRepository;
    private final CropRepository cropRepository;

    @Transactional(readOnly = true)
    public Cart getCartByCustomerId(UUID customerId) {
        return cartRepository.findByCustomer_CustomerId(customerId)
                .orElseThrow(() -> new ResourceNotFoundException("Cart not found for customer: " + customerId));
    }

    @Transactional
    public Cart getOrCreateCart(UUID customerId) {
        return cartRepository.findByCustomer_CustomerId(customerId)
                .orElseGet(() -> {
                    Customer customer = customerRepository.findById(customerId)
                            .orElseThrow(() -> new ResourceNotFoundException("Customer not found: " + customerId));
                    Cart newCart = Cart.builder().customer(customer).build();
                    return cartRepository.save(newCart);
                });
    }

    @Transactional
    public CartItem addOrUpdateItem(UUID customerId, UUID cropId, BigDecimal quantity) {
        if (quantity.compareTo(BigDecimal.ZERO) <= 0) {
            throw new BadRequestException("Quantity must be greater than zero");
        }

        Cart cart = getOrCreateCart(customerId);
        Crop crop = cropRepository.findById(cropId)
                .orElseThrow(() -> new ResourceNotFoundException("Crop not found: " + cropId));

        CartItem existingItem = cartItemRepository.findByCart_CartIdAndCrop_CropId(cart.getCartId(), cropId)
                .orElse(null);

        // Use a default price of 0 if crop doesn't have a base price directly
        BigDecimal unitPrice = BigDecimal.ZERO;

        if (existingItem != null) {
            existingItem.setQuantity(quantity);
            existingItem.setUnitPrice(unitPrice);
            return cartItemRepository.save(existingItem);
        } else {
            CartItem newItem = CartItem.builder()
                    .cart(cart)
                    .crop(crop)
                    .quantity(quantity)
                    .unitPrice(unitPrice)
                    .build();
            return cartItemRepository.save(newItem);
        }
    }

    @Transactional
    public void removeItem(UUID customerId, UUID cropId) {
        Cart cart = getCartByCustomerId(customerId);
        CartItem item = cartItemRepository.findByCart_CartIdAndCrop_CropId(cart.getCartId(), cropId)
                .orElseThrow(() -> new ResourceNotFoundException("Item not in cart"));
        cartItemRepository.delete(item);
    }

    @Transactional
    public void clearCart(UUID customerId) {
        Cart cart = getCartByCustomerId(customerId);
        cartItemRepository.deleteByCart_CartId(cart.getCartId());
        log.info("Cart cleared for customer: {}", customerId);
    }
}
