package com.agrilink.repository;

import com.agrilink.entity.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ReviewRepository extends JpaRepository<Review, UUID> {

    Page<Review> findByCrop_CropId(UUID cropId, Pageable pageable);

    Page<Review> findByCustomer_CustomerId(UUID customerId, Pageable pageable);

    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.crop.cropId = :cropId")
    Double findAverageRatingByCropId(@Param("cropId") UUID cropId);
}
