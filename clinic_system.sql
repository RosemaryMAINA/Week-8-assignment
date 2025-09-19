-- clinic_system.sql
-- Clinic Booking System
-- MySQL schema: creates database and all tables with constraints
-- Save and run: mysql -u root -p < clinic_system.sql
-- or run within MySQL client: SOURCE /path/to/clinic_system.sql;

CREATE DATABASE clinic_db CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci;
USE clinic_db;
-- ----------------------------
-- Table: patients
-- ----------------------------
CREATE TABLE patients (
  patient_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  date_of_birth DATE NOT NULL,
  gender ENUM('female','male','other','prefer_not_say') DEFAULT 'prefer_not_say',
  phone VARCHAR(20),
  email VARCHAR(255),
  address VARCHAR(512),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (patient_id),
  UNIQUE (email),
  INDEX idx_patient_name (last_name, first_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insurances (master list)
CREATE TABLE insurances (
  insurance_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  provider_name VARCHAR(200) NOT NULL,
  contact_phone VARCHAR(50),
  policy_url VARCHAR(512),
  PRIMARY KEY (insurance_id),
  UNIQUE (provider_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Patient <-> Insurance (many-to-many)
CREATE TABLE patient_insurances (
  patient_id INT UNSIGNED NOT NULL,
  insurance_id INT UNSIGNED NOT NULL,
  policy_number VARCHAR(100),
  coverage_start DATE,
  coverage_end DATE,
  PRIMARY KEY (patient_id, insurance_id),
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (insurance_id) REFERENCES insurances(insurance_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Doctors
CREATE TABLE doctors (
  doctor_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  license_number VARCHAR(100) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(20),
  bio TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (doctor_id),
  UNIQUE (license_number),
  UNIQUE (email),
  INDEX idx_doctor_name (last_name, first_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Specialties
CREATE TABLE specialties (
  specialty_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  description VARCHAR(512),
  PRIMARY KEY (specialty_id),
  UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Doctor <-> Specialty (many-to-many)
CREATE TABLE doctor_specialties (
  doctor_id INT UNSIGNED NOT NULL,
  specialty_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (doctor_id, specialty_id),
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Rooms
CREATE TABLE rooms (
  room_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(50) NOT NULL,
  name VARCHAR(150),
  capacity INT UNSIGNED DEFAULT 1,
  location VARCHAR(255),
  PRIMARY KEY (room_id),
  UNIQUE (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Appointments
CREATE TABLE appointments (
  appointment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  patient_id INT UNSIGNED NOT NULL,
  doctor_id INT UNSIGNED NOT NULL,
  room_id INT UNSIGNED,
  appointment_datetime DATETIME NOT NULL,
  duration_minutes INT UNSIGNED NOT NULL DEFAULT 30,
  status ENUM('scheduled','checked_in','in_progress','completed','cancelled','no_show') NOT NULL DEFAULT 'scheduled',
  reason VARCHAR(512),
  created_by VARCHAR(100),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (appointment_id),
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (room_id) REFERENCES rooms(room_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  UNIQUE KEY uq_doctor_datetime (doctor_id, appointment_datetime),
  UNIQUE KEY uq_patient_datetime (patient_id, appointment_datetime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Payments
CREATE TABLE payments (
  payment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  appointment_id INT UNSIGNED NOT NULL,
  amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  method ENUM('cash','card','insurance','mobile_money','other') DEFAULT 'cash',
  reference VARCHAR(255),
  paid_at DATETIME DEFAULT NULL,
  status ENUM('pending','paid','refunded','failed') DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (payment_id),
  FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_payment_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Prescriptions
CREATE TABLE prescriptions (
  prescription_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  appointment_id INT UNSIGNED NOT NULL,
  patient_id INT UNSIGNED NOT NULL,
  doctor_id INT UNSIGNED NOT NULL,
  notes TEXT,
  issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (prescription_id),
  FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Medications master list
CREATE TABLE medications (
  medication_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(200) NOT NULL,
  generic_name VARCHAR(200),
  form VARCHAR(100),
  strength VARCHAR(100),
  instructions TEXT,
  PRIMARY KEY (medication_id),
  UNIQUE (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Prescription items
CREATE TABLE prescription_items (
  prescription_id INT UNSIGNED NOT NULL,
  medication_id INT UNSIGNED NOT NULL,
  dosage VARCHAR(100) NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  notes VARCHAR(512),
  PRIMARY KEY (prescription_id, medication_id),
  FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (medication_id) REFERENCES medications(medication_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Medical records
CREATE TABLE medical_records (
  record_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  patient_id INT UNSIGNED NOT NULL,
  doctor_id INT UNSIGNED,
  appointment_id INT UNSIGNED,
  title VARCHAR(255),
  content TEXT,
  record_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (record_id),
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Helpful indexes
CREATE INDEX idx_appointment_datetime ON appointments (appointment_datetime);
CREATE INDEX idx_prescription_issued_at ON prescriptions (issued_at);