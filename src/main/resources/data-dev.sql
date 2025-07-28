-- Datos iniciales para desarrollo

-- Insertar usuarios por defecto
INSERT INTO users (username, email, password, first_name, last_name, role, is_active, created_at, updated_at) 
VALUES 
('admin', 'admin@gym.com', '$2a$12$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Admin', 'User', 'ADMIN', true, NOW(), NOW()),
('manager', 'manager@gym.com', '$2a$12$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Manager', 'User', 'MANAGER', true, NOW(), NOW()),
('receptionist', 'receptionist@gym.com', '$2a$12$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'Receptionist', 'User', 'RECEPTIONIST', true, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- Insertar algunos miembros de ejemplo
INSERT INTO members (first_name, last_name, email, phone, date_of_birth, gender, address, emergency_contact, emergency_phone, membership_type, start_date, end_date, notes, is_active, created_at, updated_at) 
VALUES 
('Juan', 'Pérez', 'juan.perez@email.com', '+56987654321', '1990-05-15', 'MALE', 'Av. Providencia 1234', 'María Pérez', '+56912345678', 'BASIC', '2024-01-01', '2024-12-31', 'Cliente nuevo', true, NOW(), NOW()),
('Ana', 'García', 'ana.garcia@email.com', '+56912345678', '1985-08-22', 'FEMALE', 'Las Condes 5678', 'Carlos García', '+56987654321', 'PREMIUM', '2024-01-01', '2024-12-31', 'Cliente premium', true, NOW(), NOW()),
('Carlos', 'López', 'carlos.lopez@email.com', '+56955555555', '1992-12-10', 'MALE', 'Ñuñoa 9012', 'Laura López', '+56944444444', 'VIP', '2024-01-01', '2024-12-31', 'Cliente VIP', true, NOW(), NOW())
ON DUPLICATE KEY UPDATE updated_at = NOW(); 