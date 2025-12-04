package com.foodapp.repository;

import com.foodapp.entity.FoodItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FoodItemRepository extends JpaRepository<FoodItem, Long> {
    
    List<FoodItem> findByShopId(Long shopId);
    
    List<FoodItem> findByCategoryId(Long categoryId);
    
    List<FoodItem> findByShopIdAndCategoryId(Long shopId, Long categoryId);
    
    @Query("SELECT f FROM FoodItem f WHERE LOWER(f.foodName) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<FoodItem> searchByName(@Param("keyword") String keyword);
    
    @Query("SELECT f FROM FoodItem f WHERE f.shop.id = :shopId ORDER BY f.createdAt DESC")
    List<FoodItem> findByShopIdOrderByCreatedAtDesc(@Param("shopId") Long shopId);
}
