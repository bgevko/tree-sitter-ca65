# Modernize Tree-Sitter CA65 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modernize the `tree-sitter-ca65` fork so it has reliable CA65 grammar tests, current Tree-sitter Rust bindings, regenerated parser artifacts, and can be consumed by `ca65-lsp`.

**Architecture:** Keep this repository as the standalone grammar package. The JavaScript Tree-sitter grammar remains the source of truth, generated C artifacts live under `src/`, and Rust consumers use the crate through `bindings/rust/lib.rs`. Improve the grammar in small test-first patches, regenerating parser artifacts after each grammar change.

**Tech Stack:** Tree-sitter grammar DSL in `grammar.js`, `tree-sitter-cli`, Node package scripts, Cargo, `cc`, `tree-sitter-language`, Rust 2021.

---

## File Structure

- Modify `grammar.js`: CA65 grammar rules. Remove unsafe extras, accept files without final newline, fix directive token, and clarify labels/directives/instructions.
- Modify `corpus/*.tst`: Tree-sitter parser corpus tests. Add focused tests before each grammar change.
- Modify `queries/highlights.scm`: Keep highlight captures aligned with renamed or clarified grammar nodes.
- Modify `package.json`: Update Tree-sitter CLI scripts and metadata for local testing.
- Modify `Cargo.toml`: Modernize Rust crate metadata and dependencies.
- Modify `bindings/rust/lib.rs`: Expose modern `LANGUAGE: LanguageFn` API plus node/query constants.
- Modify `bindings/rust/build.rs`: Keep parser compilation robust and current.
- Regenerate `src/parser.c`, `src/grammar.json`, and `src/node-types.json`: Generated Tree-sitter artifacts.
- Create `test/corpus/examples.txt`: Tiny fixture based on `ca65-lsp/examples/test.asm`.
- Create `docs/superpowers/plans/2026-06-17-modernize-tree-sitter-ca65.md`: This plan.

## Task 1: Establish Baseline

**Files:**
- Read: `grammar.js`
- Read: `corpus/*.tst`
- Read: `Cargo.toml`
- Read: `package.json`
- Read: `bindings/rust/lib.rs`
- Read: `bindings/rust/build.rs`

- [ ] **Step 1: Run Tree-sitter corpus tests**

Run:

```bash
npm test
```

Expected: PASS, or FAIL only if local dependencies are missing. If dependencies are missing, run Step 2.

- [ ] **Step 2: Install Node dependencies if needed**

Run:

```bash
npm install
```

Expected: installs `tree-sitter-cli` and `nan`, creates or updates `package-lock.json`.

- [ ] **Step 3: Re-run Tree-sitter corpus tests**

Run:

```bash
npm test
```

Expected: PASS with all existing corpus fixtures.

- [ ] **Step 4: Run Rust crate tests**

Run:

```bash
cargo test
```

Expected: PASS for `test_can_load_grammar`.

- [ ] **Step 5: Commit baseline lockfile only if npm created one**

Run:

```bash
git status --short
git add package-lock.json
git commit -m "chore: add npm lockfile"
```

Expected: commit only if `package-lock.json` exists and is untracked or modified. If no `package-lock.json` change exists, skip this step.

## Task 2: Add CA65 Example Corpus

**Files:**
- Create: `test/corpus/examples.txt`
- Modify: `package.json`

- [ ] **Step 1: Add a fixture copied from `ca65-lsp/examples/test.asm`**

Create `test/corpus/examples.txt`:

```text
==================
basic ca65 example
==================
.segment "CODE"

reset:
    lda #$00
    sta $0200
    rts

---

(source_file
  (preprocgen
    (preproccmd)
    (string))
  (label)
  (mnemonic
    (operand
      (value
        (valuetag)
        (base)
        (number))))
  (mnemonic
    (operand
      (mem_address
        (base)
        (number))))
  (mnemonic))
```

- [ ] **Step 2: Run test to verify fixture path is picked up**

Run:

```bash
tree-sitter test
```

Expected: PASS or FAIL showing actual parse tree mismatch for `basic ca65 example`.

- [ ] **Step 3: If `test/corpus` is ignored, use existing corpus directory**

If Step 2 does not discover `test/corpus/examples.txt`, move fixture:

```bash
mv test/corpus/examples.txt corpus/examples.tst
rmdir test/corpus
rmdir test
tree-sitter test
```

