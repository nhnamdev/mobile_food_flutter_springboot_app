package com.foodapp.controller;

import com.foodapp.dto.response.ApiResponse;
import com.foodapp.dto.response.ShopResponse;
import com.foodapp.service.ShopService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/shops")
@RequiredArgsConstructor
public class ShopController {
    
    private final ShopService shopService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<ShopResponse>>> getAllShops() {
        List<ShopResponse> shops = shopService.getAllShops();
        return ResponseEntity.ok(ApiResponse.success(shops));
    }
    
    @GetMapping("/active")
    public ResponseEntity<ApiResponse<List<ShopResponse>>> getActiveShops() {
        List<ShopResponse> shops = shopService.getActiveShops();
        return ResponseEntity.ok(ApiResponse.success(shops));
    }
    
    @GetMapping("/top-rated")
    public ResponseEntity<ApiResponse<List<ShopResponse>>> getTopRatedShops() {
        List<ShopResponse> shops = shopService.getTopRatedShops();
        return ResponseEntity.ok(ApiResponse.success(shops));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ShopResponse>> getShopById(@PathVariable Long id) {
        try {
            ShopResponse shop = shopService.getShopById(id);
            return ResponseEntity.ok(ApiResponse.success(shop));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<ShopResponse>>> getShopsByUser(@PathVariable Long userId) {
        List<ShopResponse> shops = shopService.getShopsByUserId(userId);
        return ResponseEntity.ok(ApiResponse.success(shops));
    }
    
    @GetMapping("/category/{categoryId}")
    public ResponseEntity<ApiResponse<List<ShopResponse>>> getShopsByCategory(@PathVariable Long categoryId) {
        List<ShopResponse> shops = shopService.getShopsByCategory(categoryId);
        return ResponseEntity.ok(ApiResponse.success(shops));
    }
    
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<ShopResponse>>> searchShops(@RequestParam String keyword) {
        List<ShopResponse> shops = shopService.searchShops(keyword);
        return ResponseEntity.ok(ApiResponse.success(shops));
    }
    
    @PostMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<ShopResponse>> createShop(
            @PathVariable Long userId,
            @RequestBody ShopResponse request) {
        try {
            ShopResponse shop = shopService.createShop(userId, request);
            return ResponseEntity.ok(ApiResponse.success("Shop created successfully", shop));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ShopResponse>> updateShop(
            @PathVariable Long id,
            @RequestBody ShopResponse request) {
        try {
            ShopResponse shop = shopService.updateShop(id, request);
            return ResponseEntity.ok(ApiResponse.success("Shop updated successfully", shop));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
