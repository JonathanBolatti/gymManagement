package com.gym_management.system.model.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO de respuesta que contiene la información completa de un miembro del gimnasio.
 * 
 * <p>Esta clase se utiliza para retornar datos de miembros en las respuestas de la API REST.
 * Incluye tanto los datos básicos del miembro como campos calculados y timestamps de auditoría.</p>
 * 
 * <p><strong>Características principales:</strong></p>
 * <ul>
 *   <li>Información personal completa del miembro</li>
 *   <li>Datos físicos (altura, peso)</li>
 *   <li>Información de contacto y emergencia</li>
 *   <li>Campos calculados como edad y nombre completo</li>
 *   <li>Estado de actividad y timestamps de auditoría</li>
 * </ul>
 * 
 * <p><strong>Ejemplo de uso en JSON:</strong></p>
 * <pre>{@code
 * {
 *   "id": 1,
 *   "firstName": "Juan",
 *   "lastName": "Pérez",
 *   "fullName": "Juan Pérez",
 *   "email": "juan.perez@email.com",
 *   "phone": "+56987654321",
 *   "age": 28,
 *   "isActive": true,
 *   "createdAt": "2024-01-15T10:30:00"
 * }
 * }</pre>
 * 
 * @author Equipo de Desarrollo Gym Management
 * @version 1.0
 * @since 1.0
 * @see com.gym_management.system.model.Member
 * @see CreateMemberRequest
 * @see UpdateMemberRequest
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MemberResponse {
    
    /** Identificador único del miembro */
    private Long id;
    
    /** Nombre del miembro */
    private String firstName;
    
    /** Apellido del miembro */
    private String lastName;
    
    /** Nombre completo calculado (firstName + lastName) */
    private String fullName;
    
    /** Dirección de email del miembro (único en el sistema) */
    private String email;
    
    /** Número de teléfono del miembro */
    private String phone;
    
    /** Fecha de nacimiento del miembro (formato string) */
    private String dateOfBirth;
    
    /** Edad calculada basada en la fecha de nacimiento */
    private Integer age;
    
    /** Género del miembro (MALE, FEMALE, OTHER) */
    private String gender;
    
    /** Dirección del miembro */
    private String address;
    
    /** Nombre del contacto de emergencia */
    private String emergencyContact;
    
    /** Teléfono del contacto de emergencia */
    private String emergencyPhone;
    
    /** Tipo de membresía (BASIC, PREMIUM, VIP) */
    private String membershipType;
    
    /** Fecha de inicio de la membresía */
    private String startDate;
    
    /** Fecha de fin de la membresía */
    private String endDate;
    
    /** Notas adicionales sobre el miembro */
    private String notes;
    
    /** Altura del miembro en metros */
    private Double height;
    
    /** Peso del miembro en kilogramos */
    private Double weight;
    
    /** Indica si el miembro está activo (true) o inactivo/eliminado (false) */
    private Boolean isActive;
    
    /** Timestamp de creación del registro */
    private LocalDateTime createdAt;
    
    /** Timestamp de última actualización del registro */
    private LocalDateTime updatedAt;
} 