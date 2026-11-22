# 1. ECDF (Listing 1)
set.seed(2026)
n_sizes <- c(10, 30, 100, 1000)
cols <- c("red", "orange", "blue", "forestgreen")

curve(pnorm(x), from = -3, to = 3, lwd = 2, ylab = "F(t)", xlab = "t")
for (i in seq_along(n_sizes)) {
  lines(ecdf(rnorm(n_sizes[i])), col = cols[i], verticals = TRUE, do.points = FALSE)
}
legend("topleft", legend = c("True Normal", paste("n =", n_sizes)),
       col = c("black", cols), lwd = 2, bty = "n")

# 2. Bootstrap doi xung (Listing 2)
x <- c(1, 2, 3)
means <- rowMeans(expand.grid(x, x, x))
prob <- prop.table(table(means))
prob
se <- sqrt(mean((means - mean(means))^2))
se

# Hinh 5.1 & Bang 5.1: Hai vi du liet ke chinh xac (Doi xung & Lech phai)
x2 <- c(1, 1, 1, 9)
means2 <- rowMeans(expand.grid(x2, x2, x2, x2))

# Tinh khoang tin cay chinh xac cho ca 2 mau (Bang 5.1 Bao cao & Frame 10-11 Slide)
q1 <- unname(quantile(means, c(0.025, 0.975), type = 1))
ci1 <- rbind(
  Normal     = c(mean(x) - 1.96 * se, mean(x) + 1.96 * se),
  Basic      = c(2 * mean(x) - q1[2], 2 * mean(x) - q1[1]),
  Percentile = q1
)
colnames(ci1) <- c("Lower", "Upper")

se2 <- sqrt(mean((means2 - mean(means2))^2))
q2 <- unname(quantile(means2, c(0.025, 0.975), type = 1))
ci2 <- rbind(
  Normal     = c(mean(x2) - 1.96 * se2, mean(x2) + 1.96 * se2),
  Basic      = c(2 * mean(x2) - q2[2], 2 * mean(x2) - q2[1]),
  Percentile = q2
)
colnames(ci2) <- c("Lower", "Upper")

cat("\n=== BANG 5.1: KHOANG TIN CAY TU HAI VI DU LIET KE CHINH XAC ===\n")
cat("--- Mau doi xung x = (1, 2, 3), se = ", round(se, 4), " ---\n")
print(round(ci1, 3))
cat("--- Mau lech phai x = (1, 1, 1, 9), se = ", round(se2, 4), " ---\n")
print(round(ci2, 3))

par(mfrow = c(1, 2), las = 1)
v1 <- sort(unique(means))
p1 <- prop.table(table(means))
plot(v1, p1, type = "h", lwd = 6, col = "blue",
     ylim = c(0, max(p1) * 1.2), xlab = "Bootstrap mean", ylab = "Probability",
     main = "Symmetric sample")
abline(v = mean(x), lty = 2)
text(v1, p1 + 0.035, paste0(tabulate(match(means, v1)), "/", length(means)), cex = 0.8)

v2 <- sort(unique(means2))
p2 <- prop.table(table(means2))
plot(v2, p2, type = "h", lwd = 6, col = "blue",
     ylim = c(0, max(p2) * 1.2), xlab = "Bootstrap mean", ylab = "Probability",
     main = "Right-skewed sample")
abline(v = mean(x2), lty = 2)
text(v2, p2 + 0.035, paste0(tabulate(match(means2, v2)), "/", length(means2)), cex = 0.8)

# 3. Tinh cac khoang tin cay (Listing 3)
x <- c(1, 2, 3, 4, 5)
n <- length(x)
B <- 1000
alpha <- 0.05

theta_hat <- mean(x)
boot_means <- colMeans(matrix(sample(x, n * B, replace = TRUE), nrow = n))
se <- sd(boot_means)
q <- quantile(boot_means, c(alpha / 2, 1 - alpha / 2))

ci <- rbind(
  Normal = c(theta_hat - 1.96 * se, theta_hat + 1.96 * se),
  Basic = c(2 * theta_hat - q[2], 2 * theta_hat - q[1]),
  Percentile = c(q[1], q[2])
)
colnames(ci) <- c("Lower", "Upper")
round(ci, 3)

# Hinh 6.1 & 6.2: Mo phong Monte Carlo (Bang 7.1 Bao cao & Slide Frame 12-17)
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(20260925)

scenarios <- list(
  "Normal n = 12"      = list(draw = rnorm, theta = 0, n = 12L),
  "Normal n = 40"      = list(draw = rnorm, theta = 0, n = 40L),
  "Exponential n = 12" = list(draw = rexp,  theta = 1, n = 12L),
  "Exponential n = 40" = list(draw = rexp,  theta = 1, n = 40L)
)
methods <- c("Normal", "Basic", "Percentile")
cols <- c("blue", "orange", "darkgreen")

