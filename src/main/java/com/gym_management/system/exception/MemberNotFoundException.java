package com.gym_management.system.exception;

public class MemberNotFoundException extends RuntimeException {
    
    public MemberNotFoundException(String message) {
        super(message);
    }
    
    public MemberNotFoundException(Long id) {
        super("No se encontró el miembro con ID: " + id);
    }
    
    public MemberNotFoundException(String field, String value) {
        super("No se encontró el miembro con " + field + ": " + value);
    }
} 