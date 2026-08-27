package com.agrilink.repository;

import com.agrilink.entity.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface OrderRepository extends JpaRepository<Order, UUID> {

    Page<Order> findByCustomer_CustomerId(UUID customerId, Pageable pageable);

    Page<Order> findByOrderStatus(String orderStatus, Pageable pageable);

    @Query("SELECT o FROM Order o WHERE o.customer.customerId = :customerId AND o.orderStatus = :status")
    List<Order> findByCustomerIdAndStatus(@Param("customerId") UUID customerId, @Param("status") String status);

    @Query("SELECT o FROM Order o WHERE o.createdAt BETWEEN :from AND :to ORDER BY o.createdAt DESC")
    List<Order> findByDateRange(@Param("from") ZonedDateTime from, @Param("to") ZonedDateTime to);

    @Query("SELECT COUNT(o) FROM Order o WHERE o.customer.customerId = :customerId")
    long countByCustomerId(@Param("customerId") UUID customerId);
}
