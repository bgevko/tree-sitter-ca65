# CA65 Test Coverage Pass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add broad parser and highlight tests for CA65 syntax from the official ca65 Users Guide, then run tests and record what passes or fails without changing grammar behavior.

**Architecture:** This is a test-only pass. Add focused Tree-sitter corpus files by language area, add one larger highlight fixture, and add a coverage report that maps each new fixture to ca65 manual sections. If tests fail, do not edit `grammar.js`, generated parser artifacts, Rust bindings, or queries beyond the explicitly planned highlight fixture content; record failures for reassessment.

**Tech Stack:** Tree-sitter corpus tests under `test/corpus`, Tree-sitter highlight assertions under `test/highlight`, npm scripts, official ca65 Users Guide at `https://cc65.github.io/doc/ca65.html`.

---

## Reference Scope

Use these ca65 Users Guide sections as the source of truth:

- Input format and line shape: `https://cc65.github.io/doc/ca65.html#ss4.1`
- Number format: `https://cc65.github.io/doc/ca65.html#ss4.2`
- Expressions and operators: `https://cc65.github.io/doc/ca65.html#ss5.5`
- Symbols and labels, including cheap locals and unnamed labels: `https://cc65.github.io/doc/ca65.html#s6`
- Scopes and procedures: `https://cc65.github.io/doc/ca65.html#s7`
- Address sizes and address-size prefixes: `https://cc65.github.io/doc/ca65.html#s8`
- Pseudo variables and functions: `https://cc65.github.io/doc/ca65.html#s9` and `https://cc65.github.io/doc/ca65.html#s10`
- Control commands/directives: `https://cc65.github.io/doc/ca65.html#s11`
- Macros: `https://cc65.github.io/doc/ca65.html#s12`
- Structs and unions: `https://cc65.github.io/doc/ca65.html#s15`

Out of scope for this pass:

- Fixing grammar failures.
- Regenerating parser artifacts.
- Editing `grammar.js`.
- Editing `queries/highlights.scm`.
- Changing Rust bindings.
- Adding semantic validation beyond parse/highlight shape.

## File Structure

- Create `test/corpus/addressing-modes.tst`: 6502 addressing syntax coverage.
- Create `test/corpus/directives-data.tst`: common data/segment/include/import/export directives.
- Create `test/corpus/expressions.tst`: numeric formats, unary/binary operators, pseudo-functions, and pseudo-variables.
- Create `test/corpus/symbols-scopes.tst`: labels, cheap locals, unnamed labels, scopes, procs, explicit scope access.
- Create `test/corpus/macros-control.tst`: macros and conditional/repeat control commands.
- Create `test/corpus/structs-unions.tst`: structs, unions, enums, tags, and `.org` inside aggregates.
- Create `test/corpus/cpu-modes.tst`: processor selection directives and representative mnemonics.
- Create `test/highlight/coverage.asm`: larger highlight fixture for directives, labels, literals, operators, comments, registers, and mnemonics.
- Create `docs/test-coverage.md`: coverage matrix plus observed test results.

## Task 1: Add Addressing Mode Corpus

**Files:**
- Create: `test/corpus/addressing-modes.tst`
- Modify: `docs/test-coverage.md`

- [ ] **Step 1: Create `test/corpus/addressing-modes.tst`**

Create `test/corpus/addressing-modes.tst`:

