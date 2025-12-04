package com.foodapp.repository;

import com.foodapp.entity.Order;
import com.foodapp.entity.enums.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    Optional<Order> findByOrderCode(String orderCode);
    
    List<Order> findByCustomerId(Long customerId);
    
    List<Order> findByShopId(Long shopId);
    
    List<Order> findByCustomerIdAndOrderStatus(Long customerId, OrderStatus orderStatus);
    
    List<Order> findByShopIdAndOrderStatus(Long shopId, OrderStatus orderStatus);
    
    @Query("SELECT o FROM Order o WHERE o.customer.id = :customerId ORDER BY o.createdAt DESC")
    List<Order> findByCustomerIdOrderByCreatedAtDesc(@Param("customerId") Long customerId);
    
    @Query("SELECT o FROM Order o WHERE o.shop.id = :shopId ORDER BY o.createdAt DESC")
    List<Order> findByShopIdOrderByCreatedAtDesc(@Param("shopId") Long shopId);
}
