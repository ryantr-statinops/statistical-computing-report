# ==============================================================================
# QUY TRÌNH MÔ PHỎNG VÀ XUẤT ĐỒ THỊ, BẢNG BIỂU BÁO CÁO (NHÓM D)
# Script này chạy mô phỏng Monte Carlo chuyên sâu (K = 10000, B = 1999)
# và xuất toàn bộ các file ảnh PDF/PNG và bảng số liệu CSV vào thư mục output/
# ==============================================================================

# 1. THIẾT LẬP ĐƯỜNG DẪN VÀ THAM SỐ TOÀN CỤC
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
project_root <- if (length(script_arg)) {
  script_file <- normalizePath(sub("^--file=", "", script_arg[1]), mustWork = TRUE)
  normalizePath(file.path(dirname(script_file), ".."), mustWork = TRUE)
} else {
  normalizePath(getwd(), mustWork = TRUE)
}

if (!file.exists(file.path(project_root, "tex-report", "code", "main.tex"))) {
  stop("Vui lòng chạy script từ thư mục gốc của repository hoặc dùng Rscript r/generate_figures.R")
}

figures_dir <- file.path(project_root, "output", "figures")
tables_dir  <- file.path(project_root, "output", "tables")
logs_dir    <- file.path(project_root, "output", "logs")

for (d in c(figures_dir, tables_dir, logs_dir)) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

# Tham số mô phỏng Monte Carlo theo chuẩn báo cáo (Chương 6)
quick_test <- identical(Sys.getenv("QUICK_TEST"), "TRUE")
K <- if (quick_test) 2000L else 10000L
B <- if (quick_test) 999L else 1999L
alpha <- 0.05
z_val <- qnorm(1 - alpha / 2)
tail_probs <- c(alpha / 2, 1 - alpha / 2)
methods <- c("Normal", "Basic", "Percentile")
colors <- c("#2474A5", "#D17B21", "#35865C")

# Hàm hỗ trợ lưu đồ thị dạng PDF và PNG
save_plot <- function(stem, plot_fn, width = 9, height = 6) {
  pdf(file.path(figures_dir, paste0(stem, ".pdf")), width = width, height = height)
  plot_fn()
  invisible(dev.off())
  png(file.path(figures_dir, paste0(stem, ".png")), width = width * 180, height = height * 180, res = 180)
  plot_fn()
  invisible(dev.off())
}

# 2. HÀM TÍNH KHOẢNG TIN CẬY BOOTSTRAP (NORMAL, BASIC, PERCENTILE)
calc_boot_ci <- function(theta_hat, b_replicates, alpha = 0.05, type = 7) {
  se <- sd(b_replicates)
  z <- qnorm(1 - alpha / 2)
  q <- unname(quantile(b_replicates, c(alpha / 2, 1 - alpha / 2), type = type))
  rbind(
    Normal     = c(theta_hat - z * se, theta_hat + z * se),
    Basic      = c(2 * theta_hat - q[2], 2 * theta_hat - q[1]),
    Percentile = q
  )
}

# 3. HAI VÍ DỤ PHÂN PHỐI BOOTSTRAP CHÍNH XÁC (CHƯƠNG 5, BẢNG 5.1 & HÌNH 5.1)
cat("\n=== 1. LIỆT KÊ CHÍNH XÁC 2 MẪU MINH HỌA (CHƯƠNG 5) ===\n")
example_names <- c("Đối xứng", "Lệch phải")
example_samples <- list(c(1, 2, 3), c(1, 1, 1, 9))
example_distributions <- vector("list", 2L)
example_rows <- vector("list", 2L)

for (j in 1:2) {
  x <- example_samples[[j]]
  n <- length(x)
  indices <- as.matrix(do.call(expand.grid,
    c(rep(list(seq_len(n)), n), KEEP.OUT.ATTRS = FALSE)))
  means <- rowMeans(matrix(x[indices], ncol = n))
  support <- sort(unique(means))
  frequency <- tabulate(match(means, support), length(support))
  example_distributions[[j]] <- data.frame(
    bootstrap_mean = support, frequency = frequency,
    probability = frequency / length(means))
  theta_hat <- mean(x)
  se <- sqrt(mean((means - mean(means))^2))
  q <- unname(quantile(means, tail_probs, type = 1))
  bounds <- rbind(
    Normal = c(theta_hat - z_val * se, theta_hat + z_val * se),
    Basic = c(2 * theta_hat - q[2], 2 * theta_hat - q[1]),
    Percentile = q)
  example_rows[[j]] <- data.frame(
    example = example_names[j], method = methods,
    theta_hat = theta_hat, bootstrap_se = se,
    q_lower = q[1], q_upper = q[2],
    lower = bounds[, 1], upper = bounds[, 2])
}
example_results <- do.call(rbind, example_rows)
rownames(example_results) <- NULL

