# Week-8-assignment

# Clinic Booking System Database

This project contains a MySQL database schema for a Clinic Booking System.  
It helps manage patients, doctors, appointments, prescriptions, payments, and medical records.

---

## 📂 Files in This Repository
- **clinic_system.sql** – Main SQL script that:
  - Creates the database (`clinic_db`)
  - Creates all tables with primary and foreign keys
  - Adds indexes for faster lookups

---

## 🏥 Use Case
The database is designed for a clinic to:
- Register patients and doctors
- Store insurance information for patients
- Schedule appointments with doctors in specific rooms
- Record payments for services
- Issue and track prescriptions and medications
- Maintain medical records for patients

---

## 🛠️ How to Run the SQL Script

Using MySQL Command Line
```bash
mysql -u root -p < clinic_system.sql
