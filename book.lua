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
--    HTML and slides: removed (the problem itself is shown in the text).
--
-- 2. ::: {.answer title="Your Turn 2.2.1"}
--    A worked solution that must not sit next to its problem.
--      HTML  : a collapsed callout, opened with a click
--      PDF   : moved to the next ::: {.solutions-here} marker, which is placed
--              at the end of every section
--      slides: starts a new slide, so the answer comes after the problem

--
-- 3. ::: {.quiz session="N"}
--    Placed at the end of the last section taught in a session.
--      slides: a "Quiz: Session N" slide with space for the entry code
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

local step_names = {
  "Step 1: Hypotheses",
  "Step 2: Level of significance",
  "Step 3: Test statistic",
  "Step 4: Critical value and critical region",
  "Step 5: Decision and interpretation",
}

-- prompts inside each framed box (steps = "full")
local step_prompts = {
  { "$H_0$:", "$H_1$:" },
  { "$\\alpha$ =" },
  { "Formula:", "Substitution:", "Result:" },
  { "Critical value(s):", "Critical region:" },
  { "Decision:", "", "Interpretation:", "" },
}

local function workspace(div)
  local steps = div.attributes["steps"] or "none"
  local n = tonumber(div.attributes["lines"] or "")
  local tex = { "\\par\\medskip" }

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
    local blocks = pandoc.List({
      pandoc.Header(2, pandoc.Str("Solution: " .. title), pandoc.Attr("", { "deck" }))
    })
    blocks:extend(div.content)
    return blocks
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
        return {}
      elseif div.classes:includes("answer") then
        return solution(div)
      elseif div.classes:includes("quiz") then
        if not fmt_slides then return {} end
        local n = div.attributes["session"] or ""
        return {
          pandoc.Header(2, pandoc.Str("Quiz: Session " .. n), pandoc.Attr("", { "deck" })),
          pandoc.Para({ pandoc.Str("Quiz code: ______") }),
        }
      elseif div.classes:includes("solutions-here") then
        return solutions_here(div)
      end
    end,
  },
}