Expected: PASS or FAIL showing actual parse tree mismatch for `basic ca65 example`.

- [ ] **Step 4: Commit fixture once test expectation matches current parser**

Run:

```bash
git add test/corpus/examples.txt corpus/examples.tst package.json
git commit -m "test: add ca65 example corpus"
```

Expected: commit includes whichever fixture path exists. If `package.json` did not change, Git ignores it.

## Task 3: Accept Blank Lines and Missing Final Newline

**Files:**
- Modify: `corpus/extras.tst`
- Modify: `grammar.js`
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`

- [ ] **Step 1: Add failing corpus cases**

Append to `corpus/extras.tst`:

```text

====================
blank only file
====================



---

(source_file)

====================
no trailing newline
====================
lda #$00
---

(source_file
  (mnemonic
    (operand
      (value
        (valuetag)
        (base)
        (number)))))
```

- [ ] **Step 2: Run test to verify failure**

Run:

```bash
tree-sitter test corpus/extras.tst
```

Expected: FAIL for `blank only file`, `no trailing newline`, or both.

- [ ] **Step 3: Replace line model in `grammar.js`**

In `grammar.js`, replace:

```js
    source_file: $ => repeat($._line),
    
    _line: $ => seq(
      choice(
        $._statement,
        $._preproc,
        $.equ
      ),
      /\r?\n/
    ),
```

with:

```js
    source_file: $ => repeat(choice(
      $._statement,
      $._preproc,
      $.equ,
      $._newline
    )),

    _newline: $ => /\r?\n/,
```

- [ ] **Step 4: Regenerate parser artifacts**

Run:

```bash
tree-sitter generate
```

Expected: updates `src/parser.c`, `src/grammar.json`, and `src/node-types.json`.

- [ ] **Step 5: Run focused test**

Run:

```bash
tree-sitter test corpus/extras.tst
```

Expected: PASS.

- [ ] **Step 6: Run full Tree-sitter test suite**

Run:

```bash
tree-sitter test
```

Expected: PASS.

- [ ] **Step 7: Commit**

Run:

```bash
git add grammar.js corpus/extras.tst src/parser.c src/grammar.json src/node-types.json
git commit -m "fix(grammar): accept blank lines and final line"
```

Expected: commit created.

## Task 4: Fix Directive Token and Stop Treating Strings as Extras

**Files:**
- Modify: `corpus/extras.tst`
- Modify: `corpus/define.tst`
- Modify: `grammar.js`
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`

- [ ] **Step 1: Add failing directive and string corpus cases**

Append to `corpus/extras.tst`:

```text

====================
directive requires dot
====================
segment "CODE"
---

(source_file
  (ERROR
    (identifier)
    (string)))

====================
string stays visible
====================
.segment "CODE"
---

(source_file
  (preprocgen
    (preproccmd)
    (string)))
```

- [ ] **Step 2: Run test to verify failure**

Run:

```bash
tree-sitter test corpus/extras.tst
```

Expected: FAIL because current `preproccmd` accepts `segment` without a dot or because `string` is hidden as an extra.

- [ ] **Step 3: Fix extras and directive regex in `grammar.js`**

Replace:

```js
  extras: $ => [
    /\s+/,
    $.comment,
    $.string,
    $.char
  ],
```

with:

```js
  extras: $ => [
    /[ \t\r]+/,
    $.comment
  ],
```

Replace:

```js
    preproccmd: $ => /.[a-zA-Z_]+/,
```

with:

```js
    preproccmd: $ => /\.[a-zA-Z_]+/,
```

- [ ] **Step 4: Regenerate parser artifacts**

Run:

```bash
tree-sitter generate
```

Expected: updates generated files.

- [ ] **Step 5: Run focused test**

Run:

```bash
tree-sitter test corpus/extras.tst
```

Expected: PASS.

- [ ] **Step 6: Run full Tree-sitter test suite**

Run:

```bash
tree-sitter test
```

Expected: PASS, or FAIL showing corpus expectations that need updating because `string` and `char` are now visible.

- [ ] **Step 7: Update any visible string/char expectations**

If Step 6 fails because strings or chars now appear in parse output, update expected trees by adding explicit `(string)` or `(char)` nodes where source includes string or char literals.

Example expected tree for `lda 'c'`:

```text
(source_file
  (mnemonic
    (char)))
```

