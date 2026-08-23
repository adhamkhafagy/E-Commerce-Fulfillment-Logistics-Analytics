-- ==========================================================
-- P&L الشهري الكامل (Revenue vs كل بنود التكلفة)
-- ==========================================================
WITH warehousing_cost AS (
    SELECT
        SUM(operating_cost_monthly) AS warehousing_cost
    FROM warehouses
)
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT ft.order_id) AS num_of_orders,
    SUM(ft.amount) FILTER (WHERE ft.cost_category = 'REVENUE') AS total_revenue,
    SUM(ft.amount) FILTER (WHERE ft.cost_category = 'DELIVERY_COST') AS delivery_cost,
    SUM(ft.amount) FILTER (WHERE ft.cost_category = 'MIDDLE_MILE_COST') AS middle_mile_cost,
    SUM(ft.amount) FILTER (WHERE ft.cost_category = 'RETURNS_COST') AS returns_cost,
    wc.warehousing_cost,
    SUM(ft.amount) FILTER (WHERE ft.cost_category != 'REVENUE') + wc.warehousing_cost AS total_cost,
    SUM(ft.amount) FILTER (WHERE ft.cost_category = 'REVENUE')
        - (SUM(ft.amount) FILTER (WHERE ft.cost_category != 'REVENUE') + wc.warehousing_cost) AS net_margin,
    ROUND(
        (
            SUM(ft.amount) FILTER (WHERE ft.cost_category = 'REVENUE')
            - (SUM(ft.amount) FILTER (WHERE ft.cost_category != 'REVENUE') + wc.warehousing_cost)
        )
        * 100.0
        / NULLIF(SUM(ft.amount) FILTER (WHERE ft.cost_category = 'REVENUE'), 0),
        2
    ) AS margin_pct
FROM financial_transactions ft
JOIN dim_dates d ON ft.transaction_date = d.date_key
CROSS JOIN warehousing_cost wc
GROUP BY d.year, d.month, d.month_name, wc.warehousing_cost
ORDER BY d.year, d.month;


-- ==========================================================
-- ربحية كل تاجر (Vendor) - إيراد وتكلفة ومارجن
-- ==========================================================
SELECT
    v.vendor_name,
    v.category,
    SUM(o.order_value + o.shipping_fee) AS gross_revenue,
    COALESCE(SUM(dl.delivery_cost), 0) AS delivery_cost,
    COALESCE(SUM(r.return_cost), 0) AS return_cost,
    SUM(o.order_value + o.shipping_fee)
        - COALESCE(SUM(dl.delivery_cost), 0)
        - COALESCE(SUM(r.return_cost), 0) AS net_margin
FROM orders o
JOIN vendors v ON v.vendor_id = o.vendor_id
LEFT JOIN (
    SELECT order_id, SUM(delivery_cost) AS delivery_cost
    FROM deliveries GROUP BY order_id
) dl ON dl.order_id = o.order_id
LEFT JOIN (
    SELECT order_id, SUM(return_cost) AS return_cost
    FROM returns GROUP BY order_id
) r ON r.order_id = o.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY v.vendor_name, v.category
ORDER BY net_margin DESC
LIMIT 20;


-- ==========================================================
-- نسبة كل بند تكلفة من إجمالي التكلفة (Cost Breakdown %) - لـ Waterfall Chart
-- ==========================================================
WITH warehousing_cost AS (
    SELECT SUM(operating_cost_monthly) * 12 AS warehousing_cost
    FROM warehouses
),
other_costs AS (
    SELECT
        cost_category,
        ROUND(SUM(amount), 2) AS total_amount
    FROM financial_transactions
    WHERE cost_category NOT IN ('REVENUE', 'WAREHOUSING_COST')
    GROUP BY cost_category
),
combined AS (
    SELECT cost_category, total_amount FROM other_costs
    UNION ALL
    SELECT 'WAREHOUSING_COST', wc.warehousing_cost FROM warehousing_cost wc
)
SELECT
    cost_category,
    total_amount,
    ROUND(total_amount * 100.0 / SUM(total_amount) OVER (), 2) AS pct_of_total
FROM combined
ORDER BY total_amount DESC;


-- ==========================================================
-- تكلفة التسليم لكل أوردر ناجح (Cost to Serve) - مؤشر أساسي في fulfillment P&L
-- ==========================================================
SELECT
    d.year,
    d.month,
    ROUND(AVG(dl.total_delivery_cost), 2) AS avg_cost_per_order,
    ROUND(AVG(o.order_value), 2) AS avg_order_value,
    ROUND(AVG(dl.total_delivery_cost) * 100.0 / NULLIF(AVG(o.order_value), 0), 2) AS cost_to_serve_pct
FROM orders o
JOIN dim_dates d ON o.order_date = d.date_key
JOIN (
    SELECT order_id, SUM(delivery_cost) AS total_delivery_cost
    FROM deliveries GROUP BY order_id
) dl ON dl.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY d.year, d.month
ORDER BY d.year, d.month;
