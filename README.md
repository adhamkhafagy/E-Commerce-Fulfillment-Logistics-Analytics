# E-Commerce Fulfillment & Logistics Analytics

An end-to-end analytics project simulating the operations of an e-commerce fulfillment and delivery company in Egypt — covering inventory, middle-mile logistics, returns (RTO/RTV), demand planning, and fulfillment P&L.

Built to demonstrate the full analytics workflow a Data/BI Analyst role in logistics requires: schema design, SQL reporting, BI dashboards, and live spreadsheet integration.

> **Note on data:** All data in this project is synthetic — generated with AI assistance and manually reviewed/adjusted for realism (seasonality, cost logic, inventory consistency, etc.). No real company data is used.

---

## 🎯 What This Project Covers

| Business Area | What's Included |
|---|---|
| **Inventory Management** | Inbound/outbound tracking, current stock view, reorder point alerts |
| **Demand Planning** | Forecast vs. actual demand, replenishment triggers, safety stock policies |
| **Middle-Mile Logistics** | Hub-to-hub shipment costs, vehicle utilization, route efficiency |
| **Returns (RTO/RTV)** | Return rate trends, cost breakdown by reason and product category |
| **Fulfillment P&L** | Revenue vs. cost by category, vendor profitability, cost-to-serve |
| **Live Reporting** | PostgreSQL → Google Sheets live sync for operational trackers |

---

## 🛠️ Tech Stack

- **Database:** PostgreSQL
- **BI / Dashboards:** Metabase
- **Live Sync:** Python (psycopg2, gspread) + Google Sheets API
- **Scheduling:** Windows Task Scheduler (cron-equivalent)

---

## 🗂️ Database Schema

17 tables covering the full fulfillment lifecycle:

```
vendors, customers, warehouses, hubs, vehicles, couriers, products,
orders, order_items, deliveries, returns, inventory_movements,
inventory_policies, demand_forecast, middle_mile_shipments,
financial_transactions, dim_dates
```

Plus a `current_stock` view (derived from `inventory_movements` ledger).

Key design decisions:
- **Absorption costing** logic for per-order warehousing cost (fixed cost ÷ order volume)
- **Time-dimension table** (`dim_dates`) with peak-season flags for seasonality analysis
- **Ledger-style** `financial_transactions` table (multiple rows per order) mirroring real accounting systems

---

## 📊 Dashboards (Metabase)

1. **RTO/RTV Analysis** — monthly return rate trends, top return reasons, category & hub breakdown
![RTO RTV](Metabase_Dashboard/RTO RTV Analysis.png)
2. **Middle-Mile Analysis** — cost efficiency by vehicle type, top-cost routes, reliability metrics
 
3. **Demand Planning** — reorder alerts, forecast accuracy, warehouse-level stock health

4. **Fulfillment P&L** — monthly revenue/cost/margin, cost breakdown, vendor profitability

---

## 🔄 Live Google Sheets Integration

A Python script pulls live data from PostgreSQL and pushes it to a shared Google Sheet using a service account — no manual export needed. Covers:
- Reorder alerts (real-time stock status)
- Daily orders tracker (last 30 days)

Can be scheduled to refresh automatically (Task Scheduler / cron).

---

## 📁 Project Structure

```
├──Metabase_Dashboard/
    ├──
├── sql_reports/
│   ├── rto_rtv_analysis.sql
│   ├── middle_mile_efficiency.sql
│   ├── demand_planning.sql
│   └── fulfillment_pnl.sql
├── google_sheets_sync/
│   └── live_sheets_connector.py     # Live PostgreSQL → Sheets sync
└── README.md
```

---

## 👤 About Me

Career changer from an Accounting background into Data Analytics & AI Engineering. This project combines both — the accounting foundation shows in the P&L logic and cost-category modeling, while the analytics work covers SQL, BI dashboarding, and data pipeline automation.

