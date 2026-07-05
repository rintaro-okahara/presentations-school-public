# Class Online Learning Slides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a concise English Typst+Metropolis slide deck for the class-online-learning presentation on Steinhardt and Liang's adaptive optimistic exponentiated gradient paper.

**Architecture:** Replace the empty `class-online-learning-20260707/version/v1/main.typ` with a self-contained Touying deck patterned after `reading-seminar-2026-0616/main-v2.typ`. The deck follows the course guideline order: problem/context, setup, main result, key idea, and significance, with matrix-valued losses limited to one final main slide.

**Tech Stack:** Typst 0.14.2, Touying 0.7.4, Metropolis theme, Numbly heading numbering, Python `pypdf` for PDF page-count verification, Ghostscript for representative PNG rendering.

---

### Task 1: Reconfirm Source Material And Slide Targets

**Files:**
- Read: `docs/superpowers/specs/2026-07-05-class-online-learning-slides-design.md`
- Read: `class-online-learning-20260707/tmp/presentation_guidelines.pdf`
- Read: `class-online-learning-20260707/origin/Adaptivity and Optimism_ An Improved Exponentiated Gradient Algorithm.pdf`
- Read: `reading-seminar-2026-0616/main-v2.typ`

- [ ] **Step 1: Check the design spec**

Run:

```bash
sed -n '1,220p' docs/superpowers/specs/2026-07-05-class-online-learning-slides-design.md
```

Expected: The spec says the main message is adaptive regularization plus optimism yielding AEG-Path, and matrix-valued losses should be one final summary slide.

- [ ] **Step 2: Extract the guideline structure**

Run:

```bash
python3 - <<'PY'
from pypdf import PdfReader
path = 'class-online-learning-20260707/tmp/presentation_guidelines.pdf'
reader = PdfReader(path)
for i, page in enumerate(reader.pages, 1):
    text = page.extract_text() or ''
    print(f'\n--- PAGE {i} ---')
    print(text[:2500])
PY
```

Expected: The output includes the 15-minute structure: problem/context, setup, main result, key idea, and significance.

- [ ] **Step 3: Extract the paper sections used for the talk**

Run:

```bash
python3 - <<'PY'
from pypdf import PdfReader
path = 'class-online-learning-20260707/origin/Adaptivity and Optimism_ An Improved Exponentiated Gradient Algorithm.pdf'
reader = PdfReader(path)
for i, page in enumerate(reader.pages[:8], 1):
    text = page.extract_text() or ''
    print(f'\n--- PAGE {i} ---')
    print(text[:3500])
PY
```

Expected: The output includes the abstract, two multiplicative updates, Algorithm 1 and 2, Proposition 3.3, the path-length bound, the comparison grid, and the matrix extension summary.

- [ ] **Step 4: Confirm the style source**

Run:

```bash
sed -n '1,120p' reading-seminar-2026-0616/main-v2.typ
```

Expected: The output shows imports for Touying, Metropolis, Numbly, local colors, theorem-style block helpers, theme setup, title slide, and outline.

### Task 2: Create The Typst Deck

**Files:**
- Modify: `class-online-learning-20260707/version/v1/main.typ`

- [ ] **Step 1: Replace the empty Typst file with a Metropolis deck**

Modify `class-online-learning-20260707/version/v1/main.typ` so it starts with this structure:

