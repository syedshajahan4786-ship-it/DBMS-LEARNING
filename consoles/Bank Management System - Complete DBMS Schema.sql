-- connection: 6ae2bc4d1c1a39f2ed432423

-- ============================================================
-- BANK MANAGEMENT SYSTEM - COMPLETE DBMS PROGRAM
-- Entities: Branch, Employee, Customer, Account (Savings/Current),
--           Transaction, Loan, Loan_Payment
-- ============================================================

-- ============================================================
-- STEP 1: CREATE TABLES (in dependency order)
-- ============================================================

-- 1. BRANCH
CREATE TABLE Branch (
    Branch_ID       INT PRIMARY KEY,
    Branch_Name     VARCHAR(50) NOT NULL,
    Location        VARCHAR(100) NOT NULL,
    IFSC_Code       VARCHAR(20) NOT NULL UNIQUE
);

-- 2. EMPLOYEE (works at a branch)
CREATE TABLE Employee (
    Employee_ID     INT PRIMARY KEY,
    Employee_Name   VARCHAR(50) NOT NULL,
    Designation     VARCHAR(30) NOT NULL,
    Salary          DECIMAL(10, 2) NOT NULL CHECK (Salary > 0),
    Branch_ID       INT NOT NULL,
    CONSTRAINT FK_Employee_Branch FOREIGN KEY (Branch_ID)
        REFERENCES Branch (Branch_ID)
        ON DELETE CASCADE
);

-- 3. CUSTOMER
CREATE TABLE Customer (
    Customer_ID     INT PRIMARY KEY,
    Customer_Name   VARCHAR(50) NOT NULL,
    Phone           VARCHAR(15) NOT NULL,
    Email           VARCHAR(100) UNIQUE,
    Address         VARCHAR(200) NOT NULL,
    Date_Of_Birth   DATE NOT NULL
);

-- 4. ACCOUNT (supertype - holds common attributes)
CREATE TABLE Account (
    Account_No      VARCHAR(20) PRIMARY KEY,
    Account_Type    VARCHAR(20) NOT NULL CHECK (Account_Type IN ('Savings', 'Current')),
    Balance         DECIMAL(12, 2) NOT NULL CHECK (Balance >= 0),
    Opening_Date    DATE NOT NULL DEFAULT CURRENT_DATE,
    Customer_ID     INT NOT NULL,
    Branch_ID       INT NOT NULL,
    CONSTRAINT FK_Account_Customer FOREIGN KEY (Customer_ID)
        REFERENCES Customer (Customer_ID)
        ON DELETE CASCADE,
    CONSTRAINT FK_Account_Branch FOREIGN KEY (Branch_ID)
        REFERENCES Branch (Branch_ID)
        ON DELETE CASCADE
);

-- 5. SAVINGS ACCOUNT (subtype of Account)
CREATE TABLE Savings_Account (
    Account_No      VARCHAR(20) PRIMARY KEY,
    Interest_Rate   DECIMAL(5, 2) NOT NULL CHECK (Interest_Rate > 0),
    Minimum_Balance DECIMAL(10, 2) NOT NULL DEFAULT 1000.00,
    CONSTRAINT FK_Savings_Account FOREIGN KEY (Account_No)
        REFERENCES Account (Account_No)
        ON DELETE CASCADE
);

