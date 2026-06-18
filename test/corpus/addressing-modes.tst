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
    (operand
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
    (operand
      (immediate
        (immediate_marker)
        (number))))
  (instruction
    (mnemonic)
    (operand
      (immediate
        (immediate_marker)
        (base)
        (number))))
  (instruction
    (mnemonic)
    (operand
      (immediate
        (immediate_marker)
        (base)
        (number))))
  (instruction
    (mnemonic)
    (operand
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
    (operand
      (address_expression
        (base)
        (number))))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (base)
        (number)
        (separator)
        (register))))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (base)
        (number)
        (separator)
        (register))))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (identifier)
        (separator)
        (register))))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (identifier)
        (separator)
        (register)))))

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
    (operand
      (address_expression
        (bracket)
        (base)
        (number)
        (bracket))))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (bracket)
        (base)
        (number)
        (separator)
        (register)
        (bracket))))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (bracket)
        (base)
        (number)
        (bracket)
        (separator)
        (register)))))

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
    (operand
      (address_expression
        (register)
        (operator)
        (base)
        (number))))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (identifier)
        (operator)
        (base)
        (number))))
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (identifier)))))
