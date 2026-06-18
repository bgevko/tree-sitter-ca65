# CA65 Grammar Precision Roadmap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the CA65 Tree-sitter grammar toward clearer, LSP-friendly syntax nodes while preserving passing parser, highlight, and Rust validation after each pass.

**Architecture:** Keep the existing CA65-specific grammar as the base and borrow organization ideas from `tree-sitter-asm`: clearer node names, fields, small focused rules, and test-driven grammar changes. Do not try to encode assembler semantics such as symbol resolution, macro expansion, opcode legality, or linker-driven address-size decisions in the grammar; those belong in the LSP semantic layer.

**Tech Stack:** Tree-sitter grammar DSL in `grammar.js`, Tree-sitter CLI through `npm run generate` and `npm test`, corpus tests under `test/corpus`, highlight queries under `queries/highlights.scm`, generated artifacts under `src/`, Rust binding tests through `cargo test`.

---

## Reference Scope

Use the official ca65 Users Guide as the source of truth:

- Input syntax and line shape: `https://cc65.github.io/doc/ca65.html#ss4.1`
- Number format: `https://cc65.github.io/doc/ca65.html#ss4.2`
- Expressions and operators: `https://cc65.github.io/doc/ca65.html#s5`
- Symbols and labels: `https://cc65.github.io/doc/ca65.html#s6`
- Scopes and explicit scope syntax: `https://cc65.github.io/doc/ca65.html#s7`
- Address sizes and memory models: `https://cc65.github.io/doc/ca65.html#s8`
- Pseudo variables and pseudo functions: `https://cc65.github.io/doc/ca65.html#s9` and `https://cc65.github.io/doc/ca65.html#s10`
- Control commands: `https://cc65.github.io/doc/ca65.html#s11`
- Macros: `https://cc65.github.io/doc/ca65.html#s12`
- Structs and unions: `https://cc65.github.io/doc/ca65.html#s15`

## Current Baseline

This roadmap assumes the active grammar already uses the clearer directive names:

- `directive` for dot-prefixed assembler directives/control commands.
- `directive_name` for the dot-prefixed directive token.

Before executing this roadmap, verify the baseline:

```bash
git status --short
rg -n "preprocgen|preproccmd" grammar.js queries test src
npm run generate
npm test
npm run test:highlight
cargo test
rm -rf Cargo.lock target
```

Expected:

- `git status --short` has no output.
- `rg -n "preprocgen|preproccmd" grammar.js queries test src` exits 1 with no matches.
- `npm run generate` exits 0 with no warnings.
- `npm test` exits 0 with all parser and highlight tests passing.
- `npm run test:highlight` exits 0. The existing parser-directory warning is acceptable.
- `cargo test` exits 0 with 2 unit tests and 1 doctest passing.

## File Structure

- Modify `grammar.js`: rename vague nodes, add fields, split broad line classes, split operand classes, add expression structure, and add structured block nodes.
- Modify `queries/highlights.scm`: update renamed node references and add captures for new semantic nodes only when required.
- Modify `test/corpus/*.tst` and `test/corpus/examples.txt`: update expected trees after each grammar pass.
- Create `test/corpus/fields-structure.tst`: focused tests for named fields and top-level structure.
- Create `test/corpus/line-classification.tst`: focused tests for assignment, macro call, symbol directive, labeled directive, and enum member classification.
- Create `test/corpus/operand-structure.tst`: focused tests for named CA65 operand/addressing-mode syntax nodes.
- Create `test/corpus/expression-structure.tst`: focused tests for unary, binary, scoped, and function-like expressions.
- Create `test/corpus/block-structure.tst`: focused tests for structured `.scope`, `.struct`, `.union`, `.enum`, `.repeat`, and conditional blocks.
- Modify generated `src/parser.c`, `src/grammar.json`, and `src/node-types.json`: regenerate after each grammar change with `npm run generate`.
- Modify `docs/test-coverage.md`: record which precision passes are complete and which limitations remain deliberate.
- Do not edit historical plan docs under `docs/superpowers/plans/` except this roadmap.

## Execution Rules

- Commit after each pass.
- Do not proceed to the next pass if `npm test`, `npm run test:highlight`, or `cargo test` fails.
- If Tree-sitter reports a conflict, first try to narrow the rule. Add `prec` or `conflicts` only when the ambiguity is real and the CLI's suggested conflict is specific.
- If a corpus diff has no `ERROR` or `MISSING` nodes and the new tree is semantically better, update the expected tree.
- If a corpus diff introduces a worse broad node, fix the grammar instead of normalizing the test.
- Do not model zero-page vs absolute as a semantic fact unless the syntax explicitly says so, such as `z:` or `a:`. Plain `$12` vs `$1234` can require value/symbol information.

## Task 1: Naming and Fields Pass

