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
//  2. Main result
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
      [1:], [Initialize weights $w_(1,i) = 1$ for all $i$.],
      [2:], [
        For $t=1,dots.c,T$, using hint $m_t$, form
        #v(0.08em)
        #align(center)[
          #text(size: 0.92em)[
            $p_(t,i) =
              (w_(t,i) exp(#text(fill: m-red)[$-eta m_(t,i)$]))
              / (sum_(j=1)^n w_(t,j) exp(#text(fill: m-red)[$-eta m_(t,j)$]))$
          ]
        ]
        learner plays $p_t$.],
      [3:], [Loss vector $z_t in [-1,1]^n$ is revealed; learner suffers $p_t^top z_t$.],
      [4:], [
        For each $i$, update
        #text(size: 0.98em)[
          $w_(t+1,i)=w_(t,i) exp(-eta z_(t,i) #text(fill: m-red)[$-eta^2 (z_(t,i)-m_(t,i))^2$])$.
        ]
      ],
    )
    v(0.1em)
    line(length: 100%, stroke: 1pt)
  })

  #v(0.35em)

  The red terms use the hint in prediction and penalize inaccurate hints in
  the update.
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

  #v(0.55em)

  The step-size condition is for the proof inequality. Since
  $abs(z_(t,i) - m_(t,i)) <= 2$, $eta <= 1/4$ gives
  $abs(eta (z_(t,i) - m_(t,i))) <= 1/2$, so
  $exp(-x - x^2) <= 1 - x$ applies.
]

// ============================================================
//  3. Hint interpretations
// ============================================================
= What the Hints Mean

== Hint Choices: Path-Length and Variance

#[
  #set text(size: 0.73em)
  The second term is the hint error
  $H_i(m) := sum_t (z_(t,i) - m_(t,i))^2$.
  Different hints make $H_i(m)$ small under different patterns.

  #v(0.24em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    align: (left + top, left + top),
    [
      *Last-loss hint*

      #v(0.12em)

      $m_t = z_(t-1)$

      #v(0.18em)

      *Controls:* path length of expert $i$:
      $
        D_i := sum_t (z_(t,i) - z_(t-1,i))^2 .
      $

      #v(0.14em)

      Here $H_i(m)=D_i$, so

      #v(0.08em)

      $
        "Regret"(i^star)
          <= (log n) / eta + eta D_(i^star).
      $

      #v(0.14em)

      *Interpretation:* good when the best expert changes slowly from one round
      to the next.
    ],
    [
      *Past-average hint*

      #v(0.12em)

      $m_t = 1/t sum_(s=1)^(t-1) z_s$

      #v(0.18em)

      *Controls:* variance around a stable mean:
      $
        V_i := sum_t (z_(t,i) - mu_i)^2,
        quad
        mu_i := 1/T sum_t z_(t,i).
      $

      #v(0.14em)

      Paper's lemma:
      $
        sum_t (z_(t,i) - m_(t,i))^2 <= 2 V_i + 6.
      $

      #v(0.08em)

      $
        "Regret"(i^star)
          <= (log n) / eta + eta (2 V_(i^star) + 6).
      $

      #v(0.14em)

      *Good when:* the best expert's losses stay near one fixed average,
      even with noise.
    ],
  )
]

// ============================================================
//  4. Proof tools and extensions
// ============================================================
= Proof Tools and Extensions

== Proof Tool: Fenchel Conjugate

#spacious[
  The paper writes EG through the Fenchel conjugate of negative entropy:
  $
    psi(w) = sum_i w_i log w_i,
    quad
    psi^*(beta) = log(sum_i exp(beta_i)).
  $

  #v(0.65em)

  The conjugate turns scores into probabilities:
  $
    nabla psi^*(beta)_i =
      exp(beta_i) / (sum_j exp(beta_j)).
  $

  #v(0.65em)

  So the algorithm can be written as
  $
    p_t = nabla psi^*(beta_t - eta m_t),
  $
  and the proof tracks how $psi^*$ changes after each update.

  #v(0.45em)
]

== Matrix Extension

#[
  #set text(size: 0.9em)

  Replace distributions by density matrices and losses by symmetric matrices:
  $
    W_t, U in cal(S)_+^n,
    quad "tr"(W_t)="tr"(U)=1,
    quad ell_t(W_t)="tr"(W_t Z_t),
    quad norm(Z_t)_"op" <= 1.
  $

  #v(0.4em)

  Matrix regret is measured against a fixed density matrix $U$:
  $
    "Regret"(U) := sum_t "tr"((W_t - U) Z_t).
  $

  #v(0.45em)

  *General hint version* (Proposition 4.1):
  $
    "Regret"(U)
      <= (log n) / eta
        + eta sum_t "tr"(U (Z_t - M_t)^2).
  $

  #v(0.45em)

  *Path-length hint:* with $M_t=Z_(t-1)$,
  $
    "Regret"(U)
      <= (log n) / eta
        + eta sum_t "tr"(U (Z_t - Z_(t-1))^2).
  $
]
