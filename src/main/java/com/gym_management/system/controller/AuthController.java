package com.gym_management.system.controller;

import com.gym_management.system.model.dto.*;
import com.gym_management.system.services.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*") // Configurar según necesidades de CORS
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthService authService;

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Auth service is working with JWT!");
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        log.info("POST /api/auth/login - Usuario: {}", request.getUsername());
        
        try {
            AuthResponse response = authService.login(request);
            log.info("Login exitoso para usuario: {}", request.getUsername());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error en login: {}", e.getMessage());
            throw e;
        }
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        log.info("POST /api/auth/register - Usuario: {}", request.getUsername());
        
        try {
            AuthResponse response = authService.register(request);
            log.info("Registro exitoso para usuario: {}", request.getUsername());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error en registro: {}", e.getMessage());
            throw e;
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@RequestBody String refreshToken) {
        log.info("POST /api/auth/refresh");
        
        try {
            AuthResponse response = authService.refreshToken(refreshToken);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error renovando token: {}", e.getMessage());
            throw e;
        }
    }

    @PostMapping("/validate")
    public ResponseEntity<Boolean> validateToken(@RequestBody String token) {
        log.info("POST /api/auth/validate");
        
        try {
            boolean isValid = authService.validateToken(token);
            return ResponseEntity.ok(isValid);
        } catch (Exception e) {
            log.error("Error validando token: {}", e.getMessage());
            return ResponseEntity.ok(false);
        }
    }

    // Mantener endpoints de compatibilidad para form-data (para testing)
    @PostMapping("/login-form")
    public ResponseEntity<AuthResponse> loginForm(
            @RequestParam String username,
            @RequestParam String password) {
        
        log.info("POST /api/auth/login-form - Usuario: {}", username);
        
        LoginRequest request = new LoginRequest();
        request.setUsername(username);
        request.setPassword(password);
        
        return login(request);
    }

    @PostMapping("/validate-form")
    public ResponseEntity<Boolean> validateTokenForm(@RequestParam String token) {
        log.info("POST /api/auth/validate-form");
        return validateToken(token);
    }

    @PostMapping("/encrypt-passwords")
    public ResponseEntity<String> encryptPasswords() {
        log.info("POST /api/auth/encrypt-passwords - Iniciando encriptación");
        
        try {
            authService.encryptExistingPasswords();
            return ResponseEntity.ok("Contraseñas encriptadas exitosamente");
        } catch (Exception e) {
            log.error("Error encriptando contraseñas: {}", e.getMessage());
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }
} 