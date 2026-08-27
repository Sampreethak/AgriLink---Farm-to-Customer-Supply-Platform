package com.agrilink.repository;

import com.agrilink.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, UUID> {

    Optional<CartItem> findByCart_CartIdAndCrop_CropId(UUID cartId, UUID cropId);

    void deleteByCart_CartId(UUID cartId);
}
