#!/usr/bin/env Rscript
# Resolve paths before running the simulation. Rscript works from any directory;
# source("r/Nhom_D_TKTT.R") must be run from the repository root.
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
project_root <- if (length(script_arg)) {
  script_file <- normalizePath(sub("^--file=", "", script_arg[1]), mustWork = TRUE)
  normalizePath(file.path(dirname(script_file), ".."), mustWork = TRUE)
} else {
  normalizePath(getwd(), mustWork = TRUE)
}
if (!file.exists(file.path(project_root, "tex-report", "code", "main.tex"))) {
  stop("Run source() from the repository root, or use Rscript r/Nhom_D_TKTT.R")
}
figures_dir <- file.path(project_root, "output", "figures")
tables_dir <- file.path(project_root, "output", "tables")
logs_dir <- file.path(project_root, "output", "logs")
for (directory in c(figures_dir, tables_dir, logs_dir)) {
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
}

# 1. Tham số và công thức dùng chung.
K <- 10000L  # Số lần mô phỏng cho mỗi kịch bản
B <- 1999L   # Số mẫu bootstrap trong mỗi lần mô phỏng
simulation_seed <- 20260925
alpha <- 0.05
z <- qnorm(1 - alpha / 2)
tail_probs <- c(alpha / 2, 1 - alpha / 2)
methods <- c("Normal", "Basic", "Percentile")

confidence_intervals <- function(estimate, se, q) {
  margin <- z * se
  rbind(
    Normal = c(estimate - margin, estimate + margin),
    Basic = c(2 * estimate - q[2], 2 * estimate - q[1]),
    Percentile = q
  )
}

# 2. Hai ví dụ Bootstrap liệt kê chính xác.
example_names <- c("Đối xứng", "Lệch phải")
example_samples <- list(c(1, 2, 3), c(1, 1, 1, 9))
example_distributions <- vector("list", 2L)
example_rows <- vector("list", 2L)

for (i in seq_along(example_samples)) {
  x <- example_samples[[i]]
  # Mỗi hàng là một mẫu bootstrap có thứ tự. Giá trị lặp vẫn được tính riêng.
  sample_columns <- rep(list(x), length(x))
  all_samples <- expand.grid(sample_columns, KEEP.OUT.ATTRS = FALSE)
  boot_means <- rowMeans(all_samples)
  possible_means <- sort(unique(boot_means))
  frequency <- tabulate(match(boot_means, possible_means))
  example_distributions[[i]] <- data.frame(
    bootstrap_mean = possible_means, frequency = frequency,
    probability = frequency / length(boot_means))

  estimate <- mean(x)
  # Phân phối được liệt kê đầy đủ nên lấy độ lệch chuẩn tổng thể.
  se <- sqrt(mean((boot_means - mean(boot_means))^2))
  q <- unname(quantile(boot_means, tail_probs, type = 1))
  ci <- confidence_intervals(estimate, se, q)
  example_rows[[i]] <- data.frame(
    example = example_names[i], method = methods,
    theta_hat = estimate, bootstrap_se = se,
    q_lower = q[1], q_upper = q[2],
    lower = ci[, 1], upper = ci[, 2])
}
example_results <- do.call(rbind, example_rows)
rownames(example_results) <- NULL
stopifnot(identical(example_distributions[[1]]$frequency,
                    c(1L, 3L, 6L, 7L, 6L, 3L, 1L)),
          identical(example_distributions[[2]]$frequency,
                    c(81L, 108L, 54L, 12L, 1L)))

# 3. Mô phỏng coverage và độ dài khoảng tin cậy.
resample_means <- function(x) {
  n <- length(x)
  indices <- sample.int(n, n * B, replace = TRUE)
  # Mỗi cột chứa một mẫu bootstrap có n quan sát.
  samples <- matrix(x[indices], nrow = n)
  colMeans(samples)
}

