-- I want to help a startup film photography company's launch. This DB will allow the company to:
-- Find the most and least popular products, for future orders.
-- Check the average customer spend, for future product pricing.
-- Keep track of their customer base. With customer data they can reward loyal and high spending customers.
-- Quickly check via a stored procedure to see total customer spend from each month.
-- Have an emailing list of their customers, via a view.

CREATE database FilmPhotographyStartup;
USE FilmPhotographyStartup;

CREATE TABLE Products (
    ProductId INT PRIMARY KEY AUTO_INCREMENT,
    FilmType VARCHAR(50),
    FilmFormat VARCHAR(50),
    FilmName VARCHAR(50),
    Brand VARCHAR(50),
    FilmIso INT,
    Price DECIMAL(5,2),
    StockLevel INT,
    CONSTRAINT chk_in_stock CHECK(StockLevel > 0)
);

-- SELECT * FROM Products;

ALTER TABLE Products
ADD CONSTRAINT
UNIQUE(FilmName);

CREATE TABLE Customers (
    CustomerId INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    Surname VARCHAR(50),
    Email VARCHAR(64) NOT NULL,
    PhoneNumber VARCHAR(15) DEFAULT NULL
);

CREATE TABLE Sales (
    TransactionId INT AUTO_INCREMENT PRIMARY KEY,
    CustomerId INT,
    ProductId INT,
    SaleDate DATE NOT NULL,
    Quantity INT,
    TransactionAmount DECIMAL(6, 2),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId)
    ON DELETE SET NULL,
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
) AUTO_INCREMENT = 1000;

-- SELECT * FROM Sales;

-- Trigger for decreasing stock level after a purchase
DELIMITER $$
CREATE TRIGGER DecreaseStockLevelAfterPurchase
AFTER INSERT ON Sales
FOR EACH ROW
BEGIN
    UPDATE Products
    SET StockLevel = StockLevel - NEW.Quantity
    WHERE ProductId = NEW.ProductId;
END $$
DELIMITER ;

INSERT INTO Products (FilmType, FilmFormat, FilmName, Brand, FilmIso, Price, StockLevel)
VALUES ("colour", "35mm", "Kodak UltraMax 400", "Kodak", 400, 9.80, 200),
("colour", "35mm", "Kodak Gold 200", "Kodak", 200, 10.50, 280),
("colour", "35mm", "Kodak Portra 160", "Kodak", 160, 17.99, 170),
("colour", "35mm", "CineStill 800T", "Cinestill", 800, 19.00, 150),
("colour", "120 film", "Cinestill 50D", "Cinestill", 50, 22.00, 40),
("slide", "120 film", "Kodak Ektachrome E100", "Kodak", 100, 23.00, 50),
("black and white", "35mm", "Ilford HP5 Plus", "Ilford", 400, 7.99, 220),
("infrared", "35mm", "Rollei Infrared", "Rollei", 400, 9.00, 30),
("instant", "600 instant film", "Polaroid 600 Colour FIlm", "Polaroid", 640, 15.00, 85),
("black and white", "120 film", "Ilford FP4 Plus", "Ilford", 120, 6.50, 55),
("black and white", "35mm", "Street Candy ATM400", "Street Candy", 400, 12.00, 400),
("black and white", "120 film", "Kodak Tri-X 400", "Kodak", 400, 8.50, 35);


INSERT INTO Customers (FirstName, Surname, Email, PhoneNumber)
VALUES ("Charlotte", "McKnight", "charmckcamera@gmail.com", '+447642603406'),
("Desmond", "Clayton", "desyclayton@yahoo.co.uk" , '07880501776'),
("Harry", "Jenson", "jjharry@gmail.com", '07455728193'),
("Lydia", "Myles", "lydiam23@gmail.com", '07732612973'),
("Farid", "Razak", "faridfarid2@yahoo.com", '07448748392'),
("Simon", "Webbster", "siwebb77@hotmail.co.uk", '0733569021'),
("Aoife", "Stone", "aoife_bronagh@hotmail.co.uk", NULL),
("Katarina", "Plechek", "plecheckkat@gmail.com", NULL),
("Alex", "Trevlyn", "trev_al@gmail.com", '07928557399'),
("Xavier", "Didier", "xavdidier@yahoomail.fr", '+336938201394'),
("Lisa", "Newton", "newalisa@hotmail.co.uk", NULL);

-- Rectifying typo in customer email address 
UPDATE Customers
SET Email = "plechekkat@gmail.com"
WHERE CustomerId = 8;

-- checking table
-- SELECT * FROM Customers;

