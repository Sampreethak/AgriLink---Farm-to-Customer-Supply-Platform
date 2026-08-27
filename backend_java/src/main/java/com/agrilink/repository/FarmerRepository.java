package com.agrilink.repository;

import com.agrilink.entity.Farmer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface FarmerRepository extends JpaRepository<Farmer, UUID> {

    @Query("SELECT f FROM Farmer f WHERE f.party.user.userId = :userId")
    Optional<Farmer> findByUserId(@Param("userId") UUID userId);

    @Query("SELECT f FROM Farmer f WHERE f.isVerified = true ORDER BY f.farmerId")
    Page<Farmer> findVerifiedFarmers(Pageable pageable);
}
