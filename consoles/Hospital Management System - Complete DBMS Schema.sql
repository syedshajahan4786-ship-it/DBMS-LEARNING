-- connection: 6ae2bc4d1c1a39f2ed432423

-- ============================================================
-- HOSPITAL MANAGEMENT SYSTEM - COMPLETE DBMS PROGRAM
-- Entities: Staff (Supertype), Doctor, Nurse, Administrative_Staff
--           (Subtypes), Patient, Medical_Record (Weak Entity),
--           Department, Appointment, Treatment
-- Specialization: Staff → Doctor, Nurse, Administrative_Staff
--                 (Disjoint, Total)
-- Weak Entity: Medical_Record (depends on Patient)
-- ============================================================

-- ============================================================
-- STEP 1: CREATE TABLES (in dependency order)
-- ============================================================

-- 1. DEPARTMENT
CREATE TABLE Department (
    Department_ID       INT PRIMARY KEY,
    Department_Name     VARCHAR(50) NOT NULL UNIQUE,
    Location            VARCHAR(100) NOT NULL,
    Head_Of_Dept        VARCHAR(50),
    Phone               VARCHAR(15)
);

-- 2. STAFF (Supertype)
--    Common attributes inherited by Doctor, Nurse, Administrative_Staff
CREATE TABLE Staff (
    Staff_ID        INT PRIMARY KEY,
    Staff_Name      VARCHAR(50) NOT NULL,
    Address         VARCHAR(200) NOT NULL,
    Phone           VARCHAR(15) NOT NULL,
    Salary          DECIMAL(10, 2) NOT NULL CHECK (Salary > 0)
);

-- 3. DOCTOR (Subtype of Staff)
--    Inherits: Staff_ID (PK), Staff_Name, Address, Phone, Salary
--    Own attributes: Specialization, License_Number
CREATE TABLE Doctor (
    Staff_ID            INT PRIMARY KEY,
    Specialization      VARCHAR(50) NOT NULL,
    License_Number      VARCHAR(30) NOT NULL UNIQUE,
    Department_ID       INT NOT NULL,
    -- FK to Staff (enforces total + disjoint specialization)
    CONSTRAINT FK_Doctor_Staff FOREIGN KEY (Staff_ID)
        REFERENCES Staff (Staff_ID)
        ON DELETE CASCADE,
    -- FK to Department
    CONSTRAINT FK_Doctor_Department FOREIGN KEY (Department_ID)
        REFERENCES Department (Department_ID)
        ON DELETE CASCADE
);

-- 4. NURSE (Subtype of Staff)
--    Inherits: Staff_ID (PK), Staff_Name, Address, Phone, Salary
--    Own attributes: Qualification, Shift
CREATE TABLE Nurse (
    Staff_ID            INT PRIMARY KEY,
    Qualification       VARCHAR(50) NOT NULL,
    Shift               VARCHAR(20) NOT NULL CHECK (Shift IN ('Morning', 'Afternoon', 'Night', 'Rotating')),
    Department_ID       INT NOT NULL,
    -- FK to Staff (enforces total + disjoint specialization)
    CONSTRAINT FK_Nurse_Staff FOREIGN KEY (Staff_ID)
        REFERENCES Staff (Staff_ID)
        ON DELETE CASCADE,
    -- FK to Department
    CONSTRAINT FK_Nurse_Department FOREIGN KEY (Department_ID)
        REFERENCES Department (Department_ID)
        ON DELETE CASCADE
);

-- 5. ADMINISTRATIVE_STAFF (Subtype of Staff)
--    Inherits: Staff_ID (PK), Staff_Name, Address, Phone, Salary
--    Own attributes: Role, Office_Location
CREATE TABLE Administrative_Staff (
    Staff_ID            INT PRIMARY KEY,
    Role                VARCHAR(50) NOT NULL,
    Office_Location     VARCHAR(100) NOT NULL,
    -- FK to Staff (enforces total + disjoint specialization)
    CONSTRAINT FK_Admin_Staff FOREIGN KEY (Staff_ID)
        REFERENCES Staff (Staff_ID)
        ON DELETE CASCADE
);

