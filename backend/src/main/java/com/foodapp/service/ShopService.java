package com.foodapp.service;

import com.foodapp.dto.response.CategoryResponse;
import com.foodapp.dto.response.ShopResponse;
import com.foodapp.entity.Shop;
import com.foodapp.entity.ShopCategory;
import com.foodapp.entity.User;
import com.foodapp.entity.enums.ShopStatus;
import com.foodapp.repository.ShopRepository;
import com.foodapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ShopService {
    
    private final ShopRepository shopRepository;
    private final UserRepository userRepository;
    
    public List<ShopResponse> getAllShops() {
        return shopRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<ShopResponse> getActiveShops() {
        return shopRepository.findByStatus(ShopStatus.active).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public ShopResponse getShopById(Long id) {
        Shop shop = shopRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shop not found"));
        return mapToResponse(shop);
    }
    
    public List<ShopResponse> getShopsByUserId(Long userId) {
        return shopRepository.findByUserId(userId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<ShopResponse> searchShops(String keyword) {
        return shopRepository.searchByName(keyword).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<ShopResponse> getShopsByCategory(Long categoryId) {
        return shopRepository.findByCategoryId(categoryId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<ShopResponse> getTopRatedShops() {
        return shopRepository.findTopRatedShops().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public ShopResponse createShop(Long userId, ShopResponse request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Shop shop = new Shop();
        shop.setUser(user);
        shop.setShopName(request.getShopName());
        shop.setShopDescription(request.getShopDescription());
        shop.setCoverImage(request.getCoverImage());
        shop.setAddress(request.getAddress());
        shop.setOpeningTime(request.getOpeningTime());
        shop.setClosingTime(request.getClosingTime());
        shop.setStatus(ShopStatus.pending);
        
        shop = shopRepository.save(shop);
        return mapToResponse(shop);
    }
    
    @Transactional
    public ShopResponse updateShop(Long id, ShopResponse request) {
        Shop shop = shopRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shop not found"));
        
        if (request.getShopName() != null) {
            shop.setShopName(request.getShopName());
        }
        if (request.getShopDescription() != null) {
            shop.setShopDescription(request.getShopDescription());
        }
        if (request.getCoverImage() != null) {
            shop.setCoverImage(request.getCoverImage());
        }
        if (request.getAddress() != null) {
            shop.setAddress(request.getAddress());
        }
        if (request.getOpeningTime() != null) {
            shop.setOpeningTime(request.getOpeningTime());
        }
        if (request.getClosingTime() != null) {
            shop.setClosingTime(request.getClosingTime());
        }
        
        shop = shopRepository.save(shop);
        return mapToResponse(shop);
    }
    
    private ShopResponse mapToResponse(Shop shop) {
        List<CategoryResponse> categories = shop.getShopCategories().stream()
                .map(ShopCategory::getCategory)
                .map(cat -> CategoryResponse.builder()
                        .id(cat.getId())
                        .categoryName(cat.getCategoryName())
                        .categoryDescription(cat.getCategoryDescription())
                        .build())
                .collect(Collectors.toList());
        
        return ShopResponse.builder()
                .id(shop.getId())
                .userId(shop.getUser().getId())
                .shopName(shop.getShopName())
                .shopDescription(shop.getShopDescription())
                .coverImage(shop.getCoverImage())
                .address(shop.getAddress())
                .openingTime(shop.getOpeningTime())
                .closingTime(shop.getClosingTime())
                .status(shop.getStatus())
                .ratingAverage(shop.getRatingAverage())
                .totalReviews(shop.getTotalReviews())
                .createdAt(shop.getCreatedAt())
                .categories(categories)
                .build();
    }
}
