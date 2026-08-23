-- ==========================================================
-- كفاءة التكلفة لكل مركبة (تكلفة/كم و تكلفة/كجم)
-- ==========================================================
SELECT
    v.vehicle_type,
    COUNT(*) AS total_shipments,
    ROUND(AVG(ms.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(ms.load_kg), 2) AS avg_load_kg,
    ROUND(SUM(ms.fuel_cost + ms.driver_cost), 2) AS total_cost,
    ROUND(SUM(ms.fuel_cost + ms.driver_cost) / NULLIF(SUM(ms.distance_km), 0), 2) AS cost_per_km,
    ROUND(SUM(ms.fuel_cost + ms.driver_cost) / NULLIF(SUM(ms.load_kg), 0), 2) AS cost_per_kg
FROM middle_mile_shipments ms
JOIN vehicles v ON v.vehicle_id = ms.vehicle_id
GROUP BY v.vehicle_type
ORDER BY cost_per_km;


-- ==========================================================
-- أكتر مسارات (Origin -> Destination) تكلفة، وتكرارها
-- ==========================================================
SELECT
    ho.hub_name AS origin_hub,
    hd.hub_name AS destination_hub,
    COUNT(*) AS shipment_count,
    ROUND(AVG(ms.distance_km), 2) AS avg_distance_km,
    ROUND(SUM(ms.fuel_cost + ms.driver_cost), 2) AS total_route_cost,
    ROUND(AVG(ms.fuel_cost + ms.driver_cost), 2) AS avg_cost_per_shipment
FROM middle_mile_shipments ms
JOIN hubs ho ON ho.hub_id = ms.origin_hub_id
JOIN hubs hd ON hd.hub_id = ms.destination_hub_id
GROUP BY ho.hub_name, hd.hub_name
ORDER BY total_route_cost DESC
LIMIT 15;


-- ==========================================================
-- معدل التأخير/الإلغاء لكل مركبة (Capacity & Reliability)
-- ==========================================================
SELECT
    v.vehicle_type,
    COUNT(*) AS total_shipments,
    COUNT(*) FILTER (WHERE ms.status = 'Delayed') AS delayed_count,
    COUNT(*) FILTER (WHERE ms.status = 'Cancelled') AS cancelled_count,
    ROUND(
        COUNT(*) FILTER (WHERE ms.status = 'Delayed') * 100.0 / COUNT(*), 2
    ) AS delay_rate_pct,
    ROUND(AVG(ms.load_kg / NULLIF(v.capacity_kg, 0)) * 100, 2) AS avg_capacity_utilization_pct
FROM middle_mile_shipments ms
JOIN vehicles v ON v.vehicle_id = ms.vehicle_id
GROUP BY v.vehicle_type
ORDER BY delay_rate_pct DESC;


-- ==========================================================
-- اتجاه شهري لتكلفة النقل بين المحاور (Trend)
-- ==========================================================
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(*) AS shipment_count,
    ROUND(SUM(ms.fuel_cost), 2) AS total_fuel_cost,
    ROUND(SUM(ms.driver_cost), 2) AS total_driver_cost,
    ROUND(SUM(ms.fuel_cost + ms.driver_cost), 2) AS total_cost
FROM middle_mile_shipments ms
JOIN dim_dates d ON ms.shipment_date = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