- [ ] **Step 8: Re-run full Tree-sitter test suite**

Run:

```bash
tree-sitter test
```

Expected: PASS.

- [ ] **Step 9: Commit**

Run:

```bash
git add grammar.js corpus src/parser.c src/grammar.json src/node-types.json
git commit -m "fix(grammar): parse directives and literals explicitly"
```

Expected: commit created.

## Task 5: Split Named, Local, and Unnamed Labels

**Files:**
- Modify: `corpus/labels.tst`
- Modify: `grammar.js`
- Modify: `queries/highlights.scm`
- Regenerate: `src/parser.c`
- Regenerate: `src/grammar.json`
- Regenerate: `src/node-types.json`

- [ ] **Step 1: Add label corpus cases with clear node names**

Replace expected output in `corpus/labels.tst` so label tests expect explicit label children:

```text
=================
label
=================
label1:
  jmp   label1

---
(source_file
  (label
    (identifier))
  (mnemonic
    (operand
      (mem_address
        (identifier)))))

=================
label local
=================
@label1:
  lda   #02

---
(source_file
  (label
    (local_identifier))
  (mnemonic
    (operand
      (value
        (valuetag)
        (number)))))

=================
label unnamed -
=================
:
  jmp   :-

---
(source_file
  (label
    (unnamed_label))
  (mnemonic
    (operand
      (mem_address
        (unnamed_label_ref)))))
```

- [ ] **Step 2: Run label tests to verify failure**

Run:

```bash
tree-sitter test corpus/labels.tst
```

Expected: FAIL because current `label` is one opaque regex.

- [ ] **Step 3: Replace label rules in `grammar.js`**

Replace:

```js
    label: $ => /@{0,1}[a-zA-Z0-9_]*:/, 
    number: $ => /[0-9a-fA-F]+/,
    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,
```

with:

```js
    label: $ => seq(
      choice(
        $.identifier,
        $.local_identifier,
        $.unnamed_label
      ),
      ':'
    ),
    unnamed_label: $ => token.immediate(''),
    unnamed_label_ref: $ => seq(':', choice(repeat1('+'), repeat1('-'))),
    number: $ => /[0-9a-fA-F]+/,
    local_identifier: $ => /@[a-zA-Z_][a-zA-Z0-9_]*/,
    identifier: $ => /[a-zA-Z_][a-zA-Z0-9_]*/,
```

Then replace unnamed label refs in `mem_address`:

```js
      seq(':+', repeat('+')),
      seq(':-', repeat('-')),
```

with:

```js
      $.unnamed_label_ref,
```

- [ ] **Step 4: If `unnamed_label` empty token is rejected, use alias**

If `tree-sitter generate` rejects `token.immediate('')`, replace the label rule with:

```js
    label: $ => choice(
      seq(choice($.identifier, $.local_identifier), ':'),
      alias(':', $.unnamed_label)
    ),
```

and remove:

```js
    unnamed_label: $ => token.immediate(''),
```

- [ ] **Step 5: Regenerate parser artifacts**

Run:

```bash
tree-sitter generate
```

Expected: generated files updated without grammar conflicts.

- [ ] **Step 6: Update `queries/highlights.scm` for new label nodes**

Add or replace label captures:

```scheme
(label (identifier) @label)
(label (local_identifier) @label)
(label (unnamed_label) @label)
(unnamed_label_ref) @label
```

- [ ] **Step 7: Run label tests**

Run:

```bash
tree-sitter test corpus/labels.tst
```

Expected: PASS after expected trees match actual explicit label nodes.

- [ ] **Step 8: Run full Tree-sitter test suite**

Run:

```bash
tree-sitter test
```

Expected: PASS.

- [ ] **Step 9: Commit**

Run:

```bash
git add grammar.js corpus/labels.tst queries/highlights.scm src/parser.c src/grammar.json src/node-types.json
git commit -m "feat(grammar): expose ca65 label forms"
```

Expected: commit created.

## Task 6: Modernize Rust Binding API

**Files:**
- Modify: `Cargo.toml`
- Modify: `bindings/rust/lib.rs`
- Modify: `bindings/rust/build.rs`
- Test: Rust crate tests inside `bindings/rust/lib.rs`

- [ ] **Step 1: Replace `Cargo.toml` Rust dependency metadata**

Replace `Cargo.toml` with:

