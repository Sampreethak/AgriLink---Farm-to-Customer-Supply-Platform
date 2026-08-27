package com.agrilink.repository;

import com.agrilink.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, UUID> {

    @Query("SELECT c FROM Customer c WHERE c.party.user.userId = :userId")
    Optional<Customer> findByUserId(@Param("userId") UUID userId);

    @Query("SELECT CASE WHEN COUNT(c) > 0 THEN true ELSE false END FROM Customer c WHERE c.party.user.userId = :userId")
    boolean existsByUserId(@Param("userId") UUID userId);
}
