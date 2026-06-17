# CA65 Test Coverage

## Sources

- ca65 Users Guide: https://cc65.github.io/doc/ca65.html
- Input syntax: https://cc65.github.io/doc/ca65.html#ss4.1
- Number format: https://cc65.github.io/doc/ca65.html#ss4.2
- Expressions/operators: https://cc65.github.io/doc/ca65.html#ss5.5
- Symbols/labels: https://cc65.github.io/doc/ca65.html#s6
- Scopes: https://cc65.github.io/doc/ca65.html#s7
- Control commands: https://cc65.github.io/doc/ca65.html#s11
- Macros: https://cc65.github.io/doc/ca65.html#s12
- Structs/unions: https://cc65.github.io/doc/ca65.html#s15

## Results

| Area | File | Result | Notes |
| --- | --- | --- | --- |
| Addressing modes | `test/corpus/addressing-modes.tst` | PASS | 5/5 pass. Covers implied, accumulator, immediate, absolute/indexed, indirect, and address-size-prefix syntax. |
| Directives and data | `test/corpus/directives-data.tst` | PASS | 3/3 pass. Covers segment switches, storage allocation, data emission, includes, imports, exports, and globals. |
| Expressions | `test/corpus/expressions.tst` | PASS | 4/4 pass. Covers number forms, unary byte/bank operators, binary operators, pseudo variables, and pseudo functions. |
| Symbols and scopes | `test/corpus/symbols-scopes.tst` | PASS | 3/3 pass. Covers standard labels, cheap locals, unnamed labels, `.scope`, `.proc`, explicit scope access, `=`, `.set`, and `:=`. |
| Macros and control | `test/corpus/macros-control.tst` | PASS | 3/3 pass. Covers macro parameters, `.local`, macro invocation, conditional assembly, and `.repeat`. |
| Structs, unions, enums | `test/corpus/structs-unions.tst` | PASS | 3/3 pass. Covers `.struct`, `.union`, `.enum`, `.tag`, and member declarations. |
| CPU modes | `test/corpus/cpu-modes.tst` | PASS | 2/2 pass. Covers processor mode directives and representative 65C02/65816 mnemonics. |
| Highlight coverage | `test/highlight/coverage.asm` | PASS | Broad highlight fixture passes with standard captures. |

## Final Test Run

| Command | Result | Notes |
| --- | --- | --- |
| `npm test` | FAIL | 45/59 parser tests pass; 14 parser corpus failures remain. Highlight tests pass inside this command. |
| `npm run test:highlight` | PASS | Both `basic.asm` and `coverage.asm` pass. |
| `cargo test` | PASS | Rust binding unit tests and doctest pass. |

## Reassessment Notes

- If all tests pass, grammar coverage is substantially broader and the project is likely close to parser-smoke-test complete.
- If any tests fail, keep the failures as evidence and open a separate grammar-fix plan. Do not fix failures in this test-only pass.
- Current result: reassessment needed. Broad coverage exposed parser/expected-tree gaps in addressing modes, expressions, symbols/scopes, macros/control, aggregate directives, and CPU mode directives.
