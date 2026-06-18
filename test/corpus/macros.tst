============
macro no arg
============
.macro testmacro
  lda   #02
.endmacro

---

(source_file
  (macro
    (macrostart)
    (identifier)
    (instruction
      (mnemonic)
      (immediate_operand
        (immediate
          (immediate_marker)
          (number))))
    (macroend)))

============
macro args
============
.macro testmacro arg1, arg2
  lda   arg1
  sta   arg2
.endmacro

---

(source_file
  (macro
    (macrostart)
    (identifier)
    (macro_parameters
      (identifier)
      (separator)
      (identifier))
    (instruction
      (mnemonic)
      (address_operand
        (address_expression
          (identifier))))
    (instruction
      (mnemonic)
      (address_operand
        (address_expression
          (identifier))))
    (macroend)))

============
macro short
============
.mac testmacro
  lda   #02
.endmac

---

(source_file
  (macro
    (macrostart)
    (identifier)
    (instruction
      (mnemonic)
      (immediate_operand
        (immediate
          (immediate_marker)
          (number))))
    (macroend)))
