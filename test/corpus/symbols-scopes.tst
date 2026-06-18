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
    (address_operand
      (address_expression
        (local_identifier))))
  (label
    (unnamed_label))
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (unnamed_label_ref))))
  (instruction
    (mnemonic)
    (address_operand
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
  (scope_definition
    (scope_start
      (identifier))
    (label
      (identifier))
    (instruction
      (mnemonic)
      (immediate_operand
        (immediate
          (immediate_marker)
          (base)
          (number))))
    (scope_end))
  (proc
    (procstart)
    (identifier)
    (instruction
      (mnemonic)
      (address_operand
        (address_expression
          (scoped_identifier
            (identifier)
            (identifier)))))
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
