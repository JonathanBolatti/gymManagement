package com.gym_management.system.exception;

public class DuplicateEmailException extends RuntimeException {
    
    public DuplicateEmailException(String email) {
        super("Ya existe un miembro registrado con el email: " + email);
    }
} 