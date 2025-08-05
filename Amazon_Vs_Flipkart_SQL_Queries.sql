use sqlproject;
select * from amazon_sales_data;
#1.Total Sales per Platform
SELECT 'Amazon' AS Platform, SUM(SalesAmount) AS TotalSales FROM amazon_sales_data
UNION ALL
SELECT 'Flipkart', SUM(SalesAmount) FROM flipkart_sales_data;


#2.Total Orders per Platform
SELECT 'amazon' as 'platform',SUM(QUANTITY ) as total_order FROM amazon_sales_data
union all
SELECT 'flipkart' as 'platform',SUM(QUANTITY) FROM flipkart_sales_data;


#3.Region-wise Sales Distribution Comparison
SELECT Region, 'Amazon' AS Platform, SUM(SalesAmount) AS TotalSales FROM amazon_sales_data GROUP BY Region
UNION ALL
SELECT Region, 'Flipkart', SUM(SalesAmount) FROM flipkart_sales_data GROUP BY Region;


#4.Monthly Sales Trend Comparison
SELECT 'Amazon' AS Platform, DATE_FORMAT(Date, '%Y-%m') AS Month, SUM(SalesAmount) AS MonthlySales
FROM amazon_sales_data
GROUP BY DATE_FORMAT(Date, '%Y-%m')
UNION ALL
SELECT 'Flipkart', DATE_FORMAT(Date, '%Y-%m'), SUM(SalesAmount)
FROM flipkart_sales_data
GROUP BY DATE_FORMAT(Date, '%Y-%m');

#5.Average Order Value (AOV) per Platform
select 'amazon' as 'platform' ,avg(salesamount) as 'average amount' from amazon_sales_data
union all
select 'fkipcart' as 'platform' ,avg(salesamount) as 'average amount' from flipkart_sales_data;

#6. Top 5 Products by Sales (Amazon & Flipkart)
SELECT ProductID, 'Amazon' AS Platform, TotalSales FROM (
    SELECT ProductID, SUM(SalesAmount) AS TotalSales
    FROM Amazon_Sales_data
    GROUP BY ProductID
    ORDER BY TotalSales DESC
    LIMIT 5
) AS AmazonTop5

UNION ALL

SELECT ProductID, 'Flipkart' AS Platform, TotalSales FROM (
    SELECT ProductID, SUM(SalesAmount) AS TotalSales
    FROM Flipkart_Sales_data
    GROUP BY ProductID
    ORDER BY TotalSales DESC
    LIMIT 5
) AS FlipkartTop5;



#7. Region with Highest Sales per Platform
SELECT Platform, Region, TotalSales FROM (
    SELECT 'Amazon' AS Platform, Region, SUM(SalesAmount) AS TotalSales, RANK() OVER (PARTITION BY 'Amazon' ORDER BY SUM(SalesAmount) DESC) AS rk FROM Amazon_Sales_data GROUP BY Region
    UNION ALL
    SELECT 'Flipkart', Region, SUM(SalesAmount), RANK() OVER (PARTITION BY 'Flipkart' ORDER BY SUM(SalesAmount) DESC) FROM Flipkart_Sales_data GROUP BY Region
) t WHERE rk = 1;



#8. Running Total of Sales Month-wise (Platform-wise)
SELECT Platform, Month, SUM(TotalSales) OVER (PARTITION BY Platform ORDER BY Month) AS RunningTotal
FROM (
    SELECT 'Amazon' AS Platform, DATE_FORMAT(Date, '%Y-%m') AS Month, SUM(SalesAmount) AS TotalSales
    FROM Amazon_Sales_data
    GROUP BY DATE_FORMAT(Date, '%Y-%m')

    UNION ALL

    SELECT 'Flipkart', DATE_FORMAT(Date, '%Y-%m'), SUM(SalesAmount)
    FROM Flipkart_Sales_data
    GROUP BY DATE_FORMAT(Date, '%Y-%m')
)t;

#9.Top 3 Customers by Sales per Platform

SELECT * FROM (
    SELECT CustomerID, 'Amazon' AS Platform, SUM(SalesAmount) AS TotalSales, RANK() OVER (PARTITION BY 'Amazon' ORDER BY SUM(SalesAmount) DESC) AS rnk 
    FROM Amazon_Sales_data GROUP BY CustomerID
    UNION ALL
    SELECT CustomerID, 'Flipkart', SUM(SalesAmount), RANK() OVER (PARTITION BY 'Flipkart' ORDER BY SUM(SalesAmount) DESC) 
    FROM Flipkart_Sales_data GROUP BY CustomerID
) t WHERE rnk <= 3;

#10. Average Rating per Platform

SELECT 'Amazon' AS Platform, ROUND(AVG(Rating),2) AS AvgRating FROM Amazon_Sales_data
UNION ALL
SELECT 'Flipkart', ROUND(AVG(Rating),2) FROM Flipkart_Sales_data;



#12. Product-wise Average Rating Comparison
SELECT ProductID, 'Amazon' AS Platform, ROUND(AVG(Rating),2) AS AvgRating FROM Amazon_Sales_data GROUP BY ProductID
UNION ALL
SELECT ProductID, 'Flipkart', ROUND(AVG(Rating),2) FROM Flipkart_Sales_data GROUP BY ProductID;


#13. Product Sales Ranking Within Each Platform

SELECT ProductID, Platform, TotalSales, RANK() OVER (PARTITION BY Platform ORDER BY TotalSales DESC) AS SalesRank
FROM (
    SELECT ProductID, 'Amazon' AS Platform, SUM(SalesAmount) AS TotalSales FROM Amazon_Sales_data GROUP BY ProductID
    UNION ALL
    SELECT ProductID, 'Flipkart', SUM(SalesAmount) FROM Flipkart_Sales_data GROUP BY ProductID
) t;

