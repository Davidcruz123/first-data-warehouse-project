# My First Data Warehouse Project

A hands-on data warehouse project built with **PostgreSQL** to practice and apply the fundamentals of modern data warehousing.

## 🎯 Project Goal

The goal of this project is to gain practical experience designing and building a data warehouse from raw data through to a business-ready **Gold layer**.

The project covers:

* Data ingestion and transformation
* ETL/ELT concepts
* Bronze, Silver, and Gold layers
* Data cleansing and transformation
* Dimension and fact tables
* Star schema design
* SQL views
* Surrogate keys
* Data quality and validation

## 🏗️ Architecture

```text
                    ┌──────────────┐
                    │  Source Data │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    Bronze    │
                    │  Raw Data    │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    Silver    │
                    │ Cleaned Data │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │     Gold     │
                    │ Business Data│
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Analytics  │
                    │ & Reporting  │
                    └──────────────┘
```

## ⭐ Gold Layer

The Gold layer follows a **Star Schema** consisting of:

### Dimensions

* `gold.dim_customers`
* `gold.dim_products`

### Fact

* `gold.fact_sales`

The Gold views combine and transform data from the Silver layer into business-ready datasets for analytics and reporting.

## 🛠️ Technologies

* **PostgreSQL**
* SQL
* Data Warehousing
* Star Schema
* ETL / ELT concepts

## 📚 Purpose

This project is primarily a **learning and practice project** focused on building a solid foundation in data engineering and data warehousing concepts.
