package com.foodapp.service;

import com.foodapp.dto.response.OrderItemResponse;
import com.foodapp.dto.response.OrderResponse;
import com.foodapp.entity.*;
import com.foodapp.entity.enums.OrderStatus;
import com.foodapp.entity.enums.PaymentMethod;
import com.foodapp.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final UserRepository userRepository;
    private final ShopRepository shopRepository;
    private final CartRepository cartRepository;
    private final FoodItemRepository foodItemRepository;
    
    public List<OrderResponse> getOrdersByCustomer(Long customerId) {
        return orderRepository.findByCustomerIdOrderByCreatedAtDesc(customerId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public List<OrderResponse> getOrdersByShop(Long shopId) {
        return orderRepository.findByShopIdOrderByCreatedAtDesc(shopId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }
    
    public OrderResponse getOrderById(Long id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        return mapToResponse(order);
    }
    
    public OrderResponse getOrderByCode(String orderCode) {
        Order order = orderRepository.findByOrderCode(orderCode)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        return mapToResponse(order);
    }
    
    @Transactional
    public OrderResponse createOrderFromCart(Long customerId, Long shopId, String deliveryAddress,
            String deliveryPhone, String deliveryNote, PaymentMethod paymentMethod) {
        
        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new RuntimeException("Shop not found"));
        
        List<Cart> cartItems = cartRepository.findByUserIdAndShopId(customerId, shopId);
        if (cartItems.isEmpty()) {
            throw new RuntimeException("Cart is empty");
        }
        
        // Create order
        Order order = new Order();
        order.setOrderCode(generateOrderCode());
        order.setCustomer(customer);
        order.setShop(shop);
        order.setDeliveryAddress(deliveryAddress);
        order.setDeliveryPhone(deliveryPhone);
        order.setDeliveryNote(deliveryNote);
        order.setPaymentMethod(paymentMethod);
        order.setOrderStatus(OrderStatus.pending);
        
        BigDecimal subtotal = BigDecimal.ZERO;
        
        order = orderRepository.save(order);
        
        // Create order items
        for (Cart cartItem : cartItems) {
            FoodItem foodItem = cartItem.getFoodItem();
            BigDecimal price = foodItem.getDiscountPrice() != null ? foodItem.getDiscountPrice() : foodItem.getPrice();
            BigDecimal itemSubtotal = price.multiply(BigDecimal.valueOf(cartItem.getQuantity()));
            
            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setFoodItem(foodItem);
            orderItem.setFoodName(foodItem.getFoodName());
            orderItem.setFoodPrice(price);
            orderItem.setQuantity(cartItem.getQuantity());
            orderItem.setSubtotal(itemSubtotal);
            
            orderItemRepository.save(orderItem);
            subtotal = subtotal.add(itemSubtotal);
        }
        
        // Update order totals
        BigDecimal deliveryFee = BigDecimal.valueOf(15000); // Fixed delivery fee
        order.setSubtotal(subtotal);
        order.setDeliveryFee(deliveryFee);
        order.setDiscountAmount(BigDecimal.ZERO);
        order.setTotalAmount(subtotal.add(deliveryFee));
        
        order = orderRepository.save(order);
        
        // Clear cart
        cartRepository.deleteByUserIdAndShopId(customerId, shopId);
        
        return mapToResponse(order);
    }
    
    @Transactional
    public OrderResponse updateOrderStatus(Long orderId, OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        
        order.setOrderStatus(status);
        
        if (status == OrderStatus.confirmed) {
            order.setConfirmedAt(OffsetDateTime.now());
        } else if (status == OrderStatus.completed) {
            order.setCompletedAt(OffsetDateTime.now());
        }
        
        order = orderRepository.save(order);
        return mapToResponse(order);
    }
    
    @Transactional
    public OrderResponse cancelOrder(Long orderId, Long cancelledById, String reason) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        
        User cancelledBy = userRepository.findById(cancelledById)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        order.setOrderStatus(OrderStatus.cancelled);
        order.setCancelledBy(cancelledBy);
        order.setCancelReason(reason);
        
        order = orderRepository.save(order);
        return mapToResponse(order);
    }
    
    private String generateOrderCode() {
        return "ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
    
    private OrderResponse mapToResponse(Order order) {
        List<OrderItemResponse> items = orderItemRepository.findByOrderId(order.getId()).stream()
                .map(item -> OrderItemResponse.builder()
                        .id(item.getId())
                        .foodItemId(item.getFoodItem().getId())
                        .foodName(item.getFoodName())
                        .foodPrice(item.getFoodPrice())
                        .quantity(item.getQuantity())
                        .note(item.getNote())
                        .subtotal(item.getSubtotal())
                        .foodImage(item.getFoodItem().getImage())
                        .build())
                .collect(Collectors.toList());
        
        return OrderResponse.builder()
                .id(order.getId())
                .orderCode(order.getOrderCode())
                .customerId(order.getCustomer().getId())
                .customerName(order.getCustomer().getFullName())
                .shopId(order.getShop().getId())
                .shopName(order.getShop().getShopName())
                .deliveryAddress(order.getDeliveryAddress())
                .deliveryPhone(order.getDeliveryPhone())
                .deliveryNote(order.getDeliveryNote())
                .subtotal(order.getSubtotal())
                .deliveryFee(order.getDeliveryFee())
                .discountAmount(order.getDiscountAmount())
                .totalAmount(order.getTotalAmount())
                .paymentMethod(order.getPaymentMethod())
                .paymentStatus(order.getPaymentStatus())
                .orderStatus(order.getOrderStatus())
                .cancelReason(order.getCancelReason())
                .estimatedDeliveryTime(order.getEstimatedDeliveryTime())
                .createdAt(order.getCreatedAt())
                .confirmedAt(order.getConfirmedAt())
                .completedAt(order.getCompletedAt())
                .orderItems(items)
                .build();
    }
}
