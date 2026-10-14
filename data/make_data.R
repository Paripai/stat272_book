# Creates the hypothetical example data used in the book and the slides.
# Run from the project root:  Rscript data/make_data.R
# All values are hypothetical and used for illustration only.

dir <- "data"

# 2.2 / 3.2: daily earnings (baht) of 25 food-delivery riders in Chiang Mai
set.seed(2722)
riders <- data.frame(rider = 1:25, earnings = round(rnorm(25, 645, 85)))
write.csv(riders, file.path(dir, "rider_earnings.csv"), row.names = FALSE)

# 3.3: monthly household spending (baht) before and after a stimulus measure
set.seed(2733)
before <- round(rnorm(10, 14000, 2500), -1)
after  <- before + round(rnorm(10, 850, 800), -1)
stimulus <- data.frame(household = 1:10, before = before, after = after)
write.csv(stimulus, file.path(dir, "stimulus_spending.csv"), row.names = FALSE)

# 3.3 Your Turn: daily wage (baht) of 12 workers before and after a training course
set.seed(2734)
w_before <- round(rnorm(12, 420, 45))
w_after  <- w_before + round(rnorm(12, 18, 25))
training <- data.frame(worker = 1:12, before = w_before, after = w_after)
write.csv(training, file.path(dir, "training_wage.csv"), row.names = FALSE)

# 3.4: monthly returns (%) of two mutual funds
set.seed(2744)
funds <- rbind(
  data.frame(fund = "A", return = round(rnorm(13, 0.9, 3.1), 2)),
  data.frame(fund = "B", return = round(rnorm(16, 0.6, 1.5), 2))
)
write.csv(funds, file.path(dir, "fund_returns.csv"), row.names = FALSE)

# 3.5: daily sales (units) at stores using two pricing strategies
set.seed(2755)
pricing <- rbind(
  data.frame(strategy = "Discount", sales = round(rnorm(12, 128, 14))),
  data.frame(strategy = "Bundle",   sales = round(rnorm(10, 114, 13)))
)
write.csv(pricing, file.path(dir, "pricing_sales.csv"), row.names = FALSE)

# 3.5 (Welch): price (baht) of the same headphones at online and physical stores
set.seed(2756)
headphones <- rbind(
  data.frame(channel = "Online",   price = round(rnorm(15, 1890, 160), -1)),
  data.frame(channel = "Physical", price = round(rnorm(12, 2090, 45), -1))
)
write.csv(headphones, file.path(dir, "headphone_prices.csv"), row.names = FALSE)

# 4.1 / 4.2: weekly sales (hundred units) at 15 stores, 3 pricing strategies (CRD)
crd <- data.frame(
  strategy = rep(c("Regular", "Discount", "Bundle"), each = 5),
  sales = c(21, 24, 19, 23, 18,
            28, 31, 26, 30, 27,
            25, 22, 27, 24, 26)
)
write.csv(crd, file.path(dir, "pricing_crd.csv"), row.names = FALSE)

# 4.1 Your Turn: household savings rate (%) in 4 regions, 4 households each
crd2 <- data.frame(
  region = rep(c("North", "Northeast", "Central", "South"), each = 4),
  saving = c(12, 15, 11, 14,
              9, 10,  8, 11,
             16, 14, 17, 15,
             13, 11, 12, 14)
)
write.csv(crd2, file.path(dir, "saving_rate.csv"), row.names = FALSE)

# 4.3: weekly sales (hundred units), 3 pricing strategies in 5 provinces (RCBD)
rcbd <- data.frame(
  province = rep(c("Chiang Mai", "Lampang", "Lamphun", "Phrae", "Nan"), times = 3),
  strategy = rep(c("Regular", "Discount", "Bundle"), each = 5),
  sales = c(32, 24, 27, 23, 18,
            37, 29, 33, 27, 26,
            35, 27, 28, 22, 24)
)
write.csv(rcbd, file.path(dir, "pricing_rcbd.csv"), row.names = FALSE)

# 3.2: monthly electricity bill (baht) of 30 households
set.seed(2732)
bills <- data.frame(household = 1:30, bill = round(rnorm(30, 1265, 170)))
write.csv(bills, file.path(dir, "electricity_bills.csv"), row.names = FALSE)

# 4.3 Your Turn: interest rate (%) of 3 loan products at 6 banks (RCBD)
loans <- data.frame(
  bank = rep(paste("Bank", 1:6), times = 3),
  product = rep(c("Personal", "Car", "Home"), each = 6),
  rate = c(8.4, 7.9, 9.1, 8.8, 7.6, 9.5,
           7.4, 6.3, 8.6, 7.9, 7.1, 8.0,
           7.0, 6.4, 7.9, 8.1, 6.0, 8.4)
)
write.csv(loans, file.path(dir, "loan_rates.csv"), row.names = FALSE)
