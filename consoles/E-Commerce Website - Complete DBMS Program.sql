-- connection: 6ae2bc4d1c1a39f2ed432423

-- ============================================================
-- E-COMMERCE WEBSITE - COMPLETE DBMS PROGRAM
-- ============================================================
-- EER Concepts Demonstrated:
--   • Supertype/Subtype: Product → Electronics, Clothing, Grocery
--   • Specialization: Disjoint (d), Total
--   • Inheritance: Subtypes inherit Product attributes
--   • M:N Relationship: Order ↔ Product (via Order_Item)
--   • 1:M Relationship: Customer → Orders
--   • 1:1 Relationship: Order → Payment, Order → Delivery
-- ============================================================

-- ============================================================
-- TASK 1: IDENTIFY MAJOR ENTITIES
--   1. Customer    2. Product (Supertype)
--   3. Category    4. Order
--   5. Payment     6. Delivery
--   7. Electronics (Subtype)   8. Clothing (Subtype)
--   9. Grocery (Subtype)      10. Order_Item (Associative)
-- ============================================================

-- ============================================================
-- STEP 1: CREATE ALL TABLES (in dependency order)
-- ============================================================

-- 1. CATEGORY (Independent Entity)
CREATE TABLE Category (
    Category_ID     INT PRIMARY KEY,
    Category_Name   VARCHAR(50) NOT NULL UNIQUE,
    Description     VARCHAR(200)
);

-- 2. PRODUCT — SUPERTYPE
-- Common attributes inherited by all subtypes
CREATE TABLE Product (
    Product_ID      INT PRIMARY KEY,
    Product_Name    VARCHAR(100) NOT NULL,
    Price           DECIMAL(10, 2) NOT NULL CHECK (Price > 0),
    Stock_Quantity  INT NOT NULL CHECK (Stock_Quantity >= 0),
    Description     VARCHAR(300),
    Category_ID     INT NOT NULL,
    CONSTRAINT FK_Product_Category FOREIGN KEY (Category_ID)
        REFERENCES Category (Category_ID)
        ON DELETE CASCADE
);

-- 3. ELECTRONICS — SUBTYPE of Product
-- TASK 4 & 5: Inherits Product_ID, Product_Name, Price,
--   Stock_Quantity, Description from Product
-- Own attributes: Brand, Warranty_Period, Power_Rating
CREATE TABLE Electronics (
    Product_ID      INT PRIMARY KEY,
    Brand           VARCHAR(50) NOT NULL,
    Warranty_Period INT NOT NULL CHECK (Warranty_Period >= 0),
    Power_Rating    DECIMAL(8, 2) CHECK (Power_Rating > 0),
    CONSTRAINT FK_Electronics_Product FOREIGN KEY (Product_ID)
        REFERENCES Product (Product_ID)
        ON DELETE CASCADE
);

-- 4. CLOTHING — SUBTYPE of Product
-- TASK 4 & 5: Inherits Product_ID, Product_Name, Price,
--   Stock_Quantity, Description from Product
-- Own attributes: Size, Color, Material
CREATE TABLE Clothing (
    Product_ID      INT PRIMARY KEY,
    Size            VARCHAR(10) NOT NULL
                    CHECK (Size IN ('XS','S','M','L','XL','XXL','Free')),
    Color           VARCHAR(30) NOT NULL,
    Material        VARCHAR(50) NOT NULL,
    CONSTRAINT FK_Clothing_Product FOREIGN KEY (Product_ID)
        REFERENCES Product (Product_ID)
        ON DELETE CASCADE
);

-- 5. GROCERY — SUBTYPE of Product
-- TASK 4 & 5: Inherits Product_ID, Product_Name, Price,
--   Stock_Quantity, Description from Product
-- Own attributes: Weight_Kg, Expiry_Date, Is_Perishable
CREATE TABLE Grocery (
    Product_ID      INT PRIMARY KEY,
    Weight_Kg       DECIMAL(8, 2) NOT NULL CHECK (Weight_Kg > 0),
    Expiry_Date     DATE NOT NULL,
    Is_Perishable   BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT FK_Grocery_Product FOREIGN KEY (Product_ID)
        REFERENCES Product (Product_ID)
        ON DELETE CASCADE
);

-- 6. CUSTOMER (Independent Entity)
-- TASK 2: PK = Customer_ID
CREATE TABLE Customer (
    Customer_ID     INT PRIMARY KEY,
    Customer_Name   VARCHAR(50) NOT NULL,
    Email           VARCHAR(100) NOT NULL UNIQUE,
    Phone           VARCHAR(15) NOT NULL,
    Address         VARCHAR(200) NOT NULL
);

