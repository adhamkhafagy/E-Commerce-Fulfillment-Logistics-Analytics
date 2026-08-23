-- ==========================================================
-- نسبة الـ RTO/RTV شهريًا من إجمالي الأوردرات
-- ==========================================================
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT r.order_id) FILTER (WHERE r.return_type = 'RTO') AS rto_count,
    COUNT(DISTINCT r.order_id) FILTER (WHERE r.return_type = 'RTV') AS rtv_count,
    ROUND(
        COUNT(DISTINCT r.order_id) FILTER (WHERE r.return_type = 'RTO') * 100.0
        / NULLIF(COUNT(DISTINCT o.order_id), 0), 2
    ) AS rto_rate_pct,
    ROUND(
        COUNT(DISTINCT r.order_id) FILTER (WHERE r.return_type = 'RTV') * 100.0
        / NULLIF(COUNT(DISTINCT o.order_id), 0), 2
    ) AS rtv_rate_pct
FROM orders o
JOIN dim_dates d ON o.order_date = d.date_key
LEFT JOIN returns r ON r.order_id = o.order_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ==========================================================
-- أعلى فئات المنتجات في نسبة RTV (سبب المرتجع من العميل)
-- ==========================================================
SELECT
    p.category,
    COUNT(*) AS rtv_count,
    ROUND(AVG(r.return_cost), 2) AS avg_return_cost,
    ROUND(SUM(r.return_cost), 2) AS total_return_cost
FROM returns r
JOIN orders o ON r.order_id = o.order_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE r.return_type = 'RTV'
GROUP BY p.category
ORDER BY rtv_count DESC;


-- ==========================================================
-- أكتر أسباب الـ RTO تكرارًا وتأثيرها على التكلفة
-- ==========================================================
SELECT
    reason,
    COUNT(*) AS occurrences,
    ROUND(SUM(return_cost), 2) AS total_cost,
    ROUND(AVG(return_cost), 2) AS avg_cost
FROM returns
WHERE return_type = 'RTO'
GROUP BY reason
ORDER BY occurrences DESC;


-- ==========================================================
-- أعلى المحاور (Hubs) في معدل RTO - عشان نحدد اختناقات التشغيل
-- ==========================================================
SELECT
    h.hub_name,
    h.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT r.order_id) AS rto_orders,
    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0 / NULLIF(COUNT(DISTINCT o.order_id), 0), 2
    ) AS rto_rate_pct
FROM orders o
JOIN hubs h ON h.hub_id = o.destination_hub_id
LEFT JOIN returns r ON r.order_id = o.order_id AND r.return_type = 'RTO'
GROUP BY h.hub_name, h.city
HAVING COUNT(DISTINCT o.order_id) > 100
ORDER BY rto_rate_pct DESC
LIMIT 15;
