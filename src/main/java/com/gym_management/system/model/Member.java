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
    
    @NotNull(message = "La fecha de nacimiento es obligatoria")
    @Past(message = "La fecha de nacimiento debe ser en el pasado")
    @Column(name = "birth_date", nullable = false)
    private LocalDate birthDate;
    
    @NotBlank(message = "El género es obligatorio")
    @Pattern(regexp = "^(M|F|O)$", message = "El género debe ser M (Masculino), F (Femenino) o O (Otro)")
    @Column(name = "gender", nullable = false, length = 1)
    private String gender;
    
    @DecimalMin(value = "0.5", message = "La altura debe ser mayor a 0.5 metros")
    @DecimalMax(value = "3.0", message = "La altura debe ser menor a 3.0 metros")
    @Column(name = "height")
    private Double height;
    
    @DecimalMin(value = "20.0", message = "El peso debe ser mayor a 20 kg")
    @DecimalMax(value = "500.0", message = "El peso debe ser menor a 500 kg")
    @Column(name = "weight")
    private Double weight;
    
    @Size(max = 100, message = "El contacto de emergencia no debe exceder 100 caracteres")
    @Column(name = "emergency_contact", length = 100)
    private String emergencyContact;
    
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "El formato del teléfono de emergencia no es válido")
    @Column(name = "emergency_phone", length = 20)
    private String emergencyPhone;
    
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
    
    @Size(max = 500, message = "Las observaciones no deben exceder 500 caracteres")
    @Column(name = "observations", length = 500)
    private String observations;
    
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
    
    // Método helper para calcular la edad
    public int getAge() {
        return LocalDate.now().getYear() - birthDate.getYear();
    }
} 