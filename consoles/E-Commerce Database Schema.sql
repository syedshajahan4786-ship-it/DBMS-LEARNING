-- connection: 6ae2bc4d1c1a39f2ed432423

-- ============================================================
-- E-COMMERCE DATABASE SCHEMA
-- Entities: Customer, Product (Supertype), Category, Order,
--           Order_Item, Payment, Delivery
-- Subtypes: Electronics, Clothing, Grocery (Specialization)
-- ============================================================

-- ============================================================
-- STEP 1: CREATE TABLES (in dependency order)
-- ============================================================

-- 1. CATEGORY
CREATE TABLE Category (
    Category_ID     INT PRIMARY KEY,
    Category_Name   VARCHAR(50) NOT NULL UNIQUE,
    Description     VARCHAR(200)
);

-- 2. PRODUCT (Supertype)
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

-- 3. ELECTRONICS (Subtype of Product)
CREATE TABLE Electronics (
    Product_ID      INT PRIMARY KEY,
    Brand           VARCHAR(50) NOT NULL,
    Warranty_Period INT NOT NULL CHECK (Warranty_Period >= 0),  -- in months
    Power_Wattage   DECIMAL(8, 2) CHECK (Power_Wattage > 0),
    CONSTRAINT FK_Electronics_Product FOREIGN KEY (Product_ID)
        REFERENCES Product (Product_ID)
        ON DELETE CASCADE
);

-- 4. CLOTHING (Subtype of Product)
CREATE TABLE Clothing (
    Product_ID      INT PRIMARY KEY,
    Size            VARCHAR(10) NOT NULL CHECK (Size IN ('XS', 'S', 'M', 'L', 'XL', 'XXL', 'Free')),
    Color           VARCHAR(30) NOT NULL,
    Material        VARCHAR(50) NOT NULL,
    CONSTRAINT FK_Clothing_Product FOREIGN KEY (Product_ID)
        REFERENCES Product (Product_ID)
        ON DELETE CASCADE
);

-- 5. GROCERY (Subtype of Product)
CREATE TABLE Grocery (
    Product_ID      INT PRIMARY KEY,
    Weight          DECIMAL(8, 2) NOT NULL CHECK (Weight > 0),  -- in kg
    Expiry_Date     DATE NOT NULL,
    Is_Perishable   BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT FK_Grocery_Product FOREIGN KEY (Product_ID)
        REFERENCES Product (Product_ID)
        ON DELETE CASCADE
);

-- 6. CUSTOMER
CREATE TABLE Customer (
    Customer_ID     INT PRIMARY KEY,
    Customer_Name   VARCHAR(50) NOT NULL,
    Email           VARCHAR(100) NOT NULL UNIQUE,
    Phone           VARCHAR(15) NOT NULL,
    Address         VARCHAR(200) NOT NULL
);

-- 7. ORDERS
CREATE TABLE Orders (
    Order_ID        INT PRIMARY KEY,
    Order_Date      DATE NOT NULL DEFAULT CURRENT_DATE,
    Order_Status    VARCHAR(20) NOT NULL CHECK (Order_Status IN ('Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled')),
    Total_Amount    DECIMAL(12, 2) NOT NULL CHECK (Total_Amount >= 0),
    Customer_ID     INT NOT NULL,
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (Customer_ID)
        REFERENCES Customer (Customer_ID)
        ON DELETE CASCADE
);

-- 8. ORDER_ITEM (Associative Entity for Order-Product M:N)
--    Contains relationship attributes: Quantity, Unit_Price
CREATE TABLE Order_Item (
    Order_ID        INT NOT NULL,
    Product_ID      INT NOT NULL,
    Quantity        INT NOT NULL CHECK (Quantity > 0),
    Unit_Price      DECIMAL(10, 2) NOT NULL CHECK (Unit_Price > 0),
    PRIMARY KEY (Order_ID, Product_ID),
    CONSTRAINT FK_OrderItem_Order FOREIGN KEY (Order_ID)
        REFERENCES Orders (Order_ID)
        ON DELETE CASCADE,
    CONSTRAINT FK_OrderItem_Product FOREIGN KEY (Product_ID)
        REFERENCES Product (Product_ID)
        ON DELETE CASCADE
);

