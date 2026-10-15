# Shared setup for every section of the book and every slide deck.
# Each section starts with:
#   source(if (file.exists("R/setup.R")) "R/setup.R" else "../R/setup.R")
# (the book renders from the project root, the slides from slides/)

library(ggplot2)
library(knitr)

# Rounding as students do it on a calculator: halves round away from zero
# (base R would give round(68.46665, 4) = 68.4666 because of binary floating
# point). Quiz answers are compared exactly, so the book must match a calculator.
# This masks base::round for the calculations in the book only.
round <- function(x, digits = 0) {
  m <- 10^digits
  sign(x) * floor(abs(x) * m + 0.5 + 1e-9) / m
}

# Project root, so data files are found from the book and from the slides
root_dir <- if (file.exists("R/setup.R")) "." else ".."
data_path <- function(file) file.path(root_dir, "data", file)

# One theme for every figure in the book
theme_set(theme_minimal(base_size = 13))

# Numbers in the text: fixed decimals, never scientific notation
fmt <- function(x, digits = 4) formatC(round(x, digits), format = "f", digits = digits)

# ---- Critical values as printed in the course tables ----------------------
# Students use the department's printed tables (Tables 4-7, left-tail areas).
# These helpers give the value a student would read from the table, so the
# hand calculations in the book match the table exactly. They stop with an
# error when the table has no row or column for the request, which keeps
# every example answerable with the printed tables.
#   z: Table 4 bottom row (3 decimals)        t: Table 5 (3 decimals)
#   chi-square: Table 6 (3 significant digits) F: Table 7 (2 decimals; 1 above 100)

tab_t_p  <- c(.60, .70, .80, .90, .95, .975, .99, .995, .999, .9995)
tab_t_df <- c(1:30, 40, 50, 60, 80, 100, 200, 500, Inf)
tab_chisq_p  <- c(.0005, .001, .005, .01, .025, .05, .10, .20, .30, .40, .50,
                  .60, .70, .80, .90, .95, .975, .99, .995, .999, .9995)
tab_chisq_df <- 1:100
tab_F_p   <- c(.90, .95, .975, .99, .995)
tab_F_df1 <- c(1:10, 12, 15, 20, 24, 30, 40, 60, 120, Inf)
tab_F_df2 <- c(1:30, 40, 60, 120, Inf)
tab_z_p   <- c(.90, .95, .975, .99, .995, .999, .9995)

check_in <- function(x, set, what) {
  if (!any(abs(x - set) < 1e-9)) stop(what, " = ", x, " is not in the printed table")
}

crit_z <- function(p) {
  check_in(p, tab_z_p, "area for z")
  round(qnorm(p), 3)
}

crit_t <- function(p, df) {
  check_in(p, tab_t_p, "area for t"); check_in(df, tab_t_df, "df for t")
  round(qt(p, df), 3)
}

crit_chisq <- function(p, df) {
  check_in(p, tab_chisq_p, "area for chi-square")
  check_in(df, tab_chisq_df, "df for chi-square")
  signif(qchisq(p, df), 3)
}

crit_F <- function(p, df1, df2) {
  # Lower-tail values are not printed: F(p, df1, df2) = 1 / F(1 - p, df2, df1)
  if (p < 0.5) return(round(1 / crit_F(1 - p, df2, df1), 4))
  check_in(p, tab_F_p, "area for F")
  check_in(df1, tab_F_df1, "df1 for F"); check_in(df2, tab_F_df2, "df2 for F")
  x <- qf(p, df1, df2)
  round(x, if (x >= 1000) 0 else if (x >= 100) 1 else 2)
}

# Density of the distributions used in the course
dens_fun <- function(dist, df1 = NULL, df2 = NULL) {
  switch(dist,
    z     = function(x) dnorm(x),
    t     = function(x) dt(x, df1),
    chisq = function(x) dchisq(x, df1),
    F     = function(x) df(x, df1, df2)
  )
}

dens_range <- function(dist, df1 = NULL, df2 = NULL) {
  switch(dist,
    z     = c(-4, 4),
    t     = c(-4.5, 4.5),
    chisq = c(0, qchisq(0.999, df1)),
    F     = c(0, qf(0.995, df1, df2))
  )
}

# Blank curve for table-reading practice: students shade the left-tail area
# before reading the value. No labels or numbers on the x-axis.
blank_curve <- function(dist = c("z", "t", "chisq", "F"), df1 = NULL, df2 = NULL) {
  dist <- match.arg(dist)
  ggplot() +
    stat_function(fun = dens_fun(dist, df1, df2), xlim = dens_range(dist, df1, df2),
                  n = 500, linewidth = 0.8) +
    geom_hline(yintercept = 0, linewidth = 0.4) +
    theme_void()
}

# Curve with the left-tail area up to q shaded, and q marked (worked examples)
area_curve <- function(dist = c("z", "t", "chisq", "F"), q, df1 = NULL, df2 = NULL,
                       label = NULL) {
  dist <- match.arg(dist)
  f <- dens_fun(dist, df1, df2)
  rng <- dens_range(dist, df1, df2)
  ggplot() +
    stat_function(fun = f, xlim = c(rng[1], q), geom = "area",
                  fill = "steelblue", alpha = 0.4, n = 500) +
    stat_function(fun = f, xlim = rng, n = 500, linewidth = 0.8) +
    geom_hline(yintercept = 0, linewidth = 0.4) +
    annotate("text", x = q, y = 0, label = if (is.null(label)) fmt(q, 3) else label,
             vjust = 1.5, parse = !is.null(label)) +
    theme_void()
}

