package com.gym_management.system.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "members")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Member {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "El nombre es obligatorio")
    @Size(min = 2, max = 50, message = "El nombre debe tener entre 2 y 50 caracteres")
    @Column(name = "first_name", nullable = false, length = 50)
    private String firstName;
    
    @NotBlank(message = "El apellido es obligatorio")
    @Size(min = 2, max = 50, message = "El apellido debe tener entre 2 y 50 caracteres")
    @Column(name = "last_name", nullable = false, length = 50)
    private String lastName;
    
    @NotBlank(message = "El email es obligatorio")
    @Email(message = "El formato del email no es válido")
    @Column(name = "email", nullable = false, unique = true, length = 100)
    private String email;
    
    @NotBlank(message = "El teléfono es obligatorio")
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "El formato del teléfono no es válido")
    @Column(name = "phone", nullable = false, length = 20)
    private String phone;
    
    @NotBlank(message = "La fecha de nacimiento es obligatoria")
    @Column(name = "date_of_birth", nullable = false)
    private String dateOfBirth;
    
    @NotBlank(message = "El género es obligatorio")
    @Pattern(regexp = "^(MALE|FEMALE|OTHER)$", message = "El género debe ser MALE, FEMALE u OTHER")
    @Column(name = "gender", nullable = false, length = 10)
    private String gender;
    
    @NotBlank(message = "La dirección es obligatoria")
    @Size(max = 200, message = "La dirección no debe exceder 200 caracteres")
    @Column(name = "address", nullable = false, length = 200)
    private String address;
    
    @NotBlank(message = "El contacto de emergencia es obligatorio")
    @Size(max = 100, message = "El contacto de emergencia no debe exceder 100 caracteres")
    @Column(name = "emergency_contact", nullable = false, length = 100)
    private String emergencyContact;
    
    @NotBlank(message = "El teléfono de emergencia es obligatorio")
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "El formato del teléfono de emergencia no es válido")
    @Column(name = "emergency_phone", nullable = false, length = 20)
    private String emergencyPhone;
    
    @NotBlank(message = "El tipo de membresía es obligatorio")
    @Pattern(regexp = "^(BASIC|PREMIUM|VIP)$", message = "El tipo de membresía debe ser BASIC, PREMIUM o VIP")
    @Column(name = "membership_type", nullable = false, length = 20)
    private String membershipType;
    
    @NotBlank(message = "La fecha de inicio es obligatoria")
    @Column(name = "start_date", nullable = false)
    private String startDate;
    
    @NotBlank(message = "La fecha de fin es obligatoria")
    @Column(name = "end_date", nullable = false)
    private String endDate;
    
    @Size(max = 500, message = "Las notas no deben exceder 500 caracteres")
    @Column(name = "notes", length = 500)
    private String notes;
    
    // Campos opcionales para información física
    @DecimalMin(value = "0.5", message = "La altura debe ser mayor a 0.5 metros")
    @DecimalMax(value = "3.0", message = "La altura debe ser menor a 3.0 metros")
    @Column(name = "height")
    private Double height;
    
    @DecimalMin(value = "20.0", message = "El peso debe ser mayor a 20 kg")
    @DecimalMax(value = "500.0", message = "El peso debe ser menor a 500 kg")
    @Column(name = "weight")
    private Double weight;
    
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    // Método helper para obtener el nombre completo
    public String getFullName() {
        return firstName + " " + lastName;
    }
    
    // Método helper para calcular la edad (convertir string a LocalDate)
    public int getAge() {
        try {
            LocalDate birthDate = LocalDate.parse(dateOfBirth);
            return LocalDate.now().getYear() - birthDate.getYear();
        } catch (Exception e) {
            return 0; // Si no se puede parsear, retornar 0
        }
    }
} 