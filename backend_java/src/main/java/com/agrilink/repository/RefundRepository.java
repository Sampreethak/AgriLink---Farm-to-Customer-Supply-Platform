package com.agrilink.repository;

import com.agrilink.entity.Refund;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RefundRepository extends JpaRepository<Refund, UUID> {

    Optional<Refund> findByReturnRequest_ReturnId(UUID returnId);

    Optional<Refund> findByGatewayRefundId(String gatewayRefundId);
}
