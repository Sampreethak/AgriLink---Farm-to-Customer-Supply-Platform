package com.agrilink.repository;

import com.agrilink.entity.Crop;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CropRepository extends JpaRepository<Crop, UUID> {

    List<Crop> findByCategory_CategoryId(UUID categoryId);

    @Query("SELECT c FROM Crop c WHERE LOWER(c.cropName) LIKE LOWER(CONCAT('%', :name, '%'))")
    Page<Crop> searchByName(@Param("name") String name, Pageable pageable);

    @Query("SELECT DISTINCT fc.crop FROM FarmerCrop fc WHERE fc.farm.farmer.farmerId = :farmerId")
    List<Crop> findByFarmerId(@Param("farmerId") UUID farmerId);
}
