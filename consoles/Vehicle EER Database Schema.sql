-- connection: 6ae2bc4d1c1a39f2ed432423

-- ============================================================
-- VEHICLE EER DATABASE SCHEMA
-- Supertype: Vehicle | Subtypes: Car, Truck
-- Specialization: Disjoint (d), Total
-- ============================================================

-- ============================================================
-- STEP 1: CREATE THE SUPERTYPE TABLE (Vehicle)
-- ============================================================
CREATE TABLE Vehicle (
    Vehicle_ID          INT PRIMARY KEY,
    Registration_Number VARCHAR(20) NOT NULL UNIQUE,
    Manufacturer        VARCHAR(50) NOT NULL,
    Model               VARCHAR(50) NOT NULL,
    Year                INT NOT NULL CHECK (Year >= 1900 AND Year <= 2099),
    Purchase_Price      DECIMAL(10, 2) NOT NULL CHECK (Purchase_Price > 0)
);

-- ============================================================
-- STEP 2: CREATE THE SUBTYPE TABLE (Car)
-- Inherits Vehicle_ID as PK and FK (disjoint + total)
-- ============================================================
CREATE TABLE Car (
    Vehicle_ID       INT PRIMARY KEY,
    Number_of_Doors  INT NOT NULL CHECK (Number_of_Doors > 0),
    Fuel_Type        VARCHAR(20) NOT NULL CHECK (Fuel_Type IN ('Petrol', 'Diesel', 'Electric', 'Hybrid', 'CNG')),
    Seating_Capacity INT NOT NULL CHECK (Seating_Capacity > 0),
    -- Foreign key enforces total + disjoint specialization
    CONSTRAINT FK_Car_Vehicle FOREIGN KEY (Vehicle_ID)
        REFERENCES Vehicle (Vehicle_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================
-- STEP 3: CREATE THE SUBTYPE TABLE (Truck)
-- Inherits Vehicle_ID as PK and FK (disjoint + total)
-- ============================================================
CREATE TABLE Truck (
    Vehicle_ID     INT PRIMARY KEY,
    Load_Capacity  DECIMAL(8, 2) NOT NULL CHECK (Load_Capacity > 0),  -- in tons
    Truck_Type     VARCHAR(30) NOT NULL CHECK (Truck_Type IN ('Light', 'Medium', 'Heavy', 'Semi-Trailer')),
    Number_of_Axles INT NOT NULL CHECK (Number_of_Axles >= 2),
    -- Foreign key enforces total + disjoint specialization
    CONSTRAINT FK_Truck_Vehicle FOREIGN KEY (Vehicle_ID)
        REFERENCES Vehicle (Vehicle_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================
-- STEP 4: INSERT SAMPLE DATA INTO SUPERTYPE (Vehicle)
-- ============================================================
INSERT INTO Vehicle (Vehicle_ID, Registration_Number, Manufacturer, Model, Year, Purchase_Price) VALUES
(1, 'ABC-1234', 'Toyota',     'Camry',       2022, 28000.00),
(2, 'DEF-5678', 'Honda',      'Civic',       2023, 25000.00),
(3, 'GHI-9012', 'Ford',       'F-150',       2021, 45000.00),
(4, 'JKL-3456', 'Chevrolet',  'Silverado',   2022, 42000.00),
(5, 'MNO-7890', 'Tesla',      'Model 3',     2024, 40000.00),
(6, 'PQR-1122', 'Volvo',      'FH16',        2023, 120000.00),
(7, 'STU-3344', 'BMW',        '3 Series',    2023, 45000.00),
(8, 'VWX-5566', 'Mercedes',   'Actros',      2022, 110000.00);

-- ============================================================
-- STEP 5: INSERT SAMPLE DATA INTO SUBTYPE (Car)
-- Vehicle_ID must exist in Vehicle (FK constraint)
-- ============================================================
INSERT INTO Car (Vehicle_ID, Number_of_Doors, Fuel_Type, Seating_Capacity) VALUES
(1, 4, 'Petrol',  5),
(2, 4, 'Hybrid',  5),
(5, 4, 'Electric', 5),
(7, 2, 'Petrol',  4);

-- ============================================================
-- STEP 6: INSERT SAMPLE DATA INTO SUBTYPE (Truck)
-- Vehicle_ID must exist in Vehicle (FK constraint)
-- ============================================================
INSERT INTO Truck (Vehicle_ID, Load_Capacity, Truck_Type, Number_of_Axles) VALUES
(3, 3.5,  'Light',  2),
(4, 5.0,  'Medium', 4),
(6, 20.0, 'Heavy',  6),
(8, 25.0, 'Semi-Trailer', 5);

-- ============================================================
-- STEP 7: QUERIES TO DISPLAY THE DATA
-- ============================================================

-- Query 1: Display ALL vehicles with their type classification
SELECT
    v.Vehicle_ID,
    v.Registration_Number,
    v.Manufacturer,
    v.Model,
    v.Year,
    v.Purchase_Price,
    CASE
        WHEN c.Vehicle_ID IS NOT NULL THEN 'Car'
        WHEN t.Vehicle_ID IS NOT NULL THEN 'Truck'
        ELSE 'Unknown'
    END AS Vehicle_Type
FROM Vehicle v
LEFT JOIN Car c ON v.Vehicle_ID = c.Vehicle_ID
LEFT JOIN Truck t ON v.Vehicle_ID = t.Vehicle_ID;

-- Query 2: Display all Cars with inherited attributes
SELECT
    v.Vehicle_ID,
    v.Registration_Number,
    v.Manufacturer,
    v.Model,
    v.Year,
    v.Purchase_Price,
    c.Number_of_Doors,
    c.Fuel_Type,
    c.Seating_Capacity
FROM Vehicle v
INNER JOIN Car c ON v.Vehicle_ID = c.Vehicle_ID;

-- Query 3: Display all Trucks with inherited attributes
SELECT
    v.Vehicle_ID,
    v.Registration_Number,
    v.Manufacturer,
    v.Model,
    v.Year,
    v.Purchase_Price,
    t.Load_Capacity,
    t.Truck_Type,
    t.Number_of_Axles
FROM Vehicle v
INNER JOIN Truck t ON v.Vehicle_ID = t.Vehicle_ID;

-- Query 4: Count vehicles by type
SELECT 'Car' AS Vehicle_Type, COUNT(*) AS Total_Count
FROM Car
UNION ALL
SELECT 'Truck' AS Vehicle_Type, COUNT(*) AS Total_Count
FROM Truck;

-- Query 5: Find the most expensive vehicle in each subtype
SELECT 'Car' AS Type, v.Manufacturer, v.Model, MAX(v.Purchase_Price) AS Max_Price
FROM Vehicle v JOIN Car c ON v.Vehicle_ID = c.Vehicle_ID
GROUP BY v.Manufacturer, v.Model
UNION ALL
SELECT 'Truck' AS Type, v.Manufacturer, v.Model, MAX(v.Purchase_Price) AS Max_Price
FROM Vehicle v JOIN Truck t ON v.Vehicle_ID = t.Vehicle_ID
GROUP BY v.Manufacturer, v.Model;

-- ============================================================
-- CLEANUP (run these to drop tables if needed)
-- ============================================================
-- DROP TABLE IF EXISTS Car;
-- DROP TABLE IF EXISTS Truck;
-- DROP TABLE IF EXISTS Vehicle;
