# Unsure Domain Context

A probabilistic calculator that evaluates mathematical expressions with uncertain inputs and presents probability distributions.

## Language

**Formula**:
A mathematical expression evaluated either deterministically or through Monte Carlo simulation.
_Avoid_: Expression, calculation string

**Stochastic Formula**:
A **Formula** containing uncertain inputs that cannot be statically proven deterministic, requiring Monte Carlo simulation to evaluate.
_Avoid_: Random formula, unsure expression

**Deterministic Formula**:
A **Formula** whose output is provably invariant (either containing only exact scalar values or through algebraic identities that eliminate uncertainty), evaluated directly without simulation.
_Avoid_: Exact formula, static formula

**Provably Deterministic Term**:
An AST node or expression that guarantees an invariant output regardless of the stochasticity of its child sub-expressions (e.g., `0 * x`, `1 ^ x`, or `N~N`).
_Avoid_: Constant sub-expression, folded node

**Result**:
The statistical summary of evaluating a **Formula**, containing confidence intervals, percentiles, and distribution metadata.
_Avoid_: Output, calculation value

**Degenerate Distribution**:
A statistical outcome from a **Stochastic Formula** where all simulation samples yield the exact same value (zero variance), resulting in a scalar **Result**, suppressed **Probability Histogram**, and concise **Percentiles** summary.
_Avoid_: Flat distribution, constant output

**Probability Histogram**:
A textual visualization of outcome frequencies across partitioned value bands of a **Result**.
_Avoid_: Chart, frequency plot

**Percentiles**:
A set of values at specific sample percentage ranks across the distribution of a **Result**.
_Avoid_: Quantiles, percentile table

## Example Dialogue

Dev: "The user entered `0 * 1~2`. Is that evaluated via Monte Carlo simulation?"
Domain Expert: "No, `0 * 1~2` is a **Deterministic Formula** because the multiplication node is a **Provably Deterministic Term** that absorbs the range. It emits `0` immediately without simulation. However, if a formula cannot be proven deterministic upfront but its simulation yields identical values across all samples, it produces a **Degenerate Distribution**."
