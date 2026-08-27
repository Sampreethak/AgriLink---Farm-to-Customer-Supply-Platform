package com.agrilink.service;

import com.agrilink.entity.Review;
import com.agrilink.exception.ResourceNotFoundException;
import com.agrilink.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewService {

    private final ReviewRepository reviewRepository;

    @Transactional(readOnly = true)
    public Review findById(UUID reviewId) {
        return reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Review not found: " + reviewId));
    }

    @Transactional(readOnly = true)
    public Page<Review> getReviewsByCrop(UUID cropId, Pageable pageable) {
        return reviewRepository.findByCrop_CropId(cropId, pageable);
    }

    @Transactional(readOnly = true)
    public Page<Review> getReviewsByCustomer(UUID customerId, Pageable pageable) {
        return reviewRepository.findByCustomer_CustomerId(customerId, pageable);
    }

    @Transactional(readOnly = true)
    public Double getAverageRating(UUID cropId) {
        Double avg = reviewRepository.findAverageRatingByCropId(cropId);
        return avg != null ? avg : 0.0;
    }

    @Transactional
    public Review save(Review review) {
        return reviewRepository.save(review);
    }

    @Transactional
    public void delete(UUID reviewId) {
        Review review = findById(reviewId);
        reviewRepository.delete(review);
        log.info("Review {} deleted", reviewId);
    }
}