- Portfolio: [adhamkhafagy.github.io](https://adhamkhafagy.github.io)
- GitHub: [github.com/adhamkhafagy](https://github.com/adhamkhafagy)

---
---

# تحليل عمليات الشحن والتوصيل الإلكترونية

مشروع تحليل بيانات متكامل بيحاكي عمليات شركة توصيل وتنفيذ طلبات إلكترونية في مصر — بيغطي المخزون، النقل بين المحاور
(Middle-mile)
، المرتجعات
(RTO/RTV)
، تخطيط الطلب، والأرباح والخسائر التشغيلية
(P&L)
.

اتبنى المشروع عشان يوضح دورة العمل الكاملة اللي محتاجها أي وظيفة Data/BI Analyst في مجال اللوجستيات: تصميم قاعدة بيانات، تقارير SQL، داشبوردات BI، وربط حي بجداول بيانات خارجية.

> **ملحوظة عن البيانات:** كل البيانات في المشروع ده وهمية بالكامل — اتعملت بمساعدة الذكاء الاصطناعي، وتمت مراجعتها وتعديلها بشريًا لضمان الواقعية
(الموسمية، منطق التكلفة، اتساق المخزون، إلخ)
. مفيش أي بيانات حقيقية لأي شركة اتستخدمت.

---

## 🎯 إيه اللي المشروع بيغطيه

| المجال | اللي متغطي |
|---|---|
| **إدارة المخزون** | تتبع الوارد/الصادر، رصيد حالي لحظي، تنبيهات إعادة الطلب |
| **تخطيط الطلب** | التوقع مقابل الفعلي، نقاط إعادة التوريد، سياسات مخزون الأمان |
| **النقل بين المحاور** | تكلفة الشحنات بين المحاور، استغلال المركبات، كفاءة المسارات |
| **المرتجعات (RTO/RTV)** | اتجاه معدل المرتجعات، تفصيل التكلفة حسب السبب والفئة |
| **الأرباح والخسائر** | الإيراد مقابل التكلفة حسب البند، ربحية كل تاجر، تكلفة الخدمة |
| **التقارير الحية** | ربط PostgreSQL بـ Google Sheets لمتابعة العمليات لحظيًا |

---

## 🛠️ الأدوات المستخدمة

- **قاعدة البيانات:** PostgreSQL
- **الداشبوردات:** Metabase
- **الربط الحي:** Python (psycopg2, gspread) + Google Sheets API
- **الجدولة:** Windows Task Scheduler

---

## 🗂️ قاعدة البيانات

17 جدول بيغطوا دورة التنفيذ الكاملة، بالإضافة لـ View محسوب
(`current_stock`)
من سجل حركات المخزون.

قرارات تصميم أساسية:
- منطق **توزيع التكلفة الثابتة**
(Absorption Costing)
لحساب تكلفة التخزين لكل أوردر
- **جدول تاريخ** مخصص
(`dim_dates`)
فيه علم لمواسم الذروة لتحليل الـ Seasonality
- جدول `financial_transactions` بتصميم **سجل محاسبي**
(Ledger)
، زي أنظمة المحاسبة الحقيقية

---

## 📊 الداشبوردات

1. **تحليل RTO/RTV** — اتجاه معدل المرتجعات الشهري، أعلى الأسباب، تفصيل حسب الفئة والمحور
2. **تحليل النقل بين المحاور** — كفاءة التكلفة حسب نوع المركبة، أعلى المسارات تكلفة، مؤشرات الموثوقية
3. **تخطيط الطلب** — تنبيهات إعادة الطلب، دقة التوقع، صحة المخزون حسب المخزن
4. **الأرباح والخسائر** — الإيراد/التكلفة/الهامش الشهري، تفصيل التكلفة، ربحية التجار

---

## 🔄 الربط الحي بـ Google Sheets

سكريبت Python بيسحب بيانات حية من PostgreSQL ويكتبها في Google Sheet مشترك عن طريق Service Account، من غير أي تصدير يدوي. بيغطي:
- تنبيهات إعادة الطلب (حالة المخزون لحظيًا)
- ملخص أوردرات آخر 30 يوم

قابل للجدولة يشتغل أوتوماتيك بشكل دوري.

---

## 👤 نبذة عني

انتقلت لمجال تحليل البيانات والذكاء الاصطناعي بعد خلفية في المحاسبة. المشروع ده بيجمع الاتنين — الخلفية المحاسبية ظاهرة في منطق الـ P&L وتصنيف بنود التكلفة، والجزء التحليلي بيغطي SQL وبناء الداشبوردات وأتمتة خطوط البيانات.

- Portfolio: [adhamkhafagy.github.io](https://adhamkhafagy.github.io)
- GitHub: [github.com/adhamkhafagy](https://github.com/adhamkhafagy)
