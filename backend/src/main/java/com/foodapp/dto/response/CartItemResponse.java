package com.foodapp.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CartItemResponse {
    private Long id;
    private Long userId;
    private Long shopId;
    private String shopName;
    private Long foodItemId;
    private String foodName;
    private String foodImage;
    private BigDecimal foodPrice;
    private BigDecimal discountPrice;
    private Integer quantity;
    private BigDecimal subtotal;
    private OffsetDateTime createdAt;
}
