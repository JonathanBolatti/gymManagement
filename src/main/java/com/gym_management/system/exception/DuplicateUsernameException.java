package com.gym_management.system.exception;

public class DuplicateUsernameException extends RuntimeException {
    
    public DuplicateUsernameException(String username) {
        super("El nombre de usuario '" + username + "' ya está en uso");
    }
} 