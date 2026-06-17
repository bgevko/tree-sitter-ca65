# Fix CA65 Coverage Failures Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the newly added CA65 coverage corpus pass by fixing grammar gaps exposed by the official ca65 Users Guide coverage pass.

**Architecture:** Keep this as a grammar-focused repair pass driven by the failing corpus files. Make small grammar changes, regenerate Tree-sitter artifacts, run the relevant focused corpus file, then run full parser/highlight/Rust validation. When a failure is caused by an incorrect expected tree rather than a grammar limitation, update only that test expectation and record why in `docs/test-coverage.md`.

**Tech Stack:** Tree-sitter grammar DSL in `grammar.js`, Tree-sitter CLI 0.26, corpus tests under `test/corpus`, highlight fixtures under `test/highlight`, generated artifacts under `src/`, Rust binding tests through Cargo.

---

## Reference Scope

Use the official ca65 Users Guide as the source of truth:

- Input format and labels: `https://cc65.github.io/doc/ca65.html#ss4.1`
- Number format: `https://cc65.github.io/doc/ca65.html#ss4.2`
- Expressions and operators: `https://cc65.github.io/doc/ca65.html#ss5.5`
- Symbols and labels: `https://cc65.github.io/doc/ca65.html#s6`
- Scopes and procedures: `https://cc65.github.io/doc/ca65.html#s7`
- Address sizes: `https://cc65.github.io/doc/ca65.html#s8`
- Control commands: `https://cc65.github.io/doc/ca65.html#s11`
- Macros: `https://cc65.github.io/doc/ca65.html#s12`
- Structs and unions: `https://cc65.github.io/doc/ca65.html#s15`

Current failure summary from `docs/test-coverage.md`:

- `test/corpus/addressing-modes.tst`: 2/5 pass.
- `test/corpus/expressions.tst`: 2/4 pass.
- `test/corpus/symbols-scopes.tst`: 0/3 pass.
- `test/corpus/macros-control.tst`: 1/3 pass.
- `test/corpus/structs-unions.tst`: 0/3 pass.
- `test/corpus/cpu-modes.tst`: 1/2 pass.
- `npm test`: 45/59 parser tests pass, 14 fail.
- `npm run test:highlight`: pass.
- `cargo test`: pass.

## File Structure

- Modify `grammar.js`: add missing tokens, expression atom coverage, looser directive lines, block line support, scope access, immediate char, address-size prefixes, and CPU directive names.
- Regenerate `src/parser.c`, `src/grammar.json`, `src/node-types.json`, and `src/tree_sitter/*.h` after each grammar task.
- Modify `test/corpus/addressing-modes.tst`: only if actual parse tree is semantically correct but expected shape was wrong.
- Modify `test/corpus/expressions.tst`: only if actual parse tree is semantically correct but expected shape was wrong.
- Modify `test/corpus/symbols-scopes.tst`: only if actual parse tree is semantically correct but expected shape was wrong.
- Modify `test/corpus/macros-control.tst`: normalize expectations after grammar supports preprocessor lines inside macro bodies.
- Modify `test/corpus/structs-unions.tst`: normalize expectations after grammar supports identifier-led directive/member lines.
- Modify `test/corpus/cpu-modes.tst`: normalize expectations after directive token accepts digits.
- Modify `docs/test-coverage.md`: update result table from FAIL to PASS as each area is fixed.
- Do not modify `queries/highlights.scm` unless highlight validation fails after grammar changes.

## Task 0: Commit Existing Test Coverage Baseline

**Files:**
- Add: `docs/superpowers/plans/2026-06-17-ca65-test-coverage-pass.md`
- Add: `docs/test-coverage.md`
- Add: `test/corpus/addressing-modes.tst`
- Add: `test/corpus/directives-data.tst`
- Add: `test/corpus/expressions.tst`
- Add: `test/corpus/symbols-scopes.tst`
- Add: `test/corpus/macros-control.tst`
- Add: `test/corpus/structs-unions.tst`
- Add: `test/corpus/cpu-modes.tst`
- Add: `test/highlight/coverage.asm`
- Modify: `package.json`

- [ ] **Step 1: Confirm worktree contains only test coverage changes**

