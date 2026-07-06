#import "@preview/touying:0.7.4": *
#import themes.metropolis: *
#import "@preview/numbly:0.1.0": numbly

// ============================================================
//  Metropolis theme colors and small helpers
// ============================================================
#let m-dark-teal = rgb("#23373b")
#let m-light-brown = rgb("#eb811b")
#let m-lighter-brown = rgb("#d6c6b7")
#let m-red = rgb("#c7352b")

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
  set text(size: 0.86em)
  body
}

#let spacious(body) = {
  set text(size: 0.98em)
  body
}

#let changed(body) = text(fill: m-red, body)
#let alg-text-size = 1.1em
#let alg-row-gutter = 1.08em

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
  config-common(new-section-slide-fn: none),
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
//  1. Problem and motivation
// ============================================================
= Problem and Motivation

== Hedge Algorithm: Protocol and Bound

#compact[
  #v(-0.4em)
  #block(width: 100%, breakable: false, {
    set text(size: alg-text-size)
    line(length: 100%, stroke: 1pt)
    v(0.1em)
    text(weight: "bold", fill: m-light-brown)[Algorithm: Hedge]
    [ — expert advice protocol]
    v(0.1em)
    line(length: 100%, stroke: 0.5pt)
    v(0.28em)
    grid(
      columns: (1.4em, 1fr),
      column-gutter: 0.45em,
      row-gutter: alg-row-gutter,
      align: (right + horizon, left + horizon),
      [1:], [Initialize weights $w_(1,i)=1$ for all $i$.],
      [2:], [
        For $t=1,dots.c,T$, form
        #text(size: 1.08em)[$p_(t,i)=w_(t,i)/(sum_(j=1)^n w_(t,j))$];
        learner plays $p_t$.
      ],
      [3:], [Loss vector $z_t in [-1,1]^n$ is revealed; learner suffers $p_t^top z_t$.],
      [4:], [
        For each $i$, update
        #text(size: 1em)[$w_(t+1,i)=w_(t,i) exp(-eta z_(t,i))$].
      ],
    )
    v(0.1em)
    line(length: 100%, stroke: 1pt)
  })

  #v(0.22em)

  *Regret:* for $u in Delta_n$,
  $R_T(u) := sum_(t=1)^T (p_t - u)^top z_t$.

  #v(0.2em)

  *Standard upper bound.*
  #align(center)[
    $R_T(u) <= (log n) / eta
      + eta sum_(t=1)^T norm(z_t)_oo^2$
  ]
]

== Adaptive Weight Update: MW2

#compact[
  #v(-0.75em)
  #block(width: 100%, breakable: false, {
    set text(size: alg-text-size)
    line(length: 100%, stroke: 1pt)
    v(0.1em)
    text(weight: "bold", fill: m-light-brown)[Algorithm: MW2]
    [ — adaptive weights]
    v(0.1em)
    line(length: 100%, stroke: 0.5pt)
    v(0.28em)
    grid(
      columns: (1.4em, 1fr),
      column-gutter: 0.45em,
      row-gutter: alg-row-gutter,
      align: (right + horizon, left + horizon),
      [1:], [Initialize weights $w_(1,i)=1$ for all $i$.],
      [2:], [For $t=1,dots.c,T$, form
        #text(size: 1.08em)[$p_(t,i)=w_(t,i)/(sum_(j=1)^n w_(t,j))$];
        learner plays $p_t$.],
      [3:], [Loss vector $z_t in [-1,1]^n$ is revealed; learner suffers $p_t^top z_t$.],
      [4:], [For each $i$, update
        $w_(t+1,i)=w_(t,i)$ #changed[$(1 - eta z_(t,i))$].],
    )
    v(0.1em)
    line(length: 100%, stroke: 1pt)
  })

  #v(0.45em)

  Bound:
  #align(center)[
    $"Regret"(u) <= (log n) / eta + eta$
    #changed[$sum_i u_i sum_t z_(t,i)^2$]
  ]

  #v(0.25em)

  The second term is now averaged by the comparator $u$.
]

