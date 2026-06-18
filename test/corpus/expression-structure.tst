====================
unary and binary expressions
====================
    lda #<table
    lda #^bank_table
    lda #(one + two * three)

---

(source_file
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (unary_expression
          operator: (operator)
          argument: (identifier)))))
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (unary_expression
          operator: (operator)
          argument: (identifier)))))
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (parenthesized_expression
          (binary_expression
            left: (identifier)
            operator: (operator)
            right: (binary_expression
              left: (identifier)
              operator: (operator)
              right: (identifier))))))))

====================
scoped identifiers and pseudo functions
====================
    jsr Outer::Reset
    lda #.lobyte(table)

---

(source_file
  (instruction
    mnemonic: (mnemonic)
    operand: (address_operand
      (address_expression
        (scoped_identifier
          scope: (identifier)
          name: (identifier)))))
  (instruction
    mnemonic: (mnemonic)
    operand: (immediate_operand
      (immediate
        (immediate_marker)
        (call_expression
          function: (directive_name)
          argument: (identifier))))))
