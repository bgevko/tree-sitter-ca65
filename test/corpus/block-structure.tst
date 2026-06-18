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