== Why MW2 Improves the Bound

#spacious[
  Hedge pays for the worst coordinate on every round:

  #align(center)[
    $eta sum_t norm(z_t)_oo^2$
  ]

  #v(0.7em)

  MW2 pays only for the comparator-weighted coordinates:

  #align(center)[
    #changed[$eta sum_i u_i sum_t z_(t,i)^2$]
  ]

  #v(0.7em)

  For the best expert $u=e_(i^star)$, this becomes
  #align(center)[
    #changed[$eta sum_t z_(t,i^star)^2$]
  ]

  #v(0.6em)

  Irrelevant noisy experts no longer enlarge the second term.
]

== Optimistic Learning: Hints

#compact[
  #v(-0.75em)
  #block(width: 100%, breakable: false, {
    set text(size: alg-text-size)
    line(length: 100%, stroke: 1pt)
    v(0.1em)
    text(weight: "bold", fill: m-light-brown)[Algorithm: Optimistic EG]
    [ — hints]
    v(0.1em)
    line(length: 100%, stroke: 0.5pt)
    v(0.28em)
    grid(
      columns: (1.4em, 1fr),
      column-gutter: 0.45em,
      row-gutter: alg-row-gutter,
      align: (right + horizon, left + horizon),
      [1:], [Initialize scores $theta_(1,i)=0$ for all $i$.],
      [2:], [For $t=1,dots.c,T$, using hint $m_t$, form
        #text(size: 1.04em)[
          $p_(t,i) prop exp(theta_(t,i) #text(fill: m-red)[$-eta m_(t,i)$])$
        ];
        learner plays $p_t$.],
      [3:], [Loss vector $z_t in [-1,1]^n$ is revealed; learner suffers $p_t^top z_t$.],
      [4:], [For each $i$, update
        $theta_(t+1,i)=theta_(t,i)-eta z_(t,i)$.],
    )
    v(0.1em)
    line(length: 100%, stroke: 1pt)
  })

  #v(0.4em)

  Bound:
  #align(center)[
    $R_T(u) <= (log n) / eta + eta$
    #changed[$sum_t norm(z_t - m_t)_oo^2$]
  ]

  #v(0.25em)

  The second term now measures hint error. With $m_t=z_(t-1)$, this becomes
  a path-length quantity.
]

== Two Ways to Improve the Second Term

#spacious[
  We now have two independent changes to the Hedge template:

  #v(0.65em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.45em,
    [
      *Adaptive weights*

      #v(0.28em)

      Change the weight update.

      #v(0.28em)

      Worst-coordinate scale becomes comparator scale:
      $
        sum_i u_i sum_t z_(t,i)^2 .
      $
    ],
    [
      *Optimism / hints*

      #v(0.28em)

      Change the probability before observing $z_t$.

      #v(0.28em)

      Loss scale becomes hint-error scale:
      $
        sum_t norm(z_t - m_t)_oo^2 .
      $
    ],
  )

  #v(0.65em)

  The paper combines both changes in one algorithm.
]

== Why Improve the Second Term?

#[
  #set text(size: 0.98em)

  Many refinements keep the first term $(log n)/eta$ and replace the second
  term by a more local quantity.

  #v(0.75em)

  #{
    set text(size: 0.98em)
    grid(
      columns: (0.5em, 1fr),
      column-gutter: 0.35em,
      row-gutter: 1.1em,
      align: (left + horizon, left + horizon),
      [•], [*Standard EG:* $sum_(t=1)^T norm(z_t)_oo^2$.],
      [•], [*Adaptive / MW2:* $sum_(i=1)^n u_i sum_(t=1)^T z_(t,i)^2$.],
      [•], [*Optimistic methods:* $sum_(t=1)^T norm(z_t - m_t)_oo^2$.],
      [•], [*This paper:* $sum_(i=1)^n u_i sum_(t=1)^T (z_(t,i) - m_(t,i))^2$.],
    )
  }

  #v(0.8em)

  Drawback of $norm(z_t)_oo^2$:
  it uses the worst coordinate at each round, not the comparator chosen in
  hindsight.

  #v(0.65em)

  A noisy irrelevant expert can enlarge the bound even when the best expert is
  stable or predictable.
]

