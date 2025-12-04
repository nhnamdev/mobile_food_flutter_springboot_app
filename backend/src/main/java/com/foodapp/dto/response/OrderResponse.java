package com.foodapp.dto.response;

import com.foodapp.entity.enums.OrderStatus;
import com.foodapp.entity.enums.PaymentMethod;
import com.foodapp.entity.enums.PaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderResponse {
    private Long id;
    private String orderCode;
    private Long customerId;
    private String customerName;
    private Long shopId;
    private String shopName;
    private String deliveryAddress;
    private String deliveryPhone;
    private String deliveryNote;
    private BigDecimal subtotal;
    private BigDecimal deliveryFee;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private PaymentMethod paymentMethod;
    private PaymentStatus paymentStatus;
    private OrderStatus orderStatus;
    private String cancelReason;
    private OffsetDateTime estimatedDeliveryTime;
    private OffsetDateTime createdAt;
    private OffsetDateTime confirmedAt;
    private OffsetDateTime completedAt;
    private List<OrderItemResponse> orderItems;
}
