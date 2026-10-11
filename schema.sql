-- =======================================================
-- StudyHub Database Schema & Initial Data
-- Compatible with MySQL 8.0+ / Azure Database for MySQL
-- =======================================================

CREATE DATABASE IF NOT EXISTS studyhub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE studyhub;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(191) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Notes Table (Supports Azure Blob Storage & Local Storage)
CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    subject VARCHAR(150) NOT NULL,
    description TEXT,
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    blob_name VARCHAR(500) NOT NULL,
    blob_url VARCHAR(1000) NULL,
    file_size INT DEFAULT 0,
    downloads INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_subject (subject),
    INDEX idx_user (user_id),
    CONSTRAINT fk_notes_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Contact Messages Table
CREATE TABLE IF NOT EXISTS contact_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(191) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================================================
-- Seed Initial Demo User (Password: demo123)
-- Hash generated via bcrypt (10 rounds)
-- =======================================================
INSERT INTO users (id, full_name, email, password, role) 
VALUES (1, 'Demo Student', 'student@studyhub.com', '$2a$10$wJtFqXW2wJ0Ea6aH5N7jveGzYj58wV1a4D8uWz7wW2r7oB8rL4Zeq', 'student')
ON DUPLICATE KEY UPDATE id=id;

-- Seed Sample Notes
INSERT INTO notes (id, user_id, title, subject, description, file_name, file_type, blob_name, downloads)
VALUES 
(1, 1, 'Cloud Architecture & IaaS Fundamentals', 'Cloud Computing', 'Comprehensive notes on Infrastructure as a Service, Virtualization, and Azure basics.', 'cloud_architecture_unit1.pdf', 'pdf', 'sample-cloud-notes.pdf', 14),
(2, 1, 'REST API Design with Express & Node', 'Full Stack Development', 'Guide to designing RESTful endpoints, middleware, authentication, and error handling.', 'rest_api_guide.docx', 'docx', 'sample-api-notes.docx', 28),
(3, 1, 'UI Design Principles & Color Theory', 'UI / UX', 'Design system fundamentals, typography scale, responsive grids, and accessibility.', 'ui_ux_principles.pptx', 'pptx', 'sample-uiux-notes.pptx', 9),
(4, 1, 'TCP/IP Protocol Suite & HTTP/3 Overview', 'Internet Technologies', 'In-depth notes on transport layer protocols, sockets, and web architecture.', 'internet_technologies_unit2.pdf', 'pdf', 'sample-network-notes.pdf', 19)
ON DUPLICATE KEY UPDATE id=id;