```typst
#import "@preview/touying:0.7.4": *
#import themes.metropolis: *
#import "@preview/numbly:0.1.0": numbly

#let m-dark-teal = rgb("#23373b")
#let m-light-brown = rgb("#eb811b")
#let m-lighter-brown = rgb("#d6c6b7")

#let _admonition(kind, accent, name, body) = block(
  width: 100%,
  inset: (left: 0.9em, rest: 0.7em),
  radius: 2pt,
  fill: accent.lighten(90%),
  stroke: (left: 2.5pt + accent),
  {
    text(weight: "bold", fill: accent, kind)
    if name != none [ #text(weight: "bold", fill: accent)[ (#name)] ]
    parbreak()
    body
  },
)

#let theorem(..args) = {
  let pos = args.pos()
  let body = pos.last()
  let name = if pos.len() > 1 { pos.first() } else { args.named().at("name", default: none) }
  _admonition("Theorem", m-light-brown, name, body)
}

#let definition(..args) = {
  let pos = args.pos()
  let body = pos.last()
  let name = if pos.len() > 1 { pos.first() } else { args.named().at("name", default: none) }
  _admonition("Definition", m-dark-teal, name, body)
}

#let compact(body) = {
  set text(size: 0.78em)
  body
}

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: [],
  config-info(
    title: [Adaptivity and Optimism],
    subtitle: [An Improved Exponentiated Gradient Algorithm],
    author: [Rintaro Okahara],
    date: datetime(year: 2026, month: 7, day: 7),
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))
#show strong: it => text(fill: m-dark-teal, weight: "bold", it.body)

#title-slide()

= Outline <touying:hidden>

#outline(title: none, indent: 1em, depth: 1)
```

Expected: The file imports the same presentation stack as the reading-seminar deck and sets the correct title, subtitle, author, and presentation date.

- [ ] **Step 2: Add the Problem And Setup section**

Add these slides after the outline:

```typst
= Problem and Setup

== What Should EG Adapt To?

#compact[
  Standard exponentiated gradient is robust, but its regret bound can be driven
  by experts that are irrelevant in hindsight.

  #v(0.5em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.1em,
    [
      *Classical view*
      $
        "Regret" <= (log n) / eta
          + eta sum_(t=1)^T norm(z_t)_oo^2
      $
    ],
    [
      *Desired view*
      $
        "Regret" <= (log n) / eta
          + eta dot "complexity of " i^star
      $
    ],
  )

  #v(0.4em)

  Main question: can EG exploit that the *best expert* is easy, even when other
  experts fluctuate?
]

== Expert Advice Setting

#compact[
  #definition("Protocol")[
    On each round $t=1,dots.c,T$:
    $w_t in Delta_n$ is played, $z_t in [-1, 1]^n$ is revealed, and the learner
    pays $w_t^top z_t$.
  ]

  #v(0.45em)

  Comparator regret:
  $
    "Regret"(u)
      := sum_(t=1)^T w_t^top z_t - sum_(t=1)^T u^top z_t,
      quad u in Delta_n.
  $

  For the best expert, take $u=e_(i^star)$.
]

== Three Notions of "Easy"

#compact[
  For expert $i$, the paper compares:

  #v(0.35em)

  #grid(
    columns: (0.9fr, 1.1fr, 1.25fr),
    column-gutter: 0.8em,
    align: (left + top, left + top, left + top),
    [*Second moment*], [$S_i := sum_t z_(t,i)^2$], [small if the best expert has small losses],
    [*Variance*], [$V_i := sum_t (z_(t,i) - overline(z)_i)^2$], [small if losses are almost constant],
    [*Path length*], [$D_i := sum_t (z_(t,i) - z_(t-1,i))^2$], [small if losses are predictable from the last round],
  )

  #v(0.45em)

  Target: a regret bound depending on $D_(i^star)$, not $D_oo$ or $S_oo$.
]
```

Expected: The section covers the guideline's problem/context and setup blocks with short prose and explicit notation.

- [ ] **Step 3: Add the Motivation section**

Add these slides:

