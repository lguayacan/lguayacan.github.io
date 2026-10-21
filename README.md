# Construction Cost Analytics Portfolio

**Laura Camila Guayacan Ardila** · [LinkedIn](https://www.linkedin.com/in/lguayacan)

One question, three approaches: **what drives construction cost, and which projects deviate from what we would expect?**

The same dataset of 6,123 construction projects is analysed with regression, SQL and an interactive dashboard, using the vocabulary a project manager uses to make decisions.

## Key findings

- Equipment is a largely fixed cost (about $100k per project): 31.7% of total cost on projects under 2,000 sq ft versus 7.2% above 10,000 sq ft.
- Cost per sq ft outliers fall from 423 to 205 once equipment is removed, so most of the apparent deviation is a scale effect.
- Weather and risk indices do not explain the outliers.

## Projects

| # | Project | Tools | Skills shown |
|---|---------|-------|--------------|
| 1 | [Cost driver analysis](projects/cost-drivers/) | Google Sheets | Multiple regression, cost estimation, hold-out validation |
| 2 | [Cost variance and outlier analysis](projects/sql-outliers/) | SQL (BigQuery) | Variance analysis, benchmarking, outlier detection |
| 3 | [Project cost dashboard](dashboard/) | HTML, JavaScript | Cost reporting, what-if estimate with range, plain-language interpretation |

## Repository structure

```
index.html                  Landing page
dashboard/                  Interactive cost dashboard
projects/cost-drivers/      Case study 1: regression (README + charts)
projects/sql-outliers/      Case study 2: SQL (README, queries.sql + charts)
```

## Method in brief

- Regression results were cross-checked in Python (statsmodels): all coefficients match to 4 decimals.
- SQL results were cross-checked against the regression workbook.
- In the dashboard, the "AI" layer only interprets results with fixed, rule-based text; it does not calculate.

## Data and limitations

Source: [Kaggle "Deep Learning Building Cost Dataset"](https://www.kaggle.com/datasets/colabsss/deep-learning-building-cost-dataset). It is public and likely synthetic, so findings illustrate method rather than real-world cost benchmarks. Each case study lists its own limitations.
