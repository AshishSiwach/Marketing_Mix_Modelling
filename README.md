# 📈 BRT Marketing Mix Modeling (MMM): Budget Optimization

![R](https://img.shields.io/badge/R-4.2+-blue.svg)
![Status](https://img.shields.io/badge/Status-Complete-green.svg)
![Focus](https://img.shields.io/badge/Focus-Econometrics-orange.svg)

## 🚀 Executive Summary

This project involves the development of a **Marketing Mix Model (MMM)** to evaluate the revenue elasticity of four distinct media channels over a 60-month period. Using **Log-Log Regression analysis in R**, the model diagnosed significant budget inefficiencies and formulated a reallocation strategy projected to maximize marginal returns.

**Key Achievement:** Identified a strategy to **reallocate 23% of the annual budget** from low-performing National campaigns to high-yield Local markets, effectively **doubling investment in high-growth digital channels**.

---

## 💼 The Business Problem

**BRT Inc.** allocates its marketing budget across four primary channels:

1.  **Local Non-Digital (NDM):** Local Newspaper Designated Market.
2.  **Local Online (ONDM):** Local Outside Newspaper Designated Market.
3.  **National Non-Digital (NDM):** National Newspaper Designated Market.
4.  **National Online (ONDM):** Local Outside Newspaper Designated Market.

**The Challenge:** Despite consistent spending, revenue growth had plateaued. The stakeholders lacked visibility into which channels were actually driving sales, resulting in a "spray and pray" approach where **54% of the budget** was allocated to National campaigns based on intuition rather than data.

---

## 🛠️ Methodology

### 1. Data Processing

* **Dataset:** 60 months of historical performance data including Revenue, Media Spend by Channel, and Market Trend indicators.
* **Cleaning:** Handled currency formatting and outlier detection.
* **Transformation:** Applied **Natural Log (Ln)** transformations to all continuous variables to account for diminishing returns and to interpret coefficients as **elasticities**.

### 2. Statistical Modeling

A **Multiplicative (Log-Log) Regression Model** was built to isolate the impact of each channel:

ln(Revenue) = beta_0 + beta_1ln(textLocal\_NDM) + beta_2*ln(Local ONDM) + ...... + epsilon

* **Model Fit:** Achieved an **Adjusted $R^2$ of 0.92**, explaining 92% of the variance in revenue.
* **Significance:** All channels showed statistically significant impacts ($p < 0.05$).
* **Diagnostics:** Validated for Multicollinearity (VIF < 5) and Autocorrelation (Durbin-Watson $\approx$ 1.37).

---

## 📊 Key Insights & Findings

### 1. The "Efficiency Gap"

The model revealed a stark contrast between Local and National performance.

* **Local Spend Elasticity:** ~0.34 (1% spend increase = 0.34% revenue lift).
* **National Spend Elasticity:** ~0.14 (1% spend increase = 0.14% revenue lift).

> **Insight:** Local media channels are currently **2.5x more efficient** at driving revenue than National campaigns.

### 2. Budget vs. Reality

Comparing the *Current Allocation* (Actual Spend) against the *Optimal Allocation* (derived from elasticities) highlighted the strategic mismatch:

| Channel | Current Allocation | Optimal Allocation | Gap |
| :--- | :--- | :--- | :--- |
| **Local NDM** | 30.0% | **38.7%** | 🔼 **Under-funded** |
| **Local Digital** | 16.0% | **30.3%** | 🔼 **Severely Under-funded** |
| **National NDM** | 28.8% | 16.8% | 🔽 Over-funded |
| **National Digital** | 25.3% | 14.2% | 🔽 Over-funded |

---

<img width="900" height="646" alt="image" src="https://github.com/user-attachments/assets/ee535a87-a804-4bf6-8064-942fc878710d" />

## 💡 Strategic Recommendations

Based on the modeling results, the following actionable strategy was proposed:

1.  **Shift Strategy to "Local-First":** Reallocate **23% of the total annual budget** from National buckets to Local buckets.
2.  **Aggressively Scale Digital:** Increase funding for **Local Digital (ONDM)** by **~89%** (from 16% share to 30% share) to capture unexploited digital elasticity.
3.  **Maintain Traditional Base:** Recognize **Local NDM** as the highest-impact driver (Coefficient 0.34) and increase support by 9% to maintain the revenue baseline.

---

## 📂 Repository Structure

```bash
├── data/
│   └── BRT Data.csv    # Processed dataset used for modeling
├── scripts/
│   └── MMM_8.R          # Full R script (Data cleaning, Modeling, Optimization)
└── README.md
