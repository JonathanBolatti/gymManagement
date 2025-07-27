package com.gym_management.system.services;

import com.gym_management.system.model.dto.AuthResponse;
import com.gym_management.system.model.dto.LoginRequest;
import com.gym_management.system.model.dto.RegisterRequest;

public interface AuthService {
    
    AuthResponse login(LoginRequest request);
    
    AuthResponse register(RegisterRequest request);
    
    AuthResponse refreshToken(String refreshToken);
    
    boolean validateToken(String token);
    
    void encryptExistingPasswords();
} 