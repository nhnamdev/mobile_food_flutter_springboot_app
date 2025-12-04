package com.foodapp.dto.response;

import com.foodapp.entity.enums.ShopStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShopResponse {
    private Long id;
    private Long userId;
    private String shopName;
    private String shopDescription;
    private String coverImage;
    private String address;
    private LocalTime openingTime;
    private LocalTime closingTime;
    private ShopStatus status;
    private BigDecimal ratingAverage;
    private Integer totalReviews;
    private OffsetDateTime createdAt;
    private List<CategoryResponse> categories;
}