```typst
= Motivation: Two Useful Tricks

== Two Multiplicative Updates

#compact[
  Two updates look similar but have different guarantees:

  #v(0.35em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *EG / MW1*
      $
        w_(t+1,i) prop w_(t,i) exp(-eta z_(t,i))
      $
      Bound sees a learner-weighted or worst-coordinate scale.
    ],
    [
      *MW2*
      $
        w_(t+1,i) prop w_(t,i) (1 - eta z_(t,i))
      $
      Bound can see the best expert's second moment.
    ],
  )

  #v(0.45em)

  The puzzle: MW2 has a better type of bound, but it is not fixed-regularizer
  mirror descent.
]

== Trick 1: Adaptive Regularization

#compact[
  Write MW2 in log-weights:
  $
    beta_(t+1,i)
      = beta_(t,i) + log(1 - eta z_(t,i)).
  $

  #v(0.35em)

  Since
  $
    log(1 - x) approx -x - x^2,
  $
  MW2 behaves like EG plus a *second-order correction*:
  $
    beta_(t+1,i)
      = beta_(t,i) - eta z_(t,i) - eta^2 z_(t,i)^2.
  $

  #v(0.35em)

  Intuition: put more regularization on coordinates that have accumulated large
  correction terms.
]

== Trick 2: Optimism

#compact[
  Suppose before seeing $z_t$, we have a hint $m_t$.

  #v(0.35em)

  Optimistic mirror descent predicts from the preemptive update:
  $
    w_t = nabla psi^*(theta_t - eta m_t).
  $

  #v(0.35em)

  Regret depends on the hint error:
  $
    z_t - m_t.
  $

  #v(0.35em)

  If $m_t = z_(t-1)$, then the error is exactly the path movement
  $z_t - z_(t-1)$.
]
```

Expected: The section makes the synthesis motivation explicit before stating the algorithm.

- [ ] **Step 4: Add the Algorithm And Result section**

Add these slides:

```typst
= Main Result

== Adaptive + Optimistic EG

#compact[
  Combine the two tricks:

  #v(0.25em)

  #block(width: 100%, breakable: false, {
    set text(size: 0.82em)
    line(length: 100%, stroke: 1pt)
    v(0.12em)
    text(weight: "bold", fill: m-light-brown)[AEG with hints]
    v(0.12em)
    line(length: 100%, stroke: 0.5pt)
    v(0.3em)
    grid(
      columns: (1.4em, 1fr),
      column-gutter: 0.45em,
      row-gutter: 0.38em,
      align: (right + top, left + top),
      [1:], [Initialize $beta_(1,i) = 0$.],
      [2:], [Predict $w_(t,i) prop exp(beta_(t,i) - eta m_(t,i))$.],
      [3:], [Observe $z_t$ and suffer $w_t^top z_t$.],
      [4:], [Update
        $beta_(t+1,i) = beta_(t,i) - eta z_(t,i)
          - eta^2 (z_(t,i) - m_(t,i))^2$.],
    )
    v(0.12em)
    line(length: 100%, stroke: 1pt)
  })

  #v(0.35em)

  The correction penalizes experts whose hints were inaccurate.
]

== Generic Bound With Hints

#compact[
  #theorem("Adaptive Exponentiated Gradient")[
    If $norm(z_t)_oo <= 1$, $norm(m_t)_oo <= 1$, and $0 < eta <= 1/4$, then
    for every $u in Delta_n$,
    $
      "Regret"(u)
        <= (log n) / eta
          + eta sum_(i=1)^n u_i sum_(t=1)^T
              (z_(t,i) - m_(t,i))^2.
    $
  ]

  #v(0.4em)

  The comparator $u$ chooses which coordinates matter in the second term.
]

== AEG-Path

#compact[
  Choose the last loss vector as the hint:
  $
    m_t = z_(t-1).
  $

  #v(0.35em)

  For $u=e_(i^star)$:
  $
    "Regret"(i^star)
      <= (log n) / eta + eta D_(i^star),
      quad
      D_i := sum_(t=1)^T (z_(t,i) - z_(t-1,i))^2.
  $

  #v(0.35em)

  This is the path-length bound Kale asked for: dependence on the *best
  expert's* path length.
]

== What Improves?

#compact[
  #grid(
    columns: (1.2fr, 1.1fr, 1.1fr),
    column-gutter: 0.7em,
    row-gutter: 0.45em,
    align: (left + top, left + top, left + top),
    [*Algorithm*], [*Scale in bound*], [*What it misses*],
    [EG / Hedge], [$S_oo$], [best expert may be easy],
    [Cesa-Bianchi et al.], [$S_(i^star)$], [no variance/path adaptivity],
    [Hazan--Kale], [$max_i V_i$], [depends on all experts],
    [Chiang et al.], [$D_oo$], [depends on worst movement],
    [*AEG-Path*], [$D_(i^star)$], [best expert only],
  )

  #v(0.35em)

  The improvement is not just a constant: the quantities can differ by
  $Theta(T)$.
]
```

