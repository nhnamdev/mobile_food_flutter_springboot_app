package com.foodapp.controller;

import com.foodapp.dto.response.ApiResponse;
import com.foodapp.dto.response.ReviewResponse;
import com.foodapp.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/reviews")
@RequiredArgsConstructor
public class ReviewController {
    
    private final ReviewService reviewService;
    
    @GetMapping("/shop/{shopId}")
    public ResponseEntity<ApiResponse<List<ReviewResponse>>> getReviewsByShop(@PathVariable Long shopId) {
        List<ReviewResponse> reviews = reviewService.getReviewsByShop(shopId);
        return ResponseEntity.ok(ApiResponse.success(reviews));
    }
    
    @GetMapping("/customer/{customerId}")
    public ResponseEntity<ApiResponse<List<ReviewResponse>>> getReviewsByCustomer(@PathVariable Long customerId) {
        List<ReviewResponse> reviews = reviewService.getReviewsByCustomer(customerId);
        return ResponseEntity.ok(ApiResponse.success(reviews));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ReviewResponse>> getReviewById(@PathVariable Long id) {
        try {
            ReviewResponse review = reviewService.getReviewById(id);
            return ResponseEntity.ok(ApiResponse.success(review));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<ReviewResponse>> createReview(@RequestBody Map<String, Object> request) {
        try {
            Long orderId = Long.valueOf(request.get("orderId").toString());
            Long customerId = Long.valueOf(request.get("customerId").toString());
            Integer rating = Integer.valueOf(request.get("rating").toString());
            String comment = (String) request.get("comment");
            String images = (String) request.get("images");
            
            ReviewResponse review = reviewService.createReview(orderId, customerId, rating, comment, images);
            return ResponseEntity.ok(ApiResponse.success("Review created successfully", review));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}/reply")
    public ResponseEntity<ApiResponse<ReviewResponse>> addShopReply(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        try {
            String reply = request.get("reply");
            ReviewResponse review = reviewService.addShopReply(id, reply);
            return ResponseEntity.ok(ApiResponse.success("Reply added successfully", review));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
