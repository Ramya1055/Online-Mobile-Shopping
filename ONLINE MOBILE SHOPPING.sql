CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE NOT NULL,
    Address TEXT
);
CREATE TABLE Mobiles (
    MobileID INT PRIMARY KEY AUTO_INCREMENT,
    Brand VARCHAR(50) NOT NULL,
    Model VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL,
    Specifications TEXT
);
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    OrderDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    MobileID INT,
    Quantity INT NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (MobileID) REFERENCES Mobiles(MobileID) ON DELETE CASCADE
);
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    PaymentMethod ENUM('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Cash on Delivery') NOT NULL,
    PaymentStatus ENUM('Success', 'Failed', 'Pending') DEFAULT 'Pending',
    TransactionID VARCHAR(50) UNIQUE,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);

INSERT INTO Users (Name, Email, PhoneNumber, Address) VALUES
('Nelofer', 'nelu@example.com', '2311001147', '123 Street, Delhi'),
('Sai Divya', 'divya@example.com', '2311001146', '456 Avenue, Mumbai'),
('Ramya', 'ramya@example.com', '2311001145', '789 Road, Bangalore'),
('Mounika', 'mounika@example.com', '2311001143', '101 Colony, Chennai');
INSERT INTO Mobiles (Brand, Model, Price, Stock, Specifications) VALUES
('Apple', 'iPhone 15', 79999.00, 10, '128GB, A16 Bionic, Dual Camera'),
('Samsung', 'Galaxy S23', 74999.00, 15, '256GB, Snapdragon 8 Gen 2, Triple Camera'),
('OnePlus', 'OnePlus 11', 56999.00, 20, '128GB, Snapdragon 8 Gen 2, 50MP Camera'),
('Xiaomi', 'Redmi Note 12', 19999.00, 30, '128GB, MediaTek Dimensity, 108MP Camera');
INSERT INTO Orders (UserID, OrderDate, TotalAmount, Status) VALUES
(1, '2024-03-21 10:30:00', 79999.00, 'Pending'),       -- Anand's First Order
(1, '2024-03-22 15:45:00', 134998.00, 'Delivered'),   -- Anand's Second Order
(2, '2024-03-21 11:00:00', 74999.00, 'Shipped'),      -- Ravi's Order
(3, '2024-03-21 12:15:00', 39998.00, 'Delivered'),    -- Priya's Order (2 items)
(4, '2024-03-21 13:45:00', 56999.00, 'Cancelled');    -- Sneha's Cancelled Order
INSERT INTO OrderDetails (OrderID, MobileID, Quantity, Subtotal) VALUES
(1, 1, 1, 79999.00),    -- Anand buys 1 iPhone 15 (Pending Order)
(2, 1, 1, 79999.00),    -- Anand buys another iPhone 15 (Delivered Order)
(2, 2, 1, 54999.00),    -- Anand also buys Galaxy S23 in same order
(3, 2, 1, 74999.00),    -- Ravi buys 1 Galaxy S23 (Shipped Order)
(4, 4, 2, 39998.00),    -- Priya buys 2 Redmi Note 12 (Delivered Order)
(5, 3, 1, 56999.00);    -- Sneha buys 1 OnePlus 11 (Cancelled Order)
INSERT INTO Payments (OrderID, PaymentMethod, PaymentStatus, TransactionID) VALUES
(1, 'Credit Card', 'Pending', 'TXN1001'),   -- Anand's first order (Pending)
(2, 'UPI', 'Success', 'TXN1002'),          -- Anand's second order (Successful)
(3, 'Net Banking', 'Success', 'TXN1003'),  -- Ravi's order (Successful)
(4, 'Debit Card', 'Success', 'TXN1004'),   -- Priya's order (Successful)
(5, 'UPI', 'Failed', 'TXN1005');           -- Sneha's cancelled order (Failed Payment)


SELECT M.Brand, SUM(OD.Quantity) AS TotalUnitsSold, SUM(OD.Subtotal) AS TotalRevenue
FROM OrderDetails OD
JOIN Mobiles M ON OD.MobileID = M.MobileID
JOIN Orders O ON OD.OrderID = O.OrderID
WHERE O.Status = 'Delivered'
GROUP BY M.Brand; -- aggregate-total sales per mobile brand

SELECT O.OrderID, U.Name AS CustomerName, U.Email, M.Brand, M.Model, 
       OD.Quantity, OD.Subtotal, O.Status
FROM Orders O
JOIN Users U ON O.UserID = U.UserID
JOIN OrderDetails OD ON O.OrderID = OD.OrderID
JOIN Mobiles M ON OD.MobileID = M.MobileID; -- join-view order details with user n mobile info

SELECT U.UserID, U.Name, U.Email 
FROM Users U
WHERE U.UserID IN (
    SELECT UserID FROM Orders 
    GROUP BY UserID 
    HAVING COUNT(OrderID) > 1
); -- subquery - find users who placed more than 1 order 

SELECT U.UserID, U.Name, O.OrderID, O.TotalAmount
FROM Orders O
JOIN Users U ON O.UserID = U.UserID
WHERE O.TotalAmount = (
    SELECT MAX(TotalAmount) FROM Orders O2 
    WHERE O2.UserID = O.UserID
); -- join+aggregate+subquery - most expensive order per user

CREATE VIEW OrderSummary AS
SELECT O.OrderID, U.Name AS CustomerName, M.Brand, M.Model, 
       OD.Quantity, O.TotalAmount, O.Status, P.PaymentMethod, P.PaymentStatus
FROM Orders O
JOIN Users U ON O.UserID = U.UserID
JOIN OrderDetails OD ON O.OrderID = OD.OrderID
JOIN Mobiles M ON OD.MobileID = M.MobileID
JOIN Payments P ON O.OrderID = P.OrderID; -- view-create for quick order summary
SELECT * FROM OrderSummary;