```text
====================
implied and accumulator
====================
    clc
    rts
    asl a

---

(source_file
  (mnemonic)
  (mnemonic)
  (mnemonic)
  (operand
    (register)))

====================
immediate number forms
====================
    lda #10
    lda #$0a
    lda #%00001010
    lda #'A'

---

(source_file
  (mnemonic)
  (operand
    (value
      (valuetag)
      (number)))
  (mnemonic)
  (operand
    (value
      (valuetag)
      (base)
      (number)))
  (mnemonic)
  (operand
    (value
      (valuetag)
      (base)
      (number)))
  (mnemonic)
  (operand
    (value
      (valuetag)
      (char))))

====================
absolute and indexed
====================
    lda $1234
    lda $1234,x
    lda $1234,y
    sta table,x
    sta table,y

---

(source_file
  (mnemonic)
  (operand
    (mem_address
      (base)
      (number)))
  (mnemonic)
  (operand
    (mem_address
      (base)
      (number))
    (separator)
    (register))
  (mnemonic)
  (operand
    (mem_address
      (base)
      (number))
    (separator)
    (register))
  (mnemonic)
  (operand
    (mem_address
      (identifier))
    (separator)
    (register))
  (mnemonic)
  (operand
    (mem_address
      (identifier))
    (separator)
    (register)))

====================
indirect modes
====================
    jmp ($1234)
    lda ($20,x)
    lda ($20),y

---

(source_file
  (mnemonic)
  (operand
    (mem_address
      (bracket)
      (base)
      (number)
      (bracket)))
  (mnemonic)
  (operand
    (mem_address
      (bracket)
      (base)
      (number)
      (separator)
      (register)
      (bracket)))
  (mnemonic)
  (operand
    (mem_address
      (bracket)
      (base)
      (number)
      (bracket))
    (separator)
    (register)))

====================
address size prefixes
====================
    lda a:$00
    lda z:$1234
    jsr far_func

---

(source_file
  (mnemonic)
  (operand
    (mem_address
      (identifier)
      (operator)
      (base)
      (number)))
  (mnemonic)
  (operand
    (mem_address
      (identifier)
      (operator)
      (base)
      (number)))
  (mnemonic)
  (operand
    (mem_address
      (identifier))))
```

- [ ] **Step 2: Run addressing corpus only**

Run:

```bash
tree-sitter test --file-name addressing-modes.tst
```

Expected: PASS if all addressing mode syntax is currently parsed as intended, otherwise FAIL. Do not edit grammar or expected trees in this pass.

- [ ] **Step 3: Append result to `docs/test-coverage.md`**

Create or append to `docs/test-coverage.md`:

```markdown
# CA65 Test Coverage

## Sources

- ca65 Users Guide: https://cc65.github.io/doc/ca65.html
- Input syntax: https://cc65.github.io/doc/ca65.html#ss4.1
- Expressions/operators: https://cc65.github.io/doc/ca65.html#ss5.5
- Symbols/labels: https://cc65.github.io/doc/ca65.html#s6
- Scopes: https://cc65.github.io/doc/ca65.html#s7
- Control commands: https://cc65.github.io/doc/ca65.html#s11
- Macros: https://cc65.github.io/doc/ca65.html#s12
- Structs/unions: https://cc65.github.io/doc/ca65.html#s15

## Results

| Area | File | Result | Notes |
| --- | --- | --- | --- |
| Addressing modes | `test/corpus/addressing-modes.tst` | RECORD_RESULT | Covers implied, accumulator, immediate, absolute/indexed, indirect, and address-size-prefix syntax. |
```

Replace `RECORD_RESULT` with `PASS` or `FAIL`.

- [ ] **Step 4: Commit if desired**

If the team wants test additions committed even when failing, run:

```bash
git add test/corpus/addressing-modes.tst docs/test-coverage.md
git commit -m "test: add addressing mode coverage"
```

Expected: commit created. If failures should be reviewed before commit, skip commit and leave changes unstaged.

## Task 2: Add Directive and Data Corpus

**Files:**
- Create: `test/corpus/directives-data.tst`
- Modify: `docs/test-coverage.md`

- [ ] **Step 1: Create `test/corpus/directives-data.tst`**

Create `test/corpus/directives-data.tst`:

