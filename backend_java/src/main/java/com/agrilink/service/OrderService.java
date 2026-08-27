package com.agrilink.service;

import com.agrilink.entity.Order;
import com.agrilink.entity.OrderItem;
import com.agrilink.exception.ResourceNotFoundException;
import com.agrilink.repository.OrderItemRepository;
import com.agrilink.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;

    @Transactional(readOnly = true)
    public Order findById(UUID orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found: " + orderId));
    }

    @Transactional(readOnly = true)
    public Page<Order> getCustomerOrders(UUID customerId, Pageable pageable) {
        return orderRepository.findByCustomer_CustomerId(customerId, pageable);
    }

    @Transactional(readOnly = true)
    public List<OrderItem> getOrderItems(UUID orderId) {
        return orderItemRepository.findByOrder_OrderId(orderId);
    }

    @Transactional
    public Order save(Order order) {
        return orderRepository.save(order);
    }

    @Transactional
    public Order updateStatus(UUID orderId, String newStatus) {
        Order order = findById(orderId);
        order.setOrderStatus(newStatus);
        log.info("Order {} status changed to {}", orderId, newStatus);
        return orderRepository.save(order);
    }

    @Transactional
    public Order cancelOrder(UUID orderId) {
        return updateStatus(orderId, "Cancelled");
    }
}
