# ==============================================================================
# BÁO CÁO CUỐI KỲ: THỐNG KÊ TÍNH TOÁN - NHÓM D
# Đề tài: Khoảng tin cậy Bootstrap Chuẩn tắc, Cơ bản và Phân vị
# ==============================================================================

# 1. Khởi tạo thư mục xuất kết quả và bảng màu
out_fig <- file.path("output", "figures")
dir.create(out_fig, recursive = TRUE, showWarnings = FALSE)
colors <- c("#2474A5", "#D17B21", "#35865C")  # Normal, Basic, Percentile
methods <- c("Normal", "Basic", "Percentile")

# Hàm hỗ trợ lưu đồng thời định dạng PDF và PNG (180 DPI)
save_fig <- function(filename, w = 10, h = 6, plot_fn) {
  pdf(file.path(out_fig, paste0(filename, ".pdf")), width = w, height = h)
  plot_fn()
  invisible(dev.off())
  png(file.path(out_fig, paste0(filename, ".png")), width = w * 180, height = h * 180, res = 180)
  plot_fn()
  invisible(dev.off())
}

# 2. Hàm tính 3 khoảng tin cậy Bootstrap: Normal, Basic, Percentile
calc_boot_ci <- function(theta_hat, b_means, alpha = 0.05, type = 7) {
  se <- sd(b_means)
  z <- qnorm(1 - alpha / 2)
  q <- unname(quantile(b_means, c(alpha / 2, 1 - alpha / 2), type = type))
  rbind(
    Normal     = c(theta_hat - z * se, theta_hat + z * se),
    Basic      = c(2 * theta_hat - q[2], 2 * theta_hat - q[1]),
    Percentile = q
  )
}

# 3. Phần 1: Liệt kê chính xác (Exact Enumeration) trên 2 mẫu nhỏ
ex_samples <- list(c(1, 2, 3), c(1, 1, 1, 9))
ex_dist <- lapply(ex_samples, function(x) {
  grid <- as.matrix(expand.grid(rep(list(x), length(x))))
  means <- rowMeans(grid)
  val <- sort(unique(means))
  freq <- tabulate(match(means, val))
  data.frame(mean = val, prob = freq / length(means), label = paste0(freq, "/", length(means)))
})

save_fig("example-bootstrap-distributions", w = 10, h = 5, function() {
  par(mfrow = c(1, 2), mar = c(4, 4.5, 3, 1), las = 1)
  titles <- c("Symmetric sample", "Right-skewed sample")
  for (j in 1:2) {
    d <- ex_dist[[j]]
    plot(d$mean, d$prob, type = "h", lwd = 8, col = colors[1],
         ylim = c(0, max(d$prob) * 1.25), xlab = "Bootstrap mean", ylab = "Probability", main = titles[j])
    abline(v = mean(ex_samples[[j]]), lty = 2, lwd = 2)
    text(d$mean, d$prob + 0.035, d$label, cex = 0.8)
  }
})

# 4. Phần 2: Mô phỏng Monte Carlo (4 kịch bản phân phối & cỡ mẫu)
set.seed(20260925)
K <- 2000  # Số lần lặp mô phỏng Monte Carlo (bản đầy đủ: 10000)
B <- 999   # Số mẫu con Bootstrap trong mỗi lần lặp (bản đầy đủ: 1999)

scenarios <- list(
  list(name = "Normal n = 12",      draw = function() rnorm(12), theta = 0, n = 12),
  list(name = "Normal n = 40",      draw = function() rnorm(40), theta = 0, n = 40),
  list(name = "Exponential n = 12", draw = function() rexp(12),  theta = 1, n = 12),
  list(name = "Exponential n = 40", draw = function() rexp(40),  theta = 1, n = 40)
)

sim_res <- lapply(scenarios, function(sc) {
  cov <- matrix(FALSE, K, 3)
  len <- matrix(0, K, 3)
  for (k in 1:K) {
    x <- sc$draw()
    b_means <- colMeans(matrix(sample(x, sc$n * B, replace = TRUE), nrow = sc$n))
    ci <- calc_boot_ci(mean(x), b_means, type = 7)
    cov[k, ] <- (ci[, 1] <= sc$theta) & (sc$theta <= ci[, 2])
    len[k, ] <- ci[, 2] - ci[, 1]
  }
  list(coverage = colMeans(cov), avg_length = colMeans(len))
})

# Đồ thị 2: Xác suất bao phủ (Coverage probability)
save_fig("simulation-coverage", w = 9, h = 6, function() {
  par(mfrow = c(2, 2), mar = c(4, 4.5, 3, 1), las = 1)
  for (j in 1:4) {
    cp <- sim_res[[j]]$coverage
    plot(1:3, cp, type = "p", pch = 19, cex = 1.4, col = colors,
         xlim = c(0.7, 3.3), ylim = c(min(0.75, min(cp) - 0.03), 1),
         xaxt = "n", xlab = "Method", ylab = "Coverage probability", main = scenarios[[j]]$name)
    axis(1, at = 1:3, labels = methods)
    abline(h = 0.95, lty = 2)
  }
})

# Đồ thị 3: Độ dài khoảng tin cậy trung bình (Average interval length)
save_fig("simulation-average-length", w = 9, h = 6, function() {
  par(mfrow = c(2, 2), mar = c(4, 4.5, 3, 1), las = 1)
  max_len <- max(sapply(sim_res, function(r) max(r$avg_length)))
  for (j in 1:4) {
    al <- sim_res[[j]]$avg_length
    plot(1:3, al, type = "p", pch = 19, cex = 1.4, col = colors,
         xlim = c(0.7, 3.3), ylim = c(0, max_len * 1.15),
         xaxt = "n", xlab = "Method", ylab = "Average interval length", main = scenarios[[j]]$name)
    axis(1, at = 1:3, labels = methods)
  }
})

# 5. Phần 3: Kiểm chứng tính bất biến dưới phép biến đổi eta = log(theta)
x_inv <- c(2, 3, 4, 5, 9)
n_inv <- length(x_inv)
b_means <- colMeans(matrix(sample(x_inv, n_inv * B, replace = TRUE), nrow = n_inv))

ci_theta <- calc_boot_ci(mean(x_inv), b_means, type = 1)
ci_eta_direct <- rbind(
  Normal     = c(log(mean(x_inv)) - qnorm(0.975) * sd(log(b_means)), log(mean(x_inv)) + qnorm(0.975) * sd(log(b_means))),
  Basic      = c(2 * log(mean(x_inv)) - quantile(log(b_means), 0.975, type = 1), 2 * log(mean(x_inv)) - quantile(log(b_means), 0.025, type = 1)),
  Percentile = quantile(log(b_means), c(0.025, 0.975), type = 1)
)
ci_eta_trans <- log(ci_theta)
diff_inv <- apply(abs(ci_eta_trans - ci_eta_direct), 1, max)

save_fig("invariance-log-comparison", w = 8, h = 5, function() {
  par(mar = c(4, 4.5, 3, 1), las = 1)
  plot(1:3, diff_inv, type = "p", pch = 19, cex = 1.4, col = colors,
       xaxt = "n", xlab = "Method", ylab = "Maximum endpoint difference",
       main = "Invariance under eta = log(theta)")
  axis(1, at = 1:3, labels = methods)
  abline(h = 0, lty = 2)
})

cat("Đã hoàn tất tính toán và xuất 4 hình ảnh (PDF & PNG) vào:", out_fig, "\n")
