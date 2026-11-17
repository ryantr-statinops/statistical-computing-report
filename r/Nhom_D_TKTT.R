out <- file.path("output", "figures")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
methods <- c("Normal", "Basic", "Percentile")

# Dùng cùng ba màu cho các hình, rồi đặt seed riêng cho mô phỏng.
set.seed(NULL)
cols <- sample(grDevices::hcl.colors(8, "Dark 3"), length(methods))

save_pdf <- function(name, draw, width = 9, height = 6) {
  pdf(file.path(out, paste0(name, ".pdf")), width = width, height = height)
  on.exit(dev.off())
  draw()
}

# Khoảng tin cậy 95%. Percentile là phần mở rộng của Buổi 18.
boot_ci <- function(theta, means, type = 7) {
  q <- unname(quantile(means, c(0.025, 0.975), type = type))
  margin <- qnorm(0.975) * sd(means)
  rbind(Normal = theta + c(-margin, margin),
        Basic = 2 * theta - rev(q),
        Percentile = q)
}

# 1. Hai ví dụ nhỏ. Liệt kê toàn bộ mẫu bootstrap có hoàn lại.
examples <- list("Symmetric sample" = c(1, 2, 3),
                 "Right-skewed sample" = c(1, 1, 1, 9))
example_means <- lapply(examples, function(x) {
  rowMeans(expand.grid(rep(list(x), length(x)), KEEP.OUT.ATTRS = FALSE))
})

for (i in seq_along(examples)) {
  means <- example_means[[i]]
  ci <- boot_ci(mean(examples[[i]]), means, type = 1)
  cat("\n", names(examples)[i], " - 95% CI\n", sep = "")
  print(round(ci[c("Normal", "Basic"), ], 3))
}

save_pdf("example-bootstrap-distributions", function() {
  par(mfrow = c(1, 2), las = 1)
  for (i in seq_along(examples)) {
    means <- example_means[[i]]
    values <- sort(unique(means))
    count <- tabulate(match(means, values))
    prob <- count / length(means)
    plot(values, prob, type = "h", lwd = 8, col = cols[i],
         ylim = c(0, max(prob) * 1.25), main = names(examples)[i],
         xlab = "Bootstrap mean", ylab = "Probability")
    abline(v = mean(examples[[i]]), lty = 2)
    text(values, prob + 0.035, paste0(count, "/", length(means)), cex = 0.8)
  }
}, width = 10, height = 5)

# 2. Mô phỏng coverage và độ dài trung bình.
set.seed(20260925)
K <- 2000  # Số lần sinh dữ liệu cho mỗi kịch bản
B <- 999   # Số mẫu bootstrap trong mỗi lần

simulate <- function(draw, n, theta) {
  covered <- lengths <- matrix(0, nrow = K, ncol = length(methods))
  for (i in seq_len(K)) {
    x <- draw(n)
    samples <- matrix(sample(x, n * B, replace = TRUE), nrow = n)
    ci <- boot_ci(mean(x), colMeans(samples))
    covered[i, ] <- ci[, 1] <= theta & theta <= ci[, 2]
    lengths[i, ] <- ci[, 2] - ci[, 1]
  }
  data.frame(Method = methods, Coverage = colMeans(covered),
             Average_length = colMeans(lengths))
}

results <- list(
  "Normal n = 12" = simulate(rnorm, n = 12, theta = 0),
  "Normal n = 40" = simulate(rnorm, n = 40, theta = 0),
  "Exponential n = 12" = simulate(rexp, n = 12, theta = 1),
  "Exponential n = 40" = simulate(rexp, n = 40, theta = 1)
)

for (name in names(results)) {
  cat("\n", name, "\n", sep = "")
  print(results[[name]], row.names = FALSE, digits = 4)
}

# 3. Vẽ hai chỉ tiêu trên cùng bố cục.
plot_results <- function(metric, ylab, ylim, reference = NULL) {
  par(mfrow = c(2, 2), mar = c(4, 4.5, 3, 1), las = 1)
  for (name in names(results)) {
    plot(seq_along(methods), results[[name]][[metric]], pch = 19, cex = 1.4,
         col = cols, ylim = ylim, xaxt = "n", xlab = "Method", ylab = ylab,
         main = name)
    axis(1, at = seq_along(methods), labels = methods)
    if (!is.null(reference)) abline(h = reference, lty = 2)
  }
}

sim <- do.call(rbind, results)
save_pdf("simulation-coverage", function() {
  plot_results("Coverage", "Coverage probability",
               c(min(0.75, min(sim$Coverage) - 0.03), 1), reference = 0.95)
})
save_pdf("simulation-average-length", function() {
  plot_results("Average_length", "Average interval length",
               c(0, max(sim$Average_length) * 1.15))
})
