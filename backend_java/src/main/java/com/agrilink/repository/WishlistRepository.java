package com.agrilink.repository;

import com.agrilink.entity.Wishlist;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface WishlistRepository extends JpaRepository<Wishlist, UUID> {

    List<Wishlist> findByCustomer_CustomerId(UUID customerId);

    Optional<Wishlist> findByCustomer_CustomerIdAndCrop_CropId(UUID customerId, UUID cropId);

    boolean existsByCustomer_CustomerIdAndCrop_CropId(UUID customerId, UUID cropId);

    void deleteByCustomer_CustomerIdAndCrop_CropId(UUID customerId, UUID cropId);
}
