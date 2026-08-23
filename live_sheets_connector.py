"""
سكريبت ربط قاعدة بيانات PostgreSQL بـ Google Sheets بشكل Live
بيسحب بيانتين: تنبيهات إعادة الطلب + ملخص أوردرات آخر 30 يوم (من آخر تاريخ فعلي في البيانات)
وبيكتبهم في صفحتين منفصلتين جوه نفس الشيت
شغّله دوريًا (كل ساعة مثلًا) عن طريق Task Scheduler عشان يفضل Live

قبل التشغيل: انسخ .env.example لملف اسمه .env واملأ بياناتك الحقيقية فيه
"""

import os
import gspread
from google.oauth2.service_account import Credentials
import psycopg2
import pandas as pd
from dotenv import load_dotenv

load_dotenv()

# ==========================================================
# إعدادات الاتصال - بتتقرأ من ملف .env (مش مكتوبة هنا مباشرة)
# ==========================================================
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5432"),
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
}

SERVICE_ACCOUNT_FILE = os.getenv("SERVICE_ACCOUNT_FILE", "service_account.json")
SPREADSHEET_ID = os.getenv("SPREADSHEET_ID")

SCOPES = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive",
]


def get_sheet_client():
    """الاتصال بـ Google Sheets عن طريق الـ Service Account"""
    creds = Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)
    return gspread.authorize(creds)


def get_db_connection():
    """الاتصال بقاعدة بيانات PostgreSQL"""
    return psycopg2.connect(**DB_CONFIG)


def fetch_reorder_alerts(conn):
    """جلب المنتجات اللي قربت من نقطة إعادة الطلب"""
    query = """
        SELECT
            p.product_name,
            p.category,
            w.warehouse_name,
            cs.current_quantity,
            ip.reorder_point,
            ip.safety_stock,
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
    """
    return pd.read_sql(query, conn)


def fetch_daily_orders_tracker(conn):
    """ملخص أوردرات آخر 30 يوم (من آخر تاريخ فعلي موجود في البيانات، مش تاريخ اليوم الحقيقي)"""
    query = """
        SELECT
            order_date,
            COUNT(*) AS total_orders,
            COUNT(*) FILTER (WHERE order_status = 'Delivered') AS delivered,
            COUNT(*) FILTER (WHERE order_status = 'RTO') AS rto,
            COUNT(*) FILTER (WHERE order_status = 'Cancelled') AS cancelled,
            ROUND(SUM(order_value), 2) AS total_order_value
        FROM orders
        WHERE order_date >= (SELECT MAX(order_date) FROM orders) - INTERVAL '30 days'
        GROUP BY order_date
        ORDER BY order_date DESC;
    """
    return pd.read_sql(query, conn)


def write_dataframe_to_sheet(sheet, worksheet_name, df):
    """كتابة DataFrame كامل في صفحة معينة (بيمسح القديم ويحط الجديد)"""
    worksheet = sheet.worksheet(worksheet_name)
    worksheet.clear()
    worksheet.update([df.columns.tolist()] + df.astype(str).values.tolist())


def main():
    print("جاري الاتصال بقاعدة البيانات...")
    conn = get_db_connection()

    print("جاري سحب البيانات...")
    reorder_df = fetch_reorder_alerts(conn)
    orders_df = fetch_daily_orders_tracker(conn)
    conn.close()

    print("جاري الاتصال بـ Google Sheets...")
    client = get_sheet_client()
    sheet = client.open_by_key(SPREADSHEET_ID)

    print("جاري كتابة البيانات في الشيت...")
    write_dataframe_to_sheet(sheet, "Reorder Alerts", reorder_df)
    write_dataframe_to_sheet(sheet, "Daily Orders Tracker", orders_df)

    print(f"تم التحديث بنجاح: {len(reorder_df)} صف Reorder + {len(orders_df)} صف Orders")


if __name__ == "__main__":
    main()
