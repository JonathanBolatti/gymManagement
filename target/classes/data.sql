-- Datos iniciales para Gym Management System
-- Se cargan automáticamente al inicializar la aplicación

INSERT IGNORE INTO members (first_name, last_name, email, phone, birth_date, gender, height, weight, emergency_contact, emergency_phone, is_active, observations, created_at, updated_at) VALUES
('Juan', 'Pérez', 'juan.perez@email.com', '+123456789', '1990-05-15', 'M', 1.75, 75.0, 'María Pérez', '+123456788', true, 'Miembro activo desde hace 2 años', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Ana', 'García', 'ana.garcia@email.com', '+123456790', '1985-08-22', 'F', 1.68, 62.0, 'Luis García', '+123456791', true, 'Interesada en clases de yoga', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Carlos', 'López', 'carlos.lopez@email.com', '+123456792', '1988-12-10', 'M', 1.80, 85.0, 'Carmen López', '+123456793', true, 'Entrena en las mañanas', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('María', 'Rodríguez', 'maria.rodriguez@email.com', '+123456794', '1992-03-18', 'F', 1.65, 58.0, 'Pedro Rodríguez', '+123456795', false, 'Miembro inactivo temporalmente', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('David', 'Martínez', 'david.martinez@email.com', '+123456796', '1995-07-25', 'M', 1.78, 70.0, 'Isabel Martínez', '+123456797', true, 'Le gusta el entrenamiento funcional', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP); 