run_scenario <- function(distribution, n, true_mean, draw_sample) {
  # Mỗi hàng là một lần mô phỏng, mỗi cột là một phương pháp.
  covered <- matrix(FALSE, nrow = K, ncol = length(methods))
  interval_lengths <- matrix(0, nrow = K, ncol = length(methods))

  for (i in seq_len(K)) {
    x <- draw_sample(n)
    boot_means <- resample_means(x)
    q <- unname(quantile(boot_means, tail_probs, type = 7))
    ci <- confidence_intervals(mean(x), sd(boot_means), q)
    lower <- ci[, 1]
    upper <- ci[, 2]
    covered[i, ] <- lower <= true_mean & true_mean <= upper
    interval_lengths[i, ] <- upper - lower
  }

  coverage <- colMeans(covered)
  data.frame(
    distribution = distribution, n = n,
    method = methods, coverage = coverage,
    average_length = colMeans(interval_lengths),
    coverage_mcse = sqrt(coverage * (1 - coverage) / K))
}

# Chọn màu trước khi cố định seed cho các phép tính thống kê.
set.seed(NULL)
method_colors <- sample(grDevices::hcl.colors(8, "Dark 3"), length(methods))

RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(simulation_seed)
sim_rows <- list(
  run_scenario("Normal", n = 12L, true_mean = 0, draw_sample = rnorm),
  run_scenario("Normal", n = 40L, true_mean = 0, draw_sample = rnorm),
  run_scenario("Exponential", n = 12L, true_mean = 1, draw_sample = rexp),
  run_scenario("Exponential", n = 40L, true_mean = 1, draw_sample = rexp)
)
simulation_results <- do.call(rbind, sim_rows)
rownames(simulation_results) <- NULL

# 4. Kiểm chứng tính bất biến dưới phép biến đổi eta = log(theta).
# Dùng lại cùng các bản sao Bootstrap để tách tác động của phép biến đổi.
invariance_sample <- c(2, 3, 4, 5, 9)
bootstrap_theta <- resample_means(invariance_sample)
stopifnot(all(bootstrap_theta > 0))
theta_hat <- mean(invariance_sample)
eta_hat <- log(theta_hat)
bootstrap_eta <- log(bootstrap_theta)
q_theta <- unname(quantile(bootstrap_theta, tail_probs, type = 1))
q_eta <- unname(quantile(bootstrap_eta, tail_probs, type = 1))
ci_theta <- confidence_intervals(theta_hat, sd(bootstrap_theta), q_theta)
ci_eta_direct <- confidence_intervals(eta_hat, sd(bootstrap_eta), q_eta)
ci_eta_transformed <- log(ci_theta)
abs_diff <- abs(ci_eta_transformed - ci_eta_direct)
max_diff <- apply(abs_diff, 1, max)
invariance_results <- data.frame(
  method = methods,
  theta_lower = ci_theta[, 1], theta_upper = ci_theta[, 2],
  log_transformed_lower = ci_eta_transformed[, 1],
  log_transformed_upper = ci_eta_transformed[, 2],
  direct_log_lower = ci_eta_direct[, 1],
  direct_log_upper = ci_eta_direct[, 2],
  max_abs_difference = max_diff,
  invariant_within_tolerance = max_diff <= 1e-12)
stopifnot(all(is.finite(as.matrix(invariance_results[, -1]))),
          all(invariance_results$theta_lower <= invariance_results$theta_upper),
          all(invariance_results$invariant_within_tolerance ==
                c(FALSE, FALSE, TRUE)))

