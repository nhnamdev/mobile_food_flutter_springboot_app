package com.foodapp.controller;

import com.foodapp.dto.request.GoogleAuthRequest;
import com.foodapp.dto.request.LoginRequest;
import com.foodapp.dto.request.RegisterRequest;
import com.foodapp.dto.response.ApiResponse;
import com.foodapp.dto.response.AuthResponse;
import com.foodapp.dto.response.UserResponse;
import com.foodapp.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final UserService userService;
    
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserResponse>> register(@Valid @RequestBody RegisterRequest request) {
        try {
            UserResponse user = userService.register(request);
            return ResponseEntity.ok(ApiResponse.success("Registration successful", user));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        try {
            AuthResponse response = userService.login(request);
            return ResponseEntity.ok(ApiResponse.success("Login successful", response));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    /**
     * Sync user từ Google OAuth (Supabase) vào database
     * Gọi sau khi user đăng nhập Google thành công
     */
    @PostMapping("/google/sync")
    public ResponseEntity<ApiResponse<UserResponse>> syncGoogleUser(@Valid @RequestBody GoogleAuthRequest request) {
        try {
            UserResponse user = userService.syncGoogleUser(request);
            return ResponseEntity.ok(ApiResponse.success("User synced successfully", user));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