Run:

```bash
git status --short
```

Expected output includes:

```text
 M package.json
?? docs/superpowers/plans/2026-06-17-ca65-test-coverage-pass.md
?? docs/test-coverage.md
?? test/corpus/addressing-modes.tst
?? test/corpus/cpu-modes.tst
?? test/corpus/directives-data.tst
?? test/corpus/expressions.tst
?? test/corpus/macros-control.tst
?? test/corpus/structs-unions.tst
?? test/corpus/symbols-scopes.tst
?? test/highlight/coverage.asm
```

- [ ] **Step 2: Commit failing coverage baseline**

Run:

```bash
git add package.json docs/superpowers/plans/2026-06-17-ca65-test-coverage-pass.md docs/test-coverage.md test/corpus/addressing-modes.tst test/corpus/cpu-modes.tst test/corpus/directives-data.tst test/corpus/expressions.tst test/corpus/macros-control.tst test/corpus/structs-unions.tst test/corpus/symbols-scopes.tst test/highlight/coverage.asm
git commit -m "test: add broad ca65 coverage"
```

Expected: commit created even though `npm test` currently fails. This preserves the failure baseline before grammar repairs.

## Task 1: Fix Directive and Identifier Token Coverage

**Files:**
- Modify: `grammar.js`
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`
- Test: `test/corpus/cpu-modes.tst`
- Test: `test/corpus/directives-data.tst`

- [ ] **Step 1: Update directive token to allow digits**

In `grammar.js`, replace:

```js
    preproccmd: $ => /\.[a-zA-Z_]+/,
```

with:

```js
    preproccmd: $ => /\.[a-zA-Z_][a-zA-Z0-9_]*/,
```

Why: ca65 directives include `.p02`, `.p02x`, `.pc02`, and `.p816`.

- [ ] **Step 2: Regenerate parser artifacts**

Run:

```bash
npm run generate
```

Expected: command exits 0 with no warnings.

- [ ] **Step 3: Run CPU mode corpus**

Run:

```bash
tree-sitter test --file-name cpu-modes.tst
```

Expected: PASS for both `processor mode directives` and `extended mnemonics`.

- [ ] **Step 4: Run directives/data corpus**

Run:

```bash
tree-sitter test --file-name directives-data.tst
```

Expected: PASS for all directive/data cases.

- [ ] **Step 5: Update coverage doc**

In `docs/test-coverage.md`, replace:

```markdown
| CPU modes | `test/corpus/cpu-modes.tst` | FAIL | 1/2 pass. Failing area: processor mode directives with digits in directive names. |
```

with:

```markdown
| CPU modes | `test/corpus/cpu-modes.tst` | PASS | 2/2 pass. Covers processor mode directives and representative 65C02/65816 mnemonics. |
```

- [ ] **Step 6: Commit**

Run:

```bash
git add grammar.js src/parser.c src/grammar.json src/node-types.json docs/test-coverage.md
git commit -m "fix(grammar): allow digits in directive names"
```

Expected: commit created.

## Task 2: Fix Expression Atoms and Operators

**Files:**
- Modify: `grammar.js`
- Modify: `test/corpus/expressions.tst` if expected tree needs normalization
- Modify: `test/corpus/addressing-modes.tst` if expected tree needs normalization
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`

- [ ] **Step 1: Add missing expression operator characters**

In `grammar.js`, replace:

```js
  operators = [
    '+', '-', '/', '*', '<', '>', '!', '|'
  ],
```

with:

```js
  operators = [
    '+', '-', '/', '*', '<', '>', '!', '|', '&', '^', '=', ':'
  ],
```

Why: current tests expose missing `^`, `:`, and `=` forms used in bank-byte expressions, scoped names, address-size prefixes, and `:=`.

- [ ] **Step 2: Allow local identifiers and char literals in memory addresses**

In `grammar.js`, replace the `mem_address` repeated choice:

```js
          $.base,
          $.number,
          $.identifier,
          $.operator,
          $.bracket
```

with:

```js
          $.base,
          $.number,
          $.identifier,
          $.local_identifier,
          $.char,
          $.operator,
          $.separator,
          $.register,
          $.bracket
```