Expected: The section states the main theorem precisely enough for the audience and makes the before/after comparison clear.

- [ ] **Step 5: Add the Key Idea And Significance sections**

Add these slides:

```typst
= Key Idea

== Proof Sketch: Push Regret Into the Regularizer

#compact[
  The framework asks the next regularizer to absorb the one-step regret:

  $
    psi^*_(t+1)(theta_t - eta z_t)
      <=
    psi^*_t(theta_t - eta m_t)
      - eta w_t^top (z_t - m_t).
  $

  #v(0.4em)

  If this holds, the regret telescopes to
  $
    "Regret"(u) <= (psi^*_1(theta_1) + psi_(T+1)(u)) / eta.
  $

  #v(0.35em)

  The correction term is chosen exactly to make this inequality true.
]

== Why the Correction Has This Shape

#compact[
  With entropy regularization,
  $
    psi^*(beta) = log(sum_i exp(beta_i)).
  $

  #v(0.35em)

  Put $a_(t,i) = (z_(t,i) - m_(t,i))^2$.
  The key scalar inequality is
  $
    exp(-x - x^2) <= 1 - x
    quad (abs(x) <= 1/2).
  $

  #v(0.35em)

  This makes
  $
    psi^*(beta_t - eta z_t - eta^2 a_t)
      <= psi^*(beta_t - eta m_t)
        - eta w_t^top (z_t - m_t).
  $
]

== Why Path Length Beats Variance Here

#compact[
  The same generic theorem gives different bounds by changing the hint:

  #v(0.35em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 0.8em,
    align: (left + top, left + top, left + top),
    [*Hint*], [*Error term*], [*Bound scale*],
    [$m_t = 0$], [$z_t$], [$S_(i^star)$],
    [$m_t = 1/t sum_(s<t) z_s$], [$z_t - m_t$], [$V_(i^star)$],
    [$m_t = z_(t-1)$], [$z_t - z_(t-1)$], [$D_(i^star)$],
  )

  #v(0.35em)

  The algorithmic template is one theorem; the hint chooses the notion of
  predictability.
]

= Significance

== What the Paper Contributes

#compact[
  - Gives a mirror-descent interpretation of MW2 through adaptive regularizers.
  - Combines adaptive regularization with optimistic learning.
  - Resolves Kale's open problem: a path-length bound for the best expert.
  - Extends the same idea to matrix exponentiated gradient.

  #v(0.45em)

  Limitation: tuning $eta$ adaptively weakens the clean $D_(i^star)$ statement.
]

== Matrix-Valued Losses: One-Slide Extension

#compact[
  Replace distributions by density matrices:
  $
    W_t succeq 0, quad "tr"(W_t) = 1,
    quad "loss" = "tr"(W_t Z_t).
  $

  #v(0.3em)

  The update becomes
  $
    B_(t+1) = B_t - eta Z_t - eta^2 (Z_t - M_t)^2,
    quad
    W_t = exp(B_t - eta M_t) / "tr"(exp(B_t - eta M_t)).
  $

  #v(0.3em)

  With $M_t = Z_(t-1)$:
  $
    "Regret"(U)
      <= (log n) / eta
        + eta sum_t "tr"(U (Z_t - Z_(t-1))^2).
  $

  New proof ingredient: Golden--Thompson plus an FTRL variant for cone-ordered,
  vector-valued losses.
]

== Reference

#compact[
  Jacob Steinhardt and Percy Liang.
  *Adaptivity and Optimism: An Improved Exponentiated Gradient Algorithm.*
  Proceedings of the 31st International Conference on Machine Learning,
  PMLR 32(1), 2014.

  #v(0.45em)

  Main takeaway:

  #align(center)[
    #text(size: 1.2em, weight: "bold", fill: m-light-brown)[
      adaptive correction + optimistic hint = best-expert path-length regret
    ]
  ]
]
```

