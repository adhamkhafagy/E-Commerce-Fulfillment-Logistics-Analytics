-- ==========================================================
-- المخزون الحالي لكل مستودع أو مخزن
-- (current_stock هو View معرّف أصلاً في schema/fulfillment_schema_full.sql)
-- ==========================================================
SELECT
    warehouse_id,
    SUM(current_quantity) AS total_warehouse_current_stock
FROM current_stock
GROUP BY warehouse_id
ORDER BY warehouse_id;


-- ==========================================================
-- المنتجات اللي وصلت أو قربت من نقطة إعادة الطلب (Reorder Point)
-- ==========================================================
SELECT
    p.product_name,
    p.category,
    w.warehouse_name,
    cs.current_quantity,
    ip.reorder_point,
    ip.safety_stock,
    ip.target_stock,
    ip.lead_time_days,
    CASE
        WHEN cs.current_quantity <= ip.safety_stock THEN 'Critical'
        WHEN cs.current_quantity <= ip.reorder_point THEN 'Reorder Now'
        ELSE 'OK'
    END AS stock_status
FROM current_stock cs
JOIN inventory_policies ip
    ON ip.product_id = cs.product_id AND ip.warehouse_id = cs.warehouse_id
JOIN products p ON p.product_id = cs.product_id
JOIN warehouses w ON w.warehouse_id = cs.warehouse_id
WHERE cs.current_quantity <= ip.reorder_point
ORDER BY stock_status, cs.current_quantity ASC;


-- ==========================================================
-- دقة التوقع (Forecast Accuracy) لكل منتج - الفرق بين المتوقع والفعلي
-- ==========================================================
SELECT
    p.product_name,
    p.category,
    df.forecast_period,
    df.forecasted_demand,
    df.actual_demand,
    (df.actual_demand - df.forecasted_demand) AS variance,
    ROUND(
        ABS(df.actual_demand - df.forecasted_demand) * 100.0
        / NULLIF(df.actual_demand, 0), 2
    ) AS error_pct
FROM demand_forecast df
JOIN products p ON p.product_id = df.product_id
WHERE df.actual_demand IS NOT NULL
  AND df.actual_demand >= 5
ORDER BY error_pct DESC
LIMIT 30;


-- ==========================================================
-- متوسط دقة التوقع الإجمالي على مستوى الفئة (Category level)
-- ==========================================================
SELECT
    p.category,
    COUNT(*) AS forecast_count,
    ROUND(AVG(ABS(df.actual_demand - df.forecasted_demand)), 2) AS avg_absolute_error,
    ROUND(
        AVG(ABS(df.actual_demand - df.forecasted_demand) * 100.0 / NULLIF(df.actual_demand, 0)), 2
    ) AS avg_error_pct
FROM demand_forecast df
JOIN products p ON p.product_id = df.product_id
WHERE df.actual_demand IS NOT NULL
  AND df.actual_demand >= 5
GROUP BY p.category
ORDER BY avg_error_pct DESC;


-- ==========================================================
-- المخازن اللي عندها أعلى عدد منتجات تحت نقطة إعادة الطلب
-- (بيوضح أنهي مخزن محتاج اهتمام فوري في التوريد)
-- ==========================================================
SELECT
    w.warehouse_name,
    w.city,
    COUNT(*) AS products_below_reorder,
    COUNT(*) FILTER (WHERE cs.current_quantity <= ip.safety_stock) AS critical_products
FROM current_stock cs
JOIN inventory_policies ip
    ON ip.product_id = cs.product_id AND ip.warehouse_id = cs.warehouse_id
JOIN warehouses w ON w.warehouse_id = cs.warehouse_id
WHERE cs.current_quantity <= ip.reorder_point
GROUP BY w.warehouse_name, w.city
ORDER BY critical_products DESC, products_below_reorder DESC;
