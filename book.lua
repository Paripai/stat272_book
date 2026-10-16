-- Filters shared by the book and the slides.
--
-- 1. ::: {.workspace steps="full|names|none" lines="N"}
--    Writing space for "Your Turn" problems. Students write on the PDF with
--    a pen on the iPad, so the space is real only in the PDF.
--      steps="full"  : a framed box for each of the 5 steps, with prompts
--                      (Sessions 2-3)
--      steps="names" : the 5 step names, each followed by ruled lines
--                      (Sessions 4-6)
--      steps="none"  : ruled lines only (default; Sessions 7-12)
--      lines="N"     : ruled lines per step (or in total for steps="none")
--      method="pvalue": Step 4 is the p-value instead of the critical value
--                      (fades the same way: full in Session 7, names in
--                      Sessions 8-9, none afterwards)
--      table="anova" rows="Region,Error,Total": an empty ANOVA table to
--                      fill in, placed before the steps or lines
--    slides: a "Your Turn: Work Space" slide with the same steps (and table),
--            short enough not to scroll, so the teacher can write on it with
--            the chalkboard pen together with the students. Spaces that are
--            only ruled lines are left out of the slides.
--    HTML  : removed (the problem itself is shown in the text).
--
-- 2. ::: {.answer title="Your Turn 2.2.1"}
--    A worked solution that must not sit next to its problem.
--      HTML  : a collapsed callout, opened with a click
--      PDF   : moved to the next ::: {.solutions-here} marker, which is placed
--              at the end of every section
--      slides: left out (the teacher works Your Turn with the class on the
--              work-space slide; students have the solutions in the book)

--
-- 3. ::: {.quiz session="N"}
--    Placed at the end of the last section taught in a session.
--      slides: a "Quiz MN" slide (M1–M11) (title only)
--      book  : removed

local fmt_pdf = quarto.doc.is_format("pdf")
local fmt_slides = quarto.doc.is_format("revealjs")

local pending = {}

local function latex(s) return pandoc.RawBlock("latex", s) end

