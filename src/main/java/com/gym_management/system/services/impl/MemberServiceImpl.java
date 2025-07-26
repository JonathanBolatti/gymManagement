package com.gym_management.system.services.impl;

import com.gym_management.system.exception.DuplicateEmailException;
import com.gym_management.system.exception.MemberNotFoundException;
import com.gym_management.system.model.Member;
import com.gym_management.system.model.dto.CreateMemberRequest;
import com.gym_management.system.model.dto.MemberResponse;
import com.gym_management.system.model.dto.UpdateMemberRequest;
import com.gym_management.system.repository.MemberRepository;
import com.gym_management.system.services.MemberService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Implementación del servicio de gestión de miembros.
 * Contiene toda la lógica de negocio para las operaciones CRUD y consultas de miembros.
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class MemberServiceImpl implements MemberService {

    private final MemberRepository memberRepository;

    @Override
    public MemberResponse createMember(CreateMemberRequest request) {
        log.info("Creando nuevo miembro con email: {}", request.getEmail());
        
        // Verificar si el email ya existe
        if (memberRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException(request.getEmail());
        }

        // Mapear DTO a entidad
        Member member = mapToEntity(request);
        
        // Guardar en base de datos
        Member savedMember = memberRepository.save(member);
        
        log.info("Miembro creado exitosamente con ID: {}", savedMember.getId());
        return mapToResponse(savedMember);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<MemberResponse> getAllMembers(int page, int size, String sortBy, String sortDirection) {
        log.info("Obteniendo miembros - página: {}, tamaño: {}, orden: {} {}", page, size, sortBy, sortDirection);
        
        Sort.Direction direction = sortDirection.equalsIgnoreCase("desc") ? Sort.Direction.DESC : Sort.Direction.ASC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));
        
        Page<Member> members = memberRepository.findAll(pageable);
        return members.map(this::mapToResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public MemberResponse getMemberById(Long id) {
        log.info("Buscando miembro con ID: {}", id);
        
        Member member = memberRepository.findById(id)
                .orElseThrow(() -> new MemberNotFoundException(id));
        
        return mapToResponse(member);
    }

    @Override
    @Transactional(readOnly = true)
    public MemberResponse getMemberByEmail(String email) {
        log.info("Buscando miembro con email: {}", email);
        
        Member member = memberRepository.findByEmail(email)
                .orElseThrow(() -> new MemberNotFoundException("email", email));
        
        return mapToResponse(member);
    }

    @Override
    public MemberResponse updateMember(Long id, UpdateMemberRequest request) {
        log.info("Actualizando miembro con ID: {}", id);
        
        Member existingMember = memberRepository.findById(id)
                .orElseThrow(() -> new MemberNotFoundException(id));

        // Verificar email duplicado (si se está cambiando)
        if (request.getEmail() != null && !request.getEmail().equals(existingMember.getEmail())) {
            if (memberRepository.existsByEmailAndIdNot(request.getEmail(), id)) {
                throw new DuplicateEmailException(request.getEmail());
            }
        }

        // Actualizar campos no nulos
        updateMemberFields(existingMember, request);
        
        Member updatedMember = memberRepository.save(existingMember);
        
        log.info("Miembro actualizado exitosamente con ID: {}", id);
        return mapToResponse(updatedMember);
    }

    @Override
    public void deleteMember(Long id) {
        log.info("Eliminando miembro con ID: {}", id);
        
        Member member = memberRepository.findById(id)
                .orElseThrow(() -> new MemberNotFoundException(id));
        
        member.setIsActive(false);
        memberRepository.save(member);
        
        log.info("Miembro eliminado (desactivado) exitosamente con ID: {}", id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<MemberResponse> searchMembersByName(String searchTerm) {
        log.info("Buscando miembros por nombre: {}", searchTerm);
        
        List<Member> members = memberRepository.findByNameContaining(searchTerm);
        return members.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<MemberResponse> getActiveMembers() {
        log.info("Obteniendo miembros activos");
        
        List<Member> activeMembers = memberRepository.findByIsActiveTrue();
        return activeMembers.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public MemberStats getMemberStats() {
        log.info("Obteniendo estadísticas de miembros");
        
        long totalMembers = memberRepository.count();
        long activeMembers = memberRepository.countByIsActiveTrue();
        long inactiveMembers = memberRepository.countByIsActiveFalse();
        
        return new MemberStats(totalMembers, activeMembers, inactiveMembers);
    }

    // Métodos privados de mapeo y utilidades

    /**
     * Mapea un DTO de creación a una entidad Member.
     *
     * @param request DTO con los datos del miembro a crear
     * @return Entidad Member mapeada
     */
    private Member mapToEntity(CreateMemberRequest request) {
        Member member = new Member();
        member.setFirstName(request.getFirstName());
        member.setLastName(request.getLastName());
        member.setEmail(request.getEmail());
        member.setPhone(request.getPhone());
        member.setBirthDate(request.getBirthDate());
        member.setGender(request.getGender());
        member.setHeight(request.getHeight());
        member.setWeight(request.getWeight());
        member.setEmergencyContact(request.getEmergencyContact());
        member.setEmergencyPhone(request.getEmergencyPhone());
        member.setObservations(request.getObservations());
        member.setIsActive(true); // Por defecto activo
        return member;
    }

    /**
     * Mapea una entidad Member a un DTO de respuesta.
     *
     * @param member Entidad Member a mapear
     * @return DTO de respuesta con la información del miembro
     */
    private MemberResponse mapToResponse(Member member) {
        MemberResponse response = new MemberResponse();
        response.setId(member.getId());
        response.setFirstName(member.getFirstName());
        response.setLastName(member.getLastName());
        response.setFullName(member.getFullName());
        response.setEmail(member.getEmail());
        response.setPhone(member.getPhone());
        response.setBirthDate(member.getBirthDate());
        response.setAge(member.getAge());
        response.setGender(member.getGender());
        response.setHeight(member.getHeight());
        response.setWeight(member.getWeight());
        response.setEmergencyContact(member.getEmergencyContact());
        response.setEmergencyPhone(member.getEmergencyPhone());
        response.setIsActive(member.getIsActive());
        response.setObservations(member.getObservations());
        response.setCreatedAt(member.getCreatedAt());
        response.setUpdatedAt(member.getUpdatedAt());
        return response;
    }

    /**
     * Actualiza los campos de un miembro con los valores no nulos del DTO de actualización.
     *
     * @param member Entidad Member a actualizar
     * @param request DTO con los campos a actualizar
     */
    private void updateMemberFields(Member member, UpdateMemberRequest request) {
        if (request.getFirstName() != null) {
            member.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            member.setLastName(request.getLastName());
        }
        if (request.getEmail() != null) {
            member.setEmail(request.getEmail());
        }
        if (request.getPhone() != null) {
            member.setPhone(request.getPhone());
        }
        if (request.getBirthDate() != null) {
            member.setBirthDate(request.getBirthDate());
        }
        if (request.getGender() != null) {
            member.setGender(request.getGender());
        }
        if (request.getHeight() != null) {
            member.setHeight(request.getHeight());
        }
        if (request.getWeight() != null) {
            member.setWeight(request.getWeight());
        }
        if (request.getEmergencyContact() != null) {
            member.setEmergencyContact(request.getEmergencyContact());
        }
        if (request.getEmergencyPhone() != null) {
            member.setEmergencyPhone(request.getEmergencyPhone());
        }
        if (request.getIsActive() != null) {
            member.setIsActive(request.getIsActive());
        }
        if (request.getObservations() != null) {
            member.setObservations(request.getObservations());
        }
    }
} 