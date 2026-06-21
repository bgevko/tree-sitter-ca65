# tree-sitter-ca65

CA65 grammar for [tree-sitter](https://github.com/tree-sitter/tree-sitter).

This grammar targets the [ca65](https://cc65.github.io/doc/ca65.html)
assembler syntax used by the cc65 toolchain. It includes parser coverage for
common CA65 source files and ships a default highlighting query.

## Features

- 6502, WDC 65C02/65816, Rockwell 65C02, `.macpack`-style, and common illegal
  mnemonics
- CA65 labels, cheap local labels, unnamed label definitions, and unnamed label
  references
- Immediate, accumulator, address, indexed, indirect, indexed-indirect, and
  indirect-indexed operand syntax
- Address-size prefixes such as `a:`, `f:`, and `z:`
- Number forms, strings, chars, unary and binary expressions, scoped
  identifiers, and pseudo-function calls
- Assignments with `=`, `.set`-style directive lines, and `:=`
- `.proc`, `.scope`, `.struct`, `.union`, `.enum`, `.macro`, `.repeat`, and
  conditional assembly blocks
- Default syntax highlighting for directives, mnemonics, labels, operands,
  strings, numbers, comments, operators, brackets, and separators

Declared file types are `asm`, `s`, `inc`, and `ca65`.

## Generate

```bash
npm run generate
```

## Test

```bash
npm test
npm run test:highlight
cargo test
```

`npm test` runs the tree-sitter corpus tests. `npm run test:highlight` checks
the highlight fixtures explicitly. See [docs/test-coverage.md](docs/test-coverage.md)
for the current coverage notes.

## Rust Usage

This repository currently publishes a Rust binding. Other generated language
bindings are disabled in `tree-sitter.json`.

```rust
let code = ".segment \"CODE\"\nreset:\n    lda #$00\n";
let mut parser = tree_sitter::Parser::new();
parser
    .set_language(&tree_sitter_ca65::LANGUAGE.into())
    .expect("Error loading ca65 grammar");

let tree = parser.parse(code, None).unwrap();
assert!(!tree.root_node().has_error());
```

The Rust crate also exposes:

- `LANGUAGE`: the tree-sitter language function
- `NODE_TYPES`: the generated `node-types.json`
- `HIGHLIGHTS_QUERY`: the default highlights query

## Status

The grammar is intended for parsing and editor tooling. It recognizes a broad
set of CA65 syntax forms, but it does not perform assembler-level semantic
resolution such as choosing zero-page versus absolute addressing by symbol
value.

## References

- [ca65 Users Guide](https://cc65.github.io/doc/ca65.html)
