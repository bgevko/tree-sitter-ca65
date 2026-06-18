================
comments
================
; test comments
  lda   $02 ;another comment

---

(source_file
  (comment)
  (instruction
    (mnemonic)
    (operand
      (address_expression
        (base)
        (number))))
  (comment))

====================
blank only file
====================



---

(source_file)

====================
no trailing newline
====================
lda #$00
---

(source_file
  (instruction
    (mnemonic)
    (operand
      (immediate
        (immediate_marker)
        (base)
        (number)))))

====================
directive requires dot
====================
segment "CODE"
---

(source_file
  (generic_line
    (macro_call
      (identifier)
      (argument_list
        (string)))))

====================
string stays visible
====================
.segment "CODE"
---

(source_file
  (directive
    (directive_name)
    (directive_arguments
      (string))))
