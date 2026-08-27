package com.agrilink.repository;

import com.agrilink.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, UUID> {

    List<OrderItem> findByOrder_OrderId(UUID orderId);

    @Query("SELECT oi FROM OrderItem oi WHERE oi.crop.cropId = :cropId ORDER BY oi.createdAt DESC")
    List<OrderItem> findByCropId(@Param("cropId") UUID cropId);
}
