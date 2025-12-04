package com.foodapp.controller;

import com.foodapp.dto.response.ApiResponse;
import com.foodapp.dto.response.CartItemResponse;
import com.foodapp.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/cart")
@RequiredArgsConstructor
public class CartController {
    
    private final CartService cartService;
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<CartItemResponse>>> getCartByUser(@PathVariable Long userId) {
        List<CartItemResponse> cartItems = cartService.getCartByUserId(userId);
        return ResponseEntity.ok(ApiResponse.success(cartItems));
    }
    
    @GetMapping("/user/{userId}/shop/{shopId}")
    public ResponseEntity<ApiResponse<List<CartItemResponse>>> getCartByUserAndShop(
            @PathVariable Long userId,
            @PathVariable Long shopId) {
        List<CartItemResponse> cartItems = cartService.getCartByUserAndShop(userId, shopId);
        return ResponseEntity.ok(ApiResponse.success(cartItems));
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<CartItemResponse>> addToCart(@RequestBody Map<String, Object> request) {
        try {
            Long userId = Long.valueOf(request.get("userId").toString());
            Long shopId = Long.valueOf(request.get("shopId").toString());
            Long foodItemId = Long.valueOf(request.get("foodItemId").toString());
            Integer quantity = Integer.valueOf(request.get("quantity").toString());
            
            CartItemResponse cartItem = cartService.addToCart(userId, shopId, foodItemId, quantity);
            return ResponseEntity.ok(ApiResponse.success("Item added to cart", cartItem));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{cartId}")
    public ResponseEntity<ApiResponse<CartItemResponse>> updateCartQuantity(
            @PathVariable Long cartId,
            @RequestBody Map<String, Integer> request) {
        try {
            Integer quantity = request.get("quantity");
            CartItemResponse cartItem = cartService.updateCartQuantity(cartId, quantity);
            
            if (cartItem == null) {
                return ResponseEntity.ok(ApiResponse.success("Item removed from cart", null));
            }
            return ResponseEntity.ok(ApiResponse.success("Cart updated", cartItem));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/{cartId}")
    public ResponseEntity<ApiResponse<Void>> removeFromCart(@PathVariable Long cartId) {
        try {
            cartService.removeFromCart(cartId);
            return ResponseEntity.ok(ApiResponse.success("Item removed from cart", null));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<Void>> clearCart(@PathVariable Long userId) {
        cartService.clearCart(userId);
        return ResponseEntity.ok(ApiResponse.success("Cart cleared", null));
    }
    
    @DeleteMapping("/user/{userId}/shop/{shopId}")
    public ResponseEntity<ApiResponse<Void>> clearCartByShop(
            @PathVariable Long userId,
            @PathVariable Long shopId) {
        cartService.clearCartByShop(userId, shopId);
        return ResponseEntity.ok(ApiResponse.success("Cart cleared for shop", null));
    }
}