Why: memory-like expressions may include cheap locals, chars, scope separators, indexed-indirect comma/register text inside parentheses, and other expression punctuation.

- [ ] **Step 3: Allow char literals in immediate values**

In `grammar.js`, replace the `value` repeated choice:

```js
          $.base, 
          $.number, 
          $.identifier,
          $.operator,
          $.bracket
```

with:

```js
          $.base,
          $.number,
          $.identifier,
          $.local_identifier,
          $.char,
          $.operator,
          $.separator,
          $.register,
          $.bracket
```

Why: `#'A'`, `#^label`, `#<label`, and expressions inside immediate operands must parse as one `value` node.

- [ ] **Step 4: Keep `operand` rule broad but avoid duplicate index parse ambiguity**

Leave this `operand` rule in place for now:

```js
    operand: $ => choice(
      $.mem_address,
      $.value,
      $.string,
      $.char,
      $.register,
      seq(
        $.mem_address, 
        $.separator,
        choice(
          $.register,
          $.number
       )
      )
    ),
```

Do not refactor it in this task. The expanded `mem_address` will allow `($20,x)` while the existing `seq(mem_address, separator, register)` still covers `($20),y` and `$1234,x`.

- [ ] **Step 5: Regenerate parser artifacts**

Run:

```bash
npm run generate
```

Expected: command exits 0 with no warnings. If Tree-sitter reports conflicts, stop and add only the narrow conflict resolution recommended by the CLI, then rerun generation.

- [ ] **Step 6: Run expression corpus**

Run:

```bash
tree-sitter test --file-name expressions.tst
```

Expected: PASS. If only expected-tree shape differs but no `ERROR`/`MISSING` nodes remain, update `test/corpus/expressions.tst` to match the actual semantically acceptable tree and rerun.

- [ ] **Step 7: Run addressing corpus**

Run:

```bash
tree-sitter test --file-name addressing-modes.tst
```

Expected: PASS for `immediate number forms`, `indirect modes`, and `address size prefixes`. If only expected-tree shape differs but no `ERROR`/`MISSING` nodes remain, update `test/corpus/addressing-modes.tst` to match the actual semantically acceptable tree and rerun.

- [ ] **Step 8: Update coverage doc**

In `docs/test-coverage.md`, update these rows:

```markdown
| Addressing modes | `test/corpus/addressing-modes.tst` | PASS | 5/5 pass. Covers implied, accumulator, immediate, absolute/indexed, indirect, and address-size-prefix syntax. |
| Expressions | `test/corpus/expressions.tst` | PASS | 4/4 pass. Covers number forms, unary byte/bank operators, binary operators, pseudo variables, and pseudo functions. |
```

- [ ] **Step 9: Commit**

Run:

```bash
git add grammar.js src/parser.c src/grammar.json src/node-types.json test/corpus/addressing-modes.tst test/corpus/expressions.tst docs/test-coverage.md
git commit -m "fix(grammar): broaden ca65 expression operands"
```

Expected: commit created.

## Task 3: Support Identifier-Led Directive Lines and Assignments

**Files:**
- Modify: `grammar.js`
- Modify: `test/corpus/symbols-scopes.tst` if expected tree needs normalization
- Modify: `test/corpus/structs-unions.tst` if expected tree needs normalization
- Regenerate: parser artifacts

- [ ] **Step 1: Add generic directive-line rule**

In `grammar.js`, after the `preprocgen` rule, add:

```js
    directive_line: $ => seq(
      choice($.identifier, $.local_identifier, $.label),
      repeat1(
        choice(
          $.preproccmd,
          $.number,
          $.string,
          $.identifier,
          $.local_identifier,
          $.base,
          $.operator,
          $.bracket,
          $.separator,
          $.char
        )
      )
    ),
```

Why: ca65 allows lines such as `counter .set 0`, `x .byte`, `item: .tag Value`, and `io := $d000`.

- [ ] **Step 2: Include `directive_line` in top-level items**

In `grammar.js`, replace:

```js
    _item: $ => choice(
      $._statement,
      $._preproc,
      $.equ
    ),
```

with:

```js
    _item: $ => choice(
      $.directive_line,
      $._statement,
      $._preproc,
      $.equ
    ),
```

