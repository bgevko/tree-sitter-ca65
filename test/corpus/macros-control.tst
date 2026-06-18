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
    (directive (directive_name) (identifier))
    (mnemonic)
    (label (identifier))
    (mnemonic)
    (macroend))
  (generic_line (identifier) (register)))

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
  (directive (directive_name) (directive_name) (bracket) (identifier) (bracket))
  (mnemonic) (operand (value (valuetag) (number)))
  (directive (directive_name) (directive_name) (bracket) (identifier) (bracket))
  (mnemonic) (operand (value (valuetag) (number)))
  (directive (directive_name))
  (mnemonic) (operand (value (valuetag) (number)))
  (directive (directive_name)))

====================
repeat control
====================
.repeat 4, i
    .byte i
.endrepeat

---

(source_file
  (directive (directive_name) (number) (separator) (identifier))
  (directive (directive_name) (identifier))
  (directive (directive_name)))
