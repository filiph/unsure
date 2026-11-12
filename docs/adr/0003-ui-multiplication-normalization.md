# UI Multiplication Normalization and Input Submission

We normalize ASCII `x` and `X` as multiplication synonyms (`*`) in the `@example/` web application layer (within the keypad handler and Web Worker input pre-processor) rather than inside the core `FormulaParser` grammar, and submit formulas directly on Enter keyboard events without `<form>` wrapping.

Keeping `FormulaParser` strict avoids syntactic ambiguity with variable names and algebraic terms across the core library while maintaining full mathematical convenience and expected calculator behaviors for web UI users.

## Considered Options

- **Support 'x' in Core FormulaParser**: Re-adds 'x' and 'X' directly as arithmetic operators in PetitParser. Rejected to avoid grammatical collisions with variables and identifiers in the core domain parser.
- **Keypad-Only Insertion**: Maps the keypad 'x' button to insert '*', but leaves manual keyboard inputs like `10x20` unsupported. Rejected because users typing formulas directly on their keyboard expect 'x' to function as multiplication.
- **UI-Layer Normalization (Selected)**: Pre-processes input strings in the Web Worker by mapping `x` and `X` to `*` and appends `*` on keypad button clicks, while keeping the core parser grammar clean.