INSERT INTO Sales (CustomerId, ProductId, SaleDate, Quantity, TransactionAmount)
VALUES
    (1, 1, '2023-09-24', 2, 19.60),
    (1, 1, '2023-09-24', 1, 9.99),
    (2, 3, '2023-09-25', 3, 53.97),
    (4, 11, '2023-09-25', 1, 12.00),
    (7, 12, '2023-09-27', 1, 8.50),
    (8, 7, '2023-09-29', 6, 47.94),
    (6, 4, '2023-09-30', 1, 19.00),
    (6, 3, '2023-09-30', 2, 35.98),
    (6, 2, '2023-09-30', 1, 10.50),
    (3, 9, '2023-10-01', 2, 30.00),
    (5, 1, '2023-10-02', 2, 19.60),
    (5, 10, '2023-10-02', 2, 13.00),
    (9, 5, '2023-10-03', 1, 22.00),
    (9, 4, '2023-10-03', 2, 38.00),
    (9, 7, '2023-10-03', 1, 7.99),
    (11, 1, '2023-10-04', 1, 9.80),
	(11, 2, '2023-10-04', 1, 10.50),    
    (11, 3, '2023-10-04', 1, 17.99),
	(11, 12, '2023-10-04', 1, 8.50),
    (1, 4, '2023-10-05', 2, 38.00),
    (1, 11, '2023-10-05', 1, 12.00),
    (3, 10, '2023-10-05', 1, 6.50),
    (4, 10, '2023-10-05', 1, 6.50);

-- checking to see if trigger worked
-- SELECT * FROM Products;

-- Example if customer wants their account deleted but we still want to save their purchase in the sales table
DELETE FROM Customers
WHERE CustomerId = 2;

-- checking to see if prev code worked
 -- SELECT * FROM Sales;

-- Creating a view of customer emails
CREATE VIEW CustomerMailingList AS
SELECT Email
FROM Customers;

SELECT * FROM CustomerMailingList

-- stored procedure:
-- User types in month number and total sales amounth of sepecified month is returned
DELIMITER $$
CREATE PROCEDURE MonthlySalesFigure(IN MonthNumber INT)
BEGIN
    SELECT
        SUM(s.TransactionAmount) AS MonthSalesAmount
    FROM
        Sales s
    WHERE
        MONTH(s.SaleDate) = MonthNumber;
END $$
DELIMITER ;

CALL MonthlySalesFigure(9);
CALL MonthlySalesFigure(10);

-- various queries:

-- inner join to show 5 most popular film names based on sales quantity
SELECT p.FilmName, SUM(s.Quantity) AS TotalSales
FROM Sales s
INNER JOIN Products p ON s.ProductId = p.ProductId
GROUP BY p.FilmName
ORDER BY TotalSales DESC
LIMIT 5;

-- left join to show the most and least profitable film names. I'm using left join as I want to show and include NULL values 
SELECT p.FilmName, SUM(s.TransactionAmount) AS TotalProfit
FROM Products p
LEFT JOIN Sales s ON p.ProductId = s.ProductId
GROUP BY p.FilmName
ORDER BY TotalProfit DESC;

-- right join finding most to least popular film type
SELECT p.FilmType, SUM(s.Quantity) AS TotalSalesQuantity
FROM Sales s
RIGHT JOIN Products p ON s.ProductId = p.ProductId
GROUP BY p.FilmType
ORDER BY TotalSalesQuantity DESC;

-- Query to see how many customers bought BOTH black and white and colour film
SELECT COUNT(*) AS TotalCustomers
FROM (
    SELECT s.CustomerId
    FROM Sales s
    JOIN Products p ON s.ProductId = p.ProductId
    WHERE p.FilmType IN ('black and white', 'colour')
    GROUP BY s.CustomerId
    HAVING COUNT(DISTINCT p.FilmType) = 2
) AS CustomersMeetingCriteria;


-- how much the average customer spends at the store. this may be helpful for future pricing.
SELECT ROUND(AVG(AvgSpend), 2) AS AverageCustomerSpend
FROM (
    SELECT AVG(s.TransactionAmount) AS AvgSpend
    FROM Customers c
    LEFT JOIN Sales s ON c.CustomerId = s.CustomerId
) AS CustomerAverages;

-- finding the 3 highest spending customers. We can email them a discount code for future purchases/
SELECT CONCAT(c.FirstName, ' ', c.Surname) AS CustomerName, c.Email, SUM(s.TransactionAmount) AS TotalSpend
FROM Customers c  
JOIN Sales s ON c.CustomerId = s.CustomerId
GROUP BY c.CustomerId, CustomerName, c.Email
ORDER BY TotalSpend DESC
LIMIT 3;

-- Query to find customers who ordered before October. These are the oldest customers and can receive a loyalty reward via email.
SELECT DISTINCT c.CustomerId, CONCAT(c.FirstName, ' ', c.Surname) AS CustomerName, c.Email
FROM Customers c
JOIN Sales s ON c.CustomerId = s.CustomerId
WHERE DATE_FORMAT(s.SaleDate, '%Y-%m') < '2023-10'
ORDER BY c.CustomerId;






