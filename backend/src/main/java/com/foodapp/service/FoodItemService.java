package com.foodapp.service;

import com.foodapp.dto.response.FoodItemResponse;
import com.foodapp.entity.Category;
import com.foodapp.entity.FoodItem;
import com.foodapp.entity.Shop;
import com.foodapp.repository.CategoryRepository;
import com.foodapp.repository.FoodItemRepository;
import com.foodapp.repository.ShopRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FoodItemService {
    
    private final FoodItemRepository foodItemRepository;
    private final ShopRepository shopRepository;
    private final CategoryRepository categoryRepository;
    
    public List<FoodItemResponse> getAllFoodItems() {
        return foodItemRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public FoodItemResponse getFoodItemById(Long id) {
        FoodItem foodItem = foodItemRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Food item not found"));
        return mapToResponse(foodItem);
    }
    
    public List<FoodItemResponse> getFoodItemsByShop(Long shopId) {
        return foodItemRepository.findByShopIdOrderByCreatedAtDesc(shopId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<FoodItemResponse> getFoodItemsByCategory(Long categoryId) {
        return foodItemRepository.findByCategoryId(categoryId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<FoodItemResponse> searchFoodItems(String keyword) {
        return foodItemRepository.searchByName(keyword).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public FoodItemResponse createFoodItem(Long shopId, Long categoryId, String name, 
            String description, BigDecimal price, BigDecimal discountPrice, String image) {
        
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new RuntimeException("Shop not found"));
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new RuntimeException("Category not found"));
        
        FoodItem foodItem = new FoodItem();
        foodItem.setShop(shop);
        foodItem.setCategory(category);
        foodItem.setFoodName(name);
        foodItem.setFoodDescription(description);
        foodItem.setPrice(price);
        foodItem.setDiscountPrice(discountPrice);
        foodItem.setImage(image);
        
        foodItem = foodItemRepository.save(foodItem);
        return mapToResponse(foodItem);
    }
    
    @Transactional
    public FoodItemResponse updateFoodItem(Long id, String name, String description,
            BigDecimal price, BigDecimal discountPrice, String image) {
        
        FoodItem foodItem = foodItemRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Food item not found"));
        
        if (name != null) {
            foodItem.setFoodName(name);
        }
        if (description != null) {
            foodItem.setFoodDescription(description);
        }
        if (price != null) {
            foodItem.setPrice(price);
        }
        if (discountPrice != null) {
            foodItem.setDiscountPrice(discountPrice);
        }
        if (image != null) {
            foodItem.setImage(image);
        }
        
        foodItem = foodItemRepository.save(foodItem);
        return mapToResponse(foodItem);
    }
    
    @Transactional
    public void deleteFoodItem(Long id) {
        if (!foodItemRepository.existsById(id)) {
            throw new RuntimeException("Food item not found");
        }
        foodItemRepository.deleteById(id);
    }
    
    private FoodItemResponse mapToResponse(FoodItem foodItem) {
        return FoodItemResponse.builder()
                .id(foodItem.getId())
                .shopId(foodItem.getShop().getId())
                .shopName(foodItem.getShop().getShopName())
                .categoryId(foodItem.getCategory().getId())
                .categoryName(foodItem.getCategory().getCategoryName())
                .foodName(foodItem.getFoodName())
                .foodDescription(foodItem.getFoodDescription())
                .price(foodItem.getPrice())
                .discountPrice(foodItem.getDiscountPrice())
                .image(foodItem.getImage())
                .createdAt(foodItem.getCreatedAt())
                .build();
    }
}
