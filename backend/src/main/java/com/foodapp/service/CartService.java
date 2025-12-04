package com.foodapp.service;

import com.foodapp.dto.response.CartItemResponse;
import com.foodapp.entity.Cart;
import com.foodapp.entity.FoodItem;
import com.foodapp.entity.Shop;
import com.foodapp.entity.User;
import com.foodapp.repository.CartRepository;
import com.foodapp.repository.FoodItemRepository;
import com.foodapp.repository.ShopRepository;
import com.foodapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CartService {
    
    private final CartRepository cartRepository;
    private final UserRepository userRepository;
    private final ShopRepository shopRepository;
    private final FoodItemRepository foodItemRepository;
    
    public List<CartItemResponse> getCartByUserId(Long userId) {
        return cartRepository.findByUserId(userId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<CartItemResponse> getCartByUserAndShop(Long userId, Long shopId) {
        return cartRepository.findByUserIdAndShopId(userId, shopId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public CartItemResponse addToCart(Long userId, Long shopId, Long foodItemId, Integer quantity) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new RuntimeException("Shop not found"));
        FoodItem foodItem = foodItemRepository.findById(foodItemId)
                .orElseThrow(() -> new RuntimeException("Food item not found"));
        
        // Check if item already exists in cart
        Optional<Cart> existingCart = cartRepository.findByUserIdAndShopIdAndFoodItemId(userId, shopId, foodItemId);
        
        Cart cart;
        if (existingCart.isPresent()) {
            cart = existingCart.get();
            cart.setQuantity(cart.getQuantity() + quantity);
        } else {
            cart = new Cart();
            cart.setUser(user);
            cart.setShop(shop);
            cart.setFoodItem(foodItem);
            cart.setQuantity(quantity);
        }
        
        cart = cartRepository.save(cart);
        return mapToResponse(cart);
    }
    
    @Transactional
    public CartItemResponse updateCartQuantity(Long cartId, Integer quantity) {
        Cart cart = cartRepository.findById(cartId)
                .orElseThrow(() -> new RuntimeException("Cart item not found"));
        
        if (quantity <= 0) {
            cartRepository.delete(cart);
            return null;
        }
        
        cart.setQuantity(quantity);
        cart = cartRepository.save(cart);
        return mapToResponse(cart);
    }
    
    @Transactional
    public void removeFromCart(Long cartId) {
        if (!cartRepository.existsById(cartId)) {
            throw new RuntimeException("Cart item not found");
        }
        cartRepository.deleteById(cartId);
    }
    
    @Transactional
    public void clearCart(Long userId) {
        cartRepository.deleteByUserId(userId);
    }
    
    @Transactional
    public void clearCartByShop(Long userId, Long shopId) {
        cartRepository.deleteByUserIdAndShopId(userId, shopId);
    }
    
    private CartItemResponse mapToResponse(Cart cart) {
        FoodItem foodItem = cart.getFoodItem();
        BigDecimal price = foodItem.getDiscountPrice() != null ? foodItem.getDiscountPrice() : foodItem.getPrice();
        BigDecimal subtotal = price.multiply(BigDecimal.valueOf(cart.getQuantity()));
        
        return CartItemResponse.builder()
                .id(cart.getId())
                .userId(cart.getUser().getId())
                .shopId(cart.getShop().getId())
                .shopName(cart.getShop().getShopName())
                .foodItemId(foodItem.getId())
                .foodName(foodItem.getFoodName())
                .foodImage(foodItem.getImage())
                .foodPrice(foodItem.getPrice())
                .discountPrice(foodItem.getDiscountPrice())
                .quantity(cart.getQuantity())
                .subtotal(subtotal)
                .createdAt(cart.getCreatedAt())
                .build();
    }
}
