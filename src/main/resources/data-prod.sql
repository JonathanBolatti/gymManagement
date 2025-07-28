-- Datos iniciales para producción

-- Insertar usuarios por defecto
INSERT INTO users (username, email, password, first_name, last_name, role, is_active, created_at, updated_at) 
VALUES 
('admin', 'admin@gym.com', '$2a$12$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Admin', 'User', 'ADMIN', true, NOW(), NOW()),
('manager', 'manager@gym.com', '$2a$12$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Manager', 'User', 'MANAGER', true, NOW(), NOW()),
('receptionist', 'receptionist@gym.com', '$2a$12$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Receptionist', 'User', 'RECEPTIONIST', true, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW(); 