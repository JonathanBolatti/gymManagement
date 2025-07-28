package com.gym_management.system.model.dto;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateMemberRequest {
    
    @NotBlank(message = "El nombre es obligatorio")
    @Size(min = 2, max = 50, message = "El nombre debe tener entre 2 y 50 caracteres")
    private String firstName;
    
    @NotBlank(message = "El apellido es obligatorio")
    @Size(min = 2, max = 50, message = "El apellido debe tener entre 2 y 50 caracteres")
    private String lastName;
    
    @NotBlank(message = "El email es obligatorio")
    @Email(message = "El formato del email no es válido")
    private String email;
    
    @NotBlank(message = "El teléfono es obligatorio")
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "El formato del teléfono no es válido")
    private String phone;
    
    @NotBlank(message = "La fecha de nacimiento es obligatoria")
    private String dateOfBirth;
    
    @NotBlank(message = "El género es obligatorio")
    @Pattern(regexp = "^(MALE|FEMALE|OTHER)$", message = "El género debe ser MALE, FEMALE u OTHER")
    private String gender;
    
    @NotBlank(message = "La dirección es obligatoria")
    @Size(max = 200, message = "La dirección no debe exceder 200 caracteres")
    private String address;
    
    @NotBlank(message = "El contacto de emergencia es obligatorio")
    @Size(max = 100, message = "El contacto de emergencia no debe exceder 100 caracteres")
    private String emergencyContact;
    
    @NotBlank(message = "El teléfono de emergencia es obligatorio")
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "El formato del teléfono de emergencia no es válido")
    private String emergencyPhone;
    
    @NotBlank(message = "El tipo de membresía es obligatorio")
    @Pattern(regexp = "^(BASIC|PREMIUM|VIP)$", message = "El tipo de membresía debe ser BASIC, PREMIUM o VIP")
    private String membershipType;
    
    @NotBlank(message = "La fecha de inicio es obligatoria")
    private String startDate;
    
    @NotBlank(message = "La fecha de fin es obligatoria")
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
} 