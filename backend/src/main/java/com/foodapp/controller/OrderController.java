package com.foodapp.controller;

import com.foodapp.dto.response.ApiResponse;
import com.foodapp.dto.response.OrderResponse;
import com.foodapp.entity.enums.OrderStatus;
import com.foodapp.entity.enums.PaymentMethod;
import com.foodapp.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/orders")
@RequiredArgsConstructor
public class OrderController {
    
    private final OrderService orderService;
    
    @GetMapping("/customer/{customerId}")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getOrdersByCustomer(@PathVariable Long customerId) {
        List<OrderResponse> orders = orderService.getOrdersByCustomer(customerId);
        return ResponseEntity.ok(ApiResponse.success(orders));
    }
    
    @GetMapping("/shop/{shopId}")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getOrdersByShop(@PathVariable Long shopId) {
        List<OrderResponse> orders = orderService.getOrdersByShop(shopId);
        return ResponseEntity.ok(ApiResponse.success(orders));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<OrderResponse>> getOrderById(@PathVariable Long id) {
        try {
            OrderResponse order = orderService.getOrderById(id);
            return ResponseEntity.ok(ApiResponse.success(order));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping("/code/{orderCode}")
    public ResponseEntity<ApiResponse<OrderResponse>> getOrderByCode(@PathVariable String orderCode) {
        try {
            OrderResponse order = orderService.getOrderByCode(orderCode);
            return ResponseEntity.ok(ApiResponse.success(order));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<OrderResponse>> createOrder(@RequestBody Map<String, Object> request) {
        try {
            Long customerId = Long.valueOf(request.get("customerId").toString());
            Long shopId = Long.valueOf(request.get("shopId").toString());
            String deliveryAddress = (String) request.get("deliveryAddress");
            String deliveryPhone = (String) request.get("deliveryPhone");
            String deliveryNote = (String) request.get("deliveryNote");
            PaymentMethod paymentMethod = PaymentMethod.valueOf((String) request.get("paymentMethod"));
            
            OrderResponse order = orderService.createOrderFromCart(customerId, shopId, deliveryAddress, 
                    deliveryPhone, deliveryNote, paymentMethod);
            return ResponseEntity.ok(ApiResponse.success("Order created successfully", order));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}/status")
    public ResponseEntity<ApiResponse<OrderResponse>> updateOrderStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        try {
            OrderStatus status = OrderStatus.valueOf(request.get("status"));
            OrderResponse order = orderService.updateOrderStatus(id, status);
            return ResponseEntity.ok(ApiResponse.success("Order status updated", order));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<OrderResponse>> cancelOrder(
            @PathVariable Long id,
            @RequestBody Map<String, Object> request) {
        try {
            Long cancelledById = Long.valueOf(request.get("cancelledById").toString());
            String reason = (String) request.get("reason");
            
            OrderResponse order = orderService.cancelOrder(id, cancelledById, reason);
            return ResponseEntity.ok(ApiResponse.success("Order cancelled", order));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