```text
====================
segments and storage
====================
    .segment "CODE"
    .code
    .rodata
    .data
    .bss
    .zeropage
    .res 16, $00

---

(source_file
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd) (number) (separator) (base) (number)))

====================
data emission directives
====================
    .byte "Hello", $0d, $00
    .byt "world"
    .word $1234, label
    .addr reset
    .faraddr far_proc
    .dword $12345678
    .asciiz "done"
    .literal "raw"

---

(source_file
  (preprocgen (preproccmd) (string) (separator) (base) (number) (separator) (base) (number))
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd) (base) (number) (separator) (identifier))
  (preprocgen (preproccmd) (identifier))
  (preprocgen (preproccmd) (identifier))
  (preprocgen (preproccmd) (base) (number))
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd) (string)))

====================
linkage and includes
====================
    .include "hardware.inc"
    .incbin "tiles.chr"
    .import puts, irq_handler
    .export reset
    .global main
    .forceimport initlib

---

(source_file
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd) (identifier) (separator) (identifier))
  (preprocgen (preproccmd) (identifier))
  (preprocgen (preproccmd) (identifier))
  (preprocgen (preproccmd) (identifier)))
```

- [ ] **Step 2: Run directive/data corpus only**

Run:

```bash
tree-sitter test --file-name directives-data.tst
```

Expected: PASS or FAIL. Do not fix grammar.

- [ ] **Step 3: Record result**

Append to `docs/test-coverage.md`:

```markdown
| Directives and data | `test/corpus/directives-data.tst` | RECORD_RESULT | Covers segment switches, storage allocation, data emission, includes, imports, exports, and globals. |
```

Replace `RECORD_RESULT` with `PASS` or `FAIL`.

- [ ] **Step 4: Commit if desired**

```bash
git add test/corpus/directives-data.tst docs/test-coverage.md
git commit -m "test: add directive and data coverage"
```

## Task 3: Add Expression Corpus

**Files:**
- Create: `test/corpus/expressions.tst`
- Modify: `docs/test-coverage.md`

- [ ] **Step 1: Create `test/corpus/expressions.tst`**

Create `test/corpus/expressions.tst`:

```text
====================
numeric formats
====================
    lda #10
    lda #$0a
    lda #%1010
    lda #'A'

---

(source_file
  (mnemonic) (operand (value (valuetag) (number)))
  (mnemonic) (operand (value (valuetag) (base) (number)))
  (mnemonic) (operand (value (valuetag) (base) (number)))
  (mnemonic) (operand (value (valuetag) (char))))

====================
unary byte operators
====================
    lda #<label
    lda #>label
    lda #^label

---

(source_file
  (mnemonic) (operand (value (valuetag) (operator) (identifier)))
  (mnemonic) (operand (value (valuetag) (operator) (identifier)))
  (mnemonic) (operand (value (valuetag) (operator) (identifier))))

====================
binary operators
====================
    value = base + 1
    mask = value & $0f
    shifted = value << 2
    compare = value >= 10
    logic = .not .defined(value) .or value = 0

---

(source_file
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything)))

====================
pseudo variables and functions
====================
    pc_value = *
    cpu_name = .CPU
    version = .VERSION
    addr_size = .addrsize(label)
    is_known = .defined(label)
    length = .strlen("text")

---

(source_file
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything)))
```

- [ ] **Step 2: Run expression corpus only**

Run:

```bash
tree-sitter test --file-name expressions.tst
```

Expected: PASS or FAIL. Do not fix grammar.

- [ ] **Step 3: Record result**

Append to `docs/test-coverage.md`:

```markdown
| Expressions | `test/corpus/expressions.tst` | RECORD_RESULT | Covers number forms, unary byte/bank operators, binary operators, pseudo variables, and pseudo functions. |
```

Replace `RECORD_RESULT` with `PASS` or `FAIL`.

- [ ] **Step 4: Commit if desired**

```bash
git add test/corpus/expressions.tst docs/test-coverage.md
git commit -m "test: add expression coverage"
```

## Task 4: Add Symbols, Labels, and Scope Corpus

**Files:**
- Create: `test/corpus/symbols-scopes.tst`
- Modify: `docs/test-coverage.md`

- [ ] **Step 1: Create `test/corpus/symbols-scopes.tst`**

Create `test/corpus/symbols-scopes.tst`:

