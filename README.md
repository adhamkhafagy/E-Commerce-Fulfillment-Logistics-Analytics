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
![RTO RTV Dashboard](Metabase%20Dashboard/RTO_RTV_Analysis.png)
2. **Middle-Mile Analysis** — cost efficiency by vehicle type, top-cost routes, reliability metrics
![Middle-Mile Dashboard](Metabase%20Dashboard/Middle_Mile_Analysis.png)
3. **Demand Planning** — reorder alerts, forecast accuracy, warehouse-level stock health
![Demand Planning Dashboard](Metabase%20Dashboard/Demand_Planning.png)
4. **Fulfillment P&L** — monthly revenue/cost/margin, cost breakdown, vendor profitability
![Fulfillment P&L Dashboard](Metabase%20Dashboard/Fulfillment_P&L.png)
---
## 📈 Key Findings & Recommendations

*(Based on the generated dataset — replace with real figures if used against live company data)*

| Finding | Number | Recommendation |
|---|---|---|
| **RTO rate** | 13.9% of all orders | Above healthy e-commerce benchmark (~5-10%). Focus on top failure reasons (customer unavailable, wrong address) with pre-delivery confirmation calls/SMS |
| **RTV rate** | 3.2% of delivered orders | Concentrated in specific product categories — route those SKUs through stricter QC before dispatch |
| **Return cost impact** | 1.39M EGP over 2 years | Roughly equivalent to running 2-3 extra hubs for a year — a measurable P&L lever, not a rounding error |
| **Overall margin** | 58.4% | Healthy, but delivery cost is the largest controllable line — small courier-cost-per-order improvements compound at this volume |
| **Vehicle cost efficiency** | Motorcycles: 1.52 EGP/km vs. Trucks: 3.28 EGP/km | Route optimization should favor motorcycles/vans for short-haul hub transfers where load permits, reserving trucks for high-volume long-haul only |
| **Seasonality** | Peak months run ~1.7x average monthly volume | Warehouse and courier capacity planning should build in a 70%+ buffer ahead of Black Friday and Eid periods, not just linear headcount scaling |

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

1. **تحليلRTO/RTV** — اتجاه معدل المرتجعات الشهري، أعلى الأسباب، تفصيل حسب الفئة والمحور
3. **تحليل النقل بين المحاور** — كفاءة التكلفة حسب نوع المركبة، أعلى المسارات تكلفة، مؤشرات الموثوقية
4. **تخطيط الطلب** — تنبيهات إعادة الطلب، دقة التوقع، صحة المخزون حسب المخزن
5. **الأرباح والخسائر** — الإيراد/التكلفة/الهامش الشهري، تفصيل التكلفة، ربحية التجار

---
## 📈 أهم الاستنتاجات والتوصيات

*(مبنية على البيانات المولّدة — استبدلها بالأرقام الحقيقية لو استخدمت المشروع على بيانات شركة فعلية)*

| الاستنتاج | الرقم | التوصية |
|---|---|---|
| **معدل RTO** | 13.9% من كل الطلبات | أعلى من المعدل الصحي المعتاد في التجارة الإلكترونية
(~5-10%)
. لازم نركّز على أعلى أسباب الفشل
(عدم توفر العميل، عنوان خطأ)
عن طريق تأكيد قبل التوصيل برسالة أو مكالمة |
| **معدل RTV** | 3.2% من الطلبات الموصلة | متركّز في فئات منتجات معينة — لازم فحص جودة أشد على المنتجات دي قبل الشحن |
| **تكلفة المرتجعات** | 1.39 مليون جنيه على مدار سنتين | تقريبًا بتساوي تشغيل 2-3 محاور إضافية لمدة سنة — رقم فعلي مؤثر على الأرباح مش تفصيلة بسيطة |
| **الهامش الإجمالي** | 58.4% | صحي، لكن تكلفة التوصيل هي أكبر بند قابل للتحكم — أي تحسين بسيط في تكلفة الكابتن لكل أوردر بيتضاعف أثره مع الحجم ده |
| **كفاءة المركبات** | الموتوسيكل: 1.52 جنيه/كم مقابل التراك: 3.28 جنيه/كم | تخطيط المسارات لازم يفضّل الموتوسيكلات/الفانات في النقل القصير بين المحاور لما الحمولة تسمح، ويسيب التراكات للأحمال الكبيرة والمسافات الطويلة بس |
| **الموسمية** | شهور الذروة بتوصل لـ 1.7 ضعف متوسط الشهر العادي | تخطيط سعة المخازن والكباتن لازم يحسب هامش أمان 70%+ قبل الجمعة البيضاء والأعياد، مش بس زيادة خطية في عدد الموظفين |

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
