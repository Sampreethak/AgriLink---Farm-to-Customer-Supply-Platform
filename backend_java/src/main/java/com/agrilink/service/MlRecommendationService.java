package com.agrilink.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class MlRecommendationService {

    private final RestTemplate restTemplate = new RestTemplate();
    private static final String ML_ENGINE_URL = "http://localhost:8000/recommend/";

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getRecommendationsForCustomer(UUID customerId, int topK) {
        String url = ML_ENGINE_URL + customerId.toString() + "?top_k=" + topK;
        try {
            log.info("Querying ML Recommendation Engine for customer: {}", customerId);
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            if (response != null && response.containsKey("recommendations")) {
                return (List<Map<String, Object>>) response.get("recommendations");
            }
        } catch (Exception e) {
            log.warn("ML Engine service unavailable ({}), falling back to direct database recommendations", e.getMessage());
        }

        // Fallback response structure
        return Collections.emptyList();
    }
}
