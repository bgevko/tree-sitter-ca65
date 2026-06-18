====================
numeric formats
====================
    lda #10
    lda #$0a
    lda #%1010
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
unary byte operators
====================
    lda #<label
    lda #>label
    lda #^label

---

(source_file
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (unary_expression
          (operator)
          (identifier)))))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (unary_expression
          (operator)
          (identifier)))))
  (instruction
    (mnemonic)
    (immediate_operand
      (immediate
        (immediate_marker)
        (unary_expression
          (operator)
          (identifier))))))

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
  (assignment
    (identifier)
    (equal)
    (anything))
  (assignment
    (identifier)
    (equal)
    (anything))
  (assignment
    (identifier)
    (equal)
    (anything))
  (assignment
    (identifier)
    (equal)
    (anything))
  (assignment
    (identifier)
    (equal)
    (anything)))

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
  (assignment
    (identifier)
    (equal)
    (anything))
  (assignment
    (identifier)
    (equal)
    (anything))
  (assignment
    (identifier)
    (equal)
    (anything))
  (assignment
    (identifier)
    (equal)
    (anything))
  (assignment
    (identifier)
    (equal)
    (anything))
  (assignment
    (identifier)
    (equal)
    (anything)))
