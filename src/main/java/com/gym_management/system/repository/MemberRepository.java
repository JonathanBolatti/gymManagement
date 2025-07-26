package com.gym_management.system.repository;

import com.gym_management.system.model.Member;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {
    
    // Buscar por email (debe ser único)
    Optional<Member> findByEmail(String email);
    
    // Verificar si existe un email (útil para validaciones)
    boolean existsByEmail(String email);
    
    // Verificar si existe un email excluyendo un ID específico (para actualizaciones)
    boolean existsByEmailAndIdNot(String email, Long id);
    
    // Buscar miembros activos
    List<Member> findByIsActiveTrue();
    
    // Buscar miembros inactivos
    List<Member> findByIsActiveFalse();
    
    // Buscar por estado con paginación
    Page<Member> findByIsActive(Boolean isActive, Pageable pageable);
    
    // Buscar por nombre o apellido (búsqueda parcial, case insensitive)
    @Query("SELECT m FROM Member m WHERE " +
           "LOWER(m.firstName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(m.lastName) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    List<Member> findByNameContaining(@Param("searchTerm") String searchTerm);
    
    // Buscar por nombre o apellido con paginación
    @Query("SELECT m FROM Member m WHERE " +
           "LOWER(m.firstName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(m.lastName) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Member> findByNameContaining(@Param("searchTerm") String searchTerm, Pageable pageable);
    
    // Buscar por teléfono
    Optional<Member> findByPhone(String phone);
    
    // Contar miembros activos
    long countByIsActiveTrue();
    
    // Contar miembros inactivos
    long countByIsActiveFalse();
} 