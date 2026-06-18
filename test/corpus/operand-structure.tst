====================
immediate and accumulator
====================
    lda #$00
    lda #'A'
    asl a

---

(source_file
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (base)
        (number))))
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (char))))
  (instruction
    mnemonic: (mnemonic)
    operand: (accumulator_operand
      (register))))

====================
absolute and indexed syntax
====================
    lda $1234
    lda $1234,x
    lda table,y
    lda z:$12

---

(source_file
  (instruction
    mnemonic: (mnemonic)
    operand: (address_operand
      (address_expression
        (base)
        (number))))
  (instruction
    mnemonic: (mnemonic)
    operand: (indexed_operand
      address: (address_expression
        (base)
        (number))
      (separator)
      index: (register)))
  (instruction
    mnemonic: (mnemonic)
    operand: (indexed_operand
      address: (address_expression
        (identifier))
      (separator)
      index: (register)))
  (instruction
    mnemonic: (mnemonic)
    operand: (address_operand
      (address_expression
        (address_size_prefix)
        (base)
        (number)))))

====================
indirect modes
====================
    jmp ($1234)
    lda ($20,x)
    lda ($20),y

---

(source_file
  (instruction
    mnemonic: (mnemonic)
    operand: (indirect_operand
      (address_expression
        (base)
        (number))))
  (instruction
    mnemonic: (mnemonic)
    operand: (indexed_indirect_operand
      address: (address_expression
        (base)
        (number))
      (separator)
      index: (register)))
  (instruction
    mnemonic: (mnemonic)
    operand: (indirect_indexed_operand
      address: (address_expression
        (base)
        (number))
      (separator)
      index: (register))))
