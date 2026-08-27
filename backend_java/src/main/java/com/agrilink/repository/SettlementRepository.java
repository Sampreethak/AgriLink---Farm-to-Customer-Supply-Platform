package com.agrilink.repository;

import com.agrilink.entity.Settlement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface SettlementRepository extends JpaRepository<Settlement, UUID> {

    @Query("SELECT DISTINCT s FROM Settlement s JOIN s.payment p, OrderItem oi WHERE oi.order = p.order AND oi.crop.cropId IN (SELECT fc.crop.cropId FROM FarmerCrop fc WHERE fc.farm.farmer.farmerId = :farmerId)")
    Page<Settlement> findByFarmer_FarmerId(@Param("farmerId") UUID farmerId, Pageable pageable);
}

