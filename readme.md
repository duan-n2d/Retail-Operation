# Customer Analytics and Marketing Engine

A comprehensive analytics system for customer segmentation, journey tracking, and market basket analysis built on SQL.

## Overview

This repository contains a set of SQL scripts and database schemas designed to analyze customer behavior, track marketing effectiveness, and provide actionable insights for retail and e-commerce businesses. The system combines RFM (Recency, Frequency, Monetary) analysis with journey performance tracking and market basket analysis.

## Database Schema

The core database structure includes tables for:

- `Customer`: Customer demographics and personal information
- `User`: User accounts linked to customers
- `Store`: Retail location information
- `Product`: Product catalog with categorization
- `Transaction`: Purchase records linking customers, products, and stores
- `Journey`: Marketing campaign definitions and parameters
- `Promotion_Code`: Tracking of promotion code usage
- `Delivery`: Records of marketing materials delivered to customers

## Key Features

### RFM Analysis & Customer Segmentation

The system implements a robust RFM (Recency, Frequency, Monetary) analysis framework:

- **Recency**: How recently a customer made a purchase
- **Frequency**: How often a customer makes purchases
- **Monetary**: How much a customer spends

Customers are assigned scores (1-5) in each category and grouped into 11 personas:
1. Champions
2. Loyal Customers
3. Potential Loyalists
4. New Customers
5. Promising
6. Cannot Lose Them
7. Needs Attention
8. Hibernating Customers
9. At Risk
10. About To Sleep
11. Lost Customers

### Customer Movement Tracking

The system tracks how customers move between different RFM segments over time, allowing businesses to:
- Identify which segments are growing or shrinking
- Monitor changes in spending patterns
- Measure the effectiveness of retention strategies

### Marketing Journey Performance

Track the effectiveness of marketing campaigns by:
- Measuring conversion rates from journey delivery to purchase
- Analyzing promotion code usage
- Comparing revenue from different customer segments
- Breaking down performance by store location

### Market Basket Analysis

Identify product associations to support cross-selling strategies by:
- Analyzing purchase patterns within 90-day windows
- Calculating product pairing frequencies
- Identifying which products are commonly bought together
- Quantifying the strength of product relationships

## SQL Scripts

- `CustomerSegmentByRFM.sql`: Calculates RFM scores and assigns customer personas
- `RFMByMonth.SQL`: Tracks monthly RFM metrics for customers
- `CustomerRFMMovement.sql`: Analyzes movement between RFM segments over time
- `JourneyPerformance.sql`: Measures marketing journey effectiveness
- `MarketBasket.sql`: Identifies product purchase associations

## Installation and Setup

1. Execute the database schema creation scripts to set up your tables
2. Run the analytics scripts in the following order:
   - CustomerSegmentByRFM.sql
   - RFMByMonth.SQL
   - CustomerRFMMovement.sql
   - Other analysis scripts as needed

## Use Cases

- **Customer Segmentation**: Identify your most valuable customers and those at risk
- **Targeted Marketing**: Deliver personalized campaigns based on RFM personas
- **Retention Strategies**: Monitor movement between segments to measure effectiveness
- **Cross-Selling**: Use market basket insights to make relevant product recommendations
- **Campaign Optimization**: Measure journey performance to refine marketing strategies

## Requirements

- SQL database (compatible with standard SQL syntax)
- Sufficient transaction history (at least 12 months recommended)
- Regular execution schedule for trend analysis

## Contributing

Contributions to improve the analytics scripts or extend functionality are welcome. Please submit pull requests or open issues to discuss potential improvements.

## License

[LICENSE](LICENSE)
