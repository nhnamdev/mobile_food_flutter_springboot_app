package com.foodapp.dto.response;

import com.foodapp.entity.enums.UserRole;
import com.foodapp.entity.enums.UserStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private Long id;
    private String email;
    private String fullName;
    private String phone;
    private String avatar;
    private UserRole userRole;
    private UserStatus userStatus;
    private Boolean isVerified;
    private OffsetDateTime createdAt;
}
