package com.foodapp.entity;

import com.foodapp.entity.enums.ShopStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "shops")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Shop {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(name = "shop_name", nullable = false)
    private String shopName;
    
    @Column(name = "shop_description", columnDefinition = "TEXT")
    private String shopDescription;
    
    @Column(name = "cover_image", length = 500)
    private String coverImage;
    
    @Column(nullable = false, columnDefinition = "TEXT")
    private String address;
    
    @Column(name = "opening_time")
    private LocalTime openingTime;
    
    @Column(name = "closing_time")
    private LocalTime closingTime;
    
    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "shop_status_enum")
    private ShopStatus status = ShopStatus.pending;
    
    @Column(name = "rating_average", precision = 2, scale = 1)
    private BigDecimal ratingAverage = BigDecimal.ZERO;
    
    @Column(name = "total_reviews")
    private Integer totalReviews = 0;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private OffsetDateTime createdAt;
    
    @Column(name = "approved_at")
    private OffsetDateTime approvedAt;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approved_by")
    private User approvedBy;
    
    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ShopCategory> shopCategories = new ArrayList<>();
    
    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<FoodItem> foodItems = new ArrayList<>();
    
    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL)
    private List<Order> orders = new ArrayList<>();
    
    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL)
    private List<Review> reviews = new ArrayList<>();
}
