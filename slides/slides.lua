-- Filters that adapt the book chapters and sections for revealjs without
-- editing them.

-- 1. The chapters use '---' as visual separators. In revealjs a
--    horizontal rule starts a new slide, which leaves empty slides.
local function drop_rules(blocks)
  return blocks:filter(function(b) return b.t ~= "HorizontalRule" end)
end

-- 2. A level-1 heading becomes a centred section-title slide, and those
--    do not scroll, so long content under it is cut off (e.g. Key
--    Takeaways, Exercises). If a level-1 heading has content directly
--    under it, make it a normal level-2 slide, which scrolls.
local function demote_level1_with_content(blocks)
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      local nxt = blocks[i + 1]
      if nxt and nxt.t ~= "Header" then
        b.level = 2
      end
    end
  end
  return blocks
end

-- 3. Each slide file has a title slide (title, subtitle, author), so the
--    chapter's own first level-1 heading would repeat it. Drop that heading.
--    Section decks have no chapter heading, so nothing is dropped there.
local function drop_chapter_title(blocks, meta)
  if meta.title == nil or meta["section-deck"] then return blocks end
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      blocks:remove(i)
      break
    end
  end
  return blocks
end

-- 0. Chapters 2-4 have sections (##) with subsections (###). Their decks
--    include the section files directly (Quarto resolves nested includes
--    from the deck, not from the chapter file) and set section-deck: true,
--    which moves every heading up one level: each section becomes a level-1
--    divider slide and each subsection a slide.
--    Headings with the class "deck" were written for the slides (Solution,
--    Quiz, Course Rules) and stay at level 2.
local function shift_section_headings(blocks, meta)
  if not meta["section-deck"] then return blocks end
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.classes:includes("deck") then
        b.level = 2
      elseif b.level > 1 then
        b.level = b.level - 1
      end
    end
  end
  return blocks
end

function Pandoc(doc)
  local blocks = shift_section_headings(doc.blocks, doc.meta)
  blocks = drop_chapter_title(drop_rules(blocks), doc.meta)
  doc.blocks = demote_level1_with_content(blocks)
  return doc
end
