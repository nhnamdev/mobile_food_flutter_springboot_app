package com.foodapp.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderItemResponse {
    private Long id;
    private Long foodItemId;
    private String foodName;
    private BigDecimal foodPrice;
    private Integer quantity;
    private String note;
    private BigDecimal subtotal;
    private String foodImage;
}