quick_test <- identical(Sys.getenv("QUICK_TEST"), "TRUE")
K <- if (quick_test) 500L else 10000L
B <- if (quick_test) 499L else 1999L
z_val <- qnorm(1 - alpha / 2)
tail_probs <- c(alpha / 2, 1 - alpha / 2)

sim_res <- lapply(scenarios, function(sc) {
  cov <- matrix(FALSE, K, 3L)
  len <- matrix(0, K, 3L)
  for (k in seq_len(K)) {
    x <- sc$draw(sc$n)
    b_means <- colMeans(matrix(x[sample.int(sc$n, sc$n * B, replace = TRUE)], nrow = sc$n))
    se <- sd(b_means)
    q <- unname(quantile(b_means, tail_probs, type = 7))
    ci_mat <- rbind(
      mean(x) + c(-z_val, z_val) * se,
      2 * mean(x) - c(q[2], q[1]),
      q
    )
    cov[k, ] <- (ci_mat[, 1] <= sc$theta) & (sc$theta <= ci_mat[, 2])
    len[k, ] <- ci_mat[, 2] - ci_mat[, 1]
  }
  cp <- colMeans(cov)
  mcse <- sqrt(cp * (1 - cp) / K)
  list(cov = cp, len = colMeans(len), mcse = mcse, raw_cov = cov)
})

cat(sprintf("\n=== BANG 7.1: KET QUA MO PHONG MONTE CARLO (K = %d, B = %d) ===\n", K, B))
for (nm in names(sim_res)) {
  res <- data.frame(
    Method = methods,
    Coverage_Pct = round(sim_res[[nm]]$cov * 100, 2),
    AL = round(sim_res[[nm]]$len, 4),
    MCSE_Pct = round(sim_res[[nm]]$mcse * 100, 2)
  )
  cat(paste("\n---", nm, "---\n"))
  print(res)
}

# So sanh do bao phu theo cap trong Exponential (Slide Frame 16)
cat("\n=== SO SANH DO BAO PHU THEO CAP TRONG EXPONENTIAL (FRAME 16 SLIDE) ===\n")
for (idx in c("Exponential n = 12", "Exponential n = 40")) {
  cov_m <- sim_res[[idx]]$raw_cov
  diff_p_n <- (cov_m[, 3] - cov_m[, 1]) * 100
  diff_p_b <- (cov_m[, 3] - cov_m[, 2]) * 100
  cat(sprintf("%s: Percentile - Normal = %+0.2f%% (MCSE = %0.2f%%)\n",
              idx, mean(diff_p_n), sd(diff_p_n) / sqrt(K)))
  cat(sprintf("%s: Percentile - Basic  = %+0.2f%% (MCSE = %0.2f%%)\n",
              idx, mean(diff_p_b), sd(diff_p_b) / sqrt(K)))
}

# Hinh 6.1
par(mfrow = c(2, 2), las = 1)
for (j in 1:4) {
  cp <- sim_res[[j]]$cov
  plot(1:3, cp, pch = 19, cex = 1.4, col = cols,
       xlim = c(0.7, 3.3), ylim = c(min(0.75, min(cp) - 0.03), 1),
       xaxt = "n", xlab = "Method", ylab = "Coverage",
       main = names(scenarios)[j])
  axis(1, at = 1:3, labels = methods)
  abline(h = 0.95, lty = 2)
}

# Hinh 6.2
par(mfrow = c(2, 2), las = 1)
max_len <- max(sapply(sim_res, function(r) max(r$len)))
for (j in 1:4) {
  l <- sim_res[[j]]$len
  plot(1:3, l, pch = 19, cex = 1.4, col = cols,
       xlim = c(0.7, 3.3), ylim = c(0, max_len * 1.15),
       xaxt = "n", xlab = "Method", ylab = "Average length",
       main = names(scenarios)[j])
  axis(1, at = 1:3, labels = methods)
}
par(mfrow = c(1, 1))

# 4. Deng et al. (Listing 4)
measure <- c("KDQOL Symptoms", "KDQOL Burden", "QDIS Static-34", "QDIS Static-6")
rv <- c(0.26, 0.77, 0.84, 0.87)
lower <- c(0.13, 0.53, 0.71, 0.72)
upper <- c(0.44, 1.09, 0.97, 1.03)
y <- 1:4

par(mar = c(4, 9, 2, 1))
plot(rv, y, xlim = c(0, 1.3), ylim = c(0.5, 4.5), yaxt = "n", pch = 19,
     xlab = "Relative validity (RV) & BCa 95% CI", ylab = "")