-- 6. PATIENT (Strong Entity)
CREATE TABLE Patient (
    Patient_ID          INT PRIMARY KEY,
    Patient_Name        VARCHAR(50) NOT NULL,
    Date_of_Birth       DATE NOT NULL,
    Gender              VARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female', 'Other')),
    Contact_Number      VARCHAR(15) NOT NULL,
    Address             VARCHAR(200) NOT NULL,
    Blood_Group         VARCHAR(5)
);

-- 7. MEDICAL_RECORD (WEAK ENTITY)
--    Depends on Patient for identification
--    Partial Key: Record_Seq (unique only within a Patient)
--    Composite PK: (Patient_ID, Record_Seq)
--    Identifying Relationship: "Has" between Patient and Medical_Record
CREATE TABLE Medical_Record (
    Patient_ID          INT NOT NULL,
    Record_Seq          INT NOT NULL,       -- PARTIAL KEY (discriminator)
    Record_Date         DATE NOT NULL DEFAULT CURRENT_DATE,
    Diagnosis           VARCHAR(300) NOT NULL,
    Treatment_Details   VARCHAR(500) NOT NULL,
    Prescribed_Medicines VARCHAR(300),
    -- Composite Primary Key (Patient_ID + Partial Key)
    PRIMARY KEY (Patient_ID, Record_Seq),
    -- Identifying relationship FK to Patient
    CONSTRAINT FK_MedRec_Patient FOREIGN KEY (Patient_ID)
        REFERENCES Patient (Patient_ID)
        ON DELETE CASCADE
);

-- 8. APPOINTMENT (Associative Entity: Doctor ↔ Patient)
CREATE TABLE Appointment (
    Appointment_ID      INT PRIMARY KEY,
    Appointment_Date    DATE NOT NULL,
    Appointment_Time    TIME NOT NULL,
    Status              VARCHAR(20) NOT NULL CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show')),
    Reason              VARCHAR(200),
    Staff_ID            INT NOT NULL,       -- Doctor (references Staff)
    Patient_ID          INT NOT NULL,
    CONSTRAINT FK_Appt_Doctor FOREIGN KEY (Staff_ID)
        REFERENCES Doctor (Staff_ID)
        ON DELETE CASCADE,
    CONSTRAINT FK_Appt_Patient FOREIGN KEY (Patient_ID)
        REFERENCES Patient (Patient_ID)
        ON DELETE CASCADE
);

-- 9. TREATMENT (Doctor provides treatment to Patient)
CREATE TABLE Treatment (
    Treatment_ID        INT PRIMARY KEY,
    Treatment_Date      DATE NOT NULL DEFAULT CURRENT_DATE,
    Procedure_Name      VARCHAR(100) NOT NULL,
    Notes               VARCHAR(500),
    Cost                DECIMAL(10, 2) CHECK (Cost >= 0),
    Staff_ID            INT NOT NULL,       -- Doctor who provided treatment
    Patient_ID          INT NOT NULL,
    CONSTRAINT FK_Treat_Doctor FOREIGN KEY (Staff_ID)
        REFERENCES Doctor (Staff_ID)
        ON DELETE CASCADE,
    CONSTRAINT FK_Treat_Patient FOREIGN KEY (Patient_ID)
        REFERENCES Patient (Patient_ID)
        ON DELETE CASCADE
);

-- ============================================================
-- STEP 2: INSERT SAMPLE DATA
-- ============================================================

