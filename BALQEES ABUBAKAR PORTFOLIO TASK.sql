--1. Retrieve the list of all persons and their corresponding job titles, including those without any employee record.
SELECT 
    p.FirstName,
    p.LastName,
    e.JobTitle
FROM 
    person.Person AS p
LEFT JOIN 
    HumanResources.Employee AS e ON p.BusinessEntityID = e.BusinessEntityID
ORDER BY 
    p.LastName, p.FirstName;

--2. Retrieve the names and account number of all customers who have placed orders, 
-- along with the total amount of their orders
SELECT p.FirstName, p.LastName, c.AccountNumber, SUM(so.TotalDue) AS TotalOrderAmount
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader so ON c.CustomerID = so.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName, c.AccountNumber;

--3. Retrieve first names of employees starting with “A” and their job titles
SELECT 
       p.FirstName,
       p.LastName,
       e.JobTitle
FROM 
      person.Person AS p
INNER JOIN 
      HumanResources.Employee AS e ON  p.BusinessEntityID = e.BusinessEntityID
WHERE 
     p.FirstName LIKE 'A%'
ORDER BY 
    p.LastName;

--4.Retrieve the names of employees hired in the last three years and the number of employees that fall under each job title.
SELECT 
    p.FirstName,
    p.LastName,
    e.JobTitle,
    COUNT(e.BusinessEntityID) AS EmployeeCount
FROM 
    person.Person AS p
INNER JOIN 
    HumanResources.Employee AS e ON p.BusinessEntityID = e.BusinessEntityID
WHERE 
    e.HireDate >= DATEADD(YEAR, -3, GETDATE())
GROUP BY 
    p.FirstName,
    p.LastName,
    e.JobTitle
ORDER BY 
    e.JobTitle;
	
--5. Get the data (names and contact details) of persons who are employees but have not provided a middle name.
SELECT Name
FROM Production.Product AS p
WHERE p.ProductID NOT IN (
    SELECT DISTINCT ProductID
    FROM Sales.SalesOrderDetail);

--6. From Production.Product table, get a list of products that have never been sold.
SELECT Name
FROM Production.Product AS p
WHERE p.ProductID NOT IN (
    SELECT DISTINCT ProductID
    FROM Sales.SalesOrderDetail);

--7. Find all products that have a list price higher than the average list price of all products.
SELECT Name, ListPrice
From Production.Product
Where ListPrice > (SELECT AVG(ListPrice) FROM Production.Product);

--8. retrieve a list of all employees' full names (which should combine the first name, last name, and middle name with a space
--between the names and a full stop before the middle name), email addresses, and phone numbers.
SELECT CONCAT(pp.FirstName, ' ', pp.LastName, ' ', pp.MiddleName, '.') AS Full_Name, pe.EmailAddress, pph.PhoneNumber
FROM Person.Person pp
INNER JOIN Person.EmailAddress pe
ON pp.BusinessEntityID = pe.BusinessEntityID
INNER JOIN Person.PersonPhone pph
ON pe.BusinessEntityID = pph.BusinessEntityID
WHERE pp.PersonType IN ('EM');

--9. Determine the total sales amount for each product within each territory and rank them in descending order of sales
SELECT pp.Name, sst.Name, SUM(sod.LineTotal) AS TotalSalesAmount   
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product pp
ON sod.ProductID = pp.ProductID
INNER JOIN Sales.SalesOrderHeader soh
ON sod.SalesOrderID = soh.SalesOrderID
INNER JOIN Sales.SalesTerritory sst
ON soh.TerritoryID = sst.TerritoryID
WHERE soh.OrderDate LIKE '%2011%'
GROUP BY pp.Name,sst.Name
ORDER BY TotalSalesAmount DESC;

--10. Retrieve which departments have more than 5 employees and list them in descending order based on the number of employees
SELECT hd.Name, COUNT(he.BusinessEntityID)AS TotalEmployees
FROM HumanResources.Employee he
INNER JOIN HumanResources.EmployeeDepartmentHistory hed
ON he.BusinessEntityID = hed.BusinessEntityID
INNER JOIN HumanResources.Department hd
ON hed.DepartmentID = hd.DepartmentID
GROUP BY hd.Name
HAVING COUNT(he.BusinessEntityID) >5
ORDER BY TotalEmployees DESC;

--11. Calculate the total sales amount for each product from Sales.SalesOrderHeader and Sales.SalesOrderDetail tables. 
--Display the product name alongside its total sales amount.
WITH TotalSales AS (
    SELECT 
        p.ProductID, 
        SUM(soh.TotalDue) AS TotalSales
    FROM 
        Sales.SalesOrderHeader AS soh
    JOIN 
        Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN 
        Production.Product AS p ON sod.ProductID = p.ProductID
    GROUP BY 
        p.ProductID)
SELECT 
    p.Name, 
    ts.TotalSales
FROM 
    TotalSales ts
JOIN 
    Production.Product AS p ON ts.ProductID = p.ProductID
ORDER BY 
    ts.TotalSales DESC;

--12. Arrange in decreasing order the month name from the startdate column that occurs the most (e.g January etc)
SELECT DATENAME(month, StartDate)  AS MONTH, COUNT(StartDate) Total_Occurence
FROM Production.BillOfMaterials
GROUP BY DATENAME(month, StartDate)
ORDER BY COUNT(StartDate) DESC;

--13. Calculate the total sales for each product and return products with total sales greater than $10,000 
--using the Sales.SalesOrderDetail and Production.Product tables.
WITH ProductSales AS (
    SELECT 
        p.Name AS ProductName,
        SUM(sod.LineTotal) AS TotalSales
    FROM 
        Sales.SalesOrderDetail sod
    JOIN 
        Production.Product p ON sod.ProductID = p.ProductID
    GROUP BY 
        p.Name)
SELECT 
    ProductName, TotalSales
FROM 
    ProductSales
WHERE 
    TotalSales > 10000;

--14. Find the average order value for each customer who has placed at least 5 orders, 
-- and list their names along with the average order value
WITH CustomerOrderCount AS (
    SELECT 
        oh.CustomerID,
        p.FirstName + ' ' + p.LastName AS CustomerName,
        COUNT(oh.SalesOrderID) AS OrderCount,
        AVG(oh.TotalDue) AS AverageOrderValue
    FROM 
        Sales.SalesOrderHeader oh
    JOIN 
        Person.Person p ON oh.CustomerID = p.BusinessEntityID
    GROUP BY 
        oh.CustomerID, p.FirstName, p.LastName)
SELECT 
    CustomerName, 
    AverageOrderValue
FROM 
    CustomerOrderCount
WHERE 
    OrderCount >= 5;

--15. Calculate total sales amount for each year from Sales.SalesOrderHeader table
WITH YearlySales AS (
    SELECT 
        YEAR(OrderDate) AS SalesYear,
        SUM(TotalDue) AS TotalSales
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        YEAR(OrderDate))
SELECT 
    SalesYear, 
    TotalSales 
FROM 
    YearlySales
ORDER BY 
    SalesYear;






