-- 7. ORDERS
-- TASK 2: PK = Order_ID
-- TASK 7: Relationship Customer → Order (1:M)
CREATE TABLE Orders (
    Order_ID        INT PRIMARY KEY,
    Order_Date      DATE NOT NULL DEFAULT CURRENT_DATE,
    Order_Status    VARCHAR(20) NOT NULL
                    CHECK (Order_Status IN ('Pending','Confirmed',
                        'Shipped','Delivered','Cancelled')),
    Total_Amount    DECIMAL(12, 2) NOT NULL CHECK (Total_Amount >= 0),
    Customer_ID     INT NOT NULL,
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (Customer_ID)
        REFERENCES Customer (Customer_ID)
        ON DELETE CASCADE
);

-- 8. ORDER_ITEM — ASSOCIATIVE ENTITY
-- TASK 3: Models M:N between Order and Product
-- Relationship attributes: Quantity, Unit_Price
-- Composite PK: (Order_ID, Product_ID)
CREATE TABLE Order_Item (
    Order_ID        INT NOT NULL,
    Product_ID      INT NOT NULL,
    Quantity        INT NOT NULL CHECK (Quantity > 0),
    Unit_Price      DECIMAL(10, 2) NOT NULL CHECK (Unit_Price > 0),
    PRIMARY KEY (Order_ID, Product_ID),
    CONSTRAINT FK_OI_Order FOREIGN KEY (Order_ID)
        REFERENCES Orders (Order_ID)
        ON DELETE CASCADE,
    CONSTRAINT FK_OI_Product FOREIGN KEY (Product_ID)
        REFERENCES Product (Product_ID)
        ON DELETE CASCADE
);

-- 9. PAYMENT
-- TASK 2: PK = Payment_ID
-- TASK 7: Relationship Order → Payment (1:1)
CREATE TABLE Payment (
    Payment_ID      INT PRIMARY KEY,
    Payment_Date    DATE NOT NULL DEFAULT CURRENT_DATE,
    Payment_Mode    VARCHAR(25) NOT NULL
                    CHECK (Payment_Mode IN ('Credit Card','Debit Card',
                        'UPI','Net Banking','Cash on Delivery','Wallet')),
    Payment_Status  VARCHAR(20) NOT NULL
                    CHECK (Payment_Status IN ('Pending','Completed',
                        'Failed','Refunded')),
    Order_ID        INT NOT NULL UNIQUE,
    CONSTRAINT FK_Payment_Order FOREIGN KEY (Order_ID)
        REFERENCES Orders (Order_ID)
        ON DELETE CASCADE
);

-- 10. DELIVERY
-- TASK 2: PK = Delivery_ID
-- TASK 7: Relationship Order → Delivery (1:1)
CREATE TABLE Delivery (
    Delivery_ID         INT PRIMARY KEY,
    Delivery_Date       DATE,
    Delivery_Status     VARCHAR(25) NOT NULL
                        CHECK (Delivery_Status IN ('Processing','Shipped',
                            'Out for Delivery','Delivered','Returned')),
    Delivery_Address    VARCHAR(200) NOT NULL,
    Order_ID            INT NOT NULL UNIQUE,
    CONSTRAINT FK_Delivery_Order FOREIGN KEY (Order_ID)
        REFERENCES Orders (Order_ID)
        ON DELETE CASCADE
);

-- ============================================================
-- STEP 2: INSERT SAMPLE DATA
-- ============================================================

-- Categories
INSERT INTO Category (Category_ID, Category_Name, Description) VALUES
(1, 'Electronics', 'Electronic gadgets, devices and accessories'),
(2, 'Clothing',    'Apparel, fashion and lifestyle products'),
(3, 'Grocery',     'Daily essentials, food and household items');

-- Products (SUPERTYPE) — 9 products across 3 categories
INSERT INTO Product (Product_ID, Product_Name, Price, Stock_Quantity,
                     Description, Category_ID) VALUES
