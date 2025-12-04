package com.foodapp.repository;

import com.foodapp.entity.ActivityLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ActivityLogRepository extends JpaRepository<ActivityLog, Long> {
    
    List<ActivityLog> findByUserId(Long userId);
    
    List<ActivityLog> findByAction(String action);
    
    List<ActivityLog> findByUserIdOrderByCreatedAtDesc(Long userId);
}
