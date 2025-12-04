package com.foodapp.repository;

import com.foodapp.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    
    List<Review> findByShopId(Long shopId);
    
    List<Review> findByCustomerId(Long customerId);
    
    Optional<Review> findByOrderId(Long orderId);
    
    @Query("SELECT r FROM Review r WHERE r.shop.id = :shopId ORDER BY r.createdAt DESC")
    List<Review> findByShopIdOrderByCreatedAtDesc(@Param("shopId") Long shopId);
    
    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.shop.id = :shopId")
    Double getAverageRatingByShopId(@Param("shopId") Long shopId);
    
    @Query("SELECT COUNT(r) FROM Review r WHERE r.shop.id = :shopId")
    Long countByShopId(@Param("shopId") Long shopId);
}