```text
====================
cheap local and unnamed labels
====================
global:
@loop:
    bne @loop
:
    beq :+
    bne :-
:
    rts

---

(source_file
  (label (identifier))
  (label (local_identifier))
  (mnemonic) (operand (mem_address (local_identifier)))
  (label (unnamed_label))
  (mnemonic) (operand (mem_address (unnamed_label_ref)))
  (mnemonic) (operand (mem_address (unnamed_label_ref)))
  (label (unnamed_label))
  (mnemonic))

====================
scope and proc blocks
====================
.scope Outer
    label:
        lda #$00
.endscope

.proc Reset: near
    jsr Outer::label
.endproc

---

(source_file
  (preprocgen (preproccmd) (identifier))
  (label (identifier))
  (mnemonic) (operand (value (valuetag) (base) (number)))
  (preprocgen (preproccmd))
  (proc
    (procstart)
    (identifier)
    (mnemonic)
    (operand
      (mem_address
        (identifier)
        (operator)
        (operator)
        (identifier)))
    (procend)))

====================
symbol assignments
====================
two = 2
four = two * two
counter .set 0
io := $d000

---

(source_file
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (preprocgen (identifier) (preproccmd) (number))
  (preprocgen (identifier) (operator) (equal) (base) (number)))
```

- [ ] **Step 2: Run symbols/scopes corpus only**

Run:

```bash
tree-sitter test --file-name symbols-scopes.tst
```

Expected: PASS or FAIL. Do not fix grammar.

- [ ] **Step 3: Record result**

Append to `docs/test-coverage.md`:

```markdown
| Symbols and scopes | `test/corpus/symbols-scopes.tst` | RECORD_RESULT | Covers standard labels, cheap locals, unnamed labels, `.scope`, `.proc`, explicit scope access, `=`, `.set`, and `:=`. |
```

Replace `RECORD_RESULT` with `PASS` or `FAIL`.

- [ ] **Step 4: Commit if desired**

```bash
git add test/corpus/symbols-scopes.tst docs/test-coverage.md
git commit -m "test: add symbol and scope coverage"
```

## Task 5: Add Macro and Control-Flow Corpus

**Files:**
- Create: `test/corpus/macros-control.tst`
- Modify: `docs/test-coverage.md`

- [ ] **Step 1: Create `test/corpus/macros-control.tst`**

Create `test/corpus/macros-control.tst`:

```text
====================
macro with locals and parameters
====================
.macro pushreg reg
    .local done
    pha
done:
    pla
.endmacro

    pushreg a

---

(source_file
  (macro
    (macrostart)
    (identifier)
    (identifier)
    (preprocgen (preproccmd) (identifier))
    (mnemonic)
    (label (identifier))
    (mnemonic)
    (macroend))
  (preprocgen (identifier) (identifier)))

====================
conditional assembly
====================
.if .defined(DEBUG)
    lda #1
.elseif .defined(RELEASE)
    lda #2
.else
    lda #0
.endif

---

(source_file
  (preprocgen (preproccmd) (preproccmd) (bracket) (identifier) (bracket))
  (mnemonic) (operand (value (valuetag) (number)))
  (preprocgen (preproccmd) (preproccmd) (bracket) (identifier) (bracket))
  (mnemonic) (operand (value (valuetag) (number)))
  (preprocgen (preproccmd))
  (mnemonic) (operand (value (valuetag) (number)))
  (preprocgen (preproccmd)))

====================
repeat control
====================
.repeat 4, i
    .byte i
.endrepeat

---

(source_file
  (preprocgen (preproccmd) (number) (separator) (identifier))
  (preprocgen (preproccmd) (identifier))
  (preprocgen (preproccmd)))
```

- [ ] **Step 2: Run macro/control corpus only**

Run:

```bash
tree-sitter test --file-name macros-control.tst
```

Expected: PASS or FAIL. Do not fix grammar.

- [ ] **Step 3: Record result**

Append to `docs/test-coverage.md`:

```markdown
| Macros and control | `test/corpus/macros-control.tst` | RECORD_RESULT | Covers macro parameters, `.local`, macro invocation, conditional assembly, and `.repeat`. |
```

