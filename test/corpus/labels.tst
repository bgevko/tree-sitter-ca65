=================
label
=================
label1:
  jmp   label1

---

(source_file
  (label
    (identifier))
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (identifier)))))

=================
label local
=================
@label1:
  lda   #02

---

(source_file
  (label
    (local_identifier))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (number)))))

=================
label unnamed -
=================
:
  jmp   :-

---

(source_file
  (label
    (unnamed_label))
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (unnamed_label_ref)))))

=================
label unnamed +
=================
  jmp   :+
: lda   #02

---

(source_file
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (unnamed_label_ref))))
  (label
    (unnamed_label))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (number)))))

=================
label unnamed +++
=================
  jmp   :+++

---

(source_file
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (unnamed_label_ref)))))

=================
label unnamed --
=================
  jmp   :--

---

(source_file
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (unnamed_label_ref)))))

=================
label same line
=================
label:lda #02
label2: lda #03

---

(source_file
  (label
    (identifier))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (number))))
  (label
    (identifier))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (number)))))
