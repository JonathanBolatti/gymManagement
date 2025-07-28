package com.gym_management.system;

import com.gym_management.system.exception.DuplicateEmailException;
import com.gym_management.system.exception.MemberNotFoundException;
import com.gym_management.system.model.dto.CreateMemberRequest;
import com.gym_management.system.model.dto.MemberResponse;
import com.gym_management.system.services.MemberService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("dev")
@Transactional
class MemberServiceTest {

    @Autowired
    private MemberService memberService;

    @Test
    void testCreateMember() {
        // Given
        CreateMemberRequest request = new CreateMemberRequest();
        request.setFirstName("Test");
        request.setLastName("User");
        request.setEmail("test.user@email.com");
        request.setPhone("+1234567890");
        request.setDateOfBirth("1990-01-01");
        request.setGender("MALE");
        request.setAddress("Test Address");
        request.setEmergencyContact("Emergency Contact");
        request.setEmergencyPhone("+1234567891");
        request.setMembershipType("BASIC");
        request.setStartDate("2024-01-01");
        request.setEndDate("2024-12-31");
        request.setNotes("Test member");

        // When
        MemberResponse response = memberService.createMember(request);

        // Then
        assertNotNull(response);
        assertNotNull(response.getId());
        assertEquals("Test", response.getFirstName());
        assertEquals("User", response.getLastName());
        assertEquals("test.user@email.com", response.getEmail());
        assertTrue(response.getIsActive());
        assertEquals("Test User", response.getFullName());
    }

    @Test
    void testCreateMemberWithDuplicateEmail() {
        // Given - Crear primer miembro
        CreateMemberRequest firstRequest = new CreateMemberRequest();
        firstRequest.setFirstName("Juan");
        firstRequest.setLastName("Pérez");
        firstRequest.setEmail("duplicate@email.com");
        firstRequest.setPhone("+1234567890");
        firstRequest.setDateOfBirth("1990-01-01");
        firstRequest.setGender("MALE");
        firstRequest.setAddress("Test Address");
        firstRequest.setEmergencyContact("Emergency Contact");
        firstRequest.setEmergencyPhone("+1234567891");
        firstRequest.setMembershipType("BASIC");
        firstRequest.setStartDate("2024-01-01");
        firstRequest.setEndDate("2024-12-31");
        
        memberService.createMember(firstRequest);
        
        // Intentar crear segundo miembro con el mismo email
        CreateMemberRequest secondRequest = new CreateMemberRequest();
        secondRequest.setFirstName("Ana");
        secondRequest.setLastName("García");
        secondRequest.setEmail("duplicate@email.com"); // Email duplicado
        secondRequest.setPhone("+1234567891");
        secondRequest.setDateOfBirth("1985-01-01");
        secondRequest.setGender("FEMALE");
        secondRequest.setAddress("Test Address 2");
        secondRequest.setEmergencyContact("Emergency Contact 2");
        secondRequest.setEmergencyPhone("+1234567892");
        secondRequest.setMembershipType("PREMIUM");
        secondRequest.setStartDate("2024-01-01");
        secondRequest.setEndDate("2024-12-31");

        // When & Then
        assertThrows(DuplicateEmailException.class, () -> {
            memberService.createMember(secondRequest);
        });
    }

    @Test
    void testGetMemberById() {
        // Given - Crear un miembro primero
        CreateMemberRequest request = new CreateMemberRequest();
        request.setFirstName("Juan");
        request.setLastName("Pérez");
        request.setEmail("juan.test@email.com");
        request.setPhone("+1234567890");
        request.setDateOfBirth("1990-01-01");
        request.setGender("MALE");
        request.setAddress("Test Address");
        request.setEmergencyContact("Emergency Contact");
        request.setEmergencyPhone("+1234567891");
        request.setMembershipType("BASIC");
        request.setStartDate("2024-01-01");
        request.setEndDate("2024-12-31");

        MemberResponse createdMember = memberService.createMember(request);

        // When
        MemberResponse response = memberService.getMemberById(createdMember.getId());

        // Then
        assertNotNull(response);
        assertEquals(createdMember.getId(), response.getId());
        assertEquals("Juan", response.getFirstName());
        assertEquals("Pérez", response.getLastName());
    }

    @Test
    void testGetMemberByIdNotFound() {
        // Given
        Long nonExistentId = 999L;

        // When & Then
        assertThrows(MemberNotFoundException.class, () -> {
            memberService.getMemberById(nonExistentId);
        });
    }

    @Test
    void testGetMemberStats() {
        // Given - Crear algunos miembros de prueba
        CreateMemberRequest request1 = new CreateMemberRequest();
        request1.setFirstName("Test1");
        request1.setLastName("User1");
        request1.setEmail("test1@email.com");
        request1.setPhone("+1234567890");
        request1.setDateOfBirth("1990-01-01");
        request1.setGender("MALE");
        request1.setAddress("Test Address 1");
        request1.setEmergencyContact("Emergency Contact 1");
        request1.setEmergencyPhone("+1234567891");
        request1.setMembershipType("BASIC");
        request1.setStartDate("2024-01-01");
        request1.setEndDate("2024-12-31");
        
        CreateMemberRequest request2 = new CreateMemberRequest();
        request2.setFirstName("Test2");
        request2.setLastName("User2");
        request2.setEmail("test2@email.com");
        request2.setPhone("+1234567892");
        request2.setDateOfBirth("1985-01-01");
        request2.setGender("FEMALE");
        request2.setAddress("Test Address 2");
        request2.setEmergencyContact("Emergency Contact 2");
        request2.setEmergencyPhone("+1234567893");
        request2.setMembershipType("PREMIUM");
        request2.setStartDate("2024-01-01");
        request2.setEndDate("2024-12-31");

        memberService.createMember(request1);
        memberService.createMember(request2);

        // When
        MemberService.MemberStats stats = memberService.getMemberStats();

        // Then
        assertNotNull(stats);
        assertTrue(stats.getTotalMembers() >= 2); // Al menos los 2 que creamos
        assertTrue(stats.getActiveMembers() >= 2); // Los 2 creados deben estar activos
        assertEquals(stats.getTotalMembers(), stats.getActiveMembers() + stats.getInactiveMembers());
    }
} 