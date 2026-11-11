# 🇵🇰 Pakistan E-Commerce: Order Cancellation & Refund Analysis

### An End-to-End Data Analytics Project Using Python, MySQL & Power BI

An end-to-end data analytics project analyzing **574,281 order lines** (July 2016 – August 2018) from Pakistan's largest e-commerce dataset.

This project investigates order cancellations, refunds, payment failures, revenue leakage, and customer purchasing patterns to uncover business problems and provide data-driven recommendations.

---

## 📌 Table of Contents

- [Executive Summary](#-executive-summary)
- [Key Business Metrics](#-key-business-metrics)
- [Business Problem](#-business-problem--hypothesis)
- [Dataset Overview](#-dataset-overview)
- [Tech Stack](#-tech-stack)
- [Project Architecture](#-project-architecture)
- [Repository Structure](#-repository-structure)
- [Data Cleaning & Feature Engineering](#-data-cleaning--feature-engineering-python)
- [SQL Analytical Framework](#-sql-analytical-framework-mysql)
- [Power BI Dashboard](#-power-bi-executive-dashboard)
- [Key Analytical Findings](#-key-analytical-findings)
- [Strategic Recommendations](#-strategic-recommendations)
- [Methodology Limitations](#-methodology-limitations)
- [How to Reproduce](#-how-to-reproduce)
- [Author](#-author)

---

## 📊 Executive Summary

Online marketplaces lose significant revenue when orders are cancelled before fulfillment or refunded after delivery.

This project analyzes transactional data to understand:

- Why orders fail to convert into successful sales.
- Which payment methods experience the highest failure rates.
- Which product categories contribute most to revenue loss.
- How discounts and order values influence cancellations and refunds.
- Which operational improvements can reduce revenue leakage.

The analysis uncovered two distinct payment-related failure patterns:

- **Prepaid Orders:** 63.0% failure rate, primarily driven by cancellations before fulfillment.
- **COD Orders:** 27.8% failure rate, primarily driven by post-delivery refunds.

These findings challenge the conventional assumption that Cash on Delivery is the biggest source of e-commerce order failures.

## 💰 Key Business Metrics

| Metric | Value |
|:---|---:|
| Cleaned Order Lines | **574,281** |
| Final-Outcome Orders | **570,194** |
| Time Period | July 2016 – August 2018 |
| Order Completion Rate | **53.44%** |
| Overall Failure Rate | **46.20%** |
| Gross Order Value | **Rs 4.15 Billion** |
| Net Realised Revenue | **Rs 1.35 Billion** |
| Total Revenue Lost | **Rs 2.80 Billion** |
| Revenue Loss Percentage | **67.51%** |

> **Key Insight:** Approximately 46% of final-outcome order lines failed, resulting in an estimated Rs 2.80 billion in lost gross order value.

*Note: The raw dataset does not explicitly specify currency. Pakistani Rupees (Rs) are assumed throughout this analysis.*

---

## 🎯 Business Problem & Hypothesis

### The Business Challenge

Despite generating substantial order volumes, the marketplace experiences a high percentage of failed orders.

High-value transactions contribute disproportionately to revenue leakage, making it important to identify the segments responsible for cancellations and refunds.

### Initial Hypothesis vs. Actual Findings

The conventional assumption is that Cash on Delivery (COD) creates the highest order failure rate.

However, the analysis revealed:

| Payment Type | Cancellation Rate | Refund Rate | Total Failure Rate |
|:---|---:|---:|---:|
| Prepaid | 59.12% | 3.85% | **62.97%** |
| COD | 7.71% | 20.13% | **27.84%** |

**Conclusion:** Prepaid orders experience significantly higher pre-fulfillment cancellations, while COD orders experience considerably more post-delivery refunds.

---

## 📁 Dataset Overview

| Attribute | Description |
|:---|:---|
| Dataset | Pakistan's Largest E-Commerce Dataset |
| Original Author | Zeeshan-ul-hassan Usmani (CHISEL) |
| Data Format | CSV |
| Raw Dataset Size | 101.6 MB |
| Granularity | One row per order item (order_line) |
| Time Period | July 2016 – August 2018 |
| Cleaned Records | 574,281 |

### Important Columns

- `order_id` – Unique order identifier
- `item_id` – Individual order item identifier
- `customer_id` – Customer identifier
- `created_at` – Order creation date
- `status` – Order status
- `payment_method` – Payment method
- `category_name_1` – Product category
- `price` – Product price
- `qty_ordered` – Ordered quantity
- `discount_amount` – Applied discount

**Dataset Sources:**
- [Kaggle Dataset](https://www.kaggle.com/datasets/zusmani/pakistans-largest-ecommerce-dataset)
- [OpenData Pakistan](https://opendata.com.pk/)

---

## 🛠️ Tech Stack

| Technology | Purpose |
|:---|:---|
| Python | Data cleaning and preprocessing |
| Pandas | Data manipulation and analysis |
| NumPy | Numerical operations |
| Matplotlib | Data visualization |
| Seaborn | Statistical visualization |
| Jupyter Notebook | Python development environment |
| MySQL 8.0 | Database management and SQL analysis |
| MySQL Workbench | SQL query execution |
| Power BI | Interactive dashboards and reporting |
| DAX | Measures and business KPIs |

---

## 🔄 Project Architecture

The project follows an end-to-end analytics pipeline:

```text
       RAW E-COMMERCE DATASET
               |
               v
       PYTHON - PANDAS
       Data Cleaning & EDA
               |
               v
       FEATURE ENGINEERING
       Status & Payment Mapping
       Outlier Treatment
               |
          +----+----+
          |         |
          v         v
       MYSQL     CLEANED CSV
          |         |
          v         v
       SQL 17    POWER BI
       QUERIES   DASHBOARD
          |         |
          +----+----+
               |
               v
       BUSINESS INSIGHTS
       & RECOMMENDATIONS
```

---

## 📂 Repository Structure

```text
pk-ecommerce-end-to-end-analytics/
│
├── data/
│   ├── raw/
│   │   └── raw_dataset.zip
│   │
│   └── cleaned/
│       └── cleaned_dataset.zip
│
├── python/
│   └── 01_cleaning_and_eda.ipynb
│
├── sql/
│   └── analysis_queries.sql
│
├── powerbi/
│   ├── E-Commerce-Project.pbix
│   └── E-Commerce-Dashboard.pdf
│
├── images/
│   ├── Overview.jpg
│   ├── Payments.jpg
│   ├── Category & Revenue.jpg
│   └── Insights.jpg
│
├── requirements.txt
└── README.md
```

---

## 🐍 Data Cleaning & Feature Engineering (Python)

**Notebook:** `python/01_cleaning_and_eda.ipynb`

The raw dataset required several preprocessing steps before performing business analysis.

### Data Cleaning Process

1. **Structural Cleanup**
   - Removed unnamed and completely empty columns.
   - Removed empty rows and duplicate records.

2. **Schema Standardization**
   - Converted column names into snake_case.
   - Renamed `increment_id` to `order_id`.
   - Converted dates, prices, and quantities into appropriate data types.

3. **Text Normalization**
   - Removed unnecessary whitespace.
   - Standardized text to lowercase.
   - Replaced dirty placeholders such as `\N`, empty strings, and `nan` with actual missing values.

4. **Status Mapping**

   | Original Status | Analytical Category |
   |:---|:---|
   | complete, received | Completed |
   | canceled | Cancelled |
   | order_refunded, refund, closed | Refunded |
   | pending, processing, holded, etc. | Other |

5. **Payment Method Grouping**

   | Payment Methods | Analytical Category |
   |:---|:---|
   | cod, cashatdoorstep | COD |
   | payaxis, easypay, bankalfalah, jazzwallet, apg, etc. | Prepaid |
   | customercredit, marketingexpense, etc. | Store Credit |

6. **Outlier Treatment**
   - Initial IQR filtering flagged legitimate high-value electronics transactions.
   - Instead of removing all outliers, only the extreme top 0.1% was removed using the 99.9th percentile threshold of `qty_ordered` and `item_total`.

### Feature Engineering

The following analytical features were created:

- `item_total` – Price multiplied by quantity ordered.
- `is_cancelled` – Binary cancellation indicator.
- `is_refunded` – Binary refund indicator.
- `is_failed` – Combined cancellation and refund indicator.
- `is_final` – Identifies final order outcomes.
- `value_band` – Low, Medium, High, Premium.
- `discount_band` – Discount-based segmentation.
- `net_revenue` – Revenue retained from completed orders.

---

## 🗄️ SQL Analytical Framework (MySQL)

**Script:** `sql/analysis_queries.sql`

**Database:** `pk_ecommerce`

**Table:** `orders_clean`

The SQL layer contains **17 analytical queries** designed to answer important business questions.

### SQL Concepts Used

- Common Table Expressions (CTEs)
- Window Functions
- `SUM() OVER()`
- `LAG()`
- Conditional Aggregations
- `CASE WHEN`
- Subqueries
- `GROUP BY` and `HAVING`
- Revenue and Failure Rate Calculations
- Customer Segmentation

### Analytical Query Categories

| Query Group | Business Analysis |
|:---|:---|
| Queries 0–2 | Data validation, monthly trends, overall status distribution |
| Queries 3, 3A–3C | COD vs. Prepaid, payment gateway analysis, YoY comparisons |
| Queries 4–6B | Category performance, discount sensitivity, order-value risk |
| Queries 7–10 | Monthly failure spikes, revenue leakage, customer retention |
| Bonus | High-risk COD segmentation and global revenue leakage |

### Sample SQL Query: Payment Type Comparison

```sql
SELECT
    payment_type,
    COUNT(*) AS final_orders,

    ROUND(100 * AVG(is_cancelled), 2)
        AS cancel_rate_pct,

    ROUND(100 * AVG(is_refunded), 2)
        AS refund_rate_pct,

    ROUND(100 * AVG(is_failed), 2)
        AS failed_rate_pct

FROM orders_clean

WHERE is_final = 1
  AND payment_type <> 'Store Credit'

GROUP BY payment_type

ORDER BY failed_rate_pct DESC;
```

This query compares COD and Prepaid orders based on cancellation, refund, and overall failure rates.

---

## 📈 Power BI Executive Dashboard

**Files:**
- `powerbi/E-Commerce-Project.pbix`
- `powerbi/E-Commerce-Dashboard.pdf`

The Power BI report contains four interactive pages designed for executive-level decision-making.

### Dashboard Preview

#### 1. Executive Overview

![Overview Dashboard](images/Overview.jpg)

- Total Orders: 570K
- Overall Failed Rate: 46.2%
- Gross Revenue: Rs 4.15 Billion
- Revenue Lost: 67.5%
- Net Realised Revenue: Rs 1.35 Billion
- Monthly Orders vs. Failure Rate
- Order Status Distribution

#### 2. Payment Deep Dive

![Payment Dashboard](images/Payments.jpg)

- Prepaid vs. COD Failure Rates
- Cancellation vs. Refund Analysis
- Payment Gateway Cancellation Rankings
- Order Value Risk Segmentation
- Year-over-Year Payment Trends

#### 3. Category & Revenue Analysis

![Category Dashboard](images/Category & Revenue.jpg)

- Total Revenue Lost: Rs 2.80 Billion
- Revenue Loss Percentage: 67.5%
- Categories with More Than 50% Failure
- Category-wise Revenue Leakage
- Discount Band Failure Analysis

#### 4. Insights & Recommendations

![Insights Dashboard](images/Insights.jpg)

- Major Business Findings
- Payment Failure Patterns
- High-Risk Customer Segments
- Revenue Leakage Drivers
- Strategic Business Recommendations

### Dashboard Features

- Interactive Year Slicer
- Category Filter
- Payment Type Filter
- KPI Cards
- Monthly Trend Analysis
- Dynamic Visualizations
- DAX Measures

### Color Coding

| Color | Meaning |
|:---|:---|
| 🔴 Red | Cancelled / Lost |
| 🟠 Orange | Refunded |
| 🔵 Blue | Prepaid |
| 🟢 Teal | COD |
| 🟢 Green | Completed |

---

## 🔍 Key Analytical Findings

### 1. Prepaid vs. COD Failure Patterns

| Metric | Prepaid | COD |
|:---|---:|---:|
| Final Orders | 299,172 | 263,490 |
| Cancellation Rate | 59.12% | 7.71% |
| Refund Rate | 3.85% | 20.13% |
| Total Failure Rate | **62.97%** | **27.84%** |

**Finding:** Prepaid orders primarily fail before fulfillment, whereas COD orders experience more post-delivery refunds.

### 2. Payment Gateway Issues

The three largest payment gateways showed substantial cancellation rates:

| Payment Gateway | Cancellation Rate |
|:---|---:|
| PayAxis | 62.8% |
| Easypay | 62.9% |
| Bank Alfalah | 71.0% |

Together, these gateways account for approximately 200,900 order lines with significant pre-fulfillment cancellations.

### 3. High-Value COD Orders Carry Greater Risk

COD failure rates increase with order value:

| Order Value Band | COD Failure Rate |
|:---|---:|
| Low | 19.0% |
| Medium | 24.4% |
| High | 34.7% |
| Premium | 51.8% |

**Finding:** High and Premium COD orders experience a combined failure rate of 40.27%, compared with 21.65% for lower-value COD orders.

### 4. Category-Wise Revenue Leakage

Five categories exceeded a 50% failure rate:

| Category | Failure Rate |
|:---|---:|
| Others | 68.3% |
| Mobiles & Tablets | 56.6% |
| Entertainment | 56.4% |
| Computing | 54.8% |
| Appliances | 51.5% |

### Revenue Loss Concentration

| Category | Revenue Lost |
|:---|---:|
| Mobiles & Tablets | Rs 1,676M |
| Appliances | Rs 378M |
| Entertainment | Rs 317M |

**Finding:** The top three categories contribute approximately 85% of total lost revenue.

### 5. Fashion Experiences Higher Refund Rates

| Category | Refund Rate |
|:---|---:|
| Men's Fashion | 18.55% |
| Women's Fashion | 15.79% |

**Finding:** Fashion categories experience more post-delivery refunds compared with several electronics categories.

### 6. Seasonal Trends & Discount Patterns

**November Sales Peak**

| Month | Order Lines |
|:---|---:|
| November 2016 | 68.7K |
| November 2017 | 82.4K |

Despite significant sales volume increases, failure rates remained relatively stable at 43.4% and 45.4%.

**September 2017 Anomaly**

- Order volume dropped to 8,201 lines.
- Failure rate increased to 56.7%.
- This suggests a potential operational or technical disruption requiring further investigation.

**Discount Analysis**

Full-price prepaid orders experienced an 80.26% failure rate, compared with 44.9%–63.1% across discounted tiers.

---

## 💡 Strategic Recommendations

Based on the analytical findings, the following business actions are recommended:

| Priority | Recommendation | Expected Business Benefit |
|:---|:---|:---|
| High | Audit prepaid payment gateways and checkout processes | Reduce payment-related cancellations |
| High | Introduce WhatsApp/IVR verification for high-value COD orders | Reduce failed COD deliveries |
| High | Investigate inventory and operational issues in top loss categories | Reduce revenue leakage |
| Medium | Improve fashion sizing guides and product descriptions | Reduce post-delivery refunds |
| Medium | Introduce mandatory cancellation and refund reason codes | Improve root-cause identification |
| Medium | Investigate the September 2017 failure spike | Identify historical operational disruptions |

### Key Business Actions

1. **Improve Prepaid Checkout:** Investigate payment timeouts, gateway reliability, and retry mechanisms.
2. **Verify High-Value COD Orders:** Introduce customer confirmation before courier dispatch.
3. **Improve Product Information:** Use better sizing guides, product images, and transparent return policies.
4. **Monitor High-Loss Categories:** Prioritize Mobiles & Tablets, Appliances, and Entertainment.
5. **Capture Failure Reasons:** Record structured cancellation and refund reasons.
6. **Monitor Business KPIs:** Track monthly cancellation, refund, and failure rates.

---

## ⚠️ Methodology Limitations

- **Inferred Root Causes:** The original dataset does not contain explicit cancellation or refund reason codes. Therefore, operational causes are inferred from transactional patterns rather than directly confirmed.
- **Order-Line Granularity:** All counts and rates represent individual order lines, not consolidated customer baskets or unique orders.
- **Status Mapping:** The `closed` status (494 rows) was mapped to Refunded.
- **Non-Final Statuses:** Pending, processing, holded, and other non-final statuses were excluded from final-outcome comparisons.
- **Store Credit:** Internal Store Credit transactions were excluded from COD vs. Prepaid comparisons.
- **Discount Attribution:** Unapplied promotional codes on abandoned or cancelled checkouts may influence observed discount-band failure rates.
- **Currency Assumption:** Pakistani Rupees (Rs) are assumed because the original dataset does not explicitly specify currency.

---

## 👨‍💻 Author

**Izaan Imran**

Data Science Student | Aspiring Data Analyst

- **GitHub:** [izaan-imran](https://github.com/izaan-imran)
- **Portfolio:** [izaanimran.lovable.app](https://izaanimran.lovable.app)
- **LinkedIn:** [Connect with me](https://www.linkedin.com/in/izaan-imran/)

### Dataset Credit

Original dataset by **Zeeshan-ul-hassan Usmani (CHISEL)**.

---

⭐ If you find this project useful, consider giving this repository a star!

**Built with Python, MySQL, and Power BI.**
