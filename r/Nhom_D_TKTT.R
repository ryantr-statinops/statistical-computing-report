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
K <- 10000L
B <- 1999L
alpha <- 0.05
z <- qnorm(1 - alpha / 2)
tail_probs <- c(alpha / 2, 1 - alpha / 2)
methods <- c("Normal", "Basic", "Percentile")
colors <- c("#2474A5", "#D17B21", "#35865C")

# 2. Hai ví dụ Bootstrap liệt kê chính xác.
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
    Normal = c(theta_hat - z * se, theta_hat + z * se),
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

# 3. Mô phỏng bốn kịch bản độc lập.
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
      theta_hat - z * se, theta_hat + z * se,
      2 * theta_hat - q[2], 2 * theta_hat - q[1],
      q[1], q[2])
  }
  simulation_blocks[[j]] <- data.frame(
    distribution = scenario_names[j], n = scenario_n[j],
    theta = scenario_theta[j], replicate = seq_len(K),
    endpoints, check.names = FALSE)
}
simulation_raw <- do.call(rbind, simulation_blocks)
rownames(simulation_raw) <- NULL

# 4. Tính coverage và độ dài khoảng trung bình.
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

# 5. Kiểm chứng tính bất biến dưới phép biến đổi eta = log(theta).
# Dùng lại cùng các bản sao Bootstrap để tách tác động của phép biến đổi.
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
  Normal = c(theta_hat - z * se_theta, theta_hat + z * se_theta),
  Basic = c(2 * theta_hat - q_theta[2], 2 * theta_hat - q_theta[1]),
  Percentile = q_theta)
ci_eta_direct <- rbind(
  Normal = c(eta_hat - z * se_eta, eta_hat + z * se_eta),
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

# 6. Xuất bảng, thông tin lần chạy và đồ thị.
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
  paste("Seed:", 20260925),
  "RNGkind: Mersenne-Twister, Inversion, Rejection",
  "Example quantile type: 1; simulation quantile type: 7",
  "Invariance quantile type: 1",
  paste("Example sample for log invariance:",
        paste(invariance_sample, collapse = ", "))),
  file.path(logs_dir, "run-info.txt"), useBytes = TRUE)

writeLines(capture.output(sessionInfo()),
           file.path(logs_dir, "session-info.txt"), useBytes = TRUE)

plot_examples <- function() {
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
}

plot_simulation_metric <- function(metric, ylab, reference = NULL) {
  old_par <- par(mfrow = c(2, 2), mar = c(4, 4.5, 3, 1), las = 1)
  on.exit(par(old_par))
  for (j in 1:4) {
    d <- simulation_results[(3 * j - 2):(3 * j), ]
    values <- d[[metric]]
    if (identical(metric, "coverage")) {
      ylim <- c(min(.75, min(values) - .03), 1)
    } else {
      ylim <- c(0, 1.15 * max(simulation_results[[metric]]))
    }
    plot(1:3, values, type = "n", xlim = c(.7, 3.3), ylim = ylim,
         xaxt = "n", xlab = "Method", ylab = ylab,
         main = paste(scenario_names[j], "n =", scenario_n[j]))
    axis(1, at = 1:3, labels = methods)
    if (!is.null(reference)) abline(h = reference, lty = 2)
    points(1:3, values, pch = 19, cex = 1.4, col = colors)
  }
}

plot_invariance <- function() {
  old_par <- par(mar = c(4, 4.5, 3, 1), las = 1)
  on.exit(par(old_par))
  plot(1:3, invariance_results$max_abs_difference, type = "p",
       pch = 19, lwd = 2, col = colors, xaxt = "n",
       xlab = "Method", ylab = "Maximum endpoint difference",
       main = "Invariance under eta = log(theta)")
  axis(1, at = 1:3, labels = methods)
  abline(h = 0, lty = 2)
}

save_plot <- function(stem, plot_function) {
  grDevices::pdf(file.path(figures_dir, paste0(stem, ".pdf")),
                 width = 10, height = 6.5, onefile = TRUE)
  plot_function()
  grDevices::dev.off()
  grDevices::png(file.path(figures_dir, paste0(stem, ".png")),
                 width = 1800, height = 1170, res = 180)
  plot_function()
  grDevices::dev.off()
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
