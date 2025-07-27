package com.gym_management.system.services.impl;

import com.gym_management.system.exception.DuplicateEmailException;
import com.gym_management.system.exception.DuplicateUsernameException;
import com.gym_management.system.exception.UserNotFoundException;
import com.gym_management.system.model.User;
import com.gym_management.system.model.dto.*;
import com.gym_management.system.repository.UserRepository;
import com.gym_management.system.security.JwtService;
import com.gym_management.system.services.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;

    @Override
    public AuthResponse login(LoginRequest request) {
        log.info("Intentando autenticar usuario: {}", request.getUsername());

        // Autenticar usuario
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        // Obtener usuario de la base de datos
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new UserNotFoundException("username", request.getUsername()));

        // Verificar que el usuario esté activo
        if (!user.getIsActive()) {
            throw new RuntimeException("Usuario inactivo");
        }

        // Crear UserDetails para JWT
        UserDetails userDetails = userDetailsService.loadUserByUsername(request.getUsername());

        // Generar tokens
        String accessToken = jwtService.generateTokenWithRole(userDetails, user.getRole());
        String refreshToken = jwtService.generateRefreshToken(userDetails);

        // Actualizar último login
        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);

        log.info("Usuario autenticado exitosamente: {}", request.getUsername());

        // Crear respuesta
        return createAuthResponse(accessToken, refreshToken, user);
    }

    @Override
    public AuthResponse register(RegisterRequest request) {
        log.info("Registrando nuevo usuario: {}", request.getUsername());

        // Verificar si el username ya existe
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new DuplicateUsernameException(request.getUsername());
        }

        // Verificar si el email ya existe
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException(request.getEmail());
        }

        // Crear nuevo usuario
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setPhone(request.getPhone());
        user.setRole(request.getRole());
        user.setIsActive(true);

        User savedUser = userRepository.save(user);

        // Crear UserDetails para JWT
        UserDetails userDetails = userDetailsService.loadUserByUsername(savedUser.getUsername());

        // Generar tokens
        String accessToken = jwtService.generateTokenWithRole(userDetails, savedUser.getRole());
        String refreshToken = jwtService.generateRefreshToken(userDetails);

        log.info("Usuario registrado exitosamente: {}", request.getUsername());

        // Crear respuesta
        return createAuthResponse(accessToken, refreshToken, savedUser);
    }

    @Override
    public AuthResponse refreshToken(String refreshToken) {
        try {
            // Extraer username del refresh token
            String username = jwtService.extractUsername(refreshToken);
            
            if (username != null) {
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                
                if (jwtService.isTokenValid(refreshToken, userDetails)) {
                    User user = userRepository.findByUsername(username)
                            .orElseThrow(() -> new UserNotFoundException("username", username));
                    
                    // Generar nuevo access token
                    String accessToken = jwtService.generateTokenWithRole(userDetails, user.getRole());
                    
                    log.info("Token renovado para usuario: {}", username);
                    
                    return createAuthResponse(accessToken, refreshToken, user);
                }
            }
        } catch (Exception e) {
            log.error("Error renovando token: {}", e.getMessage());
        }
        
        throw new RuntimeException("Token de renovación inválido");
    }

    @Override
    public boolean validateToken(String token) {
        try {
            String username = jwtService.extractUsername(token);
            if (username != null) {
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                return jwtService.isTokenValid(token, userDetails);
            }
        } catch (Exception e) {
            log.error("Error validando token: {}", e.getMessage());
        }
        return false;
    }

    @Override
    public void encryptExistingPasswords() {
        log.info("Encriptando contraseñas existentes...");
        
        List<User> users = userRepository.findAll();
        
        for (User user : users) {
            String currentPassword = user.getPassword();
            
            // Solo encriptar si la contraseña no está ya encriptada (no comienza con $2a$)
            if (!currentPassword.startsWith("$2a$")) {
                String encryptedPassword = passwordEncoder.encode(currentPassword);
                user.setPassword(encryptedPassword);
                userRepository.save(user);
                log.info("Contraseña encriptada para usuario: {}", user.getUsername());
            } else {
                log.info("Contraseña ya encriptada para usuario: {}", user.getUsername());
            }
        }
        
        log.info("Proceso de encriptación completado");
    }

    private AuthResponse createAuthResponse(String accessToken, String refreshToken, User user) {
        LocalDateTime now = LocalDateTime.now();
        long expirationMs = jwtService.getExpirationTime();
        
        UserResponse userResponse = convertToUserResponse(user);
        
        return AuthResponse.builder()
                .token(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(expirationMs / 1000) // Convertir a segundos
                .user(userResponse)
                .issuedAt(now)
                .expiresAt(now.plusSeconds(expirationMs / 1000))
                .build();
    }

    private UserResponse convertToUserResponse(User user) {
        UserResponse response = new UserResponse();
        response.setId(user.getId());
        response.setUsername(user.getUsername());
        response.setEmail(user.getEmail());
        response.setFirstName(user.getFirstName());
        response.setLastName(user.getLastName());
        response.setPhone(user.getPhone());
        response.setRole(user.getRole());
        response.setIsActive(user.getIsActive());
        response.setLastLogin(user.getLastLogin());
        response.setCreatedAt(user.getCreatedAt());
        response.setUpdatedAt(user.getUpdatedAt());
        return response;
    }
} 