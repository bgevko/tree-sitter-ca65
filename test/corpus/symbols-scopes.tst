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
  (label (identifier))
  (label (local_identifier))
  (mnemonic) (operand (mem_address (local_identifier)))
  (label (unnamed_label))
  (mnemonic) (operand (mem_address (unnamed_label_ref)))
  (mnemonic) (operand (mem_address (unnamed_label_ref)))
  (label (unnamed_label))
  (mnemonic))

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
  (directive (directive_name) (identifier))
  (label (identifier))
  (mnemonic) (operand (value (valuetag) (base) (number)))
  (directive (directive_name))
  (proc
    (procstart)
    (identifier)
    (mnemonic)
    (operand
      (mem_address
        (identifier)
        (operator)
        (operator)
        (identifier)))
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
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (directive_line (identifier) (directive_name) (number))
  (directive_line (label (identifier)) (operator) (base) (number)))