axis(2, at = y, labels = measure, las = 1)
segments(lower, y, upper, y, lwd = 2)
abline(v = 1, lty = 2, col = "red")

# 5. Cox HR (Listing 5)
library(survival)
set.seed(2026)
n <- 40
group <- rep(c(0, 1), each = 20)
time <- rexp(n, rate = 0.1 * exp(-0.6 * group))
status <- rbinom(n, size = 1, prob = 0.85)
data_med <- data.frame(time, status, group)

fit <- coxph(Surv(time, status) ~ group, data = data_med)
hr_hat <- exp(coef(fit))

B <- 500
boot_hr <- numeric(B)
g0 <- which(group == 0)
g1 <- which(group == 1)

for (b in 1:B) {
  idx <- c(sample(g0, replace = TRUE), sample(g1, replace = TRUE))
  fit_b <- coxph(Surv(time[idx], status[idx]) ~ group[idx])
  boot_hr[b] <- exp(coef(fit_b))
}

se <- sd(boot_hr)
q <- quantile(boot_hr, c(0.025, 0.975))

ci <- rbind(
  Normal = c(hr_hat - 1.96 * se, hr_hat + 1.96 * se),
  Basic = c(2 * hr_hat - q[2], 2 * hr_hat - q[1]),
  Percentile = c(q[1], q[2])
)
colnames(ci) <- c("Lower", "Upper")
round(ci, 3)

# Vi du gia dinh Hazard Ratio (Frame 18 Slide & Muc 7.2 Bao cao)
cat("\n=== VI DU GIA DINH HAZARD RATIO (FRAME 18 SLIDE & MUC 7.2 BAO CAO) ===\n")
hr_hat_hypo <- 1.85
se_hypo <- 0.42
q_hypo <- c(1.15, 2.82)
ci_hypo <- rbind(
  Normal = c(hr_hat_hypo - 1.96 * se_hypo, hr_hat_hypo + 1.96 * se_hypo),
  Basic  = c(2 * hr_hat_hypo - q_hypo[2], 2 * hr_hat_hypo - q_hypo[1])
)
colnames(ci_hypo) <- c("Lower", "Upper")
print(round(ci_hypo, 3))

# 6. Bat bien duoi log (Listing 6)
x <- c(2, 3, 4, 5, 9)
n <- length(x)
B <- 1000

boot_theta <- colMeans(matrix(sample(x, n * B, replace = TRUE), nrow = n))
boot_eta <- log(boot_theta)

theta_hat <- mean(x)
eta_hat <- log(theta_hat)

q_theta <- quantile(boot_theta, c(0.025, 0.975), type = 1)
q_eta <- quantile(boot_eta, c(0.025, 0.975), type = 1)

diff_percentile <- max(abs(log(q_theta) - q_eta))

ci_basic_theta <- c(2 * theta_hat - q_theta[2], 2 * theta_hat - q_theta[1])
ci_basic_eta <- c(2 * eta_hat - q_eta[2], 2 * eta_hat - q_eta[1])
diff_basic <- max(abs(log(ci_basic_theta) - ci_basic_eta))

result <- c(Percentile_Diff = diff_percentile, Basic_Diff = diff_basic)
round(result, 6)

# Hinh 8.1 & Bang 7: Tinh toan diff_normal truc tiep, dong bo so lieu Bao cao & Slide
se_theta <- sd(boot_theta)
se_eta <- sd(boot_eta)
ci_norm_theta <- c(theta_hat - 1.96 * se_theta, theta_hat + 1.96 * se_theta)
ci_norm_eta <- c(eta_hat - 1.96 * se_eta, eta_hat + 1.96 * se_eta)
diff_normal <- max(abs(log(ci_norm_theta) - ci_norm_eta))

cat("\n=== PHAN VI TREN THANG LOG (FRAME 20 SLIDE) ===\n")
cat("q_theta:", round(q_theta, 1), "\n")
cat("[log(q_L), log(q_U)]:", round(log(q_theta), 3), "\n")

cat("\n=== BANG 7: SAI KHAC LON NHAT TREN THANG LOG ===\n")
diff_tbl <- c(Normal = diff_normal, Basic = diff_basic, Percentile = diff_percentile)
print(round(diff_tbl, 7))

# Hinh 8.1
par(mfrow = c(1, 1), las = 1)
plot(1:3, diff_tbl, pch = 19, cex = 1.4, col = cols,
     xaxt = "n", xlab = "Method", ylab = "Max difference",
     main = "Invariance under log(theta)")
axis(1, at = 1:3, labels = names(diff_tbl))
abline(h = 0, lty = 2)
