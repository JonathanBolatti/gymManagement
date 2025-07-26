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
    
    @NotNull(message = "La fecha de nacimiento es obligatoria")
    @Past(message = "La fecha de nacimiento debe ser en el pasado")
    private LocalDate birthDate;
    
    @NotBlank(message = "El género es obligatorio")
    @Pattern(regexp = "^(M|F|O)$", message = "El género debe ser M (Masculino), F (Femenino) o O (Otro)")
    private String gender;
    
    @DecimalMin(value = "0.5", message = "La altura debe ser mayor a 0.5 metros")
    @DecimalMax(value = "3.0", message = "La altura debe ser menor a 3.0 metros")
    private Double height;
    
    @DecimalMin(value = "20.0", message = "El peso debe ser mayor a 20 kg")
    @DecimalMax(value = "500.0", message = "El peso debe ser menor a 500 kg")
    private Double weight;
    
    @Size(max = 100, message = "El contacto de emergencia no debe exceder 100 caracteres")
    private String emergencyContact;
    
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "El formato del teléfono de emergencia no es válido")
    private String emergencyPhone;
    
    @Size(max = 500, message = "Las observaciones no deben exceder 500 caracteres")
    private String observations;
} 