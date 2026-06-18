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
    (macro_parameters
      (identifier))
    (directive
      (directive_name)
      (directive_arguments
        (identifier)))
    (instruction
      (mnemonic))
    (label
      (identifier))
    (instruction
      (mnemonic))
    (macroend))
  (generic_line
    (macro_call
      (identifier)
      (argument_list
        (register)))))

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
  (directive
    (directive_name)
    (directive_arguments
      (directive_name)
      (bracket)
      (identifier)
      (bracket)))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (number))))
  (directive
    (directive_name)
    (directive_arguments
      (directive_name)
      (bracket)
      (identifier)
      (bracket)))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (number))))
  (directive
    (directive_name))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (number))))
  (directive
    (directive_name)))

====================
repeat control
====================
.repeat 4, i
    .byte i
.endrepeat

---

(source_file
  (directive
    (directive_name)
    (directive_arguments
      (number)
      (separator)
      (identifier)))
  (directive
    (directive_name)
    (directive_arguments
      (identifier)))
  (directive
    (directive_name)))