-- Departments
INSERT INTO Department (Department_ID, Department_Name, Location, Head_Of_Dept, Phone) VALUES
(10, 'Cardiology',      'Block A, Floor 2', 'Dr. Anil Kapoor',   '011-23450001'),
(20, 'Orthopedics',     'Block B, Floor 1', 'Dr. Sunita Rao',    '011-23450002'),
(30, 'Neurology',       'Block A, Floor 3', 'Dr. Rajesh Menon',  '011-23450003'),
(40, 'Pediatrics',      'Block C, Floor 1', 'Dr. Meena Pillai',  '011-23450004'),
(50, 'General Medicine','Block D, Floor 1', 'Dr. Vikram Desai',  '011-23450005');

-- Staff (Supertype - all hospital staff members)
INSERT INTO Staff (Staff_ID, Staff_Name, Address, Phone, Salary) VALUES
-- Doctors
(1001, 'Dr. Anil Kapoor',    '12 Residency Road, Delhi',   '9876543201', 150000.00),
(1002, 'Dr. Sunita Rao',     '45 Civil Lines, Delhi',      '9876543202', 140000.00),
(1003, 'Dr. Rajesh Menon',   '78 Park Avenue, Delhi',      '9876543203', 160000.00),
(1004, 'Dr. Meena Pillai',   '34 Garden View, Delhi',      '9876543204', 135000.00),
(1005, 'Dr. Vikram Desai',   '56 Lake Road, Delhi',        '9876543205', 130000.00),
-- Nurses
(2001, 'Nurse Priya Sharma',  '22 MG Road, Delhi',         '9123456701',  55000.00),
(2002, 'Nurse Kavitha Nair',  '88 Station Road, Delhi',    '9123456702',  52000.00),
(2003, 'Nurse Rani Verma',    '15 Temple Street, Delhi',   '9123456703',  58000.00),
(2004, 'Nurse Deepa Joshi',   '67 Market Lane, Delhi',     '9123456704',  50000.00),
-- Administrative Staff
(3001, 'Ramesh Gupta',        '90 Bus Stand Road, Delhi',  '9988776601',  45000.00),
(3002, 'Sita Lakshmi',        '33 Church Street, Delhi',   '9988776602',  42000.00),
(3003, 'Mohan Das',           '44 School Road, Delhi',     '9988776603',  40000.00);

-- Doctor (Subtype) - inherits Staff attributes, adds Specialization, License_Number
INSERT INTO Doctor (Staff_ID, Specialization, License_Number, Department_ID) VALUES
(1001, 'Cardiologist',       'MH-MCI-2010-4521', 10),
(1002, 'Orthopedic Surgeon', 'MH-MCI-2012-3847', 20),
(1003, 'Neurologist',        'MH-MCI-2008-6193', 30),
(1004, 'Pediatrician',       'MH-MCI-2015-7832', 40),
(1005, 'General Physician',  'MH-MCI-2011-5460', 50);

-- Nurse (Subtype) - inherits Staff attributes, adds Qualification, Shift
INSERT INTO Nurse (Staff_ID, Qualification, Shift, Department_ID) VALUES
(2001, 'BSc Nursing',       'Morning',   10),
(2002, 'GNM',               'Afternoon', 20),
(2003, 'MSc Nursing',       'Night',     30),
(2004, 'BSc Nursing',       'Rotating',  40);

-- Administrative_Staff (Subtype) - inherits Staff attributes, adds Role, Office_Location
INSERT INTO Administrative_Staff (Staff_ID, Role, Office_Location) VALUES
(3001, 'Receptionist',          'Block A, Ground Floor'),
(3002, 'Billing Manager',       'Block B, Ground Floor'),
(3003, 'Records Clerk',         'Block C, Ground Floor');

