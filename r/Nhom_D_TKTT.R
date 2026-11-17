# ==============================================================================
# BÁO CÁO THỐNG KÊ TÍNH TOÁN - NHÓM D
# Tập hợp mã nguồn R các Listing và code vẽ các đồ thị tương ứng trong báo cáo
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
se_boot

# Đồ thị Hình 5.1: Phân phối Bootstrap mẫu đối xứng và mẫu lệch phải
x_skewed <- c(1, 1, 1, 9)
space_skewed <- expand.grid(x_skewed, x_skewed, x_skewed, x_skewed)
means_skewed <- rowMeans(space_skewed)

par(mfrow = c(1, 2), mar = c(4, 4.5, 3, 1), las = 1)
val1 <- sort(unique(means))
prob1 <- tabulate(match(means, val1)) / length(means)
plot(val1, prob1, type = "h", lwd = 8, col = "#2474A5",
     ylim = c(0, max(prob1) * 1.25), xlab = "Bootstrap mean", ylab = "Probability",
     main = "Symmetric sample")
abline(v = mean(x), lty = 2, lwd = 2)
text(val1, prob1 + 0.035, paste0(tabulate(match(means, val1)), "/", length(means)), cex = 0.8)

val2 <- sort(unique(means_skewed))
prob2 <- tabulate(match(means_skewed, val2)) / length(means_skewed)
plot(val2, prob2, type = "h", lwd = 8, col = "#2474A5",
     ylim = c(0, max(prob2) * 1.25), xlab = "Bootstrap mean", ylab = "Probability",
     main = "Right-skewed sample")
abline(v = mean(x_skewed), lty = 2, lwd = 2)
text(val2, prob2 + 0.035, paste0(tabulate(match(means_skewed, val2)), "/", length(means_skewed)), cex = 0.8)

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

# Đồ thị Hình 6.1 & 6.2: Mô phỏng Coverage và Độ dài khoảng trung bình
scenarios <- list(
  "Normal n = 12"      = list(draw = function() rnorm(12), theta = 0, n = 12),
  "Normal n = 40"      = list(draw = function() rnorm(40), theta = 0, n = 40),
  "Exponential n = 12" = list(draw = function() rexp(12),  theta = 1, n = 12),
  "Exponential n = 40" = list(draw = function() rexp(40),  theta = 1, n = 40)
)
methods_sim <- c("Normal", "Basic", "Percentile")
cols_sim <- c("#2474A5", "#D17B21", "#35865C")
K_sim <- 500
B_sim <- 499

sim_res <- lapply(scenarios, function(sc) {
  cov <- matrix(FALSE, K_sim, 3)
  len <- matrix(0, K_sim, 3)
  for (k in 1:K_sim) {
    samp <- sc$draw()
    b_means <- colMeans(matrix(sample(samp, sc$n * B_sim, replace = TRUE), nrow = sc$n))
    se_b <- sd(b_means)
    q_b <- quantile(b_means, c(0.025, 0.975))
    ci_mat <- rbind(
      mean(samp) + c(-1.96, 1.96) * se_b,
      2 * mean(samp) - c(q_b[2], q_b[1]),
      q_b
    )
    cov[k, ] <- (ci_mat[, 1] <= sc$theta) & (sc$theta <= ci_mat[, 2])
    len[k, ] <- ci_mat[, 2] - ci_mat[, 1]
  }
  list(coverage = colMeans(cov), avg_length = colMeans(len))
})

# Hình 6.1: Coverage probability
par(mfrow = c(2, 2), mar = c(4, 4.5, 3, 1), las = 1)
for (j in 1:4) {
  cp <- sim_res[[j]]$coverage
  plot(1:3, cp, pch = 19, cex = 1.4, col = cols_sim,
       xlim = c(0.7, 3.3), ylim = c(min(0.75, min(cp) - 0.03), 1),
       xaxt = "n", xlab = "Method", ylab = "Coverage probability",
       main = names(scenarios)[j])
  axis(1, at = 1:3, labels = methods_sim)
  abline(h = 0.95, lty = 2)
}

# Hình 6.2: Average interval length
par(mfrow = c(2, 2), mar = c(4, 4.5, 3, 1), las = 1)
max_len <- max(sapply(sim_res, function(r) max(r$avg_length)))
for (j in 1:4) {
  al <- sim_res[[j]]$avg_length
  plot(1:3, al, pch = 19, cex = 1.4, col = cols_sim,
       xlim = c(0.7, 3.3), ylim = c(0, max_len * 1.15),
       xaxt = "n", xlab = "Method", ylab = "Average interval length",
       main = names(scenarios)[j])
  axis(1, at = 1:3, labels = methods_sim)
}

# Listing 4: Vẽ lại các khoảng BCa trong nghiên cứu Deng et al. (2013)
measure <- c("KDQOL Symptoms", "KDQOL Burden", "QDIS Static-34", "QDIS Static-6")
rv <- c(0.26, 0.77, 0.84, 0.87)
lower <- c(0.13, 0.53, 0.71, 0.72)
upper <- c(0.44, 1.09, 0.97, 1.03)
y <- 1:4

par(mfrow = c(1, 1), mar = c(4, 8, 3, 1), las = 1)
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

# Đồ thị Hình 8.1: Sai khác giữa hai cách tính sau phép biến đổi log
diff_inv <- c(
  max(abs(trans_normal - direct_normal)),
  max(abs(trans_basic - direct_basic)),
  max(abs(trans_perc - direct_perc))
)
methods_inv <- c("Normal", "Basic", "Percentile")
cols_inv <- c("#2474A5", "#D17B21", "#35865C")

par(mfrow = c(1, 1), mar = c(4, 4.5, 3, 1), las = 1)
plot(1:3, diff_inv, pch = 19, cex = 1.4, col = cols_inv,
     xaxt = "n", xlab = "Method", ylab = "Maximum endpoint difference",
     main = "Invariance under eta = log(theta)")
axis(1, at = 1:3, labels = methods_inv)
abline(h = 0, lty = 2)
