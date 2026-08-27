package com.agrilink.service;

import com.agrilink.entity.Delivery;
import com.agrilink.exception.ResourceNotFoundException;
import com.agrilink.repository.DeliveryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class DeliveryService {

    private final DeliveryRepository deliveryRepository;

    @Transactional(readOnly = true)
    public Delivery findById(UUID deliveryId) {
        return deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new ResourceNotFoundException("Delivery not found: " + deliveryId));
    }

    @Transactional(readOnly = true)
    public Delivery findByOrderId(UUID orderId) {
        return deliveryRepository.findByOrder_OrderId(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Delivery not found for order: " + orderId));
    }

    @Transactional(readOnly = true)
    public List<Delivery> findByStatus(String status) {
        return deliveryRepository.findByDeliveryStatus(status);
    }

    @Transactional
    public Delivery save(Delivery delivery) {
        return deliveryRepository.save(delivery);
    }

    @Transactional
    public Delivery updateStatus(UUID deliveryId, String newStatus) {
        Delivery delivery = findById(deliveryId);
        delivery.setDeliveryStatus(newStatus);
        log.info("Delivery {} status changed to {}", deliveryId, newStatus);
        return deliveryRepository.save(delivery);
    }
}