```toml
[package]
name = "tree-sitter-ca65"
description = "ca65 grammar for the tree-sitter parsing library"
version = "0.1.0"
keywords = ["incremental", "parsing", "ca65"]
categories = ["parsing", "text-editors"]
repository = "https://github.com/bgevko/tree-sitter-ca65"
edition = "2021"
license = "MIT"
build = "bindings/rust/build.rs"
include = [
  "bindings/rust/*",
  "grammar.js",
  "queries/*",
  "src/*",
]

[lib]
path = "bindings/rust/lib.rs"

[dependencies]
tree-sitter-language = "0.1"

[dev-dependencies]
tree-sitter = "0.26.9"

[build-dependencies]
cc = "1.1"
```

- [ ] **Step 2: Replace Rust binding with modern `LANGUAGE` API**

Replace `bindings/rust/lib.rs` with:

```rust
//! This crate provides ca65 language support for the [tree-sitter][] parsing library.
//!
//! Typically, you will use the [`LANGUAGE`][] constant to add this language to a
//! tree-sitter [`Parser`][], and then use the parser to parse some code:
//!
//! ```
//! let code = ".segment \"CODE\"\nreset:\n    lda #$00\n";
//! let mut parser = tree_sitter::Parser::new();
//! parser
//!     .set_language(&tree_sitter_ca65::LANGUAGE.into())
//!     .expect("Error loading ca65 grammar");
//! let tree = parser.parse(code, None).unwrap();
//! assert!(!tree.root_node().has_error());
//! ```
//!
//! [`Parser`]: https://docs.rs/tree-sitter/*/tree_sitter/struct.Parser.html
//! [tree-sitter]: https://tree-sitter.github.io/

use tree_sitter_language::LanguageFn;

unsafe extern "C" {
    fn tree_sitter_ca65() -> *const ();
}

/// The tree-sitter [`LanguageFn`][LanguageFn] for this grammar.
///
/// [LanguageFn]: https://docs.rs/tree-sitter-language/*/tree_sitter_language/struct.LanguageFn.html
pub const LANGUAGE: LanguageFn = unsafe { LanguageFn::from_raw(tree_sitter_ca65) };

/// The content of the [`node-types.json`][] file for this grammar.
///
/// [`node-types.json`]: https://tree-sitter.github.io/tree-sitter/using-parsers#static-node-types
pub const NODE_TYPES: &str = include_str!("../../src/node-types.json");

/// The default highlights query for this grammar.
pub const HIGHLIGHTS_QUERY: &str = include_str!("../../queries/highlights.scm");

#[cfg(test)]
mod tests {
    #[test]
    fn can_load_grammar() {
        let mut parser = tree_sitter::Parser::new();
        parser
            .set_language(&super::LANGUAGE.into())
            .expect("Error loading ca65 language");
    }

    #[test]
    fn parses_basic_ca65() {
        let mut parser = tree_sitter::Parser::new();
        parser
            .set_language(&super::LANGUAGE.into())
            .expect("Error loading ca65 language");

        let tree = parser
            .parse(".segment \"CODE\"\nreset:\n    lda #$00\n", None)
            .expect("parser should return a tree");

        assert!(!tree.root_node().has_error());
    }
}
```

- [ ] **Step 3: Simplify build script but keep warning flags**

Replace `bindings/rust/build.rs` with:

```rust
fn main() {
    let src_dir = std::path::Path::new("src");
    let parser_path = src_dir.join("parser.c");

    cc::Build::new()
        .include(src_dir)
        .flag_if_supported("-Wno-unused-parameter")
        .flag_if_supported("-Wno-unused-but-set-variable")
        .flag_if_supported("-Wno-trigraphs")
        .file(&parser_path)
        .compile("tree-sitter-ca65");

    println!("cargo:rerun-if-changed={}", parser_path.display());
}
```

- [ ] **Step 4: Run Rust tests**

Run:

```bash
cargo test
```

Expected: PASS for `can_load_grammar` and `parses_basic_ca65`.

- [ ] **Step 5: Commit**

Run:

```bash
git add Cargo.toml bindings/rust/lib.rs bindings/rust/build.rs Cargo.lock
git commit -m "feat(rust): expose modern tree-sitter language binding"
```

Expected: commit created. Include `Cargo.lock` if Cargo creates or updates it.

## Task 7: Update Package Metadata and Scripts

**Files:**
- Modify: `package.json`
- Modify: `README.md`

- [ ] **Step 1: Replace `package.json` metadata and scripts**

Replace `package.json` with:

```json
{
  "name": "tree-sitter-ca65",
  "version": "0.1.0",
  "description": "CA65 grammar for tree-sitter",
  "main": "grammar.js",
  "scripts": {
    "generate": "tree-sitter generate",
    "test": "tree-sitter test"
  },
  "author": "",
  "license": "MIT",
  "dependencies": {
    "nan": "^2.18.0"
  },
  "devDependencies": {
    "tree-sitter-cli": "^0.26.0"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/bgevko/tree-sitter-ca65.git"
  },
  "tree-sitter": [
    {
      "scope": "source.ca65",
      "file-types": [
        "asm",
        "s",
        "inc",
        "ca65"
      ],
      "injection-regex": "ca65",
      "highlights": [
        "queries/highlights.scm"
      ]
    }
  ]
}
```

- [ ] **Step 2: Update README usage**

Replace `README.md` with:

```markdown
# tree-sitter-ca65

