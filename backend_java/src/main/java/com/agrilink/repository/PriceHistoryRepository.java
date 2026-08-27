package com.agrilink.repository;

import com.agrilink.entity.PriceHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface PriceHistoryRepository extends JpaRepository<PriceHistory, UUID> {

    Page<PriceHistory> findByCrop_CropIdOrderByCreatedAtDesc(UUID cropId, Pageable pageable);
}