Expected: The proof is a sketch, the talk closes with significance, and the matrix extension is exactly one main slide.

- [ ] **Step 6: Add backup slides**

Add these backup slides at the bottom:

```typst
= Backup <touying:hidden>

== Backup: Adaptive Regularizer Form

#compact[
  The regularizer used to realize MW2:
  $
    psi_t(u)
      = sum_i u_i log u_i + u^top (theta_t - beta_t),
    quad
    beta_(t,i) = sum_(s<t) log(1 - eta z_(s,i)).
  $

  Then
  $
    nabla psi_t^*(theta_t) = arg min_(w in Delta_n)
      sum_i w_i log w_i - w^top beta_t,
  $
  so $w_(t,i) prop exp(beta_(t,i))$.
]

== Backup: Optimizing the Path Bound

#compact[
  From
  $
    "Regret"(i^star) <= (log n) / eta + eta D_(i^star),
  $
  the best fixed step size is
  $
    eta = sqrt((log n) / D_(i^star)).
  $

  When this satisfies $eta <= 1/4$,
  $
    "Regret"(i^star) <= 2 sqrt(D_(i^star) log n).
  $

  If $D_(i^star)$ is unknown, adaptive tuning is possible but the paper's clean
  bound becomes weaker.
]
```

Expected: Backup material supports likely questions without expanding the main talk.

### Task 3: Compile And Fix Typst Errors

**Files:**
- Modify if needed: `class-online-learning-20260707/version/v1/main.typ`
- Create: `class-online-learning-20260707/version/v1/main.pdf`

- [ ] **Step 1: Run the Typst compiler**

Run:

```bash
typst compile class-online-learning-20260707/version/v1/main.typ class-online-learning-20260707/version/v1/main.pdf
```

Expected: Exit code 0 and `class-online-learning-20260707/version/v1/main.pdf` is created.

- [ ] **Step 2: If Typst reports syntax errors, fix the exact reported lines**

Use the compiler line numbers. Expected common fixes:

```typst
// If a text quote is parsed awkwardly in math, use upright text:
$ "Regret"(u) <= (log n) / eta + eta D_(i^star) $

// If a hidden section creates outline noise, keep the section hidden:
= Backup <touying:hidden>
```

Expected: Re-running the compile command exits 0.

### Task 4: Verify Rendered Output

**Files:**
- Read: `class-online-learning-20260707/version/v1/main.pdf`
- Create: `class-online-learning-20260707/version/v1/render-check/page-01.png`
- Create: `class-online-learning-20260707/version/v1/render-check/page-08.png`
- Create: `class-online-learning-20260707/version/v1/render-check/page-15.png`

- [ ] **Step 1: Check PDF page count**

Run:

```bash
python3 - <<'PY'
from pypdf import PdfReader
path = 'class-online-learning-20260707/version/v1/main.pdf'
reader = PdfReader(path)
print(len(reader.pages))
PY
```

Expected: A page count between 18 and 24 inclusive.

- [ ] **Step 2: Render representative pages**

Run:

