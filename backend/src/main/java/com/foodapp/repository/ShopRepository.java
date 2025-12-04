package com.foodapp.repository;

import com.foodapp.entity.Shop;
import com.foodapp.entity.enums.ShopStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShopRepository extends JpaRepository<Shop, Long> {
    
    List<Shop> findByUserId(Long userId);
    
    List<Shop> findByStatus(ShopStatus status);
    
    @Query("SELECT s FROM Shop s WHERE s.status = 'active' ORDER BY s.ratingAverage DESC")
    List<Shop> findTopRatedShops();
    
    @Query("SELECT s FROM Shop s WHERE s.status = 'active' AND LOWER(s.shopName) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Shop> searchByName(@Param("keyword") String keyword);
    
    @Query("SELECT s FROM Shop s JOIN s.shopCategories sc WHERE sc.category.id = :categoryId AND s.status = 'active'")
    List<Shop> findByCategoryId(@Param("categoryId") Long categoryId);
}
