# 208272 Elementary Statistics for Social Sciences II (Part 1)

Quarto book and lecture slides for the first half of 208272.

- Book (web and PDF): https://paripai.github.io/stat272_book/
- Slides: https://paripai.github.io/stat272_book/slides/ch01.html ... ch04.html, summary.html

## Layout

| Path | Contents |
|:---|:---|
| `index.qmd` | Preface: notation, the five steps, conclusion templates |
| `chapter0*.qmd` | Chapters 1-4; Chapters 2-4 include their sections |
| `sections/_*.qmd` | One file per section (one class session) |
| `summary_choosing_method.qmd` | Summary chapter (Session 12) |
| `R/setup.R` | Shared R setup: figure theme, blank curves for table practice |
| `data/` | Example data (.csv), shared by the book and the slides |
| `book.lua` | Writing space, solution boxes and quiz slides (see the comments in the file) |
| `slides/chNN.qmd`, `slides/summary.qmd` | One deck per chapter; Chapters 2-4 include their section files |

## Build

```
quarto render          # book (HTML + PDF) into _book/
quarto render slides   # slides into slides/_site/
```

Pushing to `main` renders and publishes to GitHub Pages (`.github/workflows/publish.yml`).