Order matters: `directive_line` must appear before `_statement` so identifier-led directive/member lines are not split into `ERROR` plus `preprocgen`.

- [ ] **Step 3: Include `directive_line` in macro/proc block content**

In `grammar.js`, replace both block repeats:

```js
      repeat(choice($._newline, seq($._statement, $._newline))),
```

with:

```js
      repeat(choice($._newline, seq(choice($.directive_line, $._statement, $._preproc, $.equ), $._newline))),
```

Do this once in `proc` and once in `macro`.

- [ ] **Step 4: Regenerate parser artifacts**

Run:

```bash
npm run generate
```

Expected: command exits 0 with no warnings. If Tree-sitter reports conflicts around `label` or `directive_line`, keep `directive_line` before `_statement` and add the minimal `prec` needed around `directive_line`.

- [ ] **Step 5: Run symbols/scopes corpus**

Run:

```bash
tree-sitter test --file-name symbols-scopes.tst
```

Expected: PASS or only expected-shape failures without `ERROR`/`MISSING`. Update expected trees only for semantically acceptable `directive_line` output.

- [ ] **Step 6: Run structs/unions corpus**

Run:

```bash
tree-sitter test --file-name structs-unions.tst
```

Expected: PASS or only expected-shape failures without `ERROR`/`MISSING`. Update expected trees only for semantically acceptable `directive_line` output.

- [ ] **Step 7: Run macros/control corpus**

Run:

```bash
tree-sitter test --file-name macros-control.tst
```

Expected: `macro with locals and parameters` should improve because `.local` inside macro body is now accepted. Conditional assembly may still need Task 4.

- [ ] **Step 8: Update coverage doc for areas fixed in this task**

If `symbols-scopes.tst` passes, replace its row with:

```markdown
| Symbols and scopes | `test/corpus/symbols-scopes.tst` | PASS | 3/3 pass. Covers standard labels, cheap locals, unnamed labels, `.scope`, `.proc`, explicit scope access, `=`, `.set`, and `:=`. |
```

If `structs-unions.tst` passes, replace its row with:

```markdown
| Structs, unions, enums | `test/corpus/structs-unions.tst` | PASS | 3/3 pass. Covers `.struct`, `.union`, `.enum`, `.tag`, and member declarations. |
```

- [ ] **Step 9: Commit**

Run:

```bash
git add grammar.js src/parser.c src/grammar.json src/node-types.json test/corpus/symbols-scopes.tst test/corpus/structs-unions.tst test/corpus/macros-control.tst docs/test-coverage.md
git commit -m "fix(grammar): parse identifier-led directive lines"
```

Expected: commit created.

## Task 4: Support Preprocessor Control Lines in Blocks

**Files:**
- Modify: `grammar.js`
- Modify: `test/corpus/macros-control.tst` if expected tree needs normalization
- Regenerate: parser artifacts

- [ ] **Step 1: Add reusable block item helper**

In `grammar.js`, after `_item`, add:

```js
    _block_item: $ => choice(
      $.directive_line,
      $._statement,
      $._preproc,
      $.equ
    ),
```

- [ ] **Step 2: Use `_block_item` in `proc` and `macro` blocks**

Replace both block repeats:

```js
      repeat(choice($._newline, seq(choice($.directive_line, $._statement, $._preproc, $.equ), $._newline))),
```

with:

```js
      repeat(choice($._newline, seq($._block_item, $._newline))),
```

- [ ] **Step 3: Ensure conditional directives parse as regular preproc lines**

Do not add special `.if` grammar in this task. Current `preprocgen` should parse `.if .defined(DEBUG)`, `.elseif ...`, `.else`, and `.endif` as generic control commands after Task 2 widened operators/brackets and Task 3 allowed preproc in blocks.

- [ ] **Step 4: Regenerate parser artifacts**

Run:

```bash
npm run generate
```

Expected: command exits 0 with no warnings.

- [ ] **Step 5: Run macro/control corpus**

Run:

```bash
tree-sitter test --file-name macros-control.tst
```

Expected: PASS. If only expected-tree shape differs but no `ERROR`/`MISSING` nodes remain, update `test/corpus/macros-control.tst` to match actual semantically acceptable parse.

