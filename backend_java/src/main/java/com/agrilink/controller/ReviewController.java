package com.agrilink.controller;

import com.agrilink.entity.Review;
import com.agrilink.service.ReviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/reviews")
@RequiredArgsConstructor
@Tag(name = "Reviews", description = "Product review management APIs")
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping("/{reviewId}")
    @Operation(summary = "Get a review by ID")
    public ResponseEntity<Review> getReview(@PathVariable UUID reviewId) {
        return ResponseEntity.ok(reviewService.findById(reviewId));
    }

    @GetMapping("/crop/{cropId}")
    @Operation(summary = "Get all reviews for a crop")
    public ResponseEntity<Page<Review>> getCropReviews(
            @PathVariable UUID cropId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(reviewService.getReviewsByCrop(cropId,
                PageRequest.of(page, size, Sort.by("reviewDate").descending())));
    }

    @GetMapping("/crop/{cropId}/rating")
    @Operation(summary = "Get average rating for a crop")
    public ResponseEntity<Map<String, Double>> getAverageRating(@PathVariable UUID cropId) {
        return ResponseEntity.ok(Map.of("averageRating", reviewService.getAverageRating(cropId)));
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get all reviews by a customer")
    public ResponseEntity<Page<Review>> getCustomerReviews(
            @PathVariable UUID customerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(reviewService.getReviewsByCustomer(customerId,
                PageRequest.of(page, size, Sort.by("reviewDate").descending())));
    }

    @DeleteMapping("/{reviewId}")
    @Operation(summary = "Delete a review")
    public ResponseEntity<Void> deleteReview(@PathVariable UUID reviewId) {
        reviewService.delete(reviewId);
        return ResponseEntity.noContent().build();
    }
}
