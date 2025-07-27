package com.gym_management.system;

import com.gym_management.system.exception.DuplicateEmailException;
import com.gym_management.system.exception.DuplicateUsernameException;
import com.gym_management.system.exception.UserNotFoundException;
import com.gym_management.system.model.User;
import com.gym_management.system.model.dto.CreateUserRequest;
import com.gym_management.system.model.dto.UpdateUserRequest;
import com.gym_management.system.model.dto.UserResponse;
import com.gym_management.system.repository.UserRepository;
import com.gym_management.system.services.impl.UserServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("UserService Tests")
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserServiceImpl userService;

    private User testUser;
    private CreateUserRequest createUserRequest;
    private UpdateUserRequest updateUserRequest;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("admin");
        testUser.setEmail("admin@gym.com");
        testUser.setPassword("password123");
        testUser.setFirstName("Admin");
        testUser.setLastName("Usuario");
        testUser.setPhone("+1234567890");
        testUser.setRole("ADMIN");
        testUser.setIsActive(true);
        testUser.setCreatedAt(LocalDateTime.now());
        testUser.setUpdatedAt(LocalDateTime.now());

        createUserRequest = new CreateUserRequest();
        createUserRequest.setUsername("newuser");
        createUserRequest.setEmail("newuser@gym.com");
        createUserRequest.setPassword("password123");
        createUserRequest.setFirstName("Nuevo");
        createUserRequest.setLastName("Usuario");
        createUserRequest.setPhone("+0987654321");
        createUserRequest.setRole("MANAGER");

        updateUserRequest = new UpdateUserRequest();
        updateUserRequest.setFirstName("Nombre Actualizado");
        updateUserRequest.setLastName("Apellido Actualizado");
    }

    @Test
    @DisplayName("Debe crear un usuario exitosamente")
    void testCreateUser_Success() {
        // Given
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        UserResponse result = userService.createUser(createUserRequest);

        // Then
        assertNotNull(result);
        assertEquals(testUser.getId(), result.getId());
        assertEquals(testUser.getUsername(), result.getUsername());
        assertEquals(testUser.getEmail(), result.getEmail());
        assertEquals(testUser.getRole(), result.getRole());
        assertTrue(result.getIsActive());

        verify(userRepository).existsByUsername(createUserRequest.getUsername());
        verify(userRepository).existsByEmail(createUserRequest.getEmail());
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("Debe lanzar excepción cuando username ya existe")
    void testCreateUser_DuplicateUsername() {
        // Given
        when(userRepository.existsByUsername(anyString())).thenReturn(true);

        // When & Then
        assertThrows(DuplicateUsernameException.class, 
                     () -> userService.createUser(createUserRequest));

        verify(userRepository).existsByUsername(createUserRequest.getUsername());
        verify(userRepository, never()).existsByEmail(anyString());
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Debe lanzar excepción cuando email ya existe")
    void testCreateUser_DuplicateEmail() {
        // Given
        when(userRepository.existsByUsername(anyString())).thenReturn(false);
        when(userRepository.existsByEmail(anyString())).thenReturn(true);

        // When & Then
        assertThrows(DuplicateEmailException.class, 
                     () -> userService.createUser(createUserRequest));

        verify(userRepository).existsByUsername(createUserRequest.getUsername());
        verify(userRepository).existsByEmail(createUserRequest.getEmail());
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Debe obtener usuario por ID exitosamente")
    void testGetUserById_Success() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));

        // When
        UserResponse result = userService.getUserById(1L);

        // Then
        assertNotNull(result);
        assertEquals(testUser.getId(), result.getId());
        assertEquals(testUser.getUsername(), result.getUsername());
        assertEquals(testUser.getEmail(), result.getEmail());

        verify(userRepository).findById(1L);
    }

    @Test
    @DisplayName("Debe lanzar excepción cuando usuario no existe por ID")
    void testGetUserById_NotFound() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(UserNotFoundException.class, 
                     () -> userService.getUserById(1L));

        verify(userRepository).findById(1L);
    }

    @Test
    @DisplayName("Debe obtener usuario por username exitosamente")
    void testGetUserByUsername_Success() {
        // Given
        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(testUser));

        // When
        UserResponse result = userService.getUserByUsername("admin");

        // Then
        assertNotNull(result);
        assertEquals(testUser.getUsername(), result.getUsername());

        verify(userRepository).findByUsername("admin");
    }

    @Test
    @DisplayName("Debe obtener todos los usuarios activos")
    void testGetAllActiveUsers_Success() {
        // Given
        List<User> activeUsers = Arrays.asList(testUser);
        when(userRepository.findAllActiveUsers()).thenReturn(activeUsers);

        // When
        List<UserResponse> result = userService.getAllActiveUsers();

        // Then
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals(testUser.getId(), result.get(0).getId());

        verify(userRepository).findAllActiveUsers();
    }

    @Test
    @DisplayName("Debe obtener usuarios por rol")
    void testGetUsersByRole_Success() {
        // Given
        List<User> adminUsers = Arrays.asList(testUser);
        when(userRepository.findByRole("ADMIN")).thenReturn(adminUsers);

        // When
        List<UserResponse> result = userService.getUsersByRole("ADMIN");

        // Then
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("ADMIN", result.get(0).getRole());

        verify(userRepository).findByRole("ADMIN");
    }

    @Test
    @DisplayName("Debe actualizar usuario exitosamente")
    void testUpdateUser_Success() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        UserResponse result = userService.updateUser(1L, updateUserRequest);

        // Then
        assertNotNull(result);
        verify(userRepository).findById(1L);
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("Debe desactivar usuario exitosamente")
    void testDeactivateUser_Success() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        UserResponse result = userService.deactivateUser(1L);

        // Then
        assertNotNull(result);
        verify(userRepository).findById(1L);
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("Debe activar usuario exitosamente")
    void testActivateUser_Success() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        UserResponse result = userService.activateUser(1L);

        // Then
        assertNotNull(result);
        verify(userRepository).findById(1L);
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("Debe eliminar usuario exitosamente")
    void testDeleteUser_Success() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));

        // When
        userService.deleteUser(1L);

        // Then
        verify(userRepository).findById(1L);
        verify(userRepository).delete(testUser);
    }

    @Test
    @DisplayName("Debe verificar si username existe")
    void testExistsByUsername() {
        // Given
        when(userRepository.existsByUsername("admin")).thenReturn(true);

        // When
        boolean result = userService.existsByUsername("admin");

        // Then
        assertTrue(result);
        verify(userRepository).existsByUsername("admin");
    }

    @Test
    @DisplayName("Debe verificar si email existe")
    void testExistsByEmail() {
        // Given
        when(userRepository.existsByEmail("admin@gym.com")).thenReturn(true);

        // When
        boolean result = userService.existsByEmail("admin@gym.com");

        // Then
        assertTrue(result);
        verify(userRepository).existsByEmail("admin@gym.com");
    }
} 