stopifnot(identical(example_distributions[[1]]$frequency,
                    c(1L, 3L, 6L, 7L, 6L, 3L, 1L)),
          identical(example_distributions[[2]]$frequency,
                    c(81L, 108L, 54L, 12L, 1L)))

print(example_results)

write.csv(example_distributions[[1]],
          file.path(tables_dir, "example-symmetric-distribution.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(example_distributions[[2]],
          file.path(tables_dir, "example-skewed-distribution.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(example_results,
          file.path(tables_dir, "example-confidence-intervals.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

save_plot("example-bootstrap-distributions", function() {
  old_par <- par(mfrow = c(1, 2), mar = c(4, 4.5, 3, 1), las = 1)
  on.exit(par(old_par))
  for (j in 1:2) {
    d <- example_distributions[[j]]
    plot(d$bootstrap_mean, d$probability, type = "h", lwd = 9,
         xlim = range(d$bootstrap_mean) + c(-.25, .25),
         col = colors[1], ylim = c(0, max(d$probability) * 1.2),
         xlab = "Bootstrap mean", ylab = "Probability",
         main = c("Symmetric sample", "Right-skewed sample")[j])
    abline(v = mean(example_samples[[j]]), lty = 2, lwd = 2)
    text(d$bootstrap_mean, d$probability + .035,
         paste0(d$frequency, "/", sum(d$frequency)), cex = .8)
  }
}, width = 10, height = 5)

# 4. MÔ PHỎNG MONTE CARLO (CHƯƠNG 6, BẢNG 6.1, HÌNH 6.1 & 6.2)
cat(sprintf("\n=== 2. MÔ PHỎNG MONTE CARLO (K = %d, B = %d) ===\n", K, B))
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(20260925)

scenario_names <- c("Normal", "Normal", "Exponential", "Exponential")
scenario_n <- c(12L, 40L, 12L, 40L)
scenario_theta <- c(0, 0, 1, 1)
scenario_draw <- list(rnorm, rnorm, rexp, rexp)
endpoint_names <- c("normal_lower", "normal_upper",
                    "basic_lower", "basic_upper",
                    "percentile_lower", "percentile_upper")
simulation_blocks <- vector("list", 4L)

for (j in 1:4) {
  endpoints <- matrix(NA_real_, K, 6L,
                      dimnames = list(NULL, endpoint_names))
  for (k in seq_len(K)) {
    x <- scenario_draw[[j]](scenario_n[j])
    n <- length(x)
    theta_hat <- mean(x)
    means <- colMeans(matrix(
      x[sample.int(n, n * B, replace = TRUE)], nrow = n))
    se <- sd(means)
    q <- unname(quantile(means, tail_probs, type = 7))
    endpoints[k, ] <- c(
      theta_hat - z_val * se, theta_hat + z_val * se,
      2 * theta_hat - q[2], 2 * theta_hat - q[1],
      q[1], q[2])
  }
  simulation_blocks[[j]] <- data.frame(
    distribution = scenario_names[j], n = scenario_n[j],
    theta = scenario_theta[j], replicate = seq_len(K),
    endpoints, check.names = FALSE)
}

simulation_rows <- vector("list", 12L)
row <- 1L
for (j in 1:4) {
  d <- simulation_blocks[[j]]
  for (m in 1:3) {
    lo <- d[[endpoint_names[2 * m - 1]]]
    hi <- d[[endpoint_names[2 * m]]]
    covered <- lo <= scenario_theta[j] & scenario_theta[j] <= hi
    cp <- mean(covered)
    simulation_rows[[row]] <- data.frame(
      distribution = scenario_names[j], n = scenario_n[j],
      method = methods[m], coverage = cp,
      average_length = mean(hi - lo),
      coverage_mcse = sqrt(cp * (1 - cp) / K))
    row <- row + 1L
  }
}
simulation_results <- do.call(rbind, simulation_rows)
rownames(simulation_results) <- NULL

print(simulation_results)

write.csv(simulation_results,
          file.path(tables_dir, "simulation-summary.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

save_plot("simulation-coverage", function() {
  old_par <- par(mfrow = c(2, 2), mar = c(4, 4.5, 3, 1), las = 1)
  on.exit(par(old_par))
  for (j in 1:4) {
    d <- simulation_results[(3 * j - 2):(3 * j), ]
    values <- d$coverage
    plot(1:3, values, type = "n", xlim = c(.7, 3.3),
         ylim = c(min(.75, min(values) - .03), 1),
         xaxt = "n", xlab = "Method", ylab = "Coverage probability",
         main = paste(scenario_names[j], "n =", scenario_n[j]))
    axis(1, at = 1:3, labels = methods)
    abline(h = 1 - alpha, lty = 2)
    points(1:3, values, pch = 19, cex = 1.4, col = colors)
  }
}, width = 9, height = 6)

save_plot("simulation-average-length", function() {
  old_par <- par(mfrow = c(2, 2), mar = c(4, 4.5, 3, 1), las = 1)
  on.exit(par(old_par))
  max_al <- max(simulation_results$average_length)
  for (j in 1:4) {
    d <- simulation_results[(3 * j - 2):(3 * j), ]
    values <- d$average_length
    plot(1:3, values, type = "n", xlim = c(.7, 3.3),
         ylim = c(0, 1.15 * max_al),
         xaxt = "n", xlab = "Method", ylab = "Average interval length",
         main = paste(scenario_names[j], "n =", scenario_n[j]))
    axis(1, at = 1:3, labels = methods)
    points(1:3, values, pch = 19, cex = 1.4, col = colors)
  }
}, width = 9, height = 6)

# 5. KIỂM CHỨNG TÍNH BẤT BIẾN DƯỚI PHÉP BIẾN ĐỔI LOG (CHƯƠNG 8, BẢNG 8.3 & HÌNH 8.1)
cat("\n=== 3. KIỂM CHỨNG TÍNH BẤT BIẾN (CHƯƠNG 8) ===\n")
invariance_sample <- c(2, 3, 4, 5, 9)
invariance_n <- length(invariance_sample)
invariance_B <- B
invariance_indices <- matrix(
  sample.int(invariance_n, invariance_n * invariance_B, replace = TRUE),
  nrow = invariance_n)
bootstrap_theta <- colMeans(matrix(
  invariance_sample[invariance_indices], nrow = invariance_n))
stopifnot(all(bootstrap_theta > 0))

theta_hat <- mean(invariance_sample)
eta_hat <- log(theta_hat)
bootstrap_eta <- log(bootstrap_theta)
q_theta <- unname(quantile(bootstrap_theta, tail_probs, type = 1))
q_eta <- unname(quantile(bootstrap_eta, tail_probs, type = 1))
se_theta <- sd(bootstrap_theta)
se_eta <- sd(bootstrap_eta)

ci_theta <- rbind(
  Normal = c(theta_hat - z_val * se_theta, theta_hat + z_val * se_theta),
  Basic = c(2 * theta_hat - q_theta[2], 2 * theta_hat - q_theta[1]),
  Percentile = q_theta)
ci_eta_direct <- rbind(
  Normal = c(eta_hat - z_val * se_eta, eta_hat + z_val * se_eta),
  Basic = c(2 * eta_hat - q_eta[2], 2 * eta_hat - q_eta[1]),
  Percentile = q_eta)
ci_eta_transformed <- log(ci_theta)

invariance_results <- data.frame(
  method = methods,
  theta_lower = ci_theta[, 1], theta_upper = ci_theta[, 2],
  log_transformed_lower = ci_eta_transformed[, 1],
  log_transformed_upper = ci_eta_transformed[, 2],
  direct_log_lower = ci_eta_direct[, 1],
  direct_log_upper = ci_eta_direct[, 2],
  max_abs_difference = apply(abs(ci_eta_transformed - ci_eta_direct), 1, max),
  invariant_within_tolerance = apply(
    abs(ci_eta_transformed - ci_eta_direct) <= 1e-12, 1, all))

stopifnot(all(is.finite(as.matrix(invariance_results[, -1]))),
          all(invariance_results$theta_lower <= invariance_results$theta_upper),
          all(invariance_results$invariant_within_tolerance ==
                c(FALSE, FALSE, TRUE)))

print(invariance_results)

write.csv(invariance_results,
          file.path(tables_dir, "invariance-log-comparison.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

save_plot("invariance-log-comparison", function() {
  old_par <- par(mar = c(4, 4.5, 3, 1), las = 1)
  on.exit(par(old_par))
  plot(1:3, invariance_results$max_abs_difference, type = "p",
       pch = 19, lwd = 2, col = colors, xaxt = "n",
       xlab = "Method", ylab = "Maximum endpoint difference",
       main = "Invariance under eta = log(theta)")
  axis(1, at = 1:3, labels = methods)
  abline(h = 0, lty = 2)
}, width = 8, height = 5)

writeLines(c(
  paste("R version:", getRversion()),
  paste("K:", K), paste("B:", B), paste("alpha:", alpha),
  paste("Seed:", 20260925),
  "RNGkind: Mersenne-Twister, Inversion, Rejection",
  "Example quantile type: 1; simulation quantile type: 7",
  "Invariance quantile type: 1",
  paste("Example sample for log invariance:",
        paste(invariance_sample, collapse = ", "))),
  file.path(logs_dir, "run-info.txt"), useBytes = TRUE)

writeLines(capture.output(sessionInfo()),
           file.path(logs_dir, "session-info.txt"), useBytes = TRUE)

cat("\n>>> ĐÃ HOÀN TẤT VÀ XUẤT TOÀN BỘ ẢNH (PDF & PNG) CÙNG BẢNG BIỂU (CSV) VÀO output/ <<<\n")
