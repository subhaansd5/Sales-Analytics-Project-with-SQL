# Sales-Analytics-Project-with-SQL
This a comprehensive SQL-based approach to analyzing sales performance. It encompasses Exploratory Data Analysis (EDA), the creation of structured reporting views, and advanced analytical techniques to extract valuable business insights.

-----

## 💡 Project Overview

This project provides a complete data analysis workflow, from raw data exploration to creating production-ready reports. The project uses a star schema data model consisting of three core tables (`dim_customers`, `dim_products`, and `fact_sales`) and two consolidated reporting tables (`report_customers`, `report_products`). All data is provided in a static CSV format.

The project is structured into three main components:

1.  **Foundational Analysis (`EDA.sql`):** Queries to understand business metrics, trends, and top performers.
2.  **Reporting Views (`Customer_report.sql`, `Product_report.sql`):** SQL scripts that define the logic for creating two consolidated reporting tables with key metrics and customer/product segmentation.
3.  **Advanced Analytics (`Analytics.sql`):** In-depth analysis of trends over time, cumulative sales, performance comparisons, and part-to-whole analysis.

-----

## ❓ Business Questions Addressed

This project aims to answer critical business questions to inform strategic decisions:

  * What are the overall sales figures, order volumes, and customer base size?
  * What is the historical sales performance and growth over time (yearly, monthly)?
  * How do different product categories and individual products contribute to total sales?
  * Which customers are most valuable (VIPs) and which products are top performers or underperformers?
  * How do sales metrics vary across different demographics (e.g., customer age groups, gender) and geographies?
  * How can we segment customers and products based on their behavior and profitability?

-----

## ⚙️ Methodology

All analysis was performed using **SQL queries**. The project's data pipeline is simulated by providing the final output of each stage:

  * **Datasets:** The `Datasets` folder contains CSV files for the three main data tables: `dim_customers`, `dim_products`, and `fact_sales`. These files represent the cleaned and modeled data ready for analysis.
  * **Reports:** The `Reports` folder contains the final output in CSV format for the `report_customers` and `report_products`. These files are the result of running the respective SQL scripts.
  * **SQL Scripts:** The `sql_scripts` folder contains all the SQL code used for the analysis, demonstrating the logic behind the reports and insights.

-----

## 📈 Key Findings & Insights

The analysis yielded valuable insights into sales performance:

  * **Overall Performance:** The business operates over a significant period, generating substantial total sales and serving a large customer base.
  * **Top Contributors:** Identified specific products and customer segments that drive the majority of revenue and order volume.
  * **Sales Trends:** Revealed consistent growth patterns and seasonal variations in sales over the years.
  * **Customer Segmentation:** Successfully categorized customers into actionable segments (VIP, Regular, New) based on spending and loyalty, enabling targeted marketing strategies.
  * **Product Segmentation:** Grouped products by performance (High, Mid-range, Low) and cost, providing insights for inventory management and marketing efforts.
  * **Geographic Focus:** Pinpointed key countries and customer demographics driving sales.

-----

## 💻 Technologies & Tools

  * **SQL:** The primary language utilized for all data querying and analysis.
  * **Database Management System (DBMS):** (e.g., SQL Server, PostgreSQL, MySQL) required to execute the SQL scripts.

-----

## 📁 Repository Structure

```
├── README.md                               # This file
├── datasets/                               # Folder containing the source data in CSV format
│   ├── dim_customers.csv                   # Customer dimension data
│   ├── dim_products.csv                    # Product dimension data
│   └── fact_sales.csv                      # Sales facts data
├── reports/                                # Folder containing the final report outputs in CSV format
│   ├── report_customers.csv                # Consolidated customer report
│   └── report_products.csv                 # Consolidated product report
└── sql_scripts/                            # Folder containing all SQL scripts for the analysis
    ├── EDA.sql                             # Foundational EDA queries
    ├── Analytics.sql                       # Advanced analytics queries
    ├── Customer_report.sql                 # SQL for customer reporting view logic
    └── Product_report.sql                  # SQL for product reporting view logic
```

-----