Replace `RECORD_RESULT` with `PASS` or `FAIL`.

- [ ] **Step 4: Commit if desired**

```bash
git add test/corpus/macros-control.tst docs/test-coverage.md
git commit -m "test: add macro and control coverage"
```

## Task 6: Add Struct, Union, and Enum Corpus

**Files:**
- Create: `test/corpus/structs-unions.tst`
- Modify: `docs/test-coverage.md`

- [ ] **Step 1: Create `test/corpus/structs-unions.tst`**

Create `test/corpus/structs-unions.tst`:

```text
====================
struct definition
====================
.struct Point
    x .byte
    y .byte
.endstruct

---

(source_file
  (preprocgen (preproccmd) (identifier))
  (preprocgen (identifier) (preproccmd))
  (preprocgen (identifier) (preproccmd))
  (preprocgen (preproccmd)))

====================
union and tag usage
====================
.union Value
    b .byte
    w .word
.endunion

item: .tag Value

---

(source_file
  (preprocgen (preproccmd) (identifier))
  (preprocgen (identifier) (preproccmd))
  (preprocgen (identifier) (preproccmd))
  (preprocgen (preproccmd))
  (label (identifier))
  (preprocgen (preproccmd) (identifier)))

====================
enum values
====================
.enum Token
    tok_none
    tok_ident
.endenum

---

(source_file
  (preprocgen (preproccmd) (identifier))
  (preprocgen (identifier))
  (preprocgen (identifier))
  (preprocgen (preproccmd)))
```

- [ ] **Step 2: Run struct/union corpus only**

Run:

```bash
tree-sitter test --file-name structs-unions.tst
```

Expected: PASS or FAIL. Do not fix grammar.

- [ ] **Step 3: Record result**

Append to `docs/test-coverage.md`:

```markdown
| Structs, unions, enums | `test/corpus/structs-unions.tst` | RECORD_RESULT | Covers `.struct`, `.union`, `.enum`, `.tag`, and member declarations. |
```

Replace `RECORD_RESULT` with `PASS` or `FAIL`.

- [ ] **Step 4: Commit if desired**

```bash
git add test/corpus/structs-unions.tst docs/test-coverage.md
git commit -m "test: add aggregate type coverage"
```

## Task 7: Add CPU Mode Corpus

**Files:**
- Create: `test/corpus/cpu-modes.tst`
- Modify: `docs/test-coverage.md`

- [ ] **Step 1: Create `test/corpus/cpu-modes.tst`**

Create `test/corpus/cpu-modes.tst`:

```text
====================
processor mode directives
====================
    .p02
    .p02x
    .pc02
    .p816
    .setcpu "6502"
    .setcpu "65816"

---

(source_file
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd) (string)))

====================
extended mnemonics
====================
    bra target
    stz $00
    wai
    stp
    jsl far_target
    rtl

---

(source_file
  (mnemonic) (operand (mem_address (identifier)))
  (mnemonic) (operand (mem_address (base) (number)))
  (mnemonic)
  (mnemonic)
  (mnemonic) (operand (mem_address (identifier)))
  (mnemonic))
```

- [ ] **Step 2: Run CPU mode corpus only**

Run:

```bash
tree-sitter test --file-name cpu-modes.tst
```

Expected: PASS or FAIL. Do not fix grammar.

- [ ] **Step 3: Record result**

Append to `docs/test-coverage.md`:

```markdown
| CPU modes | `test/corpus/cpu-modes.tst` | RECORD_RESULT | Covers processor mode directives and representative 65C02/65816 mnemonics. |
```

Replace `RECORD_RESULT` with `PASS` or `FAIL`.

- [ ] **Step 4: Commit if desired**

```bash
git add test/corpus/cpu-modes.tst docs/test-coverage.md
git commit -m "test: add cpu mode coverage"
```

## Task 8: Add Broad Highlight Fixture

**Files:**
- Create: `test/highlight/coverage.asm`
- Modify: `docs/test-coverage.md`