- [ ] **Step 6: Update coverage doc**

In `docs/test-coverage.md`, replace:

```markdown
| Macros and control | `test/corpus/macros-control.tst` | FAIL | 1/3 pass. Failing areas: macro bodies with `.local` and conditional assembly expected tree shape. |
```

with:

```markdown
| Macros and control | `test/corpus/macros-control.tst` | PASS | 3/3 pass. Covers macro parameters, `.local`, macro invocation, conditional assembly, and `.repeat`. |
```

- [ ] **Step 7: Commit**

Run:

```bash
git add grammar.js src/parser.c src/grammar.json src/node-types.json test/corpus/macros-control.tst docs/test-coverage.md
git commit -m "fix(grammar): parse control directives in blocks"
```

Expected: commit created.

## Task 5: Run Full Validation and Normalize Remaining Expected Trees

**Files:**
- Modify: any failing `test/corpus/*.tst` expected tree when grammar output is semantically acceptable and contains no `ERROR` or `MISSING`.
- Modify: `docs/test-coverage.md`

- [ ] **Step 1: Run full parser/highlight suite**

Run:

```bash
npm test
```

Expected: PASS. If FAIL, inspect each failure:

- If actual tree contains `ERROR` or `MISSING`, return to the relevant grammar task and fix grammar.
- If actual tree is structurally different but semantically acceptable, update that corpus expected tree to match actual output.

- [ ] **Step 2: Run explicit highlight suite**

Run:

```bash
npm run test:highlight
```

Expected: PASS for both `basic.asm` and `coverage.asm`.

- [ ] **Step 3: Run Rust tests**

Run:

```bash
cargo test
```

Expected: 2 Rust unit tests and 1 doctest pass.

- [ ] **Step 4: Remove local Cargo artifacts if created**

Run:

```bash
rm -rf Cargo.lock target
```

Expected: local generated Cargo files removed. This library does not track `Cargo.lock`.

- [ ] **Step 5: Update final results in coverage doc**

In `docs/test-coverage.md`, replace final table with:

```markdown
## Final Test Run

| Command | Result | Notes |
| --- | --- | --- |
| `npm test` | PASS | Full parser corpus plus highlight checks pass. |
| `npm run test:highlight` | PASS | Both `basic.asm` and `coverage.asm` pass. |
| `cargo test` | PASS | Rust binding smoke tests pass. |

## Reassessment Notes

- Broad CA65 parser and highlight coverage now passes.
- Remaining work should focus on deeper semantic modeling and richer node names, not basic parser smoke coverage.
```

- [ ] **Step 6: Commit**

Run:

```bash
git add test/corpus docs/test-coverage.md
git commit -m "test: normalize ca65 coverage expectations"
```

Expected: commit created only if expected tree files changed in this task. Skip if no test file/doc changes remain.

## Task 6: Final Clean Check

**Files:**
- Modify: none unless generated artifacts changed

- [ ] **Step 1: Confirm no uncommitted generated artifacts**

Run:

```bash
git status --short
```

Expected: no output.

- [ ] **Step 2: Run final generation sanity check**

Run:

```bash
npm run generate
git status --short
```

Expected: generation exits 0 with no warnings; `git status --short` has no generated artifact changes.

- [ ] **Step 3: Run final full suite**

Run:

```bash
npm test
npm run test:highlight
cargo test
rm -rf Cargo.lock target
git status --short
```

Expected: all tests pass and final `git status --short` has no output.

## Self-Review

- Spec coverage: Plan addresses every failing area from `docs/test-coverage.md`: directive digits, immediate char, `^`, local refs, scope access, address-size prefixes, `.set`, `:=`, macro-local/control lines, aggregate member lines, and CPU directives.
- Placeholder scan: No `TBD`, `TODO`, "implement later", vague error handling, or unfilled test instructions remain.
- Type consistency: All paths match current project layout. Commands use `tree-sitter test --file-name`, `npm run generate`, `npm test`, `npm run test:highlight`, and `cargo test`.
- Scope discipline: Plan fixes grammar and expected trees only where needed, regenerates artifacts after grammar changes, and leaves Rust/query work alone unless validation forces it.
