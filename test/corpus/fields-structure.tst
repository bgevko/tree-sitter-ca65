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
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (base)
        (number))))
  (instruction
    mnemonic: (mnemonic)
    operand: (indexed_operand
      address: (address_expression
        (base)
        (number))
      (separator)
      index: (register))))
