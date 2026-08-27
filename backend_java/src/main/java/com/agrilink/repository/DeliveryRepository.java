package com.agrilink.repository;

import com.agrilink.entity.Delivery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DeliveryRepository extends JpaRepository<Delivery, UUID> {

    Optional<Delivery> findByOrder_OrderId(UUID orderId);

    List<Delivery> findByDeliveryStatus(String deliveryStatus);
}