**Files:**
- Modify: `grammar.js`
- Modify: `queries/highlights.scm`
- Modify: `test/corpus/*.tst`
- Modify: `test/corpus/examples.txt`
- Create: `test/corpus/fields-structure.tst`
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`
- Modify: `docs/test-coverage.md`

**Goal:** Improve public node names and add useful fields without changing language coverage.

- [ ] **Step 1: Create focused field-structure corpus**

Create `test/corpus/fields-structure.tst`:

```text
====================
directive fields
====================
.segment "CODE"
.byte $00, $01

---

(source_file
  (directive
    name: (directive_name)
    (directive_arguments
      (string)))
  (directive
    name: (directive_name)
    (directive_arguments
      (base)
      (number)
      (separator)
      (base)
      (number))))

====================
instruction fields
====================
reset:
    lda #$00
    sta $0200,x

---

(source_file
  (label
    name: (identifier))
  (instruction
    mnemonic: (mnemonic)
    operand: (operand
      (immediate
        (immediate_marker)
        (base)
        (number))))
  (instruction
    mnemonic: (mnemonic)
    operand: (operand
      (address_expression
        (base)
        (number)
        (separator)
        (register)))))
```

- [ ] **Step 2: Run the new corpus to verify it fails**

Run:

```bash
tree-sitter test --file-name fields-structure.tst
```

Expected: FAIL because `directive_arguments`, `instruction`, `immediate`, `immediate_marker`, `address_expression`, and `label name:` do not exist yet.

- [ ] **Step 3: Rename broad operand nodes**

In `grammar.js`, replace:

```js
    [$.operand, $.mem_address],
```

with:

```js
    [$.operand, $.address_expression],