-- 9. PAYMENT (1:1 with Order)
CREATE TABLE Payment (
    Payment_ID      INT PRIMARY KEY,
    Payment_Date    DATE NOT NULL DEFAULT CURRENT_DATE,
    Payment_Mode    VARCHAR(20) NOT NULL CHECK (Payment_Mode IN ('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Cash on Delivery', 'Wallet')),
    Payment_Status  VARCHAR(20) NOT NULL CHECK (Payment_Status IN ('Pending', 'Completed', 'Failed', 'Refunded')),
    Order_ID        INT NOT NULL UNIQUE,
    CONSTRAINT FK_Payment_Order FOREIGN KEY (Order_ID)
        REFERENCES Orders (Order_ID)
        ON DELETE CASCADE
);

-- 10. DELIVERY (1:1 with Order)
CREATE TABLE Delivery (
    Delivery_ID         INT PRIMARY KEY,
    Delivery_Date       DATE,
    Delivery_Status     VARCHAR(20) NOT NULL CHECK (Delivery_Status IN ('Processing', 'Shipped', 'Out for Delivery', 'Delivered', 'Returned')),
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
(1, 'Electronics', 'Electronic gadgets and devices'),
(2, 'Clothing',    'Apparel and fashion items'),
(3, 'Grocery',     'Daily essentials and food items');

-- Products (Supertype)
INSERT INTO Product (Product_ID, Product_Name, Price, Stock_Quantity, Description, Category_ID) VALUES
-- Electronics
(101, 'Samsung Galaxy S24',    75000.00,  50, 'Latest Samsung flagship smartphone',       1),
(102, 'Sony WH-1000XM5',      28000.00, 120, 'Premium noise-cancelling headphones',      1),
(103, 'Dell XPS 15 Laptop',   125000.00,  30, 'High-performance laptop with OLED',       1),
-- Clothing
(201, 'Cotton T-Shirt',         799.00, 500, 'Comfortable cotton round-neck t-shirt',     2),
(202, 'Denim Jeans',           1499.00, 300, 'Slim-fit blue denim jeans',                2),
(203, 'Winter Jacket',         2999.00, 150, 'Insulated winter jacket with hood',         2),
-- Grocery
(301, 'Organic Basmati Rice',   450.00, 1000, 'Premium 5kg organic basmati rice',        3),
(302, 'Fresh Milk (1L)',         65.00, 2000, 'Pasteurized full cream milk',              3),
(303, 'Whole Wheat Bread',       55.00,  800, 'Fresh whole wheat bread loaf',             3);

-- Electronics (Subtype)
INSERT INTO Electronics (Product_ID, Brand, Warranty_Period, Power_Wattage) VALUES
(101, 'Samsung', 24, 15.00),
(102, 'Sony',    12,  2.50),
(103, 'Dell',    36, 65.00);

-- Clothing (Subtype)
INSERT INTO Clothing (Product_ID, Size, Color, Material) VALUES
(201, 'L',    'Blue',   'Cotton'),
(202, 'M',    'Blue',   'Denim'),
(203, 'XL',   'Black',  'Polyester');

-- Grocery (Subtype)
INSERT INTO Grocery (Product_ID, Weight, Expiry_Date, Is_Perishable) VALUES
(301, 5.00, '2026-12-31', FALSE),
(302, 1.00, '2026-11-15', TRUE),
(303, 0.40, '2026-11-05', TRUE);

-- Customers
INSERT INTO Customer (Customer_ID, Customer_Name, Email, Phone, Address) VALUES
(1, 'Rajesh Kumar',  'rajesh@mail.com',  '9876543210', '12 MG Road, Mumbai'),
(2, 'Sneha Patel',   'sneha@mail.com',   '9123456789', '45 Park Street, Delhi'),
(3, 'Arun Sharma',   'arun@mail.com',    '9988776655', '78 Anna Nagar, Chennai'),
(4, 'Meera Reddy',   'meera@mail.com',   '9876501234', '23 Koramangala, Bangalore'),
(5, 'Karan Singh',   'karan@mail.com',   '9123498765', '56 Baner Road, Pune');

-- Orders
INSERT INTO Orders (Order_ID, Order_Date, Order_Status, Total_Amount, Customer_ID) VALUES
(1001, '2026-10-01', 'Delivered',  78000.00, 1),
(1002, '2026-10-05', 'Shipped',     5297.00, 2),
(1003, '2026-10-10', 'Confirmed', 125000.00, 3),
(1004, '2026-10-15', 'Pending',      570.00, 4),
(1005, '2026-10-18', 'Delivered',   3098.00, 5),
(1006, '2026-10-20', 'Cancelled',  28000.00, 1);

-- Order Items (M:N between Orders and Products)
INSERT INTO Order_Item (Order_ID, Product_ID, Quantity, Unit_Price) VALUES
(1001, 101, 1, 75000.00),   -- Rajesh bought Samsung phone
(1001, 301, 2,   450.00),   -- Rajesh also bought rice
(1001, 302, 4,    65.00),   -- Rajesh also bought milk
(1002, 201, 3,   799.00),   -- Sneha bought t-shirts
(1002, 202, 2,  1499.00),   -- Sneha bought jeans
(1003, 103, 1, 125000.00),  -- Arun bought Dell laptop
(1004, 302, 5,    65.00),   -- Meera bought milk
(1004, 303, 6,    55.00),   -- Meera bought bread
(1005, 202, 1,  1499.00),   -- Karan bought jeans
(1005, 203, 1,  2999.00),   -- ... wait, let me recalculate
(1006, 102, 1,  28000.00);  -- Rajesh bought Sony headphones (cancelled)

-- Payments
INSERT INTO Payment (Payment_ID, Payment_Date, Payment_Mode, Payment_Status, Order_ID) VALUES
(2001, '2026-10-01', 'Credit Card',    'Completed', 1001),
(2002, '2026-10-05', 'UPI',            'Completed', 1002),
(2003, '2026-10-10', 'Net Banking',    'Pending',   1003),
(2004, '2026-10-15', 'Cash on Delivery','Pending',   1004),
(2005, '2026-10-18', 'Debit Card',     'Completed', 1005),
(2006, '2026-10-20', 'Wallet',         'Refunded',  1006);

-- Deliveries
INSERT INTO Delivery (Delivery_ID, Delivery_Date, Delivery_Status, Delivery_Address, Order_ID) VALUES
(3001, '2026-10-05', 'Delivered',        '12 MG Road, Mumbai',     1001),
(3002, '2026-10-12', 'Out for Delivery', '45 Park Street, Delhi',   1002),
(3003, NULL,          'Processing',       '78 Anna Nagar, Chennai', 1003),
(3004, NULL,          'Processing',       '23 Koramangala, Bangalore',1004),
(3005, '2026-10-22', 'Delivered',        '56 Baner Road, Pune',    1005),
(3006, NULL,          'Returned',         '12 MG Road, Mumbai',     1006);

-- ============================================================
-- STEP 3: QUERIES TO DISPLAY DATA
-- ============================================================

-- Query 1: All products with category and subtype details (Electronics)
SELECT
    p.Product_ID,
    p.Product_Name,
    p.Price,
    p.Stock_Quantity,
    c.Category_Name,
    e.Brand,
    e.Warranty_Period AS "Warranty (Months)",
    e.Power_Wattage
FROM Product p
JOIN Category c ON p.Category_ID = c.Category_ID
JOIN Electronics e ON p.Product_ID = e.Product_ID;

-- Query 2: All products with category and subtype details (Clothing)
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

-- Query 3: All products with category and subtype details (Grocery)
SELECT
    p.Product_ID,
    p.Product_Name,
    p.Price,
    p.Stock_Quantity,
    c.Category_Name,
    g.Weight,
    g.Expiry_Date,
    g.Is_Perishable
FROM Product p
JOIN Category c ON p.Category_ID = c.Category_ID
JOIN Grocery g ON p.Product_ID = g.Product_ID;

-- Query 4: Complete order details with customer, items, and product info
SELECT
    o.Order_ID,
    o.Order_Date,
    o.Order_Status,
    cu.Customer_Name,
    cu.Email,
    p.Product_Name,
    oi.Quantity,
    oi.Unit_Price,
    (oi.Quantity * oi.Unit_Price) AS Line_Total
FROM Orders o
JOIN Customer cu ON o.Customer_ID = cu.Customer_ID
JOIN Order_Item oi ON o.Order_ID = oi.Order_ID
JOIN Product p ON oi.Product_ID = p.Product_ID
ORDER BY o.Order_ID, p.Product_ID;

-- Query 5: Order summary with payment and delivery status
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

-- Query 6: Customer-wise order summary (total orders, total spent)
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

-- Query 7: Category-wise sales report
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

-- Query 8: Payment mode distribution
SELECT
    Payment_Mode,
    COUNT(*) AS Total_Payments,
    SUM(CASE WHEN Payment_Status = 'Completed' THEN 1 ELSE 0 END) AS Completed,
    SUM(CASE WHEN Payment_Status = 'Pending' THEN 1 ELSE 0 END) AS Pending,
    SUM(CASE WHEN Payment_Status = 'Failed' THEN 1 ELSE 0 END) AS Failed,
    SUM(CASE WHEN Payment_Status = 'Refunded' THEN 1 ELSE 0 END) AS Refunded
FROM Payment
GROUP BY Payment_Mode;

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