CA65 grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter).

## Generate

```bash
npm run generate
```

## Test

```bash
npm test
cargo test
```

## Rust Usage

```rust
let mut parser = tree_sitter::Parser::new();
parser
    .set_language(&tree_sitter_ca65::LANGUAGE.into())
    .expect("Error loading ca65 grammar");
```

## References

- [ca65 Users Guide](https://cc65.github.io/doc/ca65.html)
```

- [ ] **Step 3: Install/update Node dependencies**

Run:

```bash
npm install
```

Expected: updates `package-lock.json` and installs `tree-sitter-cli` compatible with `^0.26.0`.

- [ ] **Step 4: Regenerate parser artifacts with updated CLI**

Run:

```bash
npm run generate
```

Expected: updates `src/parser.c`, `src/grammar.json`, and `src/node-types.json` if CLI output differs.

- [ ] **Step 5: Run full validation**

Run:

```bash
npm test
cargo test
```

Expected: both PASS.

- [ ] **Step 6: Commit**

Run:

```bash
git add package.json package-lock.json README.md src/parser.c src/grammar.json src/node-types.json
git commit -m "chore: modernize package metadata"
```

Expected: commit created.

## Task 8: Prepare `ca65-lsp` Consumption Check

**Files:**
- Modify: none in this repository
- Read: `/Users/bgevko/.local/opt/ca65-lsp/Cargo.toml`

- [ ] **Step 1: Confirm grammar crate builds locally**

Run:

```bash
cargo test
```

Expected: PASS.

- [ ] **Step 2: Confirm package can be referenced by path from LSP repo**

Run from `/Users/bgevko/.local/opt/ca65-lsp`:

```bash
cargo add tree-sitter --version 0.26.9
cargo add tree-sitter-ca65 --path /Users/bgevko/.local/opt/tree-sitter-ca65
```

Expected: `ca65-lsp/Cargo.toml` gains `tree-sitter` and path dependency entries. Do not commit this from the grammar repo task unless working in the LSP repo task.

- [ ] **Step 3: Revert temporary LSP dependency check if it was only a probe**

Run from `/Users/bgevko/.local/opt/ca65-lsp`:

```bash
git diff Cargo.toml Cargo.lock
git checkout -- Cargo.toml Cargo.lock
```

Expected: LSP repo returns to previous state. Skip this step if the LSP dependency change is the next intended implementation patch.

- [ ] **Step 4: Commit no changes**

Run from `/Users/bgevko/.local/opt/tree-sitter-ca65`:

```bash
git status --short
```

Expected: no uncommitted changes.

## Self-Review

- Spec coverage: Plan covers updating forked grammar library, preserving grammar source, adding CA65 example fixture, improving grammar correctness, regenerating parser artifacts, modernizing Rust binding, updating metadata, and checking path consumption from `ca65-lsp`.
- Placeholder scan: No `TBD`, `TODO`, "implement later", or vague "write tests" steps remain.
- Type consistency: Rust API consistently uses `LANGUAGE: LanguageFn`; parser examples consistently call `.set_language(&tree_sitter_ca65::LANGUAGE.into())`; generated artifacts consistently named `src/parser.c`, `src/grammar.json`, and `src/node-types.json`.