local function ruled_lines(n)
  local out = {}
  for _ = 1, n do
    out[#out + 1] = "\\par\\vspace{0.8cm}\\noindent{\\color{black!30}\\rule{\\linewidth}{0.4pt}}"
  end
  return table.concat(out, "\n")
end

local function labelled_line(label)
  return "\\par\\vspace{0.6cm}\\noindent " .. label ..
         "~{\\color{black!30}\\hrulefill}"
end

local function step_names_for(method)
  return {
    "Step 1: Hypotheses",
    "Step 2: Level of significance",
    "Step 3: Test statistic",
    method == "pvalue" and "Step 4: p-value" or "Step 4: Critical value and critical region",
    "Step 5: Decision and interpretation",
  }
end

-- prompts inside each framed box (steps = "full")
local function step_prompts_for(method)
  if method == "pvalue" then
    return {
      { "$H_0$:", "$H_1$:" },
      { "$\\alpha$ =" },
      { "Test statistic:", "df:" },
      { "p-value:" },
      { "Decision:", "", "Interpretation:", "" },
    }
  end
  return {
    { "$H_0$:", "$H_1$:" },
    { "$\\alpha$ =" },
    { "Formula:", "Substitution:", "Result:" },
    { "Critical value(s):", "Critical region:" },
    { "Decision:", "", "Interpretation:", "" },
  }
end

local function split_rows(div)
  local rows = {}
  for r in (div.attributes["rows"] or "Treatments,Error,Total"):gmatch("[^,]+") do
    rows[#rows + 1] = r
  end
  return rows
end

local function anova_table_tex(div)
  local t = { "\\par\\medskip\\begin{center}{\\renewcommand{\\arraystretch}{2.2}",
              "\\begin{tabular}{|p{3cm}|p{1.6cm}|p{2.8cm}|p{2.8cm}|p{2.4cm}|}\\hline",
              "\\textbf{Source} & \\textbf{df} & \\textbf{SS} & \\textbf{MS} & \\textbf{$F$} \\\\ \\hline" }
  for _, r in ipairs(split_rows(div)) do
    t[#t + 1] = r .. " & & & & \\\\ \\hline"
  end
  t[#t + 1] = "\\end{tabular}}\\end{center}"
  return table.concat(t, "\n")
end

local function anova_table_html(div)
  local t = { '<table class="ws-table"><tr><th>Source</th><th>df</th><th>SS</th><th>MS</th><th>F</th></tr>' }
  for _, r in ipairs(split_rows(div)) do
    t[#t + 1] = "<tr><td>" .. r .. "</td><td></td><td></td><td></td><td></td></tr>"
  end
  t[#t + 1] = "</table>"
  return table.concat(t, "\n")
end

local function workspace(div)
  local steps = div.attributes["steps"] or "none"
  local n = tonumber(div.attributes["lines"] or "")
  local method = div.attributes["method"]
  local step_names, step_prompts = step_names_for(method), step_prompts_for(method)
  local tex = { "\\par\\medskip" }
  if div.attributes["table"] == "anova" then tex[#tex + 1] = anova_table_tex(div) end

  if steps == "full" then
    for i, name in ipairs(step_names) do
      tex[#tex + 1] = "\\begin{tcolorbox}[colback=white,colframe=black!40," ..
                      "arc=1mm,boxrule=0.5pt,title={\\textbf{" .. name .. "}}," ..
                      "coltitle=black,colbacktitle=black!8]"
      for _, p in ipairs(step_prompts[i]) do
        tex[#tex + 1] = labelled_line(p)
      end
      tex[#tex + 1] = "\\par\\vspace{0.3cm}\\end{tcolorbox}"
    end
  elseif steps == "names" then
    for _, name in ipairs(step_names) do
      tex[#tex + 1] = "\\par\\bigskip\\noindent\\textbf{" .. name .. "}"
      tex[#tex + 1] = ruled_lines(n or 3)
    end
  else
    tex[#tex + 1] = ruled_lines(n or 18)
  end

  tex[#tex + 1] = "\\par\\bigskip"
  return latex(table.concat(tex, "\n"))
end

-- Slide version of the writing space (HTML, styled in slides/custom.scss)
local function html_prompts_for(method)
  if method == "pvalue" then
    return {
      { "H<sub>0</sub>:", "H<sub>1</sub>:" }, { "&alpha; =" },
      { "Test statistic:", "df:" }, { "p-value:" }, { "Decision:", "Interpretation:" },
    }
  end
  return {
    { "H<sub>0</sub>:", "H<sub>1</sub>:" }, { "&alpha; =" },
    { "Formula:", "Substitution:", "Result:" },
    { "Critical value(s):", "Critical region:" }, { "Decision:", "Interpretation:" },
  }
end

local function workspace_slide(div)
  local steps = div.attributes["steps"] or "none"
  local has_table = div.attributes["table"] == "anova"
  -- spaces that are only ruled lines are not shown on the slides
  if steps == "none" and not has_table then return {} end
  local method = div.attributes["method"]
  local step_names, html_prompts = step_names_for(method), html_prompts_for(method)
  local h = { '<div class="ws">' }
  if has_table then h[#h + 1] = anova_table_html(div) end
  local function line(label)
    h[#h + 1] = '<div class="ws-line">' .. (label or "") .. '</div>'
  end
  if steps == "full" then
    for i, name in ipairs(step_names) do
      h[#h + 1] = '<div class="ws-step">' .. name .. '</div>'
      for _, p in ipairs(html_prompts[i]) do line(p) end
    end
  elseif steps == "names" then
    for _, name in ipairs(step_names) do
      h[#h + 1] = '<div class="ws-step">' .. name .. '</div>'
      line(); line()
    end
  end
  h[#h + 1] = '</div>'
  return {
    pandoc.Header(2, pandoc.Str("Your Turn: Work Space"), pandoc.Attr("", { "deck" })),
    pandoc.RawBlock("html", table.concat(h, "\n")),
  }
end

local function solution(div)
  local title = div.attributes["title"] or "Solution"
  if fmt_pdf then
    local blocks = pandoc.List({
      pandoc.Para({ pandoc.Strong(pandoc.Str("Solution: " .. title)) })
    })
    blocks:extend(div.content)
    pending[#pending + 1] = blocks
    return {}
  elseif fmt_slides then
    -- no solutions on the slides: the teacher works the problems with the
    -- class, and students have the solutions in the book
    return {}
  else
    return quarto.Callout({
      type = "tip",
      title = "Solution: " .. title,
      collapse = true,
      content = div.content,
    })
  end
end

local function solutions_here(div)
  if not fmt_pdf or #pending == 0 then return {} end
  local level = tonumber(div.attributes["level"] or "3")
  local out = pandoc.List({
    pandoc.Header(level, pandoc.Str("Solutions"), pandoc.Attr("", { "unnumbered" }))
  })
  for _, blocks in ipairs(pending) do
    out:extend(blocks)
  end
  pending = {}
  return out
end

return {
  {
    -- default traversal: nested divs are handled first, in document order
    Div = function(div)
      if div.classes:includes("workspace") then
        if fmt_pdf then return workspace(div) end
        if fmt_slides then return workspace_slide(div) end
        return {}
      elseif div.classes:includes("answer") then
        return solution(div)
      elseif div.classes:includes("quiz") then
        if not fmt_slides then return {} end
        local n = div.attributes["session"] or ""
        return {
          pandoc.Header(2, pandoc.Str("Quiz M" .. n), pandoc.Attr("", { "deck" })),
        }
      elseif div.classes:includes("solutions-here") then
        return solutions_here(div)
      end
    end,
  },
}
