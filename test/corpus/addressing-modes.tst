====================
implied and accumulator
====================
    clc
    rts
    asl a

---

(source_file
  (mnemonic)
  (mnemonic)
  (mnemonic)
  (operand
    (register)))

====================
immediate number forms
====================
    lda #10
    lda #$0a
    lda #%00001010
    lda #'A'

---

(source_file
  (mnemonic)
  (operand
    (value
      (valuetag)
      (number)))
  (mnemonic)
  (operand
    (value
      (valuetag)
      (base)
      (number)))
  (mnemonic)
  (operand
    (value
      (valuetag)
      (base)
      (number)))
  (mnemonic)
  (operand
    (value
      (valuetag)
      (char))))

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
  (mnemonic)
  (operand
    (mem_address
      (base)
      (number)))
  (mnemonic)
  (operand
    (mem_address
      (base)
      (number)
      (separator)
      (register)))
  (mnemonic)
  (operand
    (mem_address
      (base)
      (number)
      (separator)
      (register)))
  (mnemonic)
  (operand
    (mem_address
      (identifier)
      (separator)
      (register)))
  (mnemonic)
  (operand
    (mem_address
      (identifier)
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
  (mnemonic)
  (operand
    (mem_address
      (bracket)
      (base)
      (number)
      (bracket)))
  (mnemonic)
  (operand
    (mem_address
      (bracket)
      (base)
      (number)
      (separator)
      (register)
      (bracket)))
  (mnemonic)
  (operand
    (mem_address
      (bracket)
      (base)
      (number)
      (bracket)
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
  (mnemonic)
  (operand
    (mem_address
      (register)
      (operator)
      (base)
      (number)))
  (mnemonic)
  (operand
    (mem_address
      (identifier)
      (operator)
      (base)
      (number)))
  (mnemonic)
  (operand
    (mem_address
      (identifier))))
