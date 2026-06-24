# 🎯 Marketing Campaign ROI & Customer Personality Analytics

## 📌 Project Overview
This project is an end-to-end data analytics pipeline designed to optimize marketing budgets and uncover high-value customer personas. Using a Customer Personality Analysis dataset, the project demonstrates rigorous data cleaning, feature engineering, and advanced Exploratory Data Analysis (EDA) within a MySQL database. The optimized SQL queries were materialized as database Views to serve as a semantic layer, integrating directly into Microsoft Power BI to generate interactive, executive-ready financial dashboards.

## 🛠️ Tech Stack
* **Database:** MySQL (Data cleansing, standardizing, schema manipulation, staging)
* **Data Manipulation:** Advanced SQL (CTEs, Point-in-Time historical calculations, automated outlier detection, dynamic bucketing)
* **Business Intelligence:** Microsoft Power BI (Direct Query/Views integration, interactive clustering)
* **Data Source:** Customer Personality Analysis [Dataset](https://www.kaggle.com/datasets/imakash3011/customer-personality-analysis)

## 📊 Key Business Insights & Financial Variables Extracted
Through rigorous SQL querying and point-in-time analysis (anchored to 2014), the following core business metrics were analyzed mathematically before being visualized:
1. **Customer Profitability Profiling:** Engineered a unified `total_spend` metric and mapped it against generational cohorts, proving exact age brackets (e.g., 40-59) and demographic groups that yield the highest average revenue.
2. **Channel Allocation Strategy:** Segmented the customer base into dynamic income brackets to determine purchasing preferences (Web vs. Store vs. Catalog), providing a mathematical framework to reallocate digital vs. print ad spend.
3. **Product Preference Matrix:** Mapped specific product categories (Wines, Meats, Gold) against marital status and education levels to pinpoint exactly which demographic combinations drive the highest volume in premium product lines.
4. **Data Quality & Anomaly Isolation:** Built an automated Outlier Audit view to actively filter out historical anomalies (e.g., extreme wealth outliers or corrupted >100-year-old birth dates) from skewing the final financial variables.

## 📁 Repository Structure
* `marketing_campaign_data_analysis.sql` - The complete SQL script containing data cleaning commands, table alterations, feature engineering (Age, Dependents, Total Spend), and the CTE-driven Views used for the EDA.
* `marketing_campaign.csv` - The original raw dataset.
* `Marketing_ROI_Dashboard.pbix` - The final interactive dashboard file.

## 🚀 How to Replicate
1. Ensure you have **MySQL** and **Power BI Desktop** installed.
2. Download the `marketing_campaign.csv` file and import it into a new MySQL database. 
3. Run the `marketing_campaign_data_analysis.sql` script in your SQL editor. This will automatically stage the data, standardize the date formats (`STR_TO_DATE`), engineer the financial features, and generate the reporting Views.
4. Open Power BI Desktop, select **Get Data -> MySQL database**, and connect directly to the generated Views (e.g., `vw_age_bracket_profiling`, `vw_channel_preference`) to begin visualizing!
