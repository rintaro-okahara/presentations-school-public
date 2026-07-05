# Class Online Learning Slides Design

## Goal

Create an English Typst slide deck for the class-online-learning presentation on
Steinhardt and Liang, "Adaptivity and Optimism: An Improved Exponentiated
Gradient Algorithm." The deck should follow `class-online-learning-20260707/tmp/presentation_guidelines.pdf`
and reuse the visual and structural style of `reading-seminar-2026-0616/main-v2.typ`
using Touying plus the Metropolis theme.

The single message of the talk:

> Adaptive regularization gives best-expert second-moment bounds; optimism turns
> predictable losses into small hint errors; combining them yields AEG-Path,
> whose regret depends on the path length of the best expert.

## Audience And Constraints

- Audience: classmates who know the course material but not this paper.
- Talk length: plan for about 14 minutes of content plus questions.
- Style: concise English, slightly less explanatory prose than the
  reading-seminar deck, with equations, short bullets, and small tables.
- Main focus: motivation and synthesis. Avoid a full proof transcription.
- Matrix-valued loss extension: include one final summary slide only, with
  optional backup detail if space is natural.

## Source Material

- Paper: `class-online-learning-20260707/origin/Adaptivity and Optimism_ An Improved Exponentiated Gradient Algorithm.pdf`
- Guidelines: `class-online-learning-20260707/tmp/presentation_guidelines.pdf`
- Style reference: `reading-seminar-2026-0616/main-v2.typ`

## Deck Structure

Target 18 to 20 main slides plus 2 to 3 backup slides.

1. Title and outline
2. Problem and context, about 2 minutes
   - Standard EG/Hedge regret depends on global or learner-weighted second
     moments.
   - The desired guarantee is smaller when the best expert is stable.
3. Setup, about 3 minutes
   - Expert-advice protocol.
   - Regret against a fixed comparator `u` and best expert `i^*`.
   - Define `S_i`, `V_i`, and `D_i` only when needed.
4. Main result, about 4 minutes
   - Show the old bounds as a compact comparison grid.
   - State AEG-Path and the regret bound
     `Regret <= log(n) / eta + eta D_{i^*}`.
   - Explain that this answers Kale's open problem and strictly improves the
     incomparable earlier directions in the grid.
5. Key idea, about 4 minutes
   - Ingredient 1: adaptive regularization explains MW2 as a second-order
     correction and moves the bound from learner-weighted loss to best-expert
     loss.
   - Ingredient 2: optimism uses hints `m_t`; when `m_t = z_{t-1}`, hint error
     is path length.
   - Synthesis: update
     `beta_{t+1,i} = beta_{t,i} - eta z_{t,i} - eta^2 (z_{t,i} - m_{t,i})^2`,
     with prediction proportional to `exp(beta_t - eta m_t)`.
   - Proof sketch only: "push regret into the regularizer" plus the log-sum-exp
     correction inequality.
6. Significance and limitations, about 2 minutes
   - What improves over Cesa-Bianchi et al., Hazan and Kale, and Chiang et al.
   - Adaptive step size weakens the bound slightly.
   - Matrix-valued loss extension in one slide.

## Typst Implementation

- Build `class-online-learning-20260707/version/v1/main.typ`.
- Copy the local macro style from `reading-seminar-2026-0616/main-v2.typ`:
  Metropolis colors, theorem/definition/lemma blocks, and title/outline flow.
- Keep text compact:
  - Prefer 2 to 4 bullets per slide.
  - Use equations as anchors rather than long prose.
  - Use one comparison table for the bound lattice.
  - Use one "two ingredients" slide to make the synthesis explicit.
- Compile with `typst compile class-online-learning-20260707/version/v1/main.typ`.

## Verification

- `typst compile` must succeed and produce a PDF.
- Inspect the resulting PDF page count and at least representative rendered
  pages to ensure there is no obvious overflow.
- Confirm the deck includes the paper's full reference.
- Confirm the guideline structure is covered: problem/context, setup, main
  result, key idea, and significance.

## Out Of Scope

- Full matrix proof and FTRL-K derivation in the main talk.
- Adaptive step-size supplementary algorithm details.
- Follow-up literature beyond a brief closing note.
