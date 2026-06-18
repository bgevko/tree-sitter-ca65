================
instr base
================
  lda     #04

---

(source_file
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (number)))))

================
instr wdc
================
  bra     $0463

---

(source_file
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (base)
        (number)))))

================
instr rockwell
================
  bbs
  smb7

---

(source_file
  (instruction
    (mnemonic))
  (instruction
    (mnemonic)))

================
instr macpack
================
  jmi   $5ab0

---

(source_file
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (base)
        (number)))))

================
instr illegal
================
  axs
  alr

---

(source_file
  (instruction
    (mnemonic))
  (instruction
    (mnemonic)))
