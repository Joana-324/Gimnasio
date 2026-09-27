-- =============================================================================
-- SCRIPT DE CREACIÓN DE BASE DE DATOS - GIMNASIO TFI (MySQL 8.0)
-- Ubicación en Repositorio: /database/schema.sql
-- Incluye Soporte para Borrado Lógico (Soft Delete)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS gimnasio_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE gimnasio_db;

-- -----------------------------------------------------------------------------
-- 1. MÓDULO DE USUARIOS Y ROLES
-- -----------------------------------------------------------------------------

CREATE TABLE Roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
) ENGINE=InnoDB;

INSERT INTO Roles (nombre, descripcion) VALUES
('Administrador', 'Acceso total a gestión de usuarios, suscripciones y reportes'),
('Instructor', 'Creación y asignación de rutinas y ejercicios'),
('Cliente', 'Consulta de rutinas y estado de cuenta desde interfaz web/móvil');

CREATE TABLE Usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(30),
    fecha_nacimiento DATE NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    eliminado BOOLEAN DEFAULT FALSE,
    INDEX idx_dni (dni),
    INDEX idx_email (email),
    INDEX idx_eliminado (eliminado)
) ENGINE=InnoDB;

CREATE TABLE Usuario_Roles (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    PRIMARY KEY (id_usuario, id_rol),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_rol) REFERENCES Roles(id_rol) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2. MÓDULO DE ACTIVIDADES, SUSCRIPCIONES Y PAGOS
-- -----------------------------------------------------------------------------

CREATE TABLE Actividades (
    id_actividad INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    requiere_reserva BOOLEAN DEFAULT FALSE,
    eliminado BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB;

CREATE TABLE Horarios_Actividad (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    id_actividad INT NOT NULL,
    dia_semana ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado') NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    cupo_maximo INT DEFAULT 15,
    id_instructor INT,
    eliminado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_actividad) REFERENCES Actividades(id_actividad) ON DELETE CASCADE,
    FOREIGN KEY (id_instructor) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE Tipos_Suscripcion (
    id_tipo_suscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_actividad INT,
    nombre VARCHAR(100) NOT NULL,
    modalidad ENUM('Pase Libre', 'Por Créditos', 'Clases Semanales') NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    duracion_dias INT NOT NULL DEFAULT 30,
    creditos_incluidos INT DEFAULT NULL,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    eliminado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_actividad) REFERENCES Actividades(id_actividad) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE Suscripciones_Usuario (
    id_suscripcion_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_tipo_suscripcion INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    creditos_restantes INT DEFAULT NULL,
    estado ENUM('Activa', 'Vencida', 'Agotada', 'Cancelada') DEFAULT 'Activa',
    eliminado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_tipo_suscripcion) REFERENCES Tipos_Suscripcion(id_tipo_suscripcion),
    INDEX idx_usuario_estado (id_usuario, estado, eliminado)
) ENGINE=InnoDB;

CREATE TABLE Pagos (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_suscripcion_usuario INT NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    metodo_pago ENUM('Efectivo', 'Transferencia', 'MercadoPago', 'Tarjeta') NOT NULL,
    comprobante_ref VARCHAR(100),
    FOREIGN KEY (id_suscripcion_usuario) REFERENCES Suscripciones_Usuario(id_suscripcion_usuario)
) ENGINE=InnoDB;

CREATE TABLE Asistencias (
    id_asistencia INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_suscripcion_usuario INT,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    resultado_ingreso ENUM('Permitido', 'Denegado_Impago', 'Denegado_SinCreditos', 'Denegado_Inexistente') NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_suscripcion_usuario) REFERENCES Suscripciones_Usuario(id_suscripcion_usuario) ON DELETE SET NULL,
    INDEX idx_fecha (fecha_hora)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. MÓDULO DE EJERCICIOS Y RUTINAS
-- -----------------------------------------------------------------------------

CREATE TABLE Ejercicios (
    id_ejercicio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL UNIQUE,
    grupo_muscular ENUM('Pecho', 'Espalda', 'Pierna', 'Hombros', 'Bíceps', 'Tríceps', 'Abdomen', 'Cardio', 'FullBody') NOT NULL,
    descripcion TEXT,
    url_imagen_video VARCHAR(255),
    eliminado BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB;

CREATE TABLE Rutinas (
    id_rutina INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    descripcion TEXT,
    es_plantilla BOOLEAN DEFAULT FALSE,
    id_instructor_creador INT NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    eliminado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_instructor_creador) REFERENCES Usuarios(id_usuario)
) ENGINE=InnoDB;

CREATE TABLE Rutina_Ejercicios (
    id_rutina_ejercicio INT AUTO_INCREMENT PRIMARY KEY,
    id_rutina INT NOT NULL,
    id_ejercicio INT NOT NULL,
    numero_dia INT NOT NULL DEFAULT 1,
    orden INT NOT NULL DEFAULT 1,
    series INT NOT NULL DEFAULT 3,
    repeticiones VARCHAR(50) NOT NULL DEFAULT '10-12',
    descanso_segundos INT DEFAULT 60,
    observaciones VARCHAR(255),
    FOREIGN KEY (id_rutina) REFERENCES Rutinas(id_rutina) ON DELETE CASCADE,
    FOREIGN KEY (id_ejercicio) REFERENCES Ejercicios(id_ejercicio)
) ENGINE=InnoDB;

CREATE TABLE Cliente_Rutinas (
    id_cliente_rutina INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_rutina INT NOT NULL,
    id_instructor INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado ENUM('Activa', 'Finalizada', 'Cancelada') DEFAULT 'Activa',
    eliminado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_cliente) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_rutina) REFERENCES Rutinas(id_rutina),
    FOREIGN KEY (id_instructor) REFERENCES Usuarios(id_usuario)
) ENGINE=InnoDB;
```