# Critical region(s) shaded, with the critical value(s) marked.
#   side = "two", "left" or "right"; values come from the printed tables
crit_plot <- function(dist = c("z", "t", "chisq", "F"), side = c("two", "left", "right"),
                      alpha = 0.05, df1 = NULL, df2 = NULL) {
  dist <- match.arg(dist); side <- match.arg(side)
  crit <- switch(dist,
    z     = function(p) if (p < 0.5) -crit_z(1 - p) else crit_z(p),
    t     = function(p) if (p < 0.5) -crit_t(1 - p, df1) else crit_t(p, df1),
    chisq = function(p) crit_chisq(p, df1),
    F     = function(p) crit_F(p, df1, df2)
  )
  f <- dens_fun(dist, df1, df2)
  rng <- dens_range(dist, df1, df2)
  cuts <- switch(side,
    two   = c(crit(alpha / 2), crit(1 - alpha / 2)),
    left  = crit(alpha),
    right = crit(1 - alpha)
  )
  p <- ggplot() + stat_function(fun = f, xlim = rng, n = 500, linewidth = 0.8)
  shade <- function(lo, hi) stat_function(fun = f, xlim = c(lo, hi), geom = "area",
                                          fill = "firebrick", alpha = 0.45, n = 300)
  if (side %in% c("two", "left"))  p <- p + shade(rng[1], cuts[1])
  if (side %in% c("two", "right")) p <- p + shade(cuts[length(cuts)], rng[2])
  p + geom_hline(yintercept = 0, linewidth = 0.4) +
    geom_vline(xintercept = cuts, linetype = "dashed", linewidth = 0.4) +
    annotate("text", x = cuts, y = 0, vjust = 1.5, size = 4,
             label = if (dist %in% c("z", "t")) fmt(cuts, 3) else format(cuts)) +
    coord_cartesian(clip = "off") +
    theme_void() + theme(plot.margin = margin(5, 5, 18, 5))
}

# Numbers with a thousands separator, e.g. big(52100, 0) -> "52,100"
big <- function(x, d = 2) formatC(round(x, d), format = "f", digits = d, big.mark = ",")

# Intermediate values: rounded to d decimals, trailing zeros dropped
# (num(10, 4) -> "10", num(1.714286, 4) -> "1.7143")
num <- function(x, d = 4) format(round(x, d), digits = 15, nsmall = 0, scientific = FALSE, trim = TRUE)

# R code is shown in the book (web and PDF) and the slides for chunks that set
#   #| echo: !expr show_code
# Calculation chunks stay hidden so they do not reveal the answers.
show_code <- TRUE

# The data as R code, so students see the data and the command together.
# Used as a chunk option:  #| code: !expr vec_code("earnings", riders$earnings)
vec_code <- function(name, x, per_line = 10) {
  v <- if (is.character(x)) paste0('"', x, '"') else format(x, trim = TRUE, drop0trailing = TRUE)
  rows <- split(v, ceiling(seq_along(v) / per_line))
  rows <- vapply(rows, paste, "", collapse = ", ")
  pad <- strrep(" ", nchar(name) + 7)
  paste0(c(paste0(name, " <- c(", rows[1]), if (length(rows) > 1) paste0(pad, rows[-1])),
         c(rep(",", length(rows) - 1), ")"))
}

# A treatment or block factor written as R code, e.g.
#   strategy <- factor(rep(c("Regular", "Discount", "Bundle"), each = 5),
#                      levels = c("Regular", "Discount", "Bundle"))
grp_code <- function(name, levels, each = NULL, times = NULL) {
  lv <- paste0("c(", paste0('"', levels, '"', collapse = ", "), ")")
  rep_arg <- if (!is.null(each)) paste0("each = ", each) else paste0("times = ", times)
  c(paste0(name, " <- factor(rep(", lv, ", ", rep_arg, "),"),
    paste0(strrep(" ", nchar(name) + 11), "levels = ", lv, ")"))
}

# p-value as an area: the t (or z) curve with the area beyond the observed
# statistic shaded, in the direction(s) of H1
pval_plot <- function(stat, side = c("two", "left", "right"), dist = c("t", "z"), df1 = NULL) {
  side <- match.arg(side); dist <- match.arg(dist)
  f <- dens_fun(dist, df1); rng <- dens_range(dist, df1)
  rng <- c(min(rng[1], -abs(stat) - 0.5), max(rng[2], abs(stat) + 0.5))
  shade <- function(lo, hi) stat_function(fun = f, xlim = c(lo, hi), geom = "area",
                                          fill = "darkorange", alpha = 0.55, n = 300)
  marks <- switch(side, two = c(-abs(stat), abs(stat)), left = stat, right = stat)
  p <- ggplot() + stat_function(fun = f, xlim = rng, n = 500, linewidth = 0.8)
  if (side == "right") p <- p + shade(stat, rng[2])
  if (side == "left")  p <- p + shade(rng[1], stat)
  if (side == "two")   p <- p + shade(rng[1], -abs(stat)) + shade(abs(stat), rng[2])
  p + geom_hline(yintercept = 0, linewidth = 0.4) +
    geom_vline(xintercept = marks, linetype = "dashed", linewidth = 0.4) +
    annotate("text", x = marks, y = 0, label = fmt(marks, 3), vjust = 1.5, size = 4) +
    coord_cartesian(clip = "off") + theme_void() + theme(plot.margin = margin(5, 5, 18, 5))
}
