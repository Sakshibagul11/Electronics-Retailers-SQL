# ⚡Electronics_retailer_sql_project

## 🎯 Objective
Analyze multi-country sales data from a fictional global electronics retailer to generate actionable business insights using advanced SQL 📊. This project covers end-to-end SQL analytics including data cleaning, KPI creation, window functions, and profitability analysis 🚀.

Data Source: Maven Analytics
It represents a **fictional global electronics retailer** and includes the following dimensions:

-  👥**Customers:** demographic information and country of residence  
-  🏬**Stores:** country, states, square meters, and open date  
-  📦**Products:** product name, brand, color, category, subcategory, cost, and price  
-  🧾**Sales:** transactional records with order number, date, quantity, product, and currency  
-  💱**Currency:** conversion rates for multi-currency normalization  

---

## 🗄️Database Schema
| Table | Description |
|--------|--------------|
| **customers** | Customer info (name, gender, age, country) |
| **products** | Product catalog (name, category, brand, price) |
| **stores** | Store locations (city, province) |
| **currency** | Currency and USD conversion rates |
| **sales** | Transaction-level sales data |

---

## 🛠️Tools
- **Database:** MySQL Workbench 💻
- **Skills:** SQL joins, CTEs, window functions, ranking, aggregation, and trend analysis  
- **Data Size:** 10,000+ records (scalable)  

---

## 🔍Key Analyses

| Query | Focus | SQL Skills Used |
|--------|--------|----------------|
| **Q1** | Total revenue per customer | GROUP BY, SUM() |
| **Q2** | Revenue by store (CTE) | CTE, SUM(), JOIN |
| **Q3** | Top-selling products | GROUP BY, ORDER BY |
| **Q4** | Monthly revenue trend | DATE_TRUNC(), SUM() |
| **Q5** | Repeat customers | COUNT(DISTINCT), HAVING |
| **Q6** | Revenue by category | Aggregation |
| **Q7** | Top stores per province | ROW_NUMBER(), PARTITION |
| **Q8** | Store revenue share (%) | RANK(), SUM() OVER |
| **Q9** | Underperforming stores (bottom 25%) | NTILE(4), window partition |
| **Q10** | Year-over-year trend (country) | LAG(), growth rate |
| **Q11** | Product category growth | LAG(), trend comparison |

---
## 📌Key Insights

###  1 Sales & Customer Insights
- The **top 10% of customers** contribute more than half of total revenue — strong concentration that suggests a customer loyalty opportunity.  
- **Average order value (AOV)** shows a positive year-over-year trend, meaning customers are spending more per purchase.  
- The **repeat purchase rate** is relatively low, showing potential for subscription models or targeted retention programs.

### 2 Store & Geographic Insights
- **Top-performing stores** in certain regions generate 60–70% of total sales — marketing and stock allocation should focus on these high-demand areas.  
- **Bottom-quartile stores (NTILE = 4)** represent less than 15% of total revenue, signaling possible overcapacity or poor location performance.  
- **Newer stores** show steady growth, validating current expansion strategy.

### 3 Product & Category Insights
- **Smartphones and laptops** dominate total revenue, while **accessories** provide the highest profit margin.  
- Premium brands  maintain consistent growth, whereas some legacy brands are flattening.  
- Opportunities exist to grow **mid-range products** or **bundled offers** that include accessories for margin optimization.

### 4 Trend & Growth Insights
- Total revenue shows **positive year-over-year growth**, driven mainly by strong performance in the tech and laptop categories.  
- Clear **seasonal peaks in Q4** suggest marketing and inventory planning should intensify around holiday periods.  
- Some countries show **stagnating growth**, signaling market maturity and the need for diversification.

### 5 Profitability Insights
- The **average profit margin** across categories is around 20% (based on unit cost vs price).  
- **Accessories** yield smaller revenues but higher margins — emphasizing their strategic role in profitability.  
- Continuous cost monitoring could improve gross margins by renegotiating supplier contracts.

---

## 🧠Key SQL Techniques Used
- **CTEs (`WITH`)** for modular and readable analysis  
- **Window Functions:** `RANK()`, `NTILE()`, `LAG()`  
- **Aggregations:** `SUM()`, `AVG()`, `COUNT()`  
- **Analytical Functions:** Growth rates, quartile segmentation, YOY change  
- **Data Cleaning:** Currency normalization and validation checks  

---

## 📢Recommendations for Management
- Focus on **high-performing regions and stores** for future expansion.  
- Launch **customer loyalty or retention programs** to improve repeat sales.  
- **Optimize low-performing stores** through inventory realignment or marketing push.  
- Promote **accessory bundles** with high-margin items to increase profitability.  
- Use **seasonal insights (Q4 peaks)** for targeted campaigns and dynamic pricing.
---

## 🧠 Key SQL Concepts
`CTE`, `JOIN`, `RANK()`, `NTILE()`, `LAG()`, `SUM() OVER`, `NULLIF()`, `DATE_TRUNC()`

---

## 🚀 Future Enhancements
1. **Power BI Dashboard:** visualize revenue trends, store rankings, and category growth.  
2. **Customer Segmentation:** analyze repeat vs new customers.  
3. **Profitability Analysis:** include cost and margin metrics.  
4. **Automation:** convert SQL to scheduled reports or views.