```

Replace:

```js
    operand: $ => choice(
      $.mem_address,
      $.value,
      $.string,
      $.char,
      $.register
    ),

    mem_address: $ => choice(
```

with:

```js
    operand: $ => choice(
      $.address_expression,
      $.immediate,
      $.string,
      $.char,
      $.register
    ),

    address_expression: $ => choice(
```

Replace:

```js
    value: $ => seq(
      $.valuetag,
```

with:

```js
    immediate: $ => seq(
      $.immediate_marker,
```

Replace:

```js
    valuetag: $ => token('#'),
```

with:

```js
    immediate_marker: $ => token('#'),
```

- [ ] **Step 4: Add `instruction` and `directive_arguments` rules**

Replace `_statement`:

```js
    _statement: $ => choice(
      $.label,
      prec.right(1, seq(
        $.mnemonic,
        optional(
          $.operand
        )
      )),
      prec(1, seq(
        $.label,
        $.mnemonic,
        optional(
          $.operand
        )
      ))
    ),
```

with:

```js
    _statement: $ => choice(
      $.label,
      $.instruction,
      prec(1, seq(
        $.label,
        $.instruction
      ))
    ),

    instruction: $ => prec.right(1, seq(
      field('mnemonic', $.mnemonic),
      optional(field('operand', $.operand))
    )),
```

Replace `directive`:

```js
    directive: $ => seq(
      $.directive_name,
      repeat(
        choice(
          $.directive_name,
          $.number,
          $.string,
          $.identifier,
          $.base,
          $.operator,
          $.bracket,
          $.separator
        )
      )
    ),
```

with:

```js
    directive: $ => seq(
      field('name', $.directive_name),
      optional($.directive_arguments)
    ),

    directive_arguments: $ => repeat1($._directive_argument),

    _directive_argument: $ => choice(
      $.directive_name,
      $.number,
      $.string,
      $.identifier,
      $.base,
      $.operator,
      $.bracket,
      $.separator
    ),
```

- [ ] **Step 5: Add fields to labels and macro/proc names**

Replace `label`:

```js
    label: $ => choice(
      prec(1, seq(choice($.identifier, $.local_identifier), ':')),
      $.unnamed_label
    ),
```

with:

```js
    label: $ => choice(
      prec(1, seq(field('name', choice($.identifier, $.local_identifier)), ':')),
      $.unnamed_label
    ),
```

In `proc`, replace:

```js
      field("proc_name", $.identifier),
```

with:

```js
      field('name', $.identifier),
```

Do not add `.proc Name: near` or `address_size` in this pass. The ca65 manual documents `.proc Name`; the roadmap should not introduce a questionable `.proc Name: near` test.

In `macro`, replace:

```js
      $.identifier,
      repeatSep($.identifier, $.separator),
```

with:

```js
      field('name', $.identifier),
      repeatSep(field('parameter', $.identifier), $.separator),
```

- [ ] **Step 6: Update highlight query names**

In `queries/highlights.scm`, ensure the directive and immediate marker captures are:

```scheme
(directive_name) @keyword
(immediate_marker) @punctuation.delimiter
```

- [ ] **Step 7: Regenerate parser artifacts**

Run:

```bash
npm run generate
```

Expected: exits 0 with no warnings. If Tree-sitter reports a conflict involving `instruction` and `label`, prefer narrowing `_statement` before adding a conflict.

- [ ] **Step 8: Update corpus expectations**

Run:

```bash
npm test
```

Expected: FAIL only because expected trees still use old names or lack new fields/nodes. Update `test/corpus/*.tst` and `test/corpus/examples.txt`:

- `mem_address` becomes `address_expression`.
- `value` becomes `immediate`.
- `valuetag` becomes `immediate_marker`.
- Bare instruction pairs become `instruction` nodes with `mnemonic:` and optional `operand:`.
- Directives use `name: (directive_name)` and `directive_arguments` for arguments.
- Labels use `name:` where a real identifier/local identifier exists.

- [ ] **Step 9: Verify Task 1**

Run:

```bash
npm run generate
tree-sitter test --file-name fields-structure.tst
npm test
npm run test:highlight
cargo test
rm -rf Cargo.lock target
git status --short
```

Expected:

- `fields-structure.tst`: PASS.
- `npm test`: PASS.
- `npm run test:highlight`: PASS with the existing parser-directory warning.
- `cargo test`: PASS with 2 unit tests and 1 doctest.
- `git status --short`: only files touched by this task.

- [ ] **Step 10: Update coverage docs**

In `docs/test-coverage.md`, add under `## Reassessment Notes`:

```markdown
- Grammar precision pass 1 complete: public nodes now use clearer directive/immediate/address/instruction names and expose fields for directive names, instruction mnemonics/operands, labels, proc names, and macro parameters.
```

- [ ] **Step 11: Commit Task 1**

Run:

```bash
git add grammar.js queries/highlights.scm src/parser.c src/grammar.json src/node-types.json test/corpus docs/test-coverage.md
git commit -m "refactor(grammar): add clearer names and fields"
```

Expected: commit created.

## Task 2: Line Classification Pass

**Files:**
- Modify: `grammar.js`
- Modify: `test/corpus/*.tst`
- Create: `test/corpus/line-classification.tst`
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`
- Modify: `docs/test-coverage.md`

**Goal:** Split `directive_line` and `generic_line` into smaller LSP-friendly line node types.

- [ ] **Step 1: Create line classification corpus**

Create `test/corpus/line-classification.tst`:

```text
====================
assignments
====================
two = 2
counter .set 0
io := $d000

---

(source_file
  (assignment
    name: (identifier)
    operator: (equal)
    value: (anything))
  (directive_line
    (symbol_directive
      name: (identifier)
      directive: (directive_name)
      (directive_arguments
        (number))))
  (assignment
    name: (identifier)
    operator: (assignment_operator)
    value: (address_expression
      (base)
      (number))))

====================
member and labeled directives
====================
.struct Point
    x .byte
    y .byte
.endstruct

item: .tag Value

---

(source_file
  (directive
    name: (directive_name)
    (directive_arguments
      (identifier)))
  (directive_line
    (symbol_directive
      name: (identifier)
      directive: (directive_name)))
  (directive_line
    (symbol_directive
      name: (identifier)
      directive: (directive_name)))
  (directive
    name: (directive_name))
  (directive_line
    (labeled_directive
      label: (label
        name: (identifier))
      directive: (directive_name)
      (directive_arguments
        (identifier)))))

====================
macro call and enum member
====================
pushreg a
tok_none

---

(source_file
  (generic_line
    (macro_call
      name: (identifier)
      (argument_list
        (register))))
  (generic_line
    (enum_member
      name: (identifier))))
```

- [ ] **Step 2: Run the new corpus to verify it fails**

Run:

```bash
tree-sitter test --file-name line-classification.tst
```

Expected: FAIL because `assignment`, `symbol_directive`, `labeled_directive`, `macro_call`, `enum_member`, `assignment_operator`, and `argument_list` do not exist yet.

- [ ] **Step 3: Replace `equ` with `assignment`**

Replace all `$.equ` references in `_item` and `_block_item` with `$.assignment`.

Replace:

```js
    equ: $ => seq(
      field('constant', $.identifier),
      field('equ', $.equal),
      field('value', $.anything)
    ),
```

with:

```js
    assignment: $ => choice(
      seq(
        field('name', $.identifier),
        field('operator', $.equal),
        field('value', $.anything)
      ),
      seq(
        field('name', choice($.identifier, $.local_identifier)),
        field('operator', $.assignment_operator),
        field('value', $.address_expression)
      )
    ),

    assignment_operator: $ => token(':='),
```

- [ ] **Step 4: Split `directive_line`**

Replace:

```js
    directive_line: $ => seq(
      choice($.identifier, $.local_identifier, $.label),
      choice(
        $.directive_name,
        $.operator
      ),
      repeat(
        choice(
          $.directive_name,
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

with:

```js
    directive_line: $ => choice(
      $.symbol_directive,
      $.labeled_directive
    ),

    symbol_directive: $ => seq(
      field('name', choice($.identifier, $.local_identifier)),
      field('directive', $.directive_name),
      optional($.directive_arguments)
    ),

    labeled_directive: $ => seq(
      field('label', $.label),
      field('directive', $.directive_name),
      optional($.directive_arguments)
    ),
```

- [ ] **Step 5: Split `generic_line` and support real macro-call parameter syntax**

Replace:

```js
    generic_line: $ => seq(
      choice($.identifier, $.local_identifier),
      repeat(
        choice(
          $.identifier,
          $.local_identifier,
          $.register,
          $.number,
          $.base,
          $.bracket,
          $.char
        )
      )
    ),
```

with:

```js
    generic_line: $ => choice(
      $.macro_call,
      $.enum_member
    ),

    macro_call: $ => seq(
      field('name', choice($.identifier, $.local_identifier)),
      optional($.argument_list)
    ),

    enum_member: $ => seq(
      field('name', choice($.identifier, $.local_identifier))
    ),

    argument_list: $ => repeat1(choice(
      $._argument,
      $.separator
    )),

    grouped_argument: $ => seq(
      '{',
      repeat(choice(
        $.identifier,
        $.local_identifier,
        $.register,
        $.number,
        $.base,
        $.bracket,
        $.separator,
        $.operator,
        $.char,
        $.string
      )),
      '}'
    ),

    _argument: $ => choice(
      $.grouped_argument,
      $.identifier,
      $.local_identifier,
      $.register,
      $.number,
      $.base,
      $.bracket,
      $.operator,
      $.char,
      $.string
    ),
```

Why: ca65 macro calls may have comma-separated parameters, empty parameters, and brace-grouped parameters that include commas.

- [ ] **Step 6: Update conflicts**

Replace:

```js
  conflicts: $ => [
    [$.operand, $.address_expression],
    [$.directive, $.directive_line],
    [$.generic_line],
  ],
```

with:

```js
  conflicts: $ => [
    [$.operand, $.address_expression],
    [$.directive, $.directive_line],
    [$.macro, $.macro_call],
    [$.macro_call],
  ],
```

If `npm run generate` reports that `[ $.macro_call ]` is unnecessary, remove only that line and rerun generation.

- [ ] **Step 7: Regenerate parser artifacts**

Run:

```bash
npm run generate
```

Expected: exits 0 with no warnings after any CLI-suggested narrow conflict cleanup.

- [ ] **Step 8: Update corpus expectations**

Run:

```bash
npm test
```

Expected: FAIL only due to expected-tree shape changes. Update expected trees:

- `equ` becomes `assignment`.
- `directive_line` wraps `symbol_directive` or `labeled_directive`.
- `generic_line` wraps `macro_call` or `enum_member`.
- Macro calls with comma-separated, empty, or brace-grouped arguments remain clean and do not become `ERROR`.

Do not normalize a macro definition header parameter as `macro_call`; fix `macro` precedence if that appears.

- [ ] **Step 9: Verify Task 2**

Run:

```bash
npm run generate
tree-sitter test --file-name line-classification.tst
npm test
npm run test:highlight
cargo test
rm -rf Cargo.lock target
git status --short
```

Expected:

- `line-classification.tst`: PASS.
- `npm test`: PASS.
- `npm run test:highlight`: PASS with existing parser-directory warning.
- `cargo test`: PASS.
- `git status --short`: only files touched by this task.

- [ ] **Step 10: Update coverage docs**

In `docs/test-coverage.md`, add under `## Reassessment Notes`:

```markdown
- Grammar precision pass 2 complete: identifier-led and generic lines are now split into assignments, symbol directives, labeled directives, macro calls, and enum members, including ca65 macro-call argument separators and brace-grouped arguments.
```

- [ ] **Step 11: Commit Task 2**

Run:

```bash
git add grammar.js src/parser.c src/grammar.json src/node-types.json test/corpus docs/test-coverage.md
git commit -m "refactor(grammar): split line classifications"
```

Expected: commit created.

## Task 3: Operand Structure Pass

**Files:**
- Modify: `grammar.js`
- Modify: `test/corpus/*.tst`
- Create: `test/corpus/operand-structure.tst`
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`
- Modify: `docs/test-coverage.md`

**Goal:** Expose named operand syntax forms useful for LSP diagnostics and hover without pretending to know semantic address size.

- [ ] **Step 1: Create operand structure corpus**

Create `test/corpus/operand-structure.tst`:

```text
====================
immediate and accumulator
====================
    lda #$00
    lda #'A'
    asl a

---

(source_file
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (base)
        (number))))
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (char))))
  (instruction
    mnemonic: (mnemonic)
    operand: (accumulator_operand
      (register))))

====================
absolute and indexed syntax
====================
    lda $1234
    lda $1234,x
    lda table,y
    lda z:$12

---

(source_file
  (instruction
    mnemonic: (mnemonic)
    operand: (address_operand
      (address_expression
        (base)
        (number))))
  (instruction
    mnemonic: (mnemonic)
    operand: (indexed_operand
      address: (address_expression
        (base)
        (number))
      index: (register)))
  (instruction
    mnemonic: (mnemonic)
    operand: (indexed_operand
      address: (address_expression
        (identifier))
      index: (register)))
  (instruction
    mnemonic: (mnemonic)
    operand: (address_operand
      (address_expression
        (address_size_prefix)
        (base)
        (number)))))

====================
indirect modes
====================
    jmp ($1234)
    lda ($20,x)
    lda ($20),y

---

(source_file
  (instruction
    mnemonic: (mnemonic)
    operand: (indirect_operand
      (address_expression
        (base)
        (number))))
  (instruction
    mnemonic: (mnemonic)
    operand: (indexed_indirect_operand
      address: (address_expression
        (base)
        (number))
      index: (register)))
  (instruction
    mnemonic: (mnemonic)
    operand: (indirect_indexed_operand
      address: (address_expression
        (base)
        (number))
      index: (register))))
```

- [ ] **Step 2: Run the new corpus to verify it fails**

Run:

```bash
tree-sitter test --file-name operand-structure.tst
```

Expected: FAIL because named operand forms do not exist yet.

- [ ] **Step 3: Add named operand wrappers**

Replace:

```js
    operand: $ => choice(
      $.address_expression,
      $.immediate,
      $.string,
      $.char,
      $.register
    ),
```

with:

```js
    operand: $ => choice(
      $.immediate_operand,
      $.indexed_indirect_operand,
      $.indirect_indexed_operand,
      $.indirect_operand,
      $.indexed_operand,
      $.address_operand,
      $.accumulator_operand,
      $.literal_operand
    ),

    immediate_operand: $ => $.immediate,

    accumulator_operand: $ => $.register,

    literal_operand: $ => choice(
      $.string,
      $.char
    ),

    indexed_indirect_operand: $ => seq(
      '(',
      field('address', $.address_expression),
      $.separator,
      field('index', $.register),
      ')'
    ),

    indirect_indexed_operand: $ => seq(
      '(',
      field('address', $.address_expression),
      ')',
      $.separator,
      field('index', $.register)
    ),

    indirect_operand: $ => seq(
      '(',
      $.address_expression,
      ')'
    ),

    indexed_operand: $ => seq(
      field('address', $.address_expression),
      $.separator,
      field('index', $.register)
    ),

    address_operand: $ => $.address_expression,
```

- [ ] **Step 4: Add address-size prefix token**

Add near `base`:

```js
    address_size_prefix: $ => seq(
      choice('a', 'f', 'z', 'A', 'F', 'Z'),
      ':'
    ),
```

In `address_expression`, add `$.address_size_prefix` to the repeated choices before `$.identifier`.

- [ ] **Step 5: Remove parentheses from loose `address_expression` if needed**

Run:

```bash
npm run generate
tree-sitter test --file-name operand-structure.tst
```

Expected: likely FAIL until `address_expression` stops consuming parentheses that should belong to named indirect operands. If failure shows parentheses inside `address_expression`, remove `$.bracket` from `address_expression` and rerun.

- [ ] **Step 6: Update corpus expectations**

Run:

```bash
npm test
```

Expected: FAIL only due to expected tree changes around operands. Update expected trees to use:

- `immediate_operand`
- `accumulator_operand`
- `literal_operand`
- `address_operand`
- `indexed_operand`
- `indirect_operand`
- `indexed_indirect_operand`
- `indirect_indexed_operand`

Do not rename `address_operand` to `absolute_operand`; plain address syntax may be zeropage/direct or absolute depending on semantic information.

- [ ] **Step 7: Verify Task 3**

Run:

```bash
npm run generate
tree-sitter test --file-name operand-structure.tst
npm test
npm run test:highlight
cargo test
rm -rf Cargo.lock target
git status --short
```

Expected:

- `operand-structure.tst`: PASS.
- `npm test`: PASS.
- `npm run test:highlight`: PASS with existing parser-directory warning.
- `cargo test`: PASS.
- `git status --short`: only files touched by this task.

- [ ] **Step 8: Update coverage docs**

In `docs/test-coverage.md`, add under `## Reassessment Notes`:

```markdown
- Grammar precision pass 3 complete: operands now expose named immediate, accumulator, literal, address, indexed, indirect, indexed-indirect, and indirect-indexed syntax forms without claiming semantic zeropage/absolute resolution.
```

- [ ] **Step 9: Commit Task 3**

Run:

```bash
git add grammar.js src/parser.c src/grammar.json src/node-types.json test/corpus docs/test-coverage.md
git commit -m "refactor(grammar): split operand forms"
```

Expected: commit created.

## Task 4: Expression Structure Pass

**Files:**
- Modify: `grammar.js`
- Modify: `test/corpus/*.tst`
- Create: `test/corpus/expression-structure.tst`
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`
- Modify: `docs/test-coverage.md`

**Goal:** Replace common expression token soup with structured expression nodes where CA65 syntax and LSP lookup benefit.

- [ ] **Step 1: Create expression structure corpus**

Create `test/corpus/expression-structure.tst`:

```text
====================
unary and binary expressions
====================
    lda #<table
    lda #^bank_table
    lda #(one + two * three)

---

(source_file
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (unary_expression
          operator: (operator)
          argument: (identifier)))))
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (unary_expression
          operator: (operator)
          argument: (identifier)))))
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (parenthesized_expression
          (binary_expression
            left: (identifier)
            operator: (operator)
            right: (binary_expression
              left: (identifier)
              operator: (operator)
              right: (identifier))))))))

====================
scoped identifiers and pseudo functions
====================
    jsr Outer::Reset
    lda #.lobyte(table)

---

(source_file
  (instruction
    mnemonic: (mnemonic)
    operand: (address_operand
      (address_expression
        (scoped_identifier
          scope: (identifier)
          name: (identifier)))))
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (call_expression
          function: (directive_name)
          argument: (identifier))))))
```

- [ ] **Step 2: Run the new corpus to verify it fails**

Run:

```bash
tree-sitter test --file-name expression-structure.tst
```

Expected: FAIL because expression nodes do not exist yet.

- [ ] **Step 3: Add expression rules**

Add after operand rules:

```js
    expression: $ => choice(
      $.parenthesized_expression,
      $.call_expression,
      $.scoped_identifier,
      $.unary_expression,
      $.binary_expression,
      $.identifier,
      $.local_identifier,
      $.number,
      $.char
    ),

    parenthesized_expression: $ => seq(
      '(',
      $.expression,
      ')'
    ),

    call_expression: $ => seq(
      field('function', $.directive_name),
      '(',
      field('argument', $.expression),
      ')'
    ),

    scoped_identifier: $ => seq(
      field('scope', choice($.identifier, $.local_identifier)),
      '::',
      field('name', choice($.identifier, $.local_identifier))
    ),

    unary_expression: $ => prec(5, seq(
      field('operator', $.operator),
      field('argument', $.expression)
    )),

    binary_expression: $ => choice(
      ...[
        ['*', 4],
        ['/', 4],
        ['+', 3],
        ['-', 3],
        ['&', 2],
        ['^', 1],
        ['|', 0],
      ].map(([operator, precedence]) =>
        prec.left(precedence, seq(
          field('left', $.expression),
          field('operator', operator),
          field('right', $.expression)
        ))
      )
    ),
```

- [ ] **Step 4: Use expressions in `immediate`**

Replace `immediate`:

```js
    immediate: $ => seq(
      $.immediate_marker,
      repeat1(
        choice(
          $.base,
          $.number,
          $.identifier,
          $.local_identifier,
          $.char,
          $.operator,
          $.separator,
          $.register,
          $.bracket
        )
      )
    ),
```

with:

```js
    immediate: $ => seq(
      $.immediate_marker,
      choice(
        seq($.base, $.number),
        $.expression
      )
    ),
```

- [ ] **Step 5: Use expressions in `address_expression` while preserving fallback**

Replace `address_expression` with:

```js
    address_expression: $ => choice(
      $.unnamed_label_ref,
      seq(optional($.address_size_prefix), $.base, $.number),
      seq(optional($.address_size_prefix), $.scoped_identifier),
      seq(optional($.address_size_prefix), $.expression),
      prec.left(repeat1(
        choice(
          $.address_size_prefix,
          $.base,
          $.number,
          $.identifier,
          $.local_identifier,
          $.char,
          $.operator,
          $.separator,
          $.register
        )
      ))
    ),
```

Keep the loose fallback during this pass so existing corpus coverage does not regress while structured nodes are introduced.

- [ ] **Step 6: Regenerate and resolve expression conflicts**

Run:

```bash
npm run generate
```

Expected: possible conflicts around `expression`, `unary_expression`, and `binary_expression`. Prefer precedence changes over broad conflicts. If Tree-sitter asks for a specific conflict between `expression` and `address_expression`, add:

```js
    [$.expression, $.address_expression],
```

only if narrowing rules would remove valid CA65 syntax.

- [ ] **Step 7: Update corpus expectations**

Run:

```bash
tree-sitter test --file-name expression-structure.tst
npm test
```

Expected: FAIL only due to expression tree shape changes. Update expected trees for clean structured expression output. Do not normalize `ERROR` or `MISSING` nodes.

- [ ] **Step 8: Verify Task 4**

Run:

```bash
npm run generate
tree-sitter test --file-name expression-structure.tst
npm test
npm run test:highlight
cargo test
rm -rf Cargo.lock target
git status --short
```

Expected:

- `expression-structure.tst`: PASS.
- `npm test`: PASS.
- `npm run test:highlight`: PASS with existing parser-directory warning.
- `cargo test`: PASS.
- `git status --short`: only files touched by this task.

- [ ] **Step 9: Update coverage docs**

In `docs/test-coverage.md`, add under `## Reassessment Notes`:

```markdown
- Grammar precision pass 4 complete: common CA65 expressions now expose unary, binary, parenthesized, scoped identifier, and pseudo-function call nodes while preserving loose fallback coverage.
```

- [ ] **Step 10: Commit Task 4**

Run:

```bash
git add grammar.js src/parser.c src/grammar.json src/node-types.json test/corpus docs/test-coverage.md
git commit -m "refactor(grammar): add expression structure"
```

Expected: commit created.

## Task 5: Structured Blocks Pass

**Files:**
- Modify: `grammar.js`
- Modify: `test/corpus/*.tst`
- Create: `test/corpus/block-structure.tst`
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`
- Modify: `docs/test-coverage.md`

**Goal:** Add structured block nodes for common CA65 block constructs so the LSP can index scopes, macros, structs, enums, repeat blocks, and conditionals without scanning generic directive lines.

- [ ] **Step 1: Create block structure corpus**

Create `test/corpus/block-structure.tst`:

```text
====================
scope block
====================
.scope Outer
label:
    rts
.endscope

---

(source_file
  (scope_definition
    start: (scope_start
      name: (identifier))
    (label
      name: (identifier))
    (instruction
      mnemonic: (mnemonic))
    end: (scope_end)))

====================
aggregate blocks
====================
.struct Point
    x .byte
    y .byte
.endstruct

.enum Token
    tok_none
    tok_ident
.endenum

---

(source_file
  (struct_definition
    start: (struct_start
      name: (identifier))
    (directive_line
      (symbol_directive
        name: (identifier)
        directive: (directive_name)))
    (directive_line
      (symbol_directive
        name: (identifier)
        directive: (directive_name)))
    end: (struct_end))
  (enum_definition
    start: (enum_start
      name: (identifier))
    (generic_line
      (enum_member
        name: (identifier)))
    (generic_line
      (enum_member
        name: (identifier)))
    end: (enum_end)))

====================
repeat and conditional blocks
====================
.repeat 2, i
    .byte i
.endrepeat

.if .defined(DEBUG)
    lda #1
.else
    lda #0
.endif

---

(source_file
  (repeat_block
    start: (repeat_start
      (directive_arguments
        (number)
        (separator)
        (identifier)))
    (directive
      name: (directive_name)
      (directive_arguments
        (identifier)))
    end: (repeat_end))
  (conditional_block
    start: (if_start
      (directive_arguments
        (directive_name)
        (bracket)
        (identifier)
        (bracket)))
    (instruction
      mnemonic: (mnemonic)
      operand: (immediate_operand
        (immediate
          (immediate_marker)
          (number))))
    branch: (else_branch)
    (instruction
      mnemonic: (mnemonic)
      operand: (immediate_operand
        (immediate
          (immediate_marker)
          (number))))
    end: (if_end)))
```

- [ ] **Step 2: Run the new corpus to verify it fails**

Run:

```bash
tree-sitter test --file-name block-structure.tst
```

Expected: FAIL because structured block nodes do not exist yet.

- [ ] **Step 3: Add block start/end rules**

Add near `procstart`:

```js
    scope_start: $ => seq(token(choice('.scope', '.SCOPE')), field('name', $.identifier)),
    scope_end: $ => token(choice('.endscope', '.ENDSCOPE')),

    struct_start: $ => seq(token(choice('.struct', '.STRUCT')), optional(field('name', $.identifier))),
    struct_end: $ => token(choice('.endstruct', '.ENDSTRUCT')),

    union_start: $ => seq(token(choice('.union', '.UNION')), optional(field('name', $.identifier))),
    union_end: $ => token(choice('.endunion', '.ENDUNION')),

    enum_start: $ => seq(token(choice('.enum', '.ENUM')), optional(field('name', $.identifier))),
    enum_end: $ => token(choice('.endenum', '.ENDENUM')),

    repeat_start: $ => seq(token(choice('.repeat', '.REPEAT')), optional($.directive_arguments)),
    repeat_end: $ => token(choice('.endrep', '.endrepeat', '.ENDREP', '.ENDREPEAT')),

    if_start: $ => seq(token(choice('.if', '.IF', '.ifdef', '.IFDEF', '.ifndef', '.IFNDEF', '.ifblank', '.IFBLANK', '.ifnblank', '.IFNBLANK')), optional($.directive_arguments)),
    elseif_branch: $ => seq(token(choice('.elseif', '.ELSEIF')), optional($.directive_arguments)),
    else_branch: $ => token(choice('.else', '.ELSE')),
    if_end: $ => token(choice('.endif', '.ENDIF')),
```

- [ ] **Step 4: Add structured block rules**

Add after `macro`:

```js
    scope_definition: $ => seq(
      field('start', $.scope_start),
      repeat(choice($._newline, seq($._block_item, $._newline))),
      field('end', $.scope_end)
    ),

    struct_definition: $ => seq(
      field('start', $.struct_start),
      repeat(choice($._newline, seq($._block_item, $._newline))),
      field('end', $.struct_end)
    ),

    union_definition: $ => seq(
      field('start', $.union_start),
      repeat(choice($._newline, seq($._block_item, $._newline))),
      field('end', $.union_end)
    ),

    enum_definition: $ => seq(
      field('start', $.enum_start),
      repeat(choice($._newline, seq($._block_item, $._newline))),
      field('end', $.enum_end)
    ),

    repeat_block: $ => seq(
      field('start', $.repeat_start),
      repeat(choice($._newline, seq($._block_item, $._newline))),
      field('end', $.repeat_end)
    ),

    conditional_block: $ => seq(
      field('start', $.if_start),
      repeat(choice($._newline, seq($._block_item, $._newline))),
      repeat(seq(
        field('branch', choice($.elseif_branch, $.else_branch)),
        repeat(choice($._newline, seq($._block_item, $._newline)))
      )),
      field('end', $.if_end)
    ),
```

- [ ] **Step 5: Include structured blocks before generic directives**

In `_preproc`, replace:

```js
    _preproc: $ => choice(
      $.proc,
      $.macro,
      $.directive
    ),
```

with:

```js
    _preproc: $ => choice(
      $.proc,
      $.macro,
      $.scope_definition,
      $.struct_definition,
      $.union_definition,
      $.enum_definition,
      $.repeat_block,
      $.conditional_block,
      $.directive
    ),
```

Order matters: structured blocks must appear before generic `directive`.

- [ ] **Step 6: Regenerate and resolve block conflicts**

Run:

```bash
npm run generate
```

Expected: possible conflicts between generic `directive` and block start/end rules. If needed, add only the narrow conflicts named by Tree-sitter. If a conflict entry is later reported unnecessary, remove it.

- [ ] **Step 7: Update corpus expectations**

Run:

```bash
tree-sitter test --file-name block-structure.tst
npm test
```

Expected: FAIL only due to expected tree changes around blocks. Update expected trees so:

- `.scope`/`.endscope` lines become `scope_definition`.
- `.struct`/`.endstruct` lines become `struct_definition`.
- `.union`/`.endunion` lines become `union_definition`.
- `.enum`/`.endenum` lines become `enum_definition`.
- `.repeat`/`.endrepeat` lines become `repeat_block`.
- `.if`/`.elseif`/`.else`/`.endif` lines become `conditional_block`.

If nested blocks produce `ERROR` or `MISSING`, fix `_block_item` ordering before updating expectations.

- [ ] **Step 8: Verify Task 5**

Run:

```bash
npm run generate
tree-sitter test --file-name block-structure.tst
npm test
npm run test:highlight
cargo test
rm -rf Cargo.lock target
git status --short
```

Expected:

- `block-structure.tst`: PASS.
- `npm test`: PASS.
- `npm run test:highlight`: PASS with existing parser-directory warning.
- `cargo test`: PASS.
- `git status --short`: only files touched by this task.

- [ ] **Step 9: Update coverage docs**

In `docs/test-coverage.md`, add under `## Reassessment Notes`:

```markdown
- Grammar precision pass 5 complete: common CA65 block constructs now expose structured nodes for scopes, structs, unions, enums, repeat blocks, and conditionals.
```

- [ ] **Step 10: Commit Task 5**

Run:

```bash
git add grammar.js src/parser.c src/grammar.json src/node-types.json test/corpus docs/test-coverage.md
git commit -m "refactor(grammar): add structured block nodes"
```

Expected: commit created.

## Final Validation

**Files:**
- Modify: none unless generated artifacts drift

- [ ] **Step 1: Run final generation check**

Run:

```bash
npm run generate
git status --short
```

Expected:

- `npm run generate`: exits 0 with no warnings.
- `git status --short`: no generated artifact changes beyond committed work.

- [ ] **Step 2: Run final full suite**

Run:

```bash
npm test
npm run test:highlight
cargo test
rm -rf Cargo.lock target
git status --short
```

Expected:

- `npm test`: exits 0.
- `npm run test:highlight`: exits 0 with existing parser-directory warning.
- `cargo test`: exits 0 with 2 unit tests and 1 doctest.
- `git status --short`: no output.

- [ ] **Step 3: Review public node names**

Run:

```bash
rg -n "preprocgen|preproccmd|mem_address|valuetag|\\bvalue\\b|\\bequ\\b" grammar.js queries test src/node-types.json
```

Expected:

- No `preprocgen`, `preproccmd`, `mem_address`, or `valuetag` matches.
- No `equ` node references.
- `value` may appear only as a field name inside `assignment value:` or prose in comments. If `value` appears as a node type, rename it before finishing.

## Self-Review

- Spec coverage: This plan covers the five requested passes: naming/fields, line classification, operand structure, expression structure, and structured blocks.
- Corrections applied: The plan does not introduce `.proc Name: near`; macro-call arguments account for comma-separated, empty, and brace-grouped parameters; structured-block expected trees use explicit start/end nodes instead of pretending every start/end is a generic `directive`; operand naming avoids claiming semantic zeropage vs absolute resolution.
- Placeholder scan: No `TBD`, `TODO`, "implement later", vague test instructions, or empty edge-case instructions remain.
- Type consistency: Node names introduced in tests match grammar snippets: `directive`, `directive_name`, `directive_arguments`, `instruction`, `immediate`, `address_expression`, `assignment`, `symbol_directive`, `labeled_directive`, `macro_call`, `enum_member`, named operand nodes, expression nodes, and block nodes.
- Scope discipline: The plan deliberately does not implement semantic validation such as opcode/addressing-mode legality, symbol resolution, macro expansion, include resolution, or linker configuration.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-18-ca65-grammar-precision-roadmap.md`. Two execution options:

**1. Subagent-Driven (recommended)** - dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
