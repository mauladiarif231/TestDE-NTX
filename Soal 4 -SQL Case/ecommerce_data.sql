---------- Soal 3 --------------------

-- Total revenue generated from each channel grouping for the top 5 countries producing the highest revenue
SELECT 
    channelGrouping,
    country,
    SUM(totalTransactionRevenue) AS totalRevenue
FROM 
    ecommerce_data
GROUP BY 
    channelGrouping, country
ORDER BY 
    totalRevenue DESC
LIMIT 5;


-- Metrics like average timeOnSite, average pageviews, and average sessionQualityDim for each fullVisitorId
WITH UserMetrics AS (
    SELECT 
        fullVisitorId,
        AVG(timeOnSite) AS avgTimeOnSite,
        AVG(pageviews) AS avgPageviews,
        AVG(sessionQualityDim) AS avgSessionQualityDim
    FROM 
        ecommerce_data
    GROUP BY 
        fullVisitorId
)
SELECT 
    um.fullVisitorId,
    um.avgTimeOnSite,
    um.avgPageviews,
    um.avgSessionQualityDim
FROM 
    UserMetrics um
JOIN 
    ecommerce_data ed ON um.fullVisitorId = ed.fullVisitorId
WHERE 
    ed.timeOnSite > (SELECT AVG(timeOnSite) FROM ecommerce_data)
    AND ed.pageviews < (SELECT AVG(pageviews) FROM ecommerce_data);

-- Performance of each product: total revenue, total quantity sold, total refund amount, rank products based on net revenue
WITH ProductPerformance AS (
    SELECT 
        v2ProductName,
        SUM(totalTransactionRevenue) AS totalRevenue,
        UM(CASE 
            WHEN totalTransactionRevenue != '' THEN 1
            ELSE 0
        END) AS totalProductQuantity,
        SUM(productRefundAmount) AS totalRefundAmount,
        SUM(totalTransactionRevenue - productRefundAmount) AS netRevenue
    FROM 
        ecommerce_data
    GROUP BY 
        v2ProductName
)
SELECT 
    pp.v2ProductName,
    pp.totalRevenue,
    pp.totalQuantity,
    pp.totalRefundAmount,
    pp.netRevenue,
    CASE 
        WHEN pp.totalRefundAmount > (0.1 * pp.totalRevenue) THEN 'Refund exceeds 10%'
        ELSE 'Normal'
    END AS refundFlag
FROM 
    ProductPerformance pp
ORDER BY 
    netRevenue DESC;
    




