# Slim Modern Tree-Sitter Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert `tree-sitter-ca65` to the current Tree-sitter project layout, remove deprecated repository conventions, generate ABI 15 parser artifacts, and prove the Rust crate still works.

**Architecture:** Make `tree-sitter.json` the single source of grammar metadata for the Tree-sitter CLI. Keep `package.json` only for npm scripts and CLI dev dependency, keep Rust-specific metadata in `Cargo.toml`, and keep parser tests only in `test/corpus`. Regenerate generated artifacts after metadata cleanup and validate with Tree-sitter tests, Rust tests, highlight checks, and an external path-dependency smoke test.

**Tech Stack:** Tree-sitter CLI 0.26, `tree-sitter.json`, Tree-sitter grammar DSL, npm scripts, Rust 2021, `tree-sitter-language`, Cargo path dependency validation.

---

## File Structure

- Create `tree-sitter.json`: modern Tree-sitter CLI grammar metadata, query paths, file type detection, and binding choices.
- Modify `package.json`: remove deprecated top-level `"tree-sitter"` grammar metadata; keep npm scripts and `tree-sitter-cli` dev dependency only.
- Modify `README.md`: document modern layout, `tree-sitter.json`, generation, tests, Rust usage, and supported file types.
- Delete `corpus/*.tst`: old root corpus duplicates; current CLI uses `test/corpus`.
- Keep `test/corpus/*.tst` and `test/corpus/examples.txt`: active parser corpus.
- Create `test/highlight/basic.asm`: highlight fixture to prove `tree-sitter.json` points at `queries/highlights.scm`.
- Modify `queries/highlights.scm`: only if highlight test exposes invalid or weak captures.
- Regenerate `src/parser.c`, `src/grammar.json`, `src/node-types.json`, and `src/tree_sitter/*.h`: generated parser artifacts after `tree-sitter.json` is added.
- Keep `bindings/rust/build.rs` and `bindings/rust/lib.rs`: modern Rust binding already exists; validate it still works.
- Create or modify `.gitattributes`: mark generated parser artifacts as generated for GitHub diffs.
- Create or modify `.gitignore`: ignore build outputs, `node_modules`, and temporary Tree-sitter logs.

## Task 1: Add Modern Tree-Sitter Metadata

**Files:**
- Create: `tree-sitter.json`
- Modify: `package.json`
- Test: `npm run generate`

- [ ] **Step 1: Create `tree-sitter.json`**

Create `tree-sitter.json`:

```json
{
  "grammars": [
    {
      "name": "ca65",
      "camelcase": "CA65",
      "scope": "source.ca65",
      "path": ".",
      "file-types": [
        "asm",
        "s",
        "inc",
        "ca65"
      ],
      "highlights": "queries/highlights.scm",
      "injection-regex": "ca65"
    }
  ],
  "metadata": {
    "version": "0.1.0",
    "license": "MIT",
    "description": "CA65 grammar for tree-sitter",
    "authors": [
      {
        "name": "LLeny"
      },
      {
        "name": "bgevko"
      }
    ],
    "links": {
      "repository": "https://github.com/bgevko/tree-sitter-ca65"
    }
  },
  "bindings": {
    "c": false,
    "go": false,
    "node": false,
    "python": false,
    "rust": true,
    "swift": false,
    "zig": false
  }
}
```

- [ ] **Step 2: Remove deprecated grammar metadata from `package.json`**

Replace `package.json` with:

```json
{
  "name": "tree-sitter-ca65",
  "version": "0.1.0",
  "description": "CA65 grammar for tree-sitter",
  "main": "grammar.js",
  "scripts": {
    "generate": "tree-sitter generate",
    "test": "tree-sitter test",
    "test:highlight": "tree-sitter highlight --check test/highlight/basic.asm"
  },
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "tree-sitter-cli": "^0.26.0"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/bgevko/tree-sitter-ca65.git"
  }
}
```

- [ ] **Step 3: Regenerate parser artifacts**

Run:

```bash
npm run generate
```

Expected: command succeeds and does not print:

```text
No `tree-sitter.json` file found
Using ABI version 14 instead
```

It may still warn:

```text
rule separator contains a `choice` rule with a single element
```

That warning is handled in Task 2.

- [ ] **Step 4: Confirm generated parser ABI changed to 15**

Run:

```bash
rg -n 'LANGUAGE_VERSION|TREE_SITTER_LANGUAGE_VERSION|14|15' src/parser.c src/tree_sitter/parser.h
```

Expected: output shows generated parser/header language version uses `15`, not `14`.

- [ ] **Step 5: Run parser tests**

Run:

```bash
npm test
```

Expected: all 36 parser tests pass.

- [ ] **Step 6: Run Rust tests**

Run:

```bash
cargo test
```

Expected: 2 unit tests and 1 doctest pass.

- [ ] **Step 7: Commit**

Run:

```bash
git add tree-sitter.json package.json src/parser.c src/grammar.json src/node-types.json src/tree_sitter
git commit -m "chore: add modern tree-sitter metadata"
```

Expected: commit created.

## Task 2: Remove Grammar Warnings

**Files:**
- Modify: `grammar.js`
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`
- Test: `npm run generate`

- [ ] **Step 1: Replace redundant separator rule**

In `grammar.js`, replace:

```js
    separator: $ => token(
      choice(...separators)
    ),
```

with:

```js
    separator: $ => token(','),
```

- [ ] **Step 2: Remove unused `separators` constant**

In `grammar.js`, delete:

```js
  separators = [
    ','
  ];
```

Then change the previous `brackets` declaration from:

```js
  brackets = [
    '(', ')', '[', ']', '{', '}'
  ],
  separators = [
    ','
  ];
```

to:

```js
  brackets = [
    '(', ')', '[', ']', '{', '}'
  ];
```

- [ ] **Step 3: Regenerate parser artifacts**

Run:

```bash
npm run generate
```

Expected: command succeeds with no warnings.

- [ ] **Step 4: Run parser tests**

Run:

```bash
npm test
```

Expected: all 36 parser tests pass.

- [ ] **Step 5: Run Rust tests**

Run:

```bash
cargo test
```

Expected: 2 unit tests and 1 doctest pass.

- [ ] **Step 6: Commit**

Run:

```bash
git add grammar.js src/parser.c src/grammar.json src/node-types.json
git commit -m "chore(grammar): remove generation warnings"
```

Expected: commit created.

## Task 3: Remove Deprecated Root Corpus

**Files:**
- Delete: `corpus/define.tst`
- Delete: `corpus/examples.tst` if present
- Delete: `corpus/extras.tst`
- Delete: `corpus/instr.tst`
- Delete: `corpus/labels.tst`
- Delete: `corpus/macros.tst`
- Delete: `corpus/operands.tst`
- Delete: `corpus/procs.tst`
- Keep: `test/corpus/*.tst`
- Keep: `test/corpus/examples.txt`

- [ ] **Step 1: Confirm active corpus is under `test/corpus`**

Run:

```bash
find test/corpus -maxdepth 1 -type f -print | sort
```

Expected:

```text
test/corpus/define.tst
test/corpus/examples.txt
test/corpus/extras.tst
test/corpus/instr.tst
test/corpus/labels.tst
test/corpus/macros.tst
test/corpus/operands.tst
test/corpus/procs.tst
```

- [ ] **Step 2: Delete old root corpus files**

Run:

```bash
git rm -r corpus
```

Expected: removes only root `corpus/`; `test/corpus/` remains.

- [ ] **Step 3: Run parser tests**

Run:

```bash
npm test
```

Expected: all 36 parser tests pass.

- [ ] **Step 4: Commit**

Run:

```bash
git add test/corpus
git commit -m "chore: remove deprecated root corpus"
```

Expected: commit created.

## Task 4: Add Highlight Smoke Test

**Files:**
- Create: `test/highlight/basic.asm`
- Modify: `queries/highlights.scm` if needed
- Test: `npm run test:highlight`

- [ ] **Step 1: Create highlight test fixture**

Create `test/highlight/basic.asm`:

```asm
.segment "CODE"
; <- keyword.directive
         ; ^ string

reset:
; <- tag
    lda #$00
;   ^ function.builtin
;       ^ punctuation.delimiter
;        ^ type
;         ^^ number
    sta $0200
;   ^ function.builtin
;       ^ type
;        ^^^^ number
    rts
;   ^ function.builtin
```

- [ ] **Step 2: Run highlight test**

Run:

```bash
npm run test:highlight
```

Expected: PASS. If it fails, output points at a capture mismatch in `test/highlight/basic.asm`.

- [ ] **Step 3: Fix label capture if needed**

If `.segment`, string, mnemonic, labels, numbers, or prefixes do not highlight as expected, edit `queries/highlights.scm` to contain these captures:

```scheme
(preproccmd) @keyword.directive
(procstart) @keyword.directive
(procend) @keyword.directive
(macrostart) @keyword.directive
(macroend) @keyword.directive

(proc proc_name: (identifier) @function)

(mnemonic) @function.builtin

(equ constant: (identifier) @variable)
(equ equ: (equal) @operator)
(equ value: (anything) @constant)

(base) @type
(value) @variable
(mem_address) @variable
(register) @constant.builtin

(string) @string
(char) @string
(number) @number
(comment) @comment
(label (identifier) @tag)
(label (local_identifier) @tag)
(label (unnamed_label) @tag)
(unnamed_label_ref) @tag
(operator) @operator
(separator) @punctuation.delimiter
(bracket) @punctuation.bracket
(valuetag) @punctuation.delimiter
```

- [ ] **Step 4: Re-run highlight test**

Run:

```bash
npm run test:highlight
```

Expected: PASS.

- [ ] **Step 5: Run parser and Rust tests**

Run:

```bash
npm test
cargo test
```

Expected: parser tests pass; Rust unit tests and doctest pass.

- [ ] **Step 6: Commit**

Run:

```bash
git add test/highlight/basic.asm queries/highlights.scm package.json
git commit -m "test: add highlight smoke test"
```

Expected: commit created.

## Task 5: Add Generated File and Build Ignores

**Files:**
- Create: `.gitattributes`
- Create: `.gitignore`
- Test: `git status --short`

- [ ] **Step 1: Create `.gitattributes`**

Create `.gitattributes`:

```gitattributes
src/parser.c linguist-generated=true
src/grammar.json linguist-generated=true
src/node-types.json linguist-generated=true
src/tree_sitter/*.h linguist-generated=true
```

- [ ] **Step 2: Create `.gitignore`**

Create `.gitignore`:

```gitignore
/build/
/node_modules/
/target/
/log.html
```

- [ ] **Step 3: Verify ignored build outputs**

Run:

```bash
mkdir -p build node_modules target
touch log.html
git status --short --ignored
```

Expected: output includes ignored entries like:

```text
!! build/
!! node_modules/
!! target/
!! log.html
```

- [ ] **Step 4: Remove temporary ignored files**

Run:

```bash
rm -rf build node_modules target log.html
```

Expected: temporary ignored files removed.

- [ ] **Step 5: Commit**

Run:

```bash
git add .gitattributes .gitignore
git commit -m "chore: mark generated and ignored files"
```

Expected: commit created.

## Task 6: Final Validation and Path Consumption

**Files:**
- Modify: none
- Test: external temporary Cargo project

- [ ] **Step 1: Run warning-free generation**

Run:

```bash
npm run generate 2>&1 | tee /tmp/tree-sitter-ca65-generate.log
```

Expected: command exits 0.

- [ ] **Step 2: Assert no deprecated metadata or ABI warning**

Run:

```bash
rg 'No `tree-sitter.json` file found|Using ABI version 14|rule separator contains' /tmp/tree-sitter-ca65-generate.log
```

Expected: no matches and exit code 1 from `rg`.

- [ ] **Step 3: Run parser tests**

Run:

```bash
npm test
```

Expected: all 36 parser tests pass.

- [ ] **Step 4: Run highlight tests**

Run:

```bash
npm run test:highlight
```

Expected: highlight smoke test passes.

- [ ] **Step 5: Run Rust tests**

Run:

```bash
cargo test
```

Expected: 2 unit tests and 1 doctest pass.

- [ ] **Step 6: Run external path-dependency smoke test**

Run:

```bash
set -e
tmpparent=$(mktemp -d /tmp/ca65-path-parent.XXXXXX)
tmpdir="$tmpparent/check"
cargo new "$tmpdir" --bin
cat >"$tmpdir/Cargo.toml" <<'EOF'
[package]
name = "check"
version = "0.1.0"
edition = "2024"

[dependencies]
tree-sitter = "0.26.9"
tree-sitter-ca65 = { path = "/Users/bgevko/.local/opt/tree-sitter-ca65" }
EOF
cat >"$tmpdir/src/main.rs" <<'EOF'
fn main() {
    let mut parser = tree_sitter::Parser::new();
    parser
        .set_language(&tree_sitter_ca65::LANGUAGE.into())
        .expect("load ca65 grammar");

    let tree = parser
        .parse(".segment \"CODE\"\nreset:\n    lda #$00\n", None)
        .expect("parse tree");

    assert!(!tree.root_node().has_error());
}
EOF
cargo run --offline --manifest-path "$tmpdir/Cargo.toml"
```

Expected: command exits 0 and runs the temporary `check` binary without panic.

- [ ] **Step 7: Confirm clean worktree**

Run:

```bash
git status --short
```

Expected: no output.

- [ ] **Step 8: Commit final generated artifacts if any changed**

Run:

```bash
git status --short
git add src/parser.c src/grammar.json src/node-types.json src/tree_sitter package-lock.json
git commit -m "chore: refresh generated parser artifacts"
```

Expected: commit only if Step 7 showed generated or lockfile changes. If Step 7 was clean, skip this step.

## Self-Review

- Spec coverage: Plan removes deprecated `package.json.tree-sitter`, removes root `corpus/`, adds `tree-sitter.json`, validates ABI 15 generation, validates parser tests, validates highlight query wiring, validates Rust binding, and validates external path consumption.
- Placeholder scan: No `TBD`, `TODO`, "implement later", vague "write tests", or "similar to" steps remain.
- Type consistency: Rust examples consistently use `tree_sitter_ca65::LANGUAGE`; npm scripts consistently use `generate`, `test`, and `test:highlight`; parser artifacts consistently use `src/parser.c`, `src/grammar.json`, `src/node-types.json`, and `src/tree_sitter/*.h`.
