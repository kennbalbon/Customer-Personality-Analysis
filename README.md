# 🎯 Marketing Campaign ROI & Customer Personality Analytics

## 📌 Project Overview
This project is an end-to-end data analytics pipeline designed to optimize marketing budgets and uncover high-value customer personas. Using a Customer Personality Analysis dataset, the project demonstrates rigorous data cleaning, feature engineering, and advanced Exploratory Data Analysis (EDA) within a MySQL database. The optimized SQL queries were materialized as standalone database Views to serve as a high-performance semantic layer, integrating directly into Microsoft Power BI to generate a single, high-impact executive dashboard.

## 🛠️ Tech Stack
* **Database:** MySQL (Data cleansing, standardizing, schema manipulation, staging)
* **Data Manipulation:** Advanced SQL (CTEs, Point-in-Time historical calculations, automated outlier detection, dynamic bucketing)
* **Business Intelligence:** Microsoft Power BI (Views integration, executive dashboarding, visual heatmaps)
* **Data Source:** Customer Personality Analysis Dataset (marketing_campaign.xls)

## 📊 Key Business Insights & Financial Variables Extracted
Through rigorous SQL querying and point-in-time analysis (anchored to 2014), the following core business metrics are presented on the main dashboard page:
1. **Executive Financial Baseline:** Surfaces an **Avg. Customer Income of $52.25K** alongside an **Avg. Total Revenue of $607.08**, providing leadership with immediate baseline performance benchmarks.
2. **Generational Revenue Curve:** Proves that the **50-59** and **60+** age cohorts act as the primary revenue engines of the business, holding the highest average spend per customer.
3. **Product Preference Matrix:** Implemented a structured Matrix visual tracking average spending across premium categories (Wines, Meats, Gold) against marital status, pinpointing exactly which demographic segments drive volume in high-margin product lines.
4. **Channel Allocation Strategy:** Segments purchasing channels by income brackets, revealing that **High-Income** and **Very High-Income** segments heavily favor physical **In-Store** and offline **Catalog** orders over digital Web interactions.

## 📁 Repository Structure
* `marketing_campaign_data_analysis.sql` - The complete SQL script containing data cleaning commands, table alterations, feature engineering (Age, Dependents, Total Spend), and the CTE-driven Views used for the EDA.
* `marketing_campaign.xls.csv` - The original raw dataset.
* `marketing_campaign_dashboard.pbix` - The final production Power BI dashboard file.

## 🚀 Dashboard Architecture & Performance Choice
To maximize executive readability and eliminate clutter, this report was deployed strictly as a **single-page dashboard solution**. All legacy draft sheets and exploratory pages were purged from the final `.pbix` file.

To preserve backend performance and visual integrity, global canvas slicing was intentionally omitted. Because the dashboard connects to isolated, pre-aggregated SQL reporting views (ensuring lightning-fast rendering speeds on the front end), the data model bypasses heavy, resource-intensive cross-table relationships in Power BI.

## 💻 How to Replicate
1. Ensure you have **MySQL** and **Power BI Desktop** installed.
2. Download the `marketing_campaign.xls.csv` file and import it into a new MySQL database. 
3. Run the `marketing_campaign_data_analysis.sql` script in your SQL editor. This will automatically stage the data, standardize the date formats (`STR_TO_DATE`), engineer the financial features, and generate the reporting Views.
4. Open Power BI Desktop, select **Get Data -> MySQL database**, and connect directly to the generated Views (e.g., `vw_age_bracket_profiling`, `vw_channel_preference`) to display the executive interface.
