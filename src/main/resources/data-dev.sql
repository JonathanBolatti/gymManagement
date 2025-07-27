-- Datos de prueba para Members (clientes del gimnasio)
INSERT INTO members (first_name, last_name, email, phone, birth_date, gender, height, weight, emergency_contact, emergency_phone, is_active, observations, created_at, updated_at) VALUES
('Ana', 'García', 'ana.garcia@email.com', '+56912345678', '1990-05-15', 'F', 1.65, 60.5, 'Pedro García', '+56987654321', true, 'Miembro VIP con acceso completo', NOW(), NOW()),
('Carlos', 'López', 'carlos.lopez@email.com', '+56923456789', '1985-03-22', 'M', 1.78, 75.0, 'María López', '+56876543210', true, 'Entrenamiento de fuerza', NOW(), NOW()),
('Sofia', 'Martínez', 'sofia.martinez@email.com', '+56934567890', '1992-11-08', 'F', 1.60, 55.0, 'Juan Martínez', '+56765432109', true, null, NOW(), NOW()),
('Diego', 'Rodríguez', 'diego.rodriguez@email.com', '+56945678901', '1988-07-30', 'M', 1.80, 82.5, 'Carmen Rodríguez', '+56654321098', true, 'Clases de yoga y pilates', NOW(), NOW()),
('Valentina', 'Torres', 'valentina.torres@email.com', '+56956789012', '1995-09-12', 'F', 1.70, 58.0, 'Roberto Torres', '+56543210987', false, 'Suspendida temporalmente', NOW(), NOW());

-- Datos de prueba para Users (empleados/administradores del sistema)
INSERT INTO users (username, email, password, first_name, last_name, phone, role, is_active, last_login, created_at, updated_at) VALUES
('admin', 'admin@gym.com', 'admin123', 'Administrador', 'Sistema', '+56911111111', 'ADMIN', true, NOW(), NOW(), NOW()),
('manager.juan', 'juan.manager@gym.com', 'manager123', 'Juan', 'Pérez', '+56922222222', 'MANAGER', true, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('recep.maria', 'maria.recep@gym.com', 'recep123', 'María', 'González', '+56933333333', 'RECEPTIONIST', true, DATE_SUB(NOW(), INTERVAL 1 DAY), NOW(), NOW()),
('manager.ana', 'ana.manager@gym.com', 'manager123', 'Ana', 'Silva', '+56944444444', 'MANAGER', true, DATE_SUB(NOW(), INTERVAL 3 DAY), NOW(), NOW()),
('recep.carlos', 'carlos.recep@gym.com', 'recep123', 'Carlos', 'Morales', '+56955555555', 'RECEPTIONIST', false, DATE_SUB(NOW(), INTERVAL 10 DAY), NOW(), NOW()); 