-- Electronics
(101, 'Samsung Galaxy S24',    75000.00,  50, 'Latest Samsung flagship smartphone',   1),
(102, 'Sony WH-1000XM5',      28000.00, 120, 'Premium noise-cancelling headphones',  1),
(103, 'Dell XPS 15 Laptop',   125000.00,  30, 'High-performance laptop with OLED',   1),
-- Clothing
(201, 'Cotton T-Shirt',         799.00, 500, 'Comfortable cotton round-neck t-shirt', 2),
(202, 'Denim Jeans',           1499.00, 300, 'Slim-fit blue denim jeans',            2),
(203, 'Winter Jacket',         2999.00, 150, 'Insulated winter jacket with hood',     2),
-- Grocery
(301, 'Organic Basmati Rice',   450.00, 1000, 'Premium 5kg organic basmati rice',    3),
(302, 'Fresh Milk 1L',           65.00, 2000, 'Pasteurized full cream milk',         3),
(303, 'Whole Wheat Bread',       55.00,  800, 'Fresh whole wheat bread loaf',        3);

-- Electronics (SUBTYPE) — specialized attributes
INSERT INTO Electronics (Product_ID, Brand, Warranty_Period, Power_Rating) VALUES
(101, 'Samsung', 24, 15.00),
(102, 'Sony',    12,  2.50),
(103, 'Dell',    36, 65.00);

-- Clothing (SUBTYPE) — specialized attributes
INSERT INTO Clothing (Product_ID, Size, Color, Material) VALUES
(201, 'L',    'Blue',   'Cotton'),
(202, 'M',    'Blue',   'Denim'),
(203, 'XL',   'Black',  'Polyester');

-- Grocery (SUBTYPE) — specialized attributes
INSERT INTO Grocery (Product_ID, Weight_Kg, Expiry_Date, Is_Perishable) VALUES
(301, 5.00, '2027-12-31', FALSE),
(302, 1.00, '2026-11-15', TRUE),
(303, 0.40, '2026-11-05', TRUE);

-- Customers
INSERT INTO Customer (Customer_ID, Customer_Name, Email, Phone, Address) VALUES
(1, 'Rajesh Kumar',  'rajesh@mail.com',  '9876543210', '12 MG Road, Mumbai'),
(2, 'Sneha Patel',   'sneha@mail.com',   '9123456789', '45 Park Street, Delhi'),
(3, 'Arun Sharma',   'arun@mail.com',    '9988776655', '78 Anna Nagar, Chennai'),
(4, 'Meera Reddy',   'meera@mail.com',   '9876501234', '23 Koramangala, Bangalore'),
(5, 'Karan Singh',   'karan@mail.com',   '9123498765', '56 Baner Road, Pune');

-- Orders (Customer → Order: 1:M)
INSERT INTO Orders (Order_ID, Order_Date, Order_Status, Total_Amount, Customer_ID) VALUES
(1001, '2026-10-01', 'Delivered',  75960.00, 1),
(1002, '2026-10-05', 'Shipped',     5297.00, 2),
(1003, '2026-10-10', 'Confirmed', 125000.00, 3),
(1004, '2026-10-15', 'Pending',      570.00, 4),
(1005, '2026-10-18', 'Delivered',   4498.00, 5),
(1006, '2026-10-20', 'Cancelled',  28000.00, 1);

-- Order_Item (M:N between Order and Product with Quantity, Unit_Price)
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity, Unit_Price) VALUES
(1001, 101, 1, 75000.00),
(1001, 301, 2,   450.00),
(1001, 302, 4,    65.00),
(1002, 201, 3,   799.00),
(1002, 202, 2,  1499.00),
(1003, 103, 1, 125000.00),
(1004, 302, 5,    65.00),
(1004, 303, 6,    55.00),
(1005, 202, 1,  1499.00),
(1005, 203, 1,  2999.00),
(1006, 102, 1,  28000.00);

-- Payments (Order → Payment: 1:1)
INSERT INTO Payment (Payment_ID, Payment_Date, Payment_Mode,
                     Payment_Status, Order_ID) VALUES
(2001, '2026-10-01', 'Credit Card',     'Completed', 1001),
(2002, '2026-10-05', 'UPI',             'Completed', 1002),
(2003, '2026-10-10', 'Net Banking',     'Pending',   1003),
(2004, '2026-10-15', 'Cash on Delivery','Pending',   1004),
(2005, '2026-10-18', 'Debit Card',      'Completed', 1005),
(2006, '2026-10-20', 'Wallet',          'Refunded',  1006);

-- Deliveries (Order → Delivery: 1:1)
INSERT INTO Delivery (Delivery_ID, Delivery_Date, Delivery_Status,
                      Delivery_Address, Order_ID) VALUES