#14. Identify Repeat Customers Who Ordered from Both Amazon & Flipkart

SELECT DISTINCT a.CustomerID
FROM Amazon_Sales_data a
JOIN Flipkart_Sales_data f ON a.CustomerID = f.CustomerID;


#15. First Purchase Date per Customer per Platform
SELECT Platform, CustomerID, MIN(Date) AS FirstPurchaseDate FROM (
    SELECT 'Amazon' AS Platform, CustomerID, Date FROM Amazon_Sales_data
    UNION ALL
    SELECT 'Flipkart', CustomerID, Date FROM Flipkart_Sales_data
) t GROUP BY Platform, CustomerID;


#16. Percentage Contribution of Each Platform to Total Sales
SELECT Platform, 
       ROUND(SUM(SalesAmount) * 100 / (SELECT SUM(SalesAmount) FROM (
           SELECT SalesAmount FROM Amazon_Sales_data
           UNION ALL
           SELECT SalesAmount FROM Flipkart_Sales_data
       ) AS combined), 2) AS SalesPercentage
FROM (
    SELECT 'Amazon' AS Platform, SalesAmount FROM Amazon_Sales_data
    UNION ALL
    SELECT 'Flipkart', SalesAmount FROM Flipkart_Sales_data
) t
GROUP BY Platform;
#18. Product with Highest Quantity Sold per Platform

SELECT Platform, ProductID, TotalQty FROM (
    SELECT 'Amazon' AS Platform, ProductID, SUM(Quantity) AS TotalQty, RANK() OVER (PARTITION BY 'Amazon' ORDER BY SUM(Quantity) DESC) AS rk FROM Amazon_Sales_data GROUP BY ProductID
    UNION ALL
    SELECT 'Flipkart', ProductID, SUM(Quantity), RANK() OVER (PARTITION BY 'Flipkart' ORDER BY SUM(Quantity) DESC) FROM Flipkart_Sales_data GROUP BY ProductID
) t WHERE rk = 1;





#19. Date-wise Order Count per Platform
SELECT Date, Platform, COUNT(OrderID) AS OrderCount FROM (
    SELECT Date, 'Amazon' AS Platform, OrderID FROM Amazon_Sales_data
    UNION ALL
    SELECT Date, 'Flipkart'as platform, OrderID FROM Flipkart_Sales_data
) t 
GROUP BY Date, Platform
order by date,platform;



#20. Find Customers Whose Average Order Value is Above Platform Average
WITH PlatformAOV AS (
    SELECT 'Amazon' AS Platform, AVG(SalesAmount) AS AOV FROM Amazon_Sales_data
    UNION ALL
    SELECT 'Flipkart', AVG(SalesAmount) FROM Flipkart_Sales_data
)
SELECT 
    s.CustomerID, 
    s.Platform, 
    AVG(s.SalesAmount) AS CustomerAOV,
    p.AOV
FROM (
    SELECT CustomerID, 'Amazon' AS Platform, SalesAmount FROM Amazon_Sales_data
    UNION ALL
    SELECT CustomerID, 'Flipkart', SalesAmount FROM Flipkart_Sales_data
) s
JOIN PlatformAOV p ON s.Platform = p.Platform
GROUP BY s.CustomerID, s.Platform, p.AOV
HAVING CustomerAOV > p.AOV;



#22. Find Products with High Sales but Low Ratings
SELECT ProductID, Platform, SUM(SalesAmount) AS TotalSales, AVG(Rating) AS AvgRating
FROM (
    SELECT ProductID, 'Amazon' AS Platform, SalesAmount, Rating FROM Amazon_Sales_data
    UNION ALL
    SELECT ProductID, 'Flipkart', SalesAmount, Rating FROM Flipkart_Sales_data
) t
GROUP BY ProductID, Platform
HAVING TotalSales > 50000 AND AvgRating < 3.5;


#23. Calculate Year-over-Year Growth Rate in Sales
WITH AmazonYearly AS (
    SELECT 'Amazon' AS Platform, YEAR(Date) AS Year, SUM(SalesAmount) AS TotalSales
    FROM Amazon_Sales_data
    GROUP BY YEAR(Date)
),
FlipkartYearly AS (
    SELECT 'Flipkart' AS Platform, YEAR(Date) AS Year, SUM(SalesAmount) AS TotalSales
    FROM Flipkart_Sales_data
    GROUP BY YEAR(Date)
),
YearlySales AS (
    SELECT * FROM AmazonYearly
    UNION ALL
    SELECT * FROM FlipkartYearly
)
SELECT Platform, Year, TotalSales,
       ROUND((TotalSales - LAG(TotalSales) OVER (PARTITION BY Platform ORDER BY Year)) * 100 / LAG(TotalSales) OVER (PARTITION BY Platform ORDER BY Year), 2) AS YoY_Growth
FROM YearlySales;


#24. Customers Who Ordered Frequently (More than 5 times)

SELECT Platform, CustomerID, COUNT(OrderID) AS OrderCount FROM (
    SELECT 'Amazon' AS Platform, CustomerID, OrderID FROM Amazon_Sales_data
    UNION ALL
    SELECT 'Flipkart', CustomerID, OrderID FROM Flipkart_Sales_data
) t GROUP BY Platform, CustomerID HAVING OrderCount > 5;



#25. Total Quantity Sold per State per Platform

SELECT Platform, Region, SUM(Quantity) AS TotalQuantity FROM (
    SELECT 'Amazon' AS Platform, Region, Quantity FROM Amazon_Sales_data
    UNION ALL
    SELECT 'Flipkart', Region, Quantity FROM Flipkart_Sales_data
) t GROUP BY Platform, Region;




