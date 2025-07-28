package com.gym_management.system.controller;

import com.gym_management.system.model.dto.CreateMemberRequest;
import com.gym_management.system.model.dto.MemberResponse;
import com.gym_management.system.model.dto.UpdateMemberRequest;
import com.gym_management.system.services.MemberService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;

@RestController
@RequestMapping("/api/members")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*") // Configurar según necesidades de CORS
public class MemberController {

    private final MemberService memberService;

    /**
     * Crear un nuevo miembro
     * POST /api/members
     */
    @PostMapping
    public ResponseEntity<MemberResponse> createMember(@Valid @RequestBody CreateMemberRequest request) {
        log.info("Received request to create member with email: {}", request.getEmail());
        
        MemberResponse response = memberService.createMember(request);
        
        log.info("Member created successfully with ID: {}", response.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Obtener todos los miembros con paginación
     * 
     * <p><strong>Endpoint:</strong> {@code GET /api/members}</p>
     * <p><strong>Parámetros de ejemplo:</strong> 
     * {@code ?page=0&size=10&sortBy=firstName&sortDirection=asc}</p>
     */
    @GetMapping
    public ResponseEntity<Page<MemberResponse>> getAllMembers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "firstName") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDirection) {
        
        log.info("Received request to get all members - page: {}, size: {}, sortBy: {}, sortDirection: {}", 
                page, size, sortBy, sortDirection);
        
        Page<MemberResponse> members = memberService.getAllMembers(page, size, sortBy, sortDirection);
        
        return ResponseEntity.ok(members);
    }

    /**
     * Obtener miembro por ID
     * GET /api/members/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<MemberResponse> getMemberById(@PathVariable Long id) {
        log.info("Received request to get member with ID: {}", id);
        
        MemberResponse member = memberService.getMemberById(id);
        
        return ResponseEntity.ok(member);
    }

    /**
     * Actualizar miembro existente
     * PUT /api/members/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<MemberResponse> updateMember(
            @PathVariable Long id,
            @Valid @RequestBody UpdateMemberRequest request) {
        
        log.info("Received request to update member with ID: {}", id);
        
        MemberResponse updatedMember = memberService.updateMember(id, request);
        
        return ResponseEntity.ok(updatedMember);
    }

    /**
     * Eliminar miembro (borrado lógico)
     * DELETE /api/members/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMember(@PathVariable Long id) {
        log.info("Received request to delete member with ID: {}", id);
        
        memberService.deleteMember(id);
        
        return ResponseEntity.noContent().build();
    }

    /**
     * Buscar miembros por email
     * GET /api/members/email/{email}
     */
    @GetMapping("/email/{email}")
    public ResponseEntity<MemberResponse> getMemberByEmail(@PathVariable String email) {
        log.info("Received request to get member with email: {}", email);
        
        MemberResponse member = memberService.getMemberByEmail(email);
        
        return ResponseEntity.ok(member);
    }

    /**
     * Buscar miembros por nombre
     * GET /api/members/search?name=Juan
     */
    @GetMapping("/search")
    public ResponseEntity<List<MemberResponse>> searchMembersByName(@RequestParam String name) {
        log.info("Received request to search members by name: {}", name);
        
        List<MemberResponse> members = memberService.searchMembersByName(name);
        
        return ResponseEntity.ok(members);
    }

    /**
     * Obtener miembros activos
     * GET /api/members/active
     */
    @GetMapping("/active")
    public ResponseEntity<List<MemberResponse>> getActiveMembers() {
        log.info("Received request to get active members");
        
        List<MemberResponse> activeMembers = memberService.getActiveMembers();
        
        return ResponseEntity.ok(activeMembers);
    }

    /**
     * Obtener estadísticas de miembros
     * GET /api/members/stats
     */
    @GetMapping("/stats")
    public ResponseEntity<MemberService.MemberStats> getMemberStats() {
        log.info("Received request to get member statistics");
        
        MemberService.MemberStats stats = memberService.getMemberStats();
        
        return ResponseEntity.ok(stats);
    }

    /**
     * Health check del endpoint
     * GET /api/members/health
     */
    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("Members API is running");
    }
} 