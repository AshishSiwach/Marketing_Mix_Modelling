install.packages("car")
install.packages("scales")
# LOAD REQUIRED PACKAGES
library(readxl)
library(car)
library(scales)
library(tidyverse)
library(psych)
library(broom)       # Convert regression model output into a tidy format

# DISABLE SCIENTIFIC NOTATION
options(scipen = 999)  

# ------------------------------------------------------------------------------
# 2. DATA LOADING & CLEANING
# ------------------------------------------------------------------------------   
# Select an Excel file interactively and load it into a data frame
df <- read_excel(file.choose())

# Display column names of the dataset
names(df)

# Display basic summary statistics 
summary(df)

# View the imported dataset
View(df)

# ------------------------------------------------------------------------------
# 3. EXPLORATORY DATA ANALYSIS (EDA)
# ------------------------------------------------------------------------------
# Create a trend plot
ggplot(df, aes(x = Trend, y =Revenue)) +            # Map "Trend" values to x-axis, and "Revenue" values to y-axis
  geom_line(color = "blue", size = 1) +               # Create Line plot for revenue trend
  geom_point(color = "red", size = 2, alpha = 0.6) +  # Add data points
  labs(title = "Revenue Trend Over Time", 
       x = "Month", 
       y = "Revenue") +
  theme_minimal()

# ------------------------------------------------------------------------------
# 4. DATA TRANSFORMATION (LOG-LOG)
# ------------------------------------------------------------------------------
# We use Log transformation to calculate "Elasticity".
# Elasticity = % Change in Revenue for a 1% Change in Spend.
# Note: We do NOT log 'Trend' usually, as it represents linear time.

df_log <- df %>%
  mutate(
    ln_Revenue = log(Revenue),
    ln_Local_NDM = log(Local_NDM),
    ln_Local_ONDM = log(Local_ONDM),
    ln_National_NDM = log(National_NDM),
    ln_National_ONDM = log(National_ONDM)
  )

# ------------------------------------------------------------------------------
# 5. REGRESSION MODELING
# ------------------------------------------------------------------------------
cat("\n--- STEP 5: REGRESSION MODEL RESULTS ---\n")

# Model Specification
model <- lm(ln_Revenue ~ ln_Local_NDM + ln_Local_ONDM + 
              ln_National_NDM + ln_National_ONDM + Trend, 
            data = df_log)

# Print Summary Statistics (R-Squared, F-Statistic)
model_stats <- glance(model)
print(paste("R-Squared:", round(model_stats$r.squared, 3))) 
# Interpretation: If > 0.90, the model explains over 90% of revenue variance.

# Print Coefficients (Elasticities) with Significance
model_results <- tidy(model) %>%
  mutate(p.value = round(p.value, 5),
         estimate = round(estimate, 3)) %>%
  select(term, estimate, std.error, p.value)

print(model_results)
# Interpretation:
# Estimate = Elasticity. (e.g., 0.34 means 1% spend increase = 0.34% revenue increase).
# P.value < 0.05 means the channel is Statistically Significant.

# ------------------------------------------------------------------------------
# 6. MODEL DIAGNOSTICS
# ------------------------------------------------------------------------------
cat("\n--- STEP 6: DIAGNOSTICS ---\n")

# A. Multicollinearity (VIF)
# Check if channels are too correlated with each other.
vif_values <- vif(model)
print(vif_values)
# Rule of Thumb: VIF > 5 or 10 indicates a problem. If all are < 5, you are safe.

# B. Autocorrelation (Durbin-Watson)
# Check if sales today are too dependent on sales yesterday.
dw_test <- durbinWatsonTest(model)
print(paste("Durbin-Watson Statistic:", round(dw_test$dw, 2)))
# Rule of Thumb: Value should be close to 2.0. (1.5 - 2.5 is usually acceptable).

# ------------------------------------------------------------------------------
# 7. BUDGET OPTIMIZATION (THE STRATEGY)
# ------------------------------------------------------------------------------
cat("\n--- STEP 7: OPTIMIZATION & REALLOCATION ---\n")

# A. Calculate CURRENT Allocation (Where the money goes now)
current_spend <- df %>%
  summarise(
    Local_NDM = sum(Local_NDM),
    Local_ONDM = sum(Local_ONDM),
    National_NDM = sum(National_NDM),
    National_ONDM = sum(National_ONDM)
  ) %>%
  pivot_longer(everything(), names_to = "Channel", values_to = "Total_Spend") %>%
  mutate(Current_Pct = Total_Spend / sum(Total_Spend))

# B. Calculate OPTIMAL Allocation (Where the money SHOULD go)
# Formula: Optimal % = Coefficient / Sum of all Media Coefficients
coefs <- coef(model)
media_coefs <- coefs[c("ln_Local_NDM", "ln_Local_ONDM", "ln_National_NDM", "ln_National_ONDM")]
total_elasticity <- sum(media_coefs)

optimal_alloc <- data.frame(
  Channel = c("Local_NDM", "Local_ONDM", "National_NDM", "National_ONDM"),
  Elasticity = as.numeric(media_coefs)
) %>%
  mutate(Optimal_Pct = Elasticity / total_elasticity)

# C. Merge and Compare
comparison <- left_join(current_spend, optimal_alloc, by = "Channel") %>%
  mutate(
    Difference = Optimal_Pct - Current_Pct,
    Action = ifelse(Difference > 0, "INCREASE", "DECREASE")
  )

# Display the Strategic Table
print(comparison %>% 
        mutate(Current_Pct = percent(Current_Pct, 0.1),
               Optimal_Pct = percent(Optimal_Pct, 0.1),
               Difference = percent(Difference, 0.1)))

# ------------------------------------------------------------------------------
# 8. VISUALIZATION OF RECOMMENDATION
# ------------------------------------------------------------------------------
# Reshape data for plotting side-by-side bars
plot_data <- comparison %>%
  select(Channel, Current_Pct, Optimal_Pct) %>%
  pivot_longer(cols = c(Current_Pct, Optimal_Pct), names_to = "Type", values_to = "Percentage")

ggplot(plot_data, aes(x = Channel, y = Percentage, fill = Type)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = percent(Percentage, 0.1)), 
            position = position_dodge(width = 0.9), vjust = -0.5, size = 3.5) +
  scale_fill_manual(values = c("Current_Pct" = "#95a5a6", "Optimal_Pct" = "#2ecc71")) +
  labs(title = "Budget Optimization Model",
       subtitle = "Current Spending vs. Optimal Allocation based on Elasticity",
       y = "Budget Share (%)", x = "Media Channel") +
  theme_minimal() +
  theme(legend.position = "bottom")
