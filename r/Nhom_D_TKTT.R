# ==============================================================================
# BÁO CÁO THỐNG KÊ TÍNH TOÁN - NHÓM D
# Tập hợp toàn bộ mã nguồn R xuất hiện trong các Listing của báo cáo
# ==============================================================================

# Listing 1: Mô phỏng hàm phân phối thực nghiệm ECDF (Glivenko-Cantelli)
set.seed(2026)
n_sizes <- c(10, 30, 100, 1000)
colors <- c("red", "orange", "blue", "forestgreen")

curve(pnorm(x), from = -3, to = 3, lwd = 2, ylab = "F(t)", xlab = "t")
for (i in seq_along(n_sizes)) {
  sample_data <- rnorm(n_sizes[i])
  lines(ecdf(sample_data), col = colors[i], verticals = TRUE, do.points = FALSE)
}
legend("topleft", legend = c("True Normal", paste("n =", n_sizes)), col = c("black", colors), lwd = 2, bty = "n")

# Listing 2: Liệt kê chính xác phân phối Bootstrap mẫu đối xứng
x <- c(1, 2, 3)
sample_space <- expand.grid(x, x, x)
means <- rowMeans(sample_space)

prob_table <- prop.table(table(means))
print(prob_table)

se_boot <- sqrt(mean((means - mean(means))^2))
cat("Bootstrap SE:", se_boot, "\n")

# Listing 3: Tính các khoảng tin cậy Bootstrap
x <- c(1, 2, 3, 4, 5)
n <- length(x)
B <- 1000
alpha <- 0.05

boot_means <- numeric(B)
boot_t <- numeric(B)
se_orig <- sd(x) / sqrt(n)
for (b in 1:B) {
  idx <- sample(n, n, replace = TRUE)
  boot_sample <- x[idx]
  boot_means[b] <- mean(boot_sample)
  boot_t[b] <- (mean(boot_sample) - mean(x)) / (sd(boot_sample) / sqrt(n))
}

ci_normal <- c(mean(x) - qnorm(1 - alpha / 2) * sd(boot_means), mean(x) + qnorm(1 - alpha / 2) * sd(boot_means))
ci_basic <- c(2 * mean(x) - quantile(boot_means, 1 - alpha / 2), 2 * mean(x) - quantile(boot_means, alpha / 2))
ci_studentized <- c(mean(x) - quantile(boot_t, 1 - alpha / 2) * se_orig, mean(x) - quantile(boot_t, alpha / 2) * se_orig)
ci_percentile <- quantile(boot_means, c(alpha / 2, 1 - alpha / 2))

u <- numeric(n)
for (i in 1:n) u[i] <- mean(x[-i])
a_hat <- sum((mean(u) - u)^3) / (6 * (sum((mean(u) - u)^2))^1.5)
z0_hat <- qnorm(mean(boot_means < mean(x)))
alpha1 <- pnorm(z0_hat + (z0_hat + qnorm(alpha / 2)) / (1 - a_hat * (z0_hat + qnorm(alpha / 2))))
alpha2 <- pnorm(z0_hat + (z0_hat + qnorm(1 - alpha / 2)) / (1 - a_hat * (z0_hat + qnorm(1 - alpha / 2))))
ci_bca <- quantile(boot_means, c(alpha1, alpha2))

ci_matrix <- rbind(Normal = ci_normal, Basic = ci_basic, Studentized = ci_studentized, Percentile = ci_percentile, BCa = ci_bca)
print(ci_matrix)

# Listing 4: Vẽ lại các khoảng BCa trong nghiên cứu Deng et al. (2013)
measure <- c("KDQOL Symptoms", "KDQOL Burden", "QDIS Static-34", "QDIS Static-6")
rv <- c(0.26, 0.77, 0.84, 0.87)
lower <- c(0.13, 0.53, 0.71, 0.72)
upper <- c(0.44, 1.09, 0.97, 1.03)
y <- 1:4

plot(rv, y, xlim = c(0, 1.3), yaxt = "n", ylab = "", xlab = "Relative Validity (RV)", pch = 19)
axis(2, at = y, labels = measure, las = 1)
segments(lower, y, upper, y, lwd = 2)
abline(v = 1, lty = 2, col = "gray")

# Listing 5: Bootstrap phân tầng cho Hazard Ratio mô hình Cox PH
library(survival)
set.seed(2026)
n <- 40
group <- rep(c(0, 1), each = 20)
time <- rexp(n, rate = 0.1 * exp(-0.6 * group))
status <- rbinom(n, size = 1, prob = 0.8)
data <- data.frame(time = time, status = status, group = group)

fit <- coxph(Surv(time, status) ~ group, data = data)
hr_hat <- exp(coef(fit))

B <- 1000
boot_hr <- numeric(B)
idx0 <- which(data$group == 0)
idx1 <- which(data$group == 1)

for (b in 1:B) {
  sample_idx <- c(sample(idx0, replace = TRUE), sample(idx1, replace = TRUE))
  boot_fit <- coxph(Surv(time, status) ~ group, data = data[sample_idx, ])
  boot_hr[b] <- exp(coef(boot_fit))
}

alpha <- 0.05
se_hr <- sd(boot_hr)
ci_normal <- c(hr_hat - qnorm(1 - alpha / 2) * se_hr, hr_hat + qnorm(1 - alpha / 2) * se_hr)
ci_basic <- c(2 * hr_hat - quantile(boot_hr, 1 - alpha / 2), 2 * hr_hat - quantile(boot_hr, alpha / 2))
ci_percentile <- quantile(boot_hr, c(alpha / 2, 1 - alpha / 2))

cat("Hazard Ratio:", hr_hat, "\n")
print(rbind(Normal = ci_normal, Basic = ci_basic, Percentile = ci_percentile))

# Listing 6: Kiểm tra tính bất biến dưới phép biến đổi logarit
x <- c(2, 3, 4, 5, 9)
n <- length(x)
B <- 1000

boot_theta <- colMeans(matrix(sample(x, n * B, replace = TRUE), nrow = n))
boot_eta <- log(boot_theta)

ci_theta_normal <- c(mean(x) - 1.96 * sd(boot_theta), mean(x) + 1.96 * sd(boot_theta))
ci_theta_basic <- c(2 * mean(x) - quantile(boot_theta, 0.975), 2 * mean(x) - quantile(boot_theta, 0.025))
ci_theta_perc <- quantile(boot_theta, c(0.025, 0.975))

trans_normal <- log(ci_theta_normal)
trans_basic <- log(ci_theta_basic)
trans_perc <- log(ci_theta_perc)

direct_normal <- c(mean(boot_eta) - 1.96 * sd(boot_eta), mean(boot_eta) + 1.96 * sd(boot_eta))
direct_basic <- c(2 * mean(boot_eta) - quantile(boot_eta, 0.975), 2 * mean(boot_eta) - quantile(boot_eta, 0.025))
direct_perc <- quantile(boot_eta, c(0.025, 0.975))

invariance_df <- data.frame(
  Method = c("Normal", "Basic", "Percentile"),
  Transformed_Lower = c(trans_normal[1], trans_basic[1], trans_perc[1]),
  Transformed_Upper = c(trans_normal[2], trans_basic[2], trans_perc[2]),
  Direct_Lower = c(direct_normal[1], direct_basic[1], direct_perc[1]),
  Direct_Upper = c(direct_normal[2], direct_basic[2], direct_perc[2])
)
print(invariance_df)
