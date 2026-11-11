# Determinism Proof and Degenerate Distribution Handling

When evaluating formulas with uncertainty, we adopt a two-tier strategy to ensure invariant outputs are handled cleanly and efficiently:

1. **Tier 1 (AST-level Determinism Proof)**: AST terms override `isStochastic` to identify absorbing or identity elements (such as `0 * x`, `x * 0`, `1 ^ x`, `x ^ 0`, `0 / x`, and degenerate ranges `N~N`). When proven deterministic, the node marks `isStochastic` as `false` and short-circuits `emit()` to return the scalar directly without Monte Carlo simulation.
2. **Tier 2 (Simulation Degenerate Distribution Fallback)**: Formulas containing uncertainty that cannot be proven deterministic upfront run through Monte Carlo simulation. If the simulation yields zero variance (`min == max`), the resulting `Result` is treated as a `Degenerate Distribution`—formatting as a clean scalar, suppressing histogram computation, and emitting a concise percentile summary.

## Considered Options

- **Pure Monte Carlo (Degenerate Only)**: Ran all formulas with ranges through simulation, catching zero variance only post-simulation. While simple, it incurred unnecessary simulation overhead on expressions with obvious constant absorbing elements like `0 * 12~15`.
- **Global AST Simplification Engine**: Would require a full algebraic rewrite system mutating the tree during parsing, adding substantial maintenance complexity.
- **Two-Tier Strategy (Selected)**: Combines lightweight, local AST determinism checks (`isStochastic` overrides with short-circuiting) with robust zero-variance handling in `Result` for unprovable invariant distributions.
