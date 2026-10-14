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
