package com.gym_management.system.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // Desactivar CSRF para APIs REST
            .csrf(csrf -> csrf.disable())
            
            // Configurar autorización - permitir todo públicamente por ahora
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/**").permitAll()           // Todos los endpoints de la API
                .requestMatchers("/h2-console/**").permitAll()    // Consola H2
                .requestMatchers("/actuator/**").permitAll()      // Actuator endpoints
                .anyRequest().permitAll()                         // Cualquier otra petición
            )
            
            // Configurar sesiones como stateless (para APIs REST)
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            
            // Permitir frames para la consola H2
            .headers(headers -> headers
                .frameOptions().disable()
            );

        return http.build();
    }
} 