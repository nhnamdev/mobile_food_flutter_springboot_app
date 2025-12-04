package com.foodapp.service;

import com.foodapp.dto.response.ReviewResponse;
import com.foodapp.entity.Order;
import com.foodapp.entity.Review;
import com.foodapp.entity.Shop;
import com.foodapp.entity.User;
import com.foodapp.repository.OrderRepository;
import com.foodapp.repository.ReviewRepository;
import com.foodapp.repository.ShopRepository;
import com.foodapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReviewService {
    
    private final ReviewRepository reviewRepository;
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final ShopRepository shopRepository;
    
    public List<ReviewResponse> getReviewsByShop(Long shopId) {
        return reviewRepository.findByShopIdOrderByCreatedAtDesc(shopId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<ReviewResponse> getReviewsByCustomer(Long customerId) {
        return reviewRepository.findByCustomerId(customerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public ReviewResponse getReviewById(Long id) {
        Review review = reviewRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Review not found"));
        return mapToResponse(review);
    }
    
    @Transactional
    public ReviewResponse createReview(Long orderId, Long customerId, Integer rating, 
            String comment, String images) {
        
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
        
        // Check if review already exists for this order
        if (reviewRepository.findByOrderId(orderId).isPresent()) {
            throw new RuntimeException("Review already exists for this order");
        }
        
        Review review = new Review();
        review.setOrder(order);
        review.setCustomer(customer);
        review.setShop(order.getShop());
        review.setRating(rating);
        review.setComment(comment);
        review.setImages(images);
        
        review = reviewRepository.save(review);
        return mapToResponse(review);
    }
    
    @Transactional
    public ReviewResponse addShopReply(Long reviewId, String reply) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("Review not found"));
        
        review.setShopReply(reply);
        review.setRepliedAt(OffsetDateTime.now());
        
        review = reviewRepository.save(review);
        return mapToResponse(review);
    }
    
    private ReviewResponse mapToResponse(Review review) {
        return ReviewResponse.builder()
                .id(review.getId())
                .orderId(review.getOrder().getId())
                .customerId(review.getCustomer().getId())
                .customerName(review.getCustomer().getFullName())
                .customerAvatar(review.getCustomer().getAvatar())
                .shopId(review.getShop().getId())
                .rating(review.getRating())
                .comment(review.getComment())
                .images(review.getImages())
                .shopReply(review.getShopReply())
                .repliedAt(review.getRepliedAt())
                .createdAt(review.getCreatedAt())
                .build();
    }
}