-- 6. CURRENT ACCOUNT (subtype of Account)
CREATE TABLE Current_Account (
    Account_No      VARCHAR(20) PRIMARY KEY,
    Overdraft_Limit DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    Charges         DECIMAL(8, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT FK_Current_Account FOREIGN KEY (Account_No)
        REFERENCES Account (Account_No)
        ON DELETE CASCADE
);

-- 7. TRANSACTION
CREATE TABLE Transaction (
    Transaction_ID      INT PRIMARY KEY,
    Transaction_Date    DATE NOT NULL DEFAULT CURRENT_DATE,
    Transaction_Type    VARCHAR(20) NOT NULL CHECK (Transaction_Type IN ('Deposit', 'Withdrawal', 'Transfer')),
    Amount              DECIMAL(12, 2) NOT NULL CHECK (Amount > 0),
    Account_No          VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Transaction_Account FOREIGN KEY (Account_No)
        REFERENCES Account (Account_No)
        ON DELETE CASCADE
);

-- 8. LOAN
CREATE TABLE Loan (
    Loan_ID         INT PRIMARY KEY,
    Loan_Type       VARCHAR(30) NOT NULL CHECK (Loan_Type IN ('Personal', 'Home', 'Vehicle', 'Education', 'Business')),
    Loan_Amount     DECIMAL(12, 2) NOT NULL CHECK (Loan_Amount > 0),
    Interest_Rate   DECIMAL(5, 2) NOT NULL CHECK (Interest_Rate > 0),
    Loan_Status     VARCHAR(20) NOT NULL CHECK (Loan_Status IN ('Pending', 'Approved', 'Rejected', 'Closed')),
    Customer_ID     INT NOT NULL,
    Branch_ID       INT NOT NULL,
    CONSTRAINT FK_Loan_Customer FOREIGN KEY (Customer_ID)
        REFERENCES Customer (Customer_ID)
        ON DELETE CASCADE,
    CONSTRAINT FK_Loan_Branch FOREIGN KEY (Branch_ID)
        REFERENCES Branch (Branch_ID)
        ON DELETE CASCADE
);

-- 9. LOAN PAYMENT
CREATE TABLE Loan_Payment (
    Payment_ID      INT PRIMARY KEY,
    Payment_Date    DATE NOT NULL DEFAULT CURRENT_DATE,
    Payment_Amount  DECIMAL(12, 2) NOT NULL CHECK (Payment_Amount > 0),
    Loan_ID         INT NOT NULL,
    CONSTRAINT FK_Payment_Loan FOREIGN KEY (Loan_ID)
        REFERENCES Loan (Loan_ID)
        ON DELETE CASCADE
);

-- ============================================================
-- STEP 2: INSERT SAMPLE DATA
-- ============================================================

-- Branches
INSERT INTO Branch (Branch_ID, Branch_Name, Location, IFSC_Code) VALUES
(101, 'Main Branch',     'Mumbai',   'HDFC0001001'),
(102, 'North Branch',    'Delhi',    'HDFC0001002'),
(103, 'South Branch',    'Chennai',  'HDFC0001003'),
(104, 'West Branch',     'Pune',     'HDFC0001004');

-- Employees
INSERT INTO Employee (Employee_ID, Employee_Name, Designation, Salary, Branch_ID) VALUES
(1001, 'Rahul Sharma',     'Manager',        95000.00, 101),
(1002, 'Priya Patel',      'Cashier',        45000.00, 101),
(1003, 'Amit Kumar',       'Loan Officer',   65000.00, 102),
(1004, 'Sneha Reddy',      'Clerk',          38000.00, 103),
(1005, 'Vikram Singh',     'Assistant Mgr',  78000.00, 104),
(1006, 'Anita Desai',      'Cashier',        42000.00, 102);

-- Customers
INSERT INTO Customer (Customer_ID, Customer_Name, Phone, Email, Address, Date_Of_Birth) VALUES
(1, 'Arjun Mehta',     '9876543210', 'arjun@mail.com',     'Mumbai',  '1990-05-15'),
(2, 'Kavya Nair',      '9123456789', 'kavya@mail.com',     'Chennai', '1985-11-20'),
(3, 'Rohan Gupta',     '9988776655', 'rohan@mail.com',     'Delhi',   '1992-03-10'),
(4, 'Deepa Iyer',      '9876501234', 'deepa@mail.com',     'Pune',    '1988-07-25'),
(5, 'Sanjay Joshi',    '9123498765', 'sanjay@mail.com',    'Mumbai',  '1995-01-30');

-- Accounts (supertype)
INSERT INTO Account (Account_No, Account_Type, Balance, Opening_Date, Customer_ID, Branch_ID) VALUES
('SB-10001', 'Savings', 150000.00, '2022-01-10', 1, 101),
('SB-10002', 'Savings',  85000.00, '2022-03-15', 2, 103),
('SB-10003', 'Savings', 220000.00, '2021-06-20', 3, 102),
('SB-10004', 'Savings',  45000.00, '2023-02-01', 4, 104),
('SB-10005', 'Savings', 310000.00, '2020-11-05', 5, 101),
('CR-20001', 'Current', 500000.00, '2021-09-12', 1, 101),
('CR-20002', 'Current', 750000.00, '2022-07-18', 3, 102);

-- Savings Accounts (subtype)
INSERT INTO Savings_Account (Account_No, Interest_Rate, Minimum_Balance) VALUES
('SB-10001', 6.50, 1000.00),
('SB-10002', 6.25, 1000.00),
('SB-10003', 6.75, 1000.00),
('SB-10004', 6.00, 1000.00),
('SB-10005', 7.00, 1000.00);

-- Current Accounts (subtype)
INSERT INTO Current_Account (Account_No, Overdraft_Limit, Charges) VALUES
('CR-20001', 100000.00, 500.00),
('CR-20002', 200000.00, 750.00);

-- Transactions
INSERT INTO Transaction (Transaction_ID, Transaction_Date, Transaction_Type, Amount, Account_No) VALUES
(5001, '2024-01-15', 'Deposit',    25000.00, 'SB-10001'),
(5002, '2024-01-18', 'Withdrawal', 10000.00, 'SB-10001'),
(5003, '2024-02-01', 'Deposit',    50000.00, 'SB-10002'),
(5004, '2024-02-10', 'Transfer',   30000.00, 'CR-20001'),
(5005, '2024-03-05', 'Withdrawal', 15000.00, 'SB-10003'),
(5006, '2024-03-12', 'Deposit',    75000.00, 'SB-10005'),
(5007, '2024-04-01', 'Transfer',   20000.00, 'CR-20002'),
(5008, '2024-04-15', 'Deposit',     5000.00, 'SB-10004');

-- Loans
INSERT INTO Loan (Loan_ID, Loan_Type, Loan_Amount, Interest_Rate, Loan_Status, Customer_ID, Branch_ID) VALUES
(7001, 'Home',      5000000.00, 8.50, 'Approved', 1, 101),
(7002, 'Personal',   300000.00, 12.00, 'Approved', 2, 103),
(7003, 'Vehicle',    800000.00, 9.75, 'Approved', 3, 102),
(7004, 'Education',  200000.00, 7.50, 'Pending',  4, 104),
(7005, 'Business',  2000000.00, 11.00, 'Rejected', 5, 101);

-- Loan Payments
INSERT INTO Loan_Payment (Payment_ID, Payment_Date, Payment_Amount, Loan_ID) VALUES
(9001, '2024-01-20', 45000.00, 7001),
(9002, '2024-02-20', 45000.00, 7001),
(9003, '2024-03-20', 45000.00, 7001),
(9004, '2024-01-15', 15000.00, 7002),
(9005, '2024-02-15', 15000.00, 7002),
(9006, '2024-01-10', 35000.00, 7003),
(9007, '2024-02-10', 35000.00, 7003);

-- ============================================================
-- STEP 3: QUERIES TO DISPLAY DATA
-- ============================================================

-- Query 1: All customers with their accounts and branch info
SELECT
    c.Customer_ID,
    c.Customer_Name,
    a.Account_No,
    a.Account_Type,
    a.Balance,
    a.Opening_Date,
    b.Branch_Name,
    b.Location
FROM Customer c
JOIN Account a ON c.Customer_ID = a.Customer_ID
JOIN Branch b ON a.Branch_ID = b.Branch_ID
ORDER BY c.Customer_ID;

-- Query 2: Savings accounts with interest rates
SELECT
    sa.Account_No,
    c.Customer_Name,
    sa.Balance,
    s.Interest_Rate,
    s.Minimum_Balance,
    b.Branch_Name
FROM Savings_Account s
JOIN Account sa ON s.Account_No = sa.Account_No
JOIN Customer c ON sa.Customer_ID = c.Customer_ID
JOIN Branch b ON sa.Branch_ID = b.Branch_ID;

-- Query 3: Current accounts with overdraft details
SELECT
    ca.Account_No,
    c.Customer_Name,
    ca.Balance,
    cr.Overdraft_Limit,
    cr.Charges,
    b.Branch_Name
FROM Current_Account cr
JOIN Account ca ON cr.Account_No = ca.Account_No
JOIN Customer c ON ca.Customer_ID = c.Customer_ID
JOIN Branch b ON ca.Branch_ID = b.Branch_ID;

-- Query 4: All transactions with account and customer details
SELECT
    t.Transaction_ID,
    t.Transaction_Date,
    t.Transaction_Type,
    t.Amount,
    a.Account_No,
    c.Customer_Name,
    b.Branch_Name
FROM Transaction t
JOIN Account a ON t.Account_No = a.Account_No
JOIN Customer c ON a.Customer_ID = c.Customer_ID
JOIN Branch b ON a.Branch_ID = b.Branch_ID
ORDER BY t.Transaction_Date DESC;

-- Query 5: Loans with customer info and total paid
SELECT
    l.Loan_ID,
    c.Customer_Name,
    l.Loan_Type,
    l.Loan_Amount,
    l.Interest_Rate,
    l.Loan_Status,
    b.Branch_Name,
    COALESCE(SUM(lp.Payment_Amount), 0) AS Total_Paid
FROM Loan l
JOIN Customer c ON l.Customer_ID = c.Customer_ID
JOIN Branch b ON l.Branch_ID = b.Branch_ID
LEFT JOIN Loan_Payment lp ON l.Loan_ID = lp.Loan_ID
GROUP BY l.Loan_ID, c.Customer_Name, l.Loan_Type, l.Loan_Amount,
         l.Interest_Rate, l.Loan_Status, b.Branch_Name
ORDER BY l.Loan_ID;

-- Query 6: Branch-wise summary (employees, accounts, total balance)
SELECT
    b.Branch_ID,
    b.Branch_Name,
    b.Location,
    COUNT(DISTINCT e.Employee_ID) AS Total_Employees,
    COUNT(DISTINCT a.Account_No) AS Total_Accounts,
    COALESCE(SUM(a.Balance), 0) AS Total_Balance
FROM Branch b
LEFT JOIN Employee e ON b.Branch_ID = e.Branch_ID
LEFT JOIN Account a ON b.Branch_ID = a.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name, b.Location
ORDER BY b.Branch_ID;

-- Query 7: Customer-wise transaction summary
SELECT
    c.Customer_ID,
    c.Customer_Name,
    COUNT(t.Transaction_ID) AS Total_Transactions,
    COALESCE(SUM(CASE WHEN t.Transaction_Type = 'Deposit' THEN t.Amount ELSE 0 END), 0) AS Total_Deposits,
    COALESCE(SUM(CASE WHEN t.Transaction_Type = 'Withdrawal' THEN t.Amount ELSE 0 END), 0) AS Total_Withdrawals
FROM Customer c
JOIN Account a ON c.Customer_ID = a.Customer_ID
LEFT JOIN Transaction t ON a.Account_No = t.Account_No
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY c.Customer_ID;

-- ============================================================
-- CLEANUP (uncomment to drop all tables)
-- ============================================================
-- DROP TABLE IF EXISTS Loan_Payment;
-- DROP TABLE IF EXISTS Loan;
-- DROP TABLE IF EXISTS Transaction;
-- DROP TABLE IF EXISTS Current_Account;
-- DROP TABLE IF EXISTS Savings_Account;
-- DROP TABLE IF EXISTS Account;
-- DROP TABLE IF EXISTS Employee;
-- DROP TABLE IF EXISTS Customer;
-- DROP TABLE IF EXISTS Branch;
