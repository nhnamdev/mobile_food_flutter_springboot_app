package com.foodapp.entity;

import com.foodapp.entity.enums.OrderStatus;
import com.foodapp.entity.enums.PaymentMethod;
import com.foodapp.entity.enums.PaymentStatus;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "order_code", unique = true, nullable = false, length = 50)
    private String orderCode;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_id", nullable = false)
    private Shop shop;
    
    @Column(name = "delivery_address", nullable = false, columnDefinition = "TEXT")
    private String deliveryAddress;
    
    @Column(name = "delivery_phone", nullable = false, length = 20)
    private String deliveryPhone;
    
    @Column(name = "delivery_note", columnDefinition = "TEXT")
    private String deliveryNote;
    
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal subtotal;
    
    @Column(name = "delivery_fee", precision = 10, scale = 2)
    private BigDecimal deliveryFee = BigDecimal.ZERO;
    
    @Column(name = "discount_amount", precision = 10, scale = 2)
    private BigDecimal discountAmount = BigDecimal.ZERO;
    
    @Column(name = "total_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalAmount;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "payment_method", columnDefinition = "payment_method_enum")
    private PaymentMethod paymentMethod = PaymentMethod.COD;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", columnDefinition = "payment_status_enum")
    private PaymentStatus paymentStatus = PaymentStatus.unpaid;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "order_status", columnDefinition = "order_status_enum")
    private OrderStatus orderStatus = OrderStatus.pending;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cancelled_by")
    private User cancelledBy;
    
    @Column(name = "cancel_reason", columnDefinition = "TEXT")
    private String cancelReason;
    
    @Column(name = "estimated_delivery_time")
    private OffsetDateTime estimatedDeliveryTime;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private OffsetDateTime createdAt;
    
    @Column(name = "confirmed_at")
    private OffsetDateTime confirmedAt;
    
    @Column(name = "completed_at")
    private OffsetDateTime completedAt;
    
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> orderItems = new ArrayList<>();
    
    @OneToOne(mappedBy = "order", cascade = CascadeType.ALL)
    private Review review;
}
