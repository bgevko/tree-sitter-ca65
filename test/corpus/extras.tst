================
comments
================
; test comments
  lda   $02 ;another comment

---
(source_file
  (comment)
  (mnemonic)
  (operand
    (mem_address
      (base)
      (number)))
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
  (mnemonic)
  (operand
    (value
      (valuetag)
      (base)
      (number))))
