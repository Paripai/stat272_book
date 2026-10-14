# Shared setup for every section of the book and every slide deck.
# Each section starts with:
#   source(if (file.exists("R/setup.R")) "R/setup.R" else "../R/setup.R")
# (the book renders from the project root, the slides from slides/)

library(ggplot2)
library(knitr)

# Project root, so data files are found from the book and from the slides
root_dir <- if (file.exists("R/setup.R")) "." else ".."
data_path <- function(file) file.path(root_dir, "data", file)

# One theme for every figure in the book
theme_set(theme_minimal(base_size = 13))

# Numbers in the text: fixed decimals, never scientific notation
fmt <- function(x, digits = 4) formatC(x, format = "f", digits = digits)

# ---- Critical values as printed in the course tables ----------------------
# Students use the department's printed tables (Tables 3-6, left-tail areas).
# These helpers give the value a student would read from the table, so the
# hand calculations in the book match the table exactly. They stop with an
# error when the table has no row or column for the request, which keeps
# every example answerable with the printed tables.
#   z: Table 3 bottom row (3 decimals)        t: Table 4 (3 decimals)
#   chi-square: Table 5 (3 significant digits) F: Table 6 (2 decimals; 1 above 100)

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
