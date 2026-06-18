====================
operand number dec
====================
  lda   #12

---

(source_file
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (number)))))

===================
operand number bin
===================
  lda   #%01010100

---

(source_file
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (base)
        (number)))))

====================
operand number hex
====================
  lda   #$BEEF

---

(source_file
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (base)
        (number)))))

====================
operand addr
====================
  lda   $DEAD

---

(source_file
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (base)
        (number)))))

====================
operand char
====================
  lda   'c'

---

(source_file
  (instruction
    (mnemonic)
    (literal_operand
      (char))))

====================
operand register
====================
  rol   a   

---

(source_file
  (instruction
    (mnemonic)
    (accumulator_operand
      (register))))

====================
operand addr register
====================
  lda   $DEAD,x

---

(source_file
  (instruction
    (mnemonic)
    (indexed_operand
      (address_expression
        (base)
        (number))
      (separator)
      (register))))

====================
operand sep register
====================
  sta   data, y

---

(source_file
  (instruction
    (mnemonic)
    (indexed_operand
      (address_expression
        (identifier))
      (separator)
      (register))))

===================
operand addr hi/lo
===================
  lda   #>(data)
  sta   #<(data)

---

(source_file
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (operator)
        (bracket)
        (identifier)
        (bracket))))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (operator)
        (bracket)
        (identifier)
        (bracket)))))
