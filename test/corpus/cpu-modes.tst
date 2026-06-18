====================
processor mode directives
====================
    .p02
    .p02x
    .pc02
    .p816
    .setcpu "6502"
    .setcpu "65816"

---

(source_file
  (directive
    (directive_name))
  (directive
    (directive_name))
  (directive
    (directive_name))
  (directive
    (directive_name))
  (directive
    (directive_name)
    (directive_arguments
      (string)))
  (directive
    (directive_name)
    (directive_arguments
      (string))))

====================
extended mnemonics
====================
    bra target
    stz $00
    wai
    stp
    jsl far_target
    rtl

---

(source_file
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (identifier))))
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (base)
        (number))))
  (instruction
    (mnemonic))
  (instruction
    (mnemonic))
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (identifier))))
  (instruction
    (mnemonic)))