- [ ] **Step 1: Create `test/highlight/coverage.asm`**

Create `test/highlight/coverage.asm`:

```asm
.segment "CODE"
; <- keyword
;        ^^^^^^ string

reset:
; <- tag
@loop:
; <- tag
    lda #<table
;   ^^^ function.builtin
;       ^ punctuation.delimiter
;        ^ operator
;         ^^^^^ variable
    sta $0200,x
;   ^^^ function.builtin
;       ^ type
;        ^^^^ number
;            ^ punctuation.delimiter
;             ^ constant.builtin
    bne @loop
;   ^^^ function.builtin
;       ^^^^^ variable

.byte "A", 'B', $00
; <- keyword
;     ^^^ string
;          ^^^ string
;               ^ type
;                ^^ number
```

- [ ] **Step 2: Run highlight fixture**

Run:

```bash
tree-sitter highlight --check test/highlight/coverage.asm
```

Expected: PASS or FAIL. Do not edit `queries/highlights.scm` in this pass.

- [ ] **Step 3: Run npm highlight script**

Run:

```bash
npm run test:highlight
```

Expected: PASS if both highlight fixtures pass, otherwise FAIL.

- [ ] **Step 4: Record result**

Append to `docs/test-coverage.md`:

```markdown
| Highlight coverage | `test/highlight/coverage.asm` | RECORD_RESULT | Covers directives, strings, chars, labels, cheap locals, mnemonics, immediates, operators, base prefixes, separators, registers, and comments. |
```

Replace `RECORD_RESULT` with `PASS` or `FAIL`.

- [ ] **Step 5: Commit if desired**

```bash
git add test/highlight/coverage.asm docs/test-coverage.md
git commit -m "test: add broad highlight coverage"
```

## Task 9: Run Full Test Pass and Record Summary

**Files:**
- Modify: `docs/test-coverage.md`

- [ ] **Step 1: Run full parser and highlight suite**

Run:

```bash
npm test
```

Expected: PASS or FAIL. Do not fix grammar or queries.

- [ ] **Step 2: Run explicit highlight suite**

Run:

```bash
npm run test:highlight
```

Expected: PASS or FAIL. Do not fix queries.

- [ ] **Step 3: Run Rust smoke tests**

Run:

```bash
cargo test
```

Expected: existing Rust tests pass. If they fail because test-only files affected generated artifacts, stop and reassess because this plan should not touch Rust behavior.

- [ ] **Step 4: Append final summary**

Append to `docs/test-coverage.md`:

```markdown
## Final Test Run

| Command | Result | Notes |
| --- | --- | --- |
| `npm test` | RECORD_RESULT | Parser corpus plus highlight checks. |
| `npm run test:highlight` | RECORD_RESULT | Explicit highlight check. |
| `cargo test` | RECORD_RESULT | Rust binding smoke tests. |

## Reassessment Notes

- If all tests pass, grammar coverage is substantially broader and the project is likely close to parser-smoke-test complete.
- If any tests fail, keep the failures as evidence and open a separate grammar-fix plan. Do not fix failures in this test-only pass.
```

Replace each `RECORD_RESULT` with `PASS` or `FAIL`.

- [ ] **Step 5: Commit final coverage summary if desired**

```bash
git add docs/test-coverage.md
git commit -m "docs: record ca65 test coverage results"
```

## Self-Review

- Spec coverage: Plan references the official ca65 Users Guide, adds parser tests across addressing modes, directives, expressions, symbols/scopes, macros/control flow, aggregate declarations, CPU modes, and highlight coverage.
- Test-only constraint: Every task says not to edit grammar, generated parser artifacts, Rust bindings, or query implementation when failures appear. The only query-related work is highlight fixture creation, not query changes.
- Placeholder scan: No `TBD`, `TODO`, "similar to", or vague "write tests" steps remain. Each new test file has explicit content.
- Type consistency: All paths use existing project layout: `test/corpus/*.tst`, `test/highlight/*.asm`, and `docs/test-coverage.md`.
