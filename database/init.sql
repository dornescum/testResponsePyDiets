-- Medical Clinic Database Schema
USE medical_clinic;

-- Users table for authentication
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('1', '2', '3', '4') NOT NULL COMMENT '1=admin, 2=doctor, 3=assistant, 4=patient',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Patients table
CREATE TABLE IF NOT EXISTS patients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    date_of_birth DATE,
    address TEXT,
    town VARCHAR(100),
    country VARCHAR(100),
    payment_type TINYINT(1) DEFAULT 0 COMMENT '0=cash, 1=card',
    is_deleted TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Medical records table
CREATE TABLE IF NOT EXISTS medical_records (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    observation TEXT NOT NULL,
    severity ENUM('1', '2', '3') NOT NULL COMMENT '1=low, 2=medium, 3=high',
    diagnosis TEXT,
    treatment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Files table for patient documents
CREATE TABLE IF NOT EXISTS patient_files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    medical_record_id INT,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(100) NOT NULL,
    file_size INT NOT NULL,
    uploaded_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (medical_record_id) REFERENCES medical_records(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Locations table
CREATE TABLE IF NOT EXISTS locations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Appointments table
CREATE TABLE IF NOT EXISTS appointments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    patient_name VARCHAR(255) NOT NULL,
    patient_surname VARCHAR(255) NOT NULL,
    patient_email VARCHAR(255),
    patient_phone VARCHAR(20) NOT NULL,
    doctor_id INT NOT NULL,
    location_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES users(id),
    FOREIGN KEY (location_id) REFERENCES locations(id)
);

-- Sessions table (for express-session)
CREATE TABLE IF NOT EXISTS sessions (
    session_id VARCHAR(128) COLLATE utf8mb4_bin NOT NULL,
    expires INT UNSIGNED NOT NULL,
    data MEDIUMTEXT COLLATE utf8mb4_bin,
    PRIMARY KEY (session_id)
);

-- Medical Visits Table
CREATE TABLE IF NOT EXISTS medical_visits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    visit_type ENUM('first', 'control') NOT NULL,
    visit_date DATE NOT NULL,
    reasons_for_visit TEXT, -- JSON array of strings
    medical_history TEXT, -- JSON array of strings
    family_history TEXT, -- JSON array of strings
    food_preferences TEXT,
    cardio_history TEXT, -- JSON array of strings
    pathological_history TEXT, -- JSON array of strings
    metabolic_history TEXT, -- JSON array of strings
    height DECIMAL(5, 2),
    current_weight DECIMAL(5, 2),
    weight_at_20 DECIMAL(5, 2),
    next_control_visit_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

-- Insert default admin user
INSERT INTO users (name, email, password, role) VALUES 
('Admin User', 'it@clinic.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '1'),
('Doctor', 'doctor@clinic.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '2'),
('Assistant', 'info@clinic.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '3');

-- Insert default location
INSERT INTO locations (name, address) VALUES ('Studio', '123 Main St, City, State');

-- Insert sample patients
INSERT INTO patients (name, surname, phone, email, date_of_birth, address, town, country, payment_type) VALUES 
('John', 'Doe', '123-456-7890', 'john.doe@email.com', '1985-05-15', '123 Main St', 'City', 'State', 0),
('Jane', 'Smith', '234-567-8901', 'jane.smith@email.com', '1990-08-22', '456 Oak Ave', 'City', 'State', 1),
('Bob', 'Johnson', '345-678-9012', 'bob.johnson@email.com', '1978-12-03', '789 Pine Rd', 'City', 'State', 0);

-- Insert sample medical records
INSERT INTO medical_records (patient_id, doctor_id, observation, severity, diagnosis, treatment) VALUES 
(1, 2, 'Regular checkup, patient reports feeling well', '1', 'Healthy', 'Continue current lifestyle'),
(2, 2, 'Patient complains of headaches, blood pressure slightly elevated', '2', 'Hypertension', 'Prescribed medication and lifestyle changes'),
(3, 2, 'Emergency visit, severe chest pain', '3', 'Possible heart condition', 'Immediate tests and monitoring required');