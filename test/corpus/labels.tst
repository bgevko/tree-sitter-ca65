=================
label
=================
label1:
  jmp   label1

---
(source_file
  (label
    (identifier))
  (mnemonic)
  (operand
    (mem_address
      (identifier))))

=================
label local
=================
@label1:
  lda   #02

---
(source_file
  (label
    (local_identifier))
  (mnemonic)
  (operand
    (value
      (valuetag)
      (number))))

=================
label unnamed -
=================
:
  jmp   :-

---
(source_file
  (label
    (unnamed_label))
  (mnemonic)
  (operand
    (mem_address
      (unnamed_label_ref))))

=================
label unnamed +
=================
  jmp   :+
: lda   #02

---
(source_file
  (mnemonic)
  (operand
    (mem_address
      (unnamed_label_ref)))
  (label
    (unnamed_label))
  (mnemonic)
  (operand
    (value
      (valuetag)
      (number))))

=================
label unnamed +++
=================
  jmp   :+++

---
(source_file
  (mnemonic)
  (operand
    (mem_address
      (unnamed_label_ref))))

=================
label unnamed -- 
=================
  jmp   :--

---
(source_file
  (mnemonic)
  (operand
    (mem_address
      (unnamed_label_ref))))

=================
label same line
=================
label:lda #02
label2: lda #03

---
(source_file
  (label
    (identifier))
  (mnemonic)
  (operand
    (value
      (valuetag)
      (number)))
  (label
    (identifier))
  (mnemonic)
  (operand
    (value
       (valuetag)
       (number))))
