package com.foodapp.repository;

import com.foodapp.entity.Cart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CartRepository extends JpaRepository<Cart, Long> {
    
    List<Cart> findByUserId(Long userId);
    
    List<Cart> findByUserIdAndShopId(Long userId, Long shopId);
    
    Optional<Cart> findByUserIdAndShopIdAndFoodItemId(Long userId, Long shopId, Long foodItemId);
    
    void deleteByUserId(Long userId);
    
    void deleteByUserIdAndShopId(Long userId, Long shopId);
    
    @Query("SELECT DISTINCT c.shop.id FROM Cart c WHERE c.user.id = :userId")
    List<Long> findDistinctShopIdsByUserId(@Param("userId") Long userId);
}
