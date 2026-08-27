package com.agrilink.repository;

import com.agrilink.entity.Aggregator;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface AggregatorRepository extends JpaRepository<Aggregator, UUID> {

    @Query("SELECT a FROM Aggregator a WHERE a.party.user.userId = :userId")
    Optional<Aggregator> findByUser_UserId(@Param("userId") UUID userId);
}