-- Patients
INSERT INTO Patient (Patient_ID, Patient_Name, Date_of_Birth, Gender, Contact_Number, Address, Blood_Group) VALUES
(5001, 'Amit Patel',     '1985-03-15', 'Male',   '9876500001', '101 Sector 5, Noida',     'B+'),
(5002, 'Sunita Devi',    '1990-07-22', 'Female', '9876500002', '202 Sector 12, Gurgaon',  'A+'),
(5003, 'Rahul Verma',    '1978-11-08', 'Male',   '9876500003', '303 Lajpat Nagar, Delhi', 'O+'),
(5004, 'Priya Singh',    '1995-01-30', 'Female', '9876500004', '404 Dwarka, Delhi',       'AB+'),
(5005, 'Karan Malhotra', '2010-06-18', 'Male',   '9876500005', '505 Rohini, Delhi',       'O-'),
(5006, 'Anita Kumari',   '1988-09-25', 'Female', '9876500006', '606 Saket, Delhi',        'A-');

-- Medical_Record (WEAK ENTITY)
-- Partial Key: Record_Seq (unique only within a patient)
-- Composite PK: (Patient_ID, Record_Seq)
-- Identifying Relationship: Patient "Has" Medical_Record
INSERT INTO Medical_Record (Patient_ID, Record_Seq, Record_Date, Diagnosis, Treatment_Details, Prescribed_Medicines) VALUES
(5001, 1, '2026-09-10', 'Hypertension Stage 2',      'Prescribed medication and lifestyle changes',       'Amlodipine 5mg, Aspirin 75mg'),
(5001, 2, '2026-10-15', 'Follow-up: BP controlled',   'Continued medication, advised regular exercise',    'Amlodipine 5mg'),
(5002, 1, '2026-08-20', 'Fracture - Right Arm',       'Cast applied, pain management prescribed',          'Ibuprofen 400mg, Calcium supplements'),
(5002, 2, '2026-09-25', 'Cast removal and rehab',     'Cast removed, physiotherapy recommended',           'Calcium + Vitamin D3'),
(5003, 1, '2026-07-05', 'Migraine with Aura',         'MRI scan normal, prescribed preventive medication', 'Sumatriptan 50mg, Propranolol 40mg'),
(5004, 1, '2026-10-01', 'Pregnancy - First Trimester','Prenatal vitamins prescribed, scheduled follow-up', 'Folic Acid 5mg, Iron supplements'),
(5005, 1, '2026-09-15', 'Viral Fever',                'Rest and hydration advised, antipyretics given',    'Paracetamol 500mg'),
(5005, 2, '2026-10-20', 'Asthma - Mild Persistent',   'Inhaler prescribed, trigger avoidance advised',     'Salbutamol Inhaler, Montelukast 4mg'),
(5006, 1, '2026-10-08', 'Anemia (Iron Deficiency)',   'Iron supplements and dietary changes recommended',  'Ferrous Sulphate 200mg, Vitamin C');

-- Appointments (Doctor ↔ Patient)
INSERT INTO Appointment (Appointment_ID, Appointment_Date, Appointment_Time, Status, Reason, Staff_ID, Patient_ID) VALUES
(4001, '2026-09-10', '09:00:00', 'Completed', 'Chest pain and high BP',           1001, 5001),
(4002, '2026-10-15', '10:30:00', 'Completed', 'BP follow-up check',               1001, 5001),
(4003, '2026-08-20', '11:00:00', 'Completed', 'Arm injury after fall',            1002, 5002),
(4004, '2026-09-25', '14:00:00', 'Completed', 'Cast removal',                     1002, 5002),
(4005, '2026-07-05', '09:30:00', 'Completed', 'Severe headache and vision issues', 1003, 5003),
(4006, '2026-10-01', '10:00:00', 'Completed', 'Pregnancy consultation',           1004, 5004),
(4007, '2026-09-15', '15:00:00', 'Completed', 'High fever for 3 days',            1004, 5005),
(4008, '2026-10-20', '16:00:00', 'Scheduled', 'Breathing difficulty',              1004, 5005),
(4009, '2026-10-08', '11:30:00', 'Completed', 'Fatigue and dizziness',            1005, 5006),
(4010, '2026-11-01', '09:00:00', 'Scheduled', 'Annual heart checkup',             1001, 5003);

