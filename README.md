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
