package com.gym_management.system.services;

import com.gym_management.system.model.dto.CreateUserRequest;
import com.gym_management.system.model.dto.UpdateUserRequest;
import com.gym_management.system.model.dto.UserResponse;

import java.util.List;

public interface UserService {
    
    UserResponse createUser(CreateUserRequest request);
    
    UserResponse getUserById(Long id);
    
    UserResponse getUserByUsername(String username);
    
    UserResponse getUserByEmail(String email);
    
    List<UserResponse> getAllUsers();
    
    List<UserResponse> getAllActiveUsers();
    
    List<UserResponse> getUsersByRole(String role);
    
    List<UserResponse> getActiveUsersByRole(String role);
    
    List<UserResponse> searchUsers(String searchTerm);
    
    UserResponse updateUser(Long id, UpdateUserRequest request);
    
    UserResponse deactivateUser(Long id);
    
    UserResponse activateUser(Long id);
    
    void deleteUser(Long id);
    
    boolean existsByUsername(String username);
    
    boolean existsByEmail(String email);
} 