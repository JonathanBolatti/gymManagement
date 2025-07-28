package com.gym_management.system.model.dto;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateMemberRequest {
    
    @Size(min = 2, max = 50, message = "El nombre debe tener entre 2 y 50 caracteres")
    private String firstName;
    
    @Size(min = 2, max = 50, message = "El apellido debe tener entre 2 y 50 caracteres")
    private String lastName;
    
    @Email(message = "El formato del email no es válido")
    private String email;
    
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "El formato del teléfono no es válido")
    private String phone;
    
    private String dateOfBirth;
    
    @Pattern(regexp = "^(MALE|FEMALE|OTHER)$", message = "El género debe ser MALE, FEMALE u OTHER")
    private String gender;
    
    @Size(max = 200, message = "La dirección no debe exceder 200 caracteres")
    private String address;
    
    @Size(max = 100, message = "El contacto de emergencia no debe exceder 100 caracteres")
    private String emergencyContact;
    
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "El formato del teléfono de emergencia no es válido")
    private String emergencyPhone;
    
    @Pattern(regexp = "^(BASIC|PREMIUM|VIP)$", message = "El tipo de membresía debe ser BASIC, PREMIUM o VIP")
    private String membershipType;
    
    private String startDate;
    
    private String endDate;
    
    @Size(max = 500, message = "Las notas no deben exceder 500 caracteres")
    private String notes;
    
    // Campos opcionales para información física
    @DecimalMin(value = "0.5", message = "La altura debe ser mayor a 0.5 metros")
    @DecimalMax(value = "3.0", message = "La altura debe ser menor a 3.0 metros")
    private Double height;
    
    @DecimalMin(value = "20.0", message = "El peso debe ser mayor a 20 kg")
    @DecimalMax(value = "500.0", message = "El peso debe ser menor a 500 kg")
    private Double weight;
    
    private Boolean isActive;
} 