```bash
mkdir -p class-online-learning-20260707/version/v1/render-check
gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -r144 \
  -dFirstPage=1 -dLastPage=1 \
  -sOutputFile=class-online-learning-20260707/version/v1/render-check/page-01.png \
  class-online-learning-20260707/version/v1/main.pdf
gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -r144 \
  -dFirstPage=8 -dLastPage=8 \
  -sOutputFile=class-online-learning-20260707/version/v1/render-check/page-08.png \
  class-online-learning-20260707/version/v1/main.pdf
gs -q -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -r144 \
  -dFirstPage=15 -dLastPage=15 \
  -sOutputFile=class-online-learning-20260707/version/v1/render-check/page-15.png \
  class-online-learning-20260707/version/v1/main.pdf
```

Expected: The three PNG files are created.

- [ ] **Step 3: Visually inspect representative pages**

Open the three rendered images with the available image viewer.

Expected:
- Page 1 has the correct title and date.
- Page 8 has no text overflow and the algorithm/result content is readable.
- Page 15 has no text overflow and the proof/significance content is readable.

- [ ] **Step 4: If overflow is visible, reduce local text density**

Use one of these targeted fixes in `main.typ`:

```typst
// Reduce text density on the "What Improves?" slide if the table is crowded.
#[
  #set text(size: 0.72em)
  #grid(
    columns: (1.15fr, 1fr, 1.05fr),
    column-gutter: 0.55em,
    row-gutter: 0.34em,
    align: (left + top, left + top, left + top),
    [*Algorithm*], [*Scale*], [*Misses*],
    [EG / Hedge], [$S_oo$], [best expert may be easy],
    [Cesa-Bianchi et al.], [$S_(i^star)$], [no path adaptivity],
    [Hazan--Kale], [$max_i V_i$], [depends on all experts],
    [Chiang et al.], [$D_oo$], [worst movement],
    [*AEG-Path*], [$D_(i^star)$], [best expert only],
  )
]

// Split the matrix slide if needed by moving the proof ingredient to backup.
== Matrix-Valued Losses: Update

#compact[
  Replace distributions by density matrices:
  $ W_t succeq 0, quad "tr"(W_t) = 1, quad "loss" = "tr"(W_t Z_t). $

  $ B_(t+1) = B_t - eta Z_t - eta^2 (Z_t - M_t)^2,
     quad W_t = exp(B_t - eta M_t) / "tr"(exp(B_t - eta M_t)). $
]

= Backup <touying:hidden>

== Backup: Matrix Proof Ingredients

#compact[
  The matrix analysis uses Golden--Thompson for the log-partition step and
  FTRL-K for cone-ordered vector-valued losses.
]
```

Expected: Recompile, re-render, and reinspect until representative pages are readable.

### Task 5: Final Git Review And Commit

**Files:**
- Modify: `class-online-learning-20260707/version/v1/main.typ`
- Create: `class-online-learning-20260707/version/v1/main.pdf`
- Optional generated check images: do not commit `class-online-learning-20260707/version/v1/render-check/`

- [ ] **Step 1: Remove render-check artifacts from the working tree**

Run:

```bash
rm -rf class-online-learning-20260707/version/v1/render-check
```

Expected: The verification PNGs are removed.

- [ ] **Step 2: Check the final status**

Run:

```bash
git status --short
```

Expected: Only `class-online-learning-20260707/version/v1/main.typ` and `class-online-learning-20260707/version/v1/main.pdf` are changed or created.

- [ ] **Step 3: Review the final diff**

Run:

```bash
git diff -- class-online-learning-20260707/version/v1/main.typ
git diff --stat
```

Expected: The Typst file contains the new deck, and the diff stat includes `main.typ` plus the generated `main.pdf`.

- [ ] **Step 4: Commit the slide deck**

Run:

```bash
git add class-online-learning-20260707/version/v1/main.typ class-online-learning-20260707/version/v1/main.pdf
git commit -m "feat: add adaptive optimism presentation slides"
```

Expected: A new commit containing the Typst deck and compiled PDF.
