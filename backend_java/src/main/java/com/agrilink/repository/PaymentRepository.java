package com.agrilink.repository;

import com.agrilink.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, UUID> {

    Optional<Payment> findByOrder_OrderId(UUID orderId);

    Optional<Payment> findByRazorpayPaymentId(String razorpayPaymentId);

    Optional<Payment> findByTransactionId(String transactionId);
}