# 5. Xuất bảng, thông tin lần chạy và đồ thị.
write.csv(example_distributions[[1]],
          file.path(tables_dir, "example-symmetric-distribution.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(example_distributions[[2]],
          file.path(tables_dir, "example-skewed-distribution.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(example_results,
          file.path(tables_dir, "example-confidence-intervals.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(simulation_results,
          file.path(tables_dir, "simulation-summary.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(invariance_results,
          file.path(tables_dir, "invariance-log-comparison.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

writeLines(c(
  paste("R version:", getRversion()),
  paste("K:", K), paste("B:", B), paste("alpha:", alpha),
  paste("Seed:", simulation_seed),
  "RNGkind: Mersenne-Twister, Inversion, Rejection",
  "Example quantile type: 1; simulation quantile type: 7",
  "Invariance quantile type: 1",
  paste("Example sample for log invariance:",
        paste(invariance_sample, collapse = ", "))),
  file.path(logs_dir, "run-info.txt"), useBytes = TRUE)

writeLines(trimws(capture.output(sessionInfo()), which = "right"),
           file.path(logs_dir, "session-info.txt"), useBytes = TRUE)

plot_examples <- function() {
  old_par <- par(mfrow = c(1, 2), mar = c(4, 4.5, 3, 1), las = 1)
  on.exit(par(old_par))
  titles <- c("Symmetric sample", "Right-skewed sample")
  for (i in seq_along(example_samples)) {
    distribution <- example_distributions[[i]]
    plot(distribution$bootstrap_mean, distribution$probability, type = "h", lwd = 9,
         xlim = range(distribution$bootstrap_mean) + c(-.25, .25),
         col = method_colors[i], ylim = c(0, max(distribution$probability) * 1.2),
         xlab = "Bootstrap mean", ylab = "Probability",
         main = titles[i])
    abline(v = mean(example_samples[[i]]), lty = 2, lwd = 2)
    fractions <- paste0(distribution$frequency, "/", sum(distribution$frequency))
    text(distribution$bootstrap_mean, distribution$probability + .035,
         fractions, cex = .8)
  }
}

plot_simulation_metric <- function(metric, ylab, reference = NULL) {
  old_par <- par(mfrow = c(2, 2), mar = c(4, 4.5, 3, 1), las = 1)
  on.exit(par(old_par))
  for (scenario in sim_rows) {
    values <- scenario[[metric]]
    if (identical(metric, "coverage")) {
      ylim <- c(min(.75, min(values) - .03), 1)
    } else {
      ylim <- c(0, 1.15 * max(simulation_results[[metric]]))
    }
    plot(1:3, values, type = "n", xlim = c(.7, 3.3), ylim = ylim,
         xaxt = "n", xlab = "Method", ylab = ylab,
         main = paste(scenario$distribution[1], "n =", scenario$n[1]))
    axis(1, at = 1:3, labels = methods)
    if (!is.null(reference)) abline(h = reference, lty = 2)
    points(1:3, values, pch = 19, cex = 1.4, col = method_colors)
  }
}

plot_invariance <- function() {
  old_par <- par(mar = c(4, 4.5, 3, 1), las = 1)
  on.exit(par(old_par))
  plot(1:3, invariance_results$max_abs_difference, type = "p",
       pch = 19, lwd = 2, col = method_colors, xaxt = "n",
       xlab = "Method", ylab = "Maximum endpoint difference",
       main = "Invariance under eta = log(theta)")
  axis(1, at = 1:3, labels = methods)
  abline(h = 0, lty = 2)
}

save_plot <- function(stem, plot_function) {
  draw <- function(open_device) {
    open_device()
    device <- grDevices::dev.cur()
    on.exit(grDevices::dev.off(device), add = TRUE)
    plot_function()
  }

  path <- file.path(figures_dir, stem)
  draw(function() grDevices::pdf(paste0(path, ".pdf"), width = 10, height = 6.5))
  draw(function() grDevices::png(paste0(path, ".png"), width = 10, height = 6.5,
                                 units = "in", res = 300))
  invisible(NULL)
}

save_plot("example-bootstrap-distributions", plot_examples)
save_plot("simulation-coverage", function() {
  plot_simulation_metric("coverage", "Coverage probability", 1 - alpha)
})
save_plot("simulation-average-length", function() {
  plot_simulation_metric("average_length", "Average interval length")
})
save_plot("invariance-log-comparison", plot_invariance)
