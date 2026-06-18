====================
implied and accumulator
====================
    clc
    rts
    asl a

---

(source_file
  (instruction
    (mnemonic))
  (instruction
    (mnemonic))
  (instruction
    (mnemonic)
    (accumulator_operand
      (register))))

====================
immediate number forms
====================
    lda #10
    lda #$0a
    lda #%00001010
    lda #'A'

---

(source_file
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (number))))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (base)
        (number))))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (base)
        (number))))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (char)))))

====================
absolute and indexed
====================
    lda $1234
    lda $1234,x
    lda $1234,y
    sta table,x
    sta table,y

---

(source_file
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (base)
        (number))))
  (instruction
    (mnemonic)
    (indexed_operand
      (address_expression
        (base)
        (number))
      (separator)
      (register)))
  (instruction
    (mnemonic)
    (indexed_operand
      (address_expression
        (base)
        (number))
      (separator)
      (register)))
  (instruction
    (mnemonic)
    (indexed_operand
      (address_expression
        (identifier))
      (separator)
      (register)))
  (instruction
    (mnemonic)
    (indexed_operand
      (address_expression
        (identifier))
      (separator)
      (register))))

====================
indirect modes
====================
    jmp ($1234)
    lda ($20,x)
    lda ($20),y

---

(source_file
  (instruction
    (mnemonic)
    (indirect_operand
      (address_expression
        (base)
        (number))))
  (instruction
    (mnemonic)
    (indexed_indirect_operand
      (address_expression
        (base)
        (number))
      (separator)
      (register)))
  (instruction
    (mnemonic)
    (indirect_indexed_operand
      (address_expression
        (base)
        (number))
      (separator)
      (register))))

====================
address size prefixes
====================
    lda a:$00
    lda z:$1234
    jsr far_func

---

(source_file
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (address_size_prefix)
        (base)
        (number))))
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (address_size_prefix)
        (base)
        (number))))
  (instruction
    (mnemonic)
    (address_operand
      (address_expression
        (identifier)))))