-- Treatments (Doctor provides treatment to Patient)
INSERT INTO Treatment (Treatment_ID, Treatment_Date, Procedure_Name, Notes, Cost, Staff_ID, Patient_ID) VALUES
(6001, '2026-09-10', 'ECG and Blood Test',       'ECG normal, blood pressure elevated',           2500.00, 1001, 5001),
(6002, '2026-08-20', 'X-Ray and Cast Application','Fracture confirmed, plaster cast applied',      5000.00, 1002, 5002),
(6003, '2026-09-25', 'Cast Removal',              'Healing complete, physiotherapy advised',        1500.00, 1002, 5002),
(6004, '2026-07-05', 'MRI Brain Scan',            'No abnormalities detected',                     8000.00, 1003, 5003),
(6005, '2026-10-01', 'Prenatal Checkup',          'Ultrasound normal, all vitals stable',           3000.00, 1004, 5004),
(6006, '2026-09-15', 'General Consultation',      'Viral infection confirmed via blood test',       1000.00, 1004, 5005),
(6007, '2026-10-08', 'Complete Blood Count',      'Low hemoglobin confirmed',                      1200.00, 1005, 5006);

-- ============================================================
-- STEP 3: QUERIES TO DISPLAY DATA
-- ============================================================

-- Query 1: All staff with their subtype classification
-- (Shows specialization: Staff → Doctor / Nurse / Admin_Staff)
SELECT
    s.Staff_ID,
    s.Staff_Name,
    s.Phone,
    s.Salary,
    CASE
        WHEN d.Staff_ID IS NOT NULL THEN 'Doctor'
        WHEN n.Staff_ID IS NOT NULL THEN 'Nurse'
        WHEN a.Staff_ID IS NOT NULL THEN 'Administrative_Staff'
        ELSE 'Unknown'
    END AS Staff_Type
FROM Staff s
LEFT JOIN Doctor d ON s.Staff_ID = d.Staff_ID
LEFT JOIN Nurse n ON s.Staff_ID = n.Staff_ID
LEFT JOIN Administrative_Staff a ON s.Staff_ID = a.Staff_ID
ORDER BY Staff_Type, s.Staff_ID;

-- Query 2: Doctors with inherited Staff attributes + own attributes + Department
-- (Shows inheritance from Staff supertype)
SELECT
    d.Staff_ID,
    s.Staff_Name,
    s.Address,
    s.Phone,
    s.Salary,
    d.Specialization,
    d.License_Number,
    dep.Department_Name,
    dep.Location AS Dept_Location
FROM Doctor d
JOIN Staff s ON d.Staff_ID = s.Staff_ID
JOIN Department dep ON d.Department_ID = dep.Department_ID
ORDER BY d.Staff_ID;

-- Query 3: Nurses with inherited Staff attributes + own attributes
-- (Shows inheritance from Staff supertype)
SELECT
    n.Staff_ID,
    s.Staff_Name,
    s.Address,
    s.Phone,
    s.Salary,
    n.Qualification,
    n.Shift,
    dep.Department_Name
FROM Nurse n
JOIN Staff s ON n.Staff_ID = s.Staff_ID
JOIN Department dep ON n.Department_ID = dep.Department_ID
ORDER BY n.Staff_ID;

-- Query 4: Administrative Staff with inherited + own attributes
SELECT
    a.Staff_ID,
    s.Staff_Name,
    s.Phone,
    s.Salary,
    a.Role,
    a.Office_Location
FROM Administrative_Staff a
JOIN Staff s ON a.Staff_ID = s.Staff_ID
ORDER BY a.Staff_ID;

-- Query 5: WEAK ENTITY query - Medical Records with Patient info
-- (Shows identifying relationship: Patient "Has" Medical_Record)
-- Medical_Record cannot exist without Patient (partial key + FK)
SELECT
    mr.Patient_ID,
    mr.Record_Seq AS "Partial_Key",
    p.Patient_Name,
    p.Gender,
    mr.Record_Date,
    mr.Diagnosis,
    mr.Treatment_Details,
    mr.Prescribed_Medicines
