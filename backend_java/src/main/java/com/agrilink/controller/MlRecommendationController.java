package com.agrilink.controller;

import com.agrilink.service.MlRecommendationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/recommendations")
@RequiredArgsConstructor
@Tag(name = "ML Recommendations", description = "Machine Learning Recommendation APIs for Seller Listings")
public class MlRecommendationController {

    private final MlRecommendationService mlRecommendationService;

    @GetMapping("/{customerId}")
    @Operation(summary = "Get Top-K ML Recommended Seller Listings for a Customer")
    public ResponseEntity<List<Map<String, Object>>> getRecommendations(
            @PathVariable UUID customerId,
            @RequestParam(defaultValue = "10") int topK) {
        List<Map<String, Object>> recommendations = mlRecommendationService.getRecommendationsForCustomer(customerId, topK);
        return ResponseEntity.ok(recommendations);
    }
}