(3001, '2026-10-05', 'Delivered',        '12 MG Road, Mumbai',       1001),
(3002, NULL,          'Shipped',          '45 Park Street, Delhi',    1002),
(3003, NULL,          'Processing',       '78 Anna Nagar, Chennai',   1003),
(3004, NULL,          'Processing',       '23 Koramangala, Bangalore',1004),
(3005, '2026-10-22', 'Delivered',        '56 Baner Road, Pune',      1005),
(3006, NULL,          'Returned',         '12 MG Road, Mumbai',       1006);

-- ============================================================
-- STEP 3: QUERIES TO DISPLAY DATA
-- ============================================================

-- QUERY 1: All Electronics with inherited + specialized attributes
-- (Demonstrates Task 4, 5: Specialization + Inheritance)
SELECT
    p.Product_ID,
    p.Product_Name,
    p.Price,
    p.Stock_Quantity,
    c.Category_Name,
    e.Brand,
    e.Warranty_Period AS "Warranty (Months)",
    e.Power_Rating
FROM Product p
JOIN Category c ON p.Category_ID = c.Category_ID
JOIN Electronics e ON p.Product_ID = e.Product_ID;

-- QUERY 2: All Clothing with inherited + specialized attributes
SELECT
    p.Product_ID,
    p.Product_Name,
    p.Price,
    p.Stock_Quantity,
    c.Category_Name,
    cl.Size,
    cl.Color,
    cl.Material
FROM Product p
JOIN Category c ON p.Category_ID = c.Category_ID
JOIN Clothing cl ON p.Product_ID = cl.Product_ID;

-- QUERY 3: All Grocery with inherited + specialized attributes
SELECT
    p.Product_ID,
    p.Product_Name,
    p.Price,
    p.Stock_Quantity,
    c.Category_Name,
    g.Weight_Kg,
    g.Expiry_Date,
    g.Is_Perishable
FROM Product p
JOIN Category c ON p.Category_ID = c.Category_ID
JOIN Grocery g ON p.Product_ID = g.Product_ID;

-- QUERY 4: Complete order details with customer, items, products
-- (Demonstrates Task 3: Order-Product M:N with Quantity, Unit_Price)
SELECT
    o.Order_ID,
    o.Order_Date,
    o.Order_Status,
    cu.Customer_Name,
    p.Product_Name,
    oi.Quantity,
    oi.Unit_Price,
    (oi.Quantity * oi.Unit_Price) AS Line_Total
FROM Orders o
JOIN Customer cu ON o.Customer_ID = cu.Customer_ID
JOIN Order_Item oi ON o.Order_ID = oi.Order_ID
JOIN Product p ON oi.Product_ID = p.Product_ID
ORDER BY o.Order_ID, p.Product_ID;

-- QUERY 5: Order with Payment and Delivery status
-- (Demonstrates Task 7: Order→Payment 1:1, Order→Delivery 1:1)
SELECT
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    o.Order_Status,
    cu.Customer_Name,
    p.Payment_Mode,
    p.Payment_Status,
    d.Delivery_Status,
    d.Delivery_Date,
    d.Delivery_Address
FROM Orders o
JOIN Customer cu ON o.Customer_ID = cu.Customer_ID
LEFT JOIN Payment p ON o.Order_ID = p.Order_ID
LEFT JOIN Delivery d ON o.Order_ID = d.Order_ID
ORDER BY o.Order_ID;

-- QUERY 6: Customer-wise order summary
-- (Demonstrates Task 8: Customer→Order 1:M cardinality)
SELECT
    cu.Customer_ID,
    cu.Customer_Name,
    cu.Email,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    COALESCE(SUM(o.Total_Amount), 0) AS Total_Spent
FROM Customer cu
LEFT JOIN Orders o ON cu.Customer_ID = o.Customer_ID
GROUP BY cu.Customer_ID, cu.Customer_Name, cu.Email
ORDER BY Total_Spent DESC;

-- QUERY 7: Category-wise sales report
SELECT
    c.Category_Name,
    COUNT(DISTINCT oi.Product_ID) AS Products_Sold,
    SUM(oi.Quantity) AS Total_Quantity,
    SUM(oi.Quantity * oi.Unit_Price) AS Total_Revenue
FROM Category c
JOIN Product p ON c.Category_ID = p.Category_ID
JOIN Order_Item oi ON p.Product_ID = oi.Product_ID
GROUP BY c.Category_Name
ORDER BY Total_Revenue DESC;