FROM Medical_Record mr
JOIN Patient p ON mr.Patient_ID = p.Patient_ID
ORDER BY mr.Patient_ID, mr.Record_Seq;

-- Query 6: Appointments with Doctor and Patient details
-- (Shows Doctor ↔ Patient relationship through Appointment)
SELECT
    a.Appointment_ID,
    a.Appointment_Date,
    a.Appointment_Time,
    a.Status,
    a.Reason,
    s.Staff_Name AS Doctor_Name,
    d.Specialization,
    p.Patient_Name,
    p.Gender
FROM Appointment a
JOIN Doctor d ON a.Staff_ID = d.Staff_ID
JOIN Staff s ON d.Staff_ID = s.Staff_ID
JOIN Patient p ON a.Patient_ID = p.Patient_ID
ORDER BY a.Appointment_Date, a.Appointment_Time;

-- Query 7: Treatments with Doctor, Patient, and Department
-- (Shows Doctor provides Treatment to Patient)
SELECT
    t.Treatment_ID,
    t.Treatment_Date,
    t.Procedure_Name,
    t.Cost,
    s.Staff_Name AS Doctor_Name,
    d.Specialization,
    dep.Department_Name,
    p.Patient_Name
FROM Treatment t
JOIN Doctor d ON t.Staff_ID = d.Staff_ID
JOIN Staff s ON d.Staff_ID = s.Staff_ID
JOIN Department dep ON d.Department_ID = dep.Department_ID
JOIN Patient p ON t.Patient_ID = p.Patient_ID
ORDER BY t.Treatment_Date DESC;

-- Query 8: Department-wise staff count (doctors + nurses)
SELECT
    dep.Department_Name,
    dep.Location,
    COUNT(DISTINCT d.Staff_ID) AS Total_Doctors,
    COUNT(DISTINCT n.Staff_ID) AS Total_Nurses
FROM Department dep
LEFT JOIN Doctor d ON dep.Department_ID = d.Department_ID
LEFT JOIN Nurse n ON dep.Department_ID = n.Department_ID
GROUP BY dep.Department_Name, dep.Location
ORDER BY dep.Department_ID;

-- Query 9: Patient visit summary (appointments + treatments + medical records)
SELECT
    p.Patient_ID,
    p.Patient_Name,
    p.Gender,
    p.Blood_Group,
    COUNT(DISTINCT a.Appointment_ID) AS Total_Appointments,
    COUNT(DISTINCT t.Treatment_ID) AS Total_Treatments,
    COUNT(DISTINCT CONCAT(mr.Patient_ID, '-', mr.Record_Seq)) AS Total_Medical_Records,
    COALESCE(SUM(t.Cost), 0) AS Total_Treatment_Cost
FROM Patient p
LEFT JOIN Appointment a ON p.Patient_ID = a.Patient_ID
LEFT JOIN Treatment t ON p.Patient_ID = t.Patient_ID
LEFT JOIN Medical_Record mr ON p.Patient_ID = mr.Patient_ID
GROUP BY p.Patient_ID, p.Patient_Name, p.Gender, p.Blood_Group
ORDER BY p.Patient_ID;

-- ============================================================
-- CLEANUP (uncomment to drop all tables in reverse dependency)
-- ============================================================
-- DROP TABLE IF EXISTS Treatment;
-- DROP TABLE IF EXISTS Appointment;
-- DROP TABLE IF EXISTS Medical_Record;
-- DROP TABLE IF EXISTS Administrative_Staff;
-- DROP TABLE IF EXISTS Nurse;
-- DROP TABLE IF EXISTS Doctor;
-- DROP TABLE IF EXISTS Patient;
-- DROP TABLE IF EXISTS Staff;
-- DROP TABLE IF EXISTS Department;
