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
| `npm test` | PASS | Full parser corpus plus highlight checks pass. |
| `npm run test:highlight` | PASS | Both `basic.asm` and `coverage.asm` pass. |
| `cargo test` | PASS | Rust binding smoke tests pass. |

## Reassessment Notes

- Broad CA65 parser and highlight coverage now passes.
- Remaining work should focus on deeper semantic modeling and richer node names, not basic parser smoke coverage.
- Grammar precision pass 1 complete: public nodes now use clearer directive/immediate/address/instruction names and expose fields for directive names, instruction mnemonics/operands, labels, proc names, and macro parameters.
- Grammar precision pass 2 complete: identifier-led and generic lines are now split into assignments, symbol directives, labeled directives, macro calls, and enum members, including ca65 macro-call argument separators and brace-grouped arguments.
- Grammar precision pass 3 complete: operands now expose named immediate, accumulator, literal, address, indexed, indirect, indexed-indirect, and indirect-indexed syntax forms without claiming semantic zeropage/absolute resolution.
- Grammar precision pass 4 complete: common CA65 expressions now expose unary, binary, parenthesized, scoped identifier, and pseudo-function call nodes while preserving loose fallback coverage.