// ============================================================
//  2. Paper motivation
// ============================================================
= Combining Two Directions

== Paper's Motivation: Combine Them

#spacious[
  The paper's key move:

  #v(0.55em)

  #align(center)[
    #text(size: 1.22em, weight: "bold", fill: m-light-brown)[
      adaptive best-expert scale + optimistic hint error
    ]
  ]

  #v(0.85em)

  Desired second term:
  $
    sum_t (z_(t,i^star) - m_(t,i^star))^2 .
  $

  #v(0.75em)

  This yields one algorithm whose guarantee becomes variance or path length
  after choosing the hint sequence.
]

// ============================================================
//  3. Main result
// ============================================================
= Main Result

== Algorithm: Adaptive Optimistic EG

#compact[
  #v(-0.75em)
  #block(width: 100%, breakable: false, {
    set text(size: alg-text-size)
    line(length: 100%, stroke: 1pt)
    v(0.1em)
    text(weight: "bold", fill: m-light-brown)[Algorithm: Adaptive Optimistic EG]
    [ — adaptive weights + hints]
    v(0.1em)
    line(length: 100%, stroke: 0.5pt)
    v(0.28em)
    grid(
      columns: (1.4em, 1fr),
      column-gutter: 0.45em,
      row-gutter: alg-row-gutter,
      align: (right + horizon, left + horizon),
      [1:], [Initialize $beta_(1,i) = 0$.],
      [2:], [For $t=1,dots.c,T$, using hint $m_t$, form
        #text(size: 1.04em)[
          $p_(t,i) prop exp(beta_(t,i) #text(fill: m-red)[$-eta m_(t,i)$])$
        ];
        learner plays $p_t$.],
      [3:], [Loss vector $z_t in [-1,1]^n$ is revealed; learner suffers $p_t^top z_t$.],
      [4:], [For each $i$, update
        $beta_(t+1,i)=beta_(t,i)-eta z_(t,i)$
        #changed[$- eta^2 (z_(t,i)-m_(t,i))^2$].],
    )
    v(0.1em)
    line(length: 100%, stroke: 1pt)
  })

  #v(0.35em)

  The red correction downweights experts whose hints were inaccurate.
]

== Upper Bound

#spacious[
  #theorem("Adaptive Exponentiated Gradient")[
    If $norm(z_t)_oo <= 1$, $norm(m_t)_oo <= 1$, and $0 < eta <= 1/4$, then
    for every $u in Delta_n$,
    $
      "Regret"(u)
        <= (log n) / eta
          + eta sum_i u_i sum_t (z_(t,i) - m_(t,i))^2 .
    $
  ]

  #v(0.8em)

  This is exactly the desired combination:
  the comparator chooses the relevant coordinates,
  and the hint error chooses the relevant scale.
]

== Path-Length Result

#spacious[
  Set $m_t = z_(t-1)$ and take $u=e_(i^star)$:
  $
    "Regret"(i^star)
      <= (log n) / eta + eta D_(i^star),
      quad
      D_i := sum_t (z_(t,i) - z_(t-1,i))^2.
  $

  #v(0.85em)

  This answers Kale's question: can the path-length bound depend on the best
  expert rather than the worst coordinate?
]

// ============================================================
//  4. Hint interpretations
// ============================================================
= What the Hints Mean

== Three Choices of Hint

#spacious[
  The same upper bound has different interpretations:

  #v(0.65em)

  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 0.75em,
    row-gutter: 0.62em,
    align: (left + top, left + top, left + top),
    [*Hint*], [*Error term*], [*Regret scale*],
    [$m_t = 0$], [$z_t$], [$S_(i^star)$],
    [$m_t = 1/t sum_(s<t) z_s$], [$z_t - m_t$], [$V_(i^star)$],
    [$m_t = z_(t-1)$], [$z_t - z_(t-1)$], [$D_(i^star)$],
  )

  #v(0.75em)

  The paper uses this to unify second-moment, variance, and path-length bounds.
]

