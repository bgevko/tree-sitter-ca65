====================
numeric formats
====================
    lda #10
    lda #$0a
    lda #%1010
    lda #'A'

---

(source_file
  (mnemonic) (operand (value (valuetag) (number)))
  (mnemonic) (operand (value (valuetag) (base) (number)))
  (mnemonic) (operand (value (valuetag) (base) (number)))
  (mnemonic) (operand (value (valuetag) (char))))

====================
unary byte operators
====================
    lda #<label
    lda #>label
    lda #^label

---

(source_file
  (mnemonic) (operand (value (valuetag) (operator) (identifier)))
  (mnemonic) (operand (value (valuetag) (operator) (identifier)))
  (mnemonic) (operand (value (valuetag) (operator) (identifier))))

====================
binary operators
====================
    value = base + 1
    mask = value & $0f
    shifted = value << 2
    compare = value >= 10
    logic = .not .defined(value) .or value = 0

---

(source_file
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything)))

====================
pseudo variables and functions
====================
    pc_value = *
    cpu_name = .CPU
    version = .VERSION
    addr_size = .addrsize(label)
    is_known = .defined(label)
    length = .strlen("text")

---

(source_file
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything))
  (equ (identifier) (equal) (anything)))
