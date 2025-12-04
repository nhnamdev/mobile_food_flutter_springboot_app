package com.foodapp.service;

import com.foodapp.dto.response.CategoryResponse;
import com.foodapp.entity.Category;
import com.foodapp.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryService {
    
    private final CategoryRepository categoryRepository;
    
    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public CategoryResponse getCategoryById(Long id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));
        return mapToResponse(category);
    }
    
    @Transactional
    public CategoryResponse createCategory(String name, String description) {
        if (categoryRepository.existsByCategoryName(name)) {
            throw new RuntimeException("Category name already exists");
        }
        
        Category category = new Category();
        category.setCategoryName(name);
        category.setCategoryDescription(description);
        
        category = categoryRepository.save(category);
        return mapToResponse(category);
    }
    
    @Transactional
    public CategoryResponse updateCategory(Long id, String name, String description) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));
        
        if (name != null) {
            category.setCategoryName(name);
        }
        if (description != null) {
            category.setCategoryDescription(description);
        }
        
        category = categoryRepository.save(category);
        return mapToResponse(category);
    }
    
    @Transactional
    public void deleteCategory(Long id) {
        if (!categoryRepository.existsById(id)) {
            throw new RuntimeException("Category not found");
        }
        categoryRepository.deleteById(id);
    }
    
    private CategoryResponse mapToResponse(Category category) {
        return CategoryResponse.builder()
                .id(category.getId())
                .categoryName(category.getCategoryName())
                .categoryDescription(category.getCategoryDescription())
                .createdAt(category.getCreatedAt())
                .build();
    }
}
