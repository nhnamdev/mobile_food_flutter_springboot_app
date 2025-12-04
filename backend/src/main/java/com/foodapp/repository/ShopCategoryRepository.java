package com.foodapp.repository;

import com.foodapp.entity.ShopCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ShopCategoryRepository extends JpaRepository<ShopCategory, Long> {
    
    List<ShopCategory> findByShopId(Long shopId);
    
    List<ShopCategory> findByCategoryId(Long categoryId);
    
    Optional<ShopCategory> findByShopIdAndCategoryId(Long shopId, Long categoryId);
    
    void deleteByShopIdAndCategoryId(Long shopId, Long categoryId);
}
