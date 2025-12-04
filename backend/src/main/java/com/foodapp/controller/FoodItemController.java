package com.foodapp.controller;

import com.foodapp.dto.response.ApiResponse;
import com.foodapp.dto.response.FoodItemResponse;
import com.foodapp.service.FoodItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/food-items")
@RequiredArgsConstructor
public class FoodItemController {
    
    private final FoodItemService foodItemService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<FoodItemResponse>>> getAllFoodItems() {
        List<FoodItemResponse> foodItems = foodItemService.getAllFoodItems();
        return ResponseEntity.ok(ApiResponse.success(foodItems));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<FoodItemResponse>> getFoodItemById(@PathVariable Long id) {
        try {
            FoodItemResponse foodItem = foodItemService.getFoodItemById(id);
            return ResponseEntity.ok(ApiResponse.success(foodItem));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/shop/{shopId}")
    public ResponseEntity<ApiResponse<List<FoodItemResponse>>> getFoodItemsByShop(@PathVariable Long shopId) {
        List<FoodItemResponse> foodItems = foodItemService.getFoodItemsByShop(shopId);
        return ResponseEntity.ok(ApiResponse.success(foodItems));
    }
    
    @GetMapping("/category/{categoryId}")
    public ResponseEntity<ApiResponse<List<FoodItemResponse>>> getFoodItemsByCategory(@PathVariable Long categoryId) {
        List<FoodItemResponse> foodItems = foodItemService.getFoodItemsByCategory(categoryId);
        return ResponseEntity.ok(ApiResponse.success(foodItems));
    }
    
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<FoodItemResponse>>> searchFoodItems(@RequestParam String keyword) {
        List<FoodItemResponse> foodItems = foodItemService.searchFoodItems(keyword);
        return ResponseEntity.ok(ApiResponse.success(foodItems));
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<FoodItemResponse>> createFoodItem(@RequestBody Map<String, Object> request) {
        try {
            Long shopId = Long.valueOf(request.get("shopId").toString());
            Long categoryId = Long.valueOf(request.get("categoryId").toString());
            String name = (String) request.get("foodName");
            String description = (String) request.get("foodDescription");
            BigDecimal price = new BigDecimal(request.get("price").toString());
            BigDecimal discountPrice = request.get("discountPrice") != null 
                    ? new BigDecimal(request.get("discountPrice").toString()) : null;
            String image = (String) request.get("image");
            
            FoodItemResponse foodItem = foodItemService.createFoodItem(shopId, categoryId, name, 
                    description, price, discountPrice, image);
            return ResponseEntity.ok(ApiResponse.success("Food item created successfully", foodItem));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<FoodItemResponse>> updateFoodItem(
            @PathVariable Long id,
            @RequestBody Map<String, Object> request) {
        try {
            String name = (String) request.get("foodName");
            String description = (String) request.get("foodDescription");
            BigDecimal price = request.get("price") != null 
                    ? new BigDecimal(request.get("price").toString()) : null;
            BigDecimal discountPrice = request.get("discountPrice") != null 
                    ? new BigDecimal(request.get("discountPrice").toString()) : null;
            String image = (String) request.get("image");
            
            FoodItemResponse foodItem = foodItemService.updateFoodItem(id, name, description, 
                    price, discountPrice, image);
            return ResponseEntity.ok(ApiResponse.success("Food item updated successfully", foodItem));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteFoodItem(@PathVariable Long id) {
        try {
            foodItemService.deleteFoodItem(id);
            return ResponseEntity.ok(ApiResponse.success("Food item deleted successfully", null));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
