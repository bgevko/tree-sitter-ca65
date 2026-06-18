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
  (label
    (identifier))
  (label
    (local_identifier))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (local_identifier))))
  (label
    (unnamed_label))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (unnamed_label_ref))))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (unnamed_label_ref))))
  (label
    (unnamed_label))
  (instruction
    (mnemonic)))

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
  (directive
    (directive_name)
    (directive_arguments
      (identifier)))
  (label
    (identifier))
  (instruction
    (mnemonic)
    (operand
      (immediate
        (immediate_marker)
        (base)
        (number))))
  (directive
    (directive_name))
  (proc
    (procstart)
    (identifier)
    (instruction
      (mnemonic)
      (operand
        (address_expression
          (identifier)
          (operator)
          (operator)
          (identifier))))
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
  (assignment
    (identifier)
    (equal)
    (anything))
  (assignment
    (identifier)
    (equal)
    (anything))
  (directive_line
    (symbol_directive
      (identifier)
      (directive_name)
      (directive_arguments
        (number))))
  (assignment
    (identifier)
    (assignment_operator)
    (address_expression
      (base)
      (number))))