== When Is Regret Small?

#spacious[
  #show list: set block(spacing: 0.62em)

  - $S_(i^star)$ is small when the best expert's losses are close to zero.
  - $V_(i^star)$ is small when the best expert's losses are nearly constant.
  - $D_(i^star)$ is small when the best expert's losses move slowly.

  #v(0.9em)

  The path-length view is strongest when the best expert may have large losses,
  but those losses are predictable from the previous round.
]

== Comparison of Bounds

#[
  #set text(size: 0.94em)
  #grid(
    columns: (1.18fr, 1.03fr, 1.18fr),
    column-gutter: 0.65em,
    row-gutter: 0.58em,
    align: (left + top, left + top, left + top),
    [*Algorithm*], [*Scale in bound*], [*What it misses*],
    [EG / Hedge], [$S_oo$], [best expert may be easy],
    [Cesa-Bianchi et al.], [$S_(i^star)$], [no variance/path adaptivity],
    [Hazan--Kale], [$max_i V_i$], [depends on all experts],
    [Chiang et al.], [$D_oo$], [depends on worst movement],
    [*AEG-Path*], [$D_(i^star)$], [best expert only],
  )

  #v(0.75em)

  Even if $D_(i^star)=Theta(1)$, the other scales can be $Theta(T)$.
]

// ============================================================
//  5. Proof tools and extensions
// ============================================================
= Proof Tools and Extensions

== Proof Tool: Log-Sum-Exp Potential

#spacious[
  Use the normalizing potential
  $
    L(beta) := log(sum_i exp(beta_i)).
  $

  #v(0.75em)

  The weights are just the normalized exponential scores:
  $
    w_i(beta) =
      exp(beta_i) / (sum_j exp(beta_j)).
  $

  #v(0.75em)

  So the proof can be read as a statement about how $L(beta)$ changes under
  exponentiated updates.
]

== Why the Correction Works

#spacious[
  The proof asks the correction to make
  $
    L(beta_t - eta z_t - eta^2 a_t)
      <= L(beta_t - eta m_t)
        - eta w_t^top (z_t - m_t).
  $

  #v(0.75em)

  With $a_(t,i)=(z_(t,i)-m_(t,i))^2$, the scalar input is
  $
    exp(-x - x^2) <= 1 - x
    quad (abs(x) <= 1/2).
  $

  #v(0.75em)

  Then the potential differences telescope into the stated regret bound.
]

== Matrix Extension

#spacious[
  The paper writes the general version in mirror-descent language, using a
  Fenchel-conjugate potential.

  #v(0.55em)

  Replace distributions by density matrices:
  $
    W_t in cal(S)_+^n, quad "tr"(W_t)=1,
    quad "loss" = "tr"(W_t Z_t).
  $

  #v(0.55em)

  The analogous update is
  $
    B_(t+1) = B_t - eta Z_t - eta^2 (Z_t - M_t)^2,
    quad
    W_t = exp(B_t - eta M_t) / ("tr"(exp(B_t - eta M_t))).
  $

  #v(0.55em)

  The noncommutative step uses Golden--Thompson:
  $
    "tr"(exp(A+B)) <= "tr"(exp(A) exp(B)).
  $
]

// ============================================================
//  Backup
// ============================================================
= Backup <touying:hidden>

== Backup: Optimizing the Path Bound

#spacious[
  From
  $
    "Regret"(i^star) <= (log n) / eta + eta D_(i^star),
  $
  the best fixed step size is
  $
    eta = sqrt((log n) / D_(i^star)).
  $

  #v(0.45em)

  When this satisfies $eta <= 1/4$,
  $
    "Regret"(i^star) <= 2 sqrt(D_(i^star) log n).
  $

  #v(0.45em)

  If $D_(i^star)$ is unknown, adaptive tuning is possible but the paper's clean
  bound becomes weaker.
]
