#import "@preview/touying:0.7.4": *
#import themes.metropolis: *
#import "@preview/numbly:0.1.0": numbly

// ============================================================
//  Metropolis theme colors and small helpers
// ============================================================
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

// ============================================================
//  Theme setup
// ============================================================
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

// ============================================================
//  Title and outline
// ============================================================
#title-slide()

= Outline <touying:hidden>

#outline(title: none, indent: 1em, depth: 1)

// ============================================================
//  Problem and setup
// ============================================================
= Problem and Setup

== What Should EG Adapt To?

#compact[
  Standard exponentiated gradient is robust, but its bound can be driven by
  experts that are irrelevant in hindsight.

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

  #v(0.45em)

  Main question: can EG exploit that the *best expert* is easy, even when other
  experts fluctuate?
]

== Expert Advice Setting

#compact[
  #definition("Protocol")[
    On each round $t=1,dots.c,T$: $w_t in Delta_n$ is played,
    $z_t in [-1, 1]^n$ is revealed, and the learner pays $w_t^top z_t$.
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
    row-gutter: 0.42em,
    align: (left + top, left + top, left + top),
    [*Second moment*], [$S_i := sum_t z_(t,i)^2$], [small losses],
    [*Variance*], [$V_i := sum_t (z_(t,i) - overline(z)_i)^2$], [almost constant losses],
    [*Path length*], [$D_i := sum_t (z_(t,i) - z_(t-1,i))^2$], [predictable from the last round],
  )

  #v(0.45em)

  Target: depend on $D_(i^star)$, not $D_oo$ or $S_oo$.
]

// ============================================================
//  Motivation
// ============================================================
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

  Puzzle: MW2 has the better type of bound, but it is not mirror descent with a
  fixed regularizer.
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

  Coordinates with larger correction terms receive stronger regularization.
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

  Regret depends on the hint error $z_t - m_t$.

  #v(0.35em)

  If $m_t = z_(t-1)$, the error is exactly the path movement
  $z_t - z_(t-1)$.
]

// ============================================================
//  Main result
// ============================================================
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

#[
  #set text(size: 0.74em)
  #grid(
    columns: (1.18fr, 1.03fr, 1.18fr),
    column-gutter: 0.65em,
    row-gutter: 0.42em,
    align: (left + top, left + top, left + top),
    [*Algorithm*], [*Scale in bound*], [*What it misses*],
    [EG / Hedge], [$S_oo$], [best expert may be easy],
    [Cesa-Bianchi et al.], [$S_(i^star)$], [no variance/path adaptivity],
    [Hazan--Kale], [$max_i V_i$], [depends on all experts],
    [Chiang et al.], [$D_oo$], [depends on worst movement],
    [*AEG-Path*], [$D_(i^star)$], [best expert only],
  )

  #v(0.35em)

  The difference can be order $T$: even when $D_(i^star)=Theta(1)$,
  $max_i D_i$ and $V_(i^star)$ can be $Theta(T)$.
]

// ============================================================
//  Key idea
// ============================================================
= Key Idea

== Push Regret Into the Regularizer

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

  The correction term is chosen to make this inequality true.
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

  Therefore
  $
    psi^*(beta_t - eta z_t - eta^2 a_t)
      <= psi^*(beta_t - eta m_t)
        - eta w_t^top (z_t - m_t).
  $
]

== One Template, Different Hints

#compact[
  The same theorem gives different bounds by changing the hint:

  #v(0.35em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 0.8em,
    row-gutter: 0.42em,
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

// ============================================================
//  Significance
// ============================================================
= Significance

== What the Paper Contributes

#compact[
  - Explains MW2 through adaptive regularizers.
  - Combines adaptive regularization with optimistic learning.
  - Resolves Kale's open problem: a path-length bound for the best expert.
  - Extends the idea to matrix exponentiated gradient.

  #v(0.45em)

  Limitation: adaptive tuning of $eta$ weakens the clean $D_(i^star)$ statement.
]

== Matrix-Valued Losses: One-Slide Extension

#compact[
  Replace distributions by density matrices:
  $
    W_t in cal(S)_+^n, quad "tr"(W_t) = 1,
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

  New proof ingredient: Golden--Thompson plus FTRL-K for cone-ordered losses.
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
    #text(size: 1.16em, weight: "bold", fill: m-light-brown)[
      adaptive correction + optimistic hint = best-expert path-length regret
    ]
  ]
]

// ============================================================
//  Backup
// ============================================================
= Backup <touying:hidden>

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