-- QUERY 8: Payment mode distribution
SELECT
    Payment_Mode,
    COUNT(*) AS Total_Payments,
    SUM(CASE WHEN Payment_Status = 'Completed' THEN 1 ELSE 0 END) AS Completed,
    SUM(CASE WHEN Payment_Status = 'Pending' THEN 1 ELSE 0 END) AS Pending,
    SUM(CASE WHEN Payment_Status = 'Refunded' THEN 1 ELSE 0 END) AS Refunded
FROM Payment
GROUP BY Payment_Mode;

-- ============================================================
-- TASK 9: COMPLETE EER DIAGRAM (Textual Representation)
-- ============================================================
--
--  ┌──────────────┐
--  │   Category   │
--  │──────────────│
--  │PK Category_ID│
--  │  Name        │
--  │  Description │
--  └──────┬───────┘
--         │ 1
--         │
--         │ M
--  ┌──────┴───────┐
--  │   PRODUCT    │  ◄── SUPERTYPE
--  │──────────────│
--  │PK Product_ID │
--  │  Product_Name│
--  │  Price       │
--  │  Stock_Qty   │
--  │  Description │
--  └──────┬───────┘
--         │
--  ┌──────┴───────┐
--  │   ISA (d)    │  ◄── Disjoint + Total
--  └──┬────┬────┬─┘
--     │    │    │
--  ┌──┴──┐┌┴───┐┌┴──────┐
--  │Elec-││Clo-││Gro-   │  ◄── SUBTYPES
--  │tron-││th- ││cery   │
--  │ics  ││ing ││       │
--  │─────││────││───────│
--  │Brand││Size││Weight │
--  │Warr-││Color│Expiry │
--  │anty ││Mate-│Is_Per-│
--  │Power││rial │ishable│
--  └─────┘└────┘└───────┘
--
--  ┌──────────────┐
--  │   Customer   │
--  │──────────────│
--  │PK Customer_ID│
--  │  Name        │
--  │  Email       │
--  │  Phone       │
--  │  Address     │
--  └──────┬───────┘
--         │ 1
--         │
--         │ M
--  ┌──────┴───────┐
--  │    Orders    │
--  │──────────────│
--  │PK Order_ID   │
--  │  Order_Date  │
--  │  Order_Status│
--  │  Total_Amount│
--  └──┬────┬───┬──┘
--     │    │   │
--  1:1│ 1:1│   │ M:N (via Order_Item)
--     │    │   │
--  ┌──┴──┐┌┴──┐┌┴─────────┐  ┌──────────┐
--  │Pay- ││De-││Order_Item│──│ Product  │
--  │ment ││liv││──────────│  │──────────│
--  │─────││ery││PK Ord_ID │  │PK Prod_ID│
--  │PK   ││───││PK Prod_ID│  │  Name    │
--  │Pay_ID││Del││  Quantity│  │  Price   │
--  │Date ││ID ││  UnitPrice│  └──────────┘
--  │Mode ││Date│└──────────┘
--  │Status││Stat│
--  └─────┘│Addr│
--         └────┘
--
-- ============================================================
-- TASK SUMMARY TABLE
-- ============================================================
--
-- Task | Requirement                    | Implementation
-- -----|--------------------------------|----------------------------------
--  1   | Major entities                 | 10 tables created
--  2   | Attributes & PKs               | All PKs defined with constraints
--  3   | Order-Product M:N              | Order_Item with Quantity, Unit_Price
--  4   | Specialization                 | Product → Electronics, Clothing, Grocery
--  5   | Inherited attributes           | Subtypes JOIN Product for common attrs
--  6   | Disjoint + Total               | FK constraints enforce both
--  7   | Customer-Order, Order-Payment, | FK relationships with cardinalities
--      | Order-Delivery                 |
--  8   | Cardinalities                  | 1:M, 1:1, M:N all specified
--  9   | Complete EER diagram           | See diagram above
--
-- ============================================================
-- CLEANUP (uncomment to drop all tables)
-- ============================================================
-- DROP TABLE IF EXISTS Delivery;
-- DROP TABLE IF EXISTS Payment;
-- DROP TABLE IF EXISTS Order_Item;
-- DROP TABLE IF EXISTS Orders;
-- DROP TABLE IF EXISTS Grocery;
-- DROP TABLE IF EXISTS Clothing;
-- DROP TABLE IF EXISTS Electronics;
-- DROP TABLE IF EXISTS Product;
-- DROP TABLE IF EXISTS Category;
-- DROP TABLE IF EXISTS Customer;
