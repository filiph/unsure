## 0.3.0

- Introduce variables: a formula can point to a previously parsed formula
- Add `%`, `K` and `M` postfixes (for things like `20%`, `20~30K`, and so on)
- BREAKING: you now have to instantiate a `FormulaParser`
  before parsing formulas. This is to allow the parser to recognize variables.
- BREAKING: `x` and `X` no longer work for multiplication, to avoid confusion
  with variables (which are often named something like `x`)
- Allow using unicode symbols for multiplication (×, ·) and division (÷)
- Weed out `dynamic` from the code

## 0.2.0

- Migrate to null safety

## 0.1.2

- Allow installing `unsure` with `pub global activate unsure`
- Fix crash if the CLI `unsure` tool is called without a formula

## 0.1.1

- Loosened Dart SDK constraints
- Wrote a better description for the package

## 0.1.0

- Initial version
