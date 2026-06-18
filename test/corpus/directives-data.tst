====================
segments and storage
====================
    .segment "CODE"
    .code
    .rodata
    .data
    .bss
    .zeropage
    .res 16, $00

---

(source_file
  (directive
    (directive_name)
    (directive_arguments
      (string)))
  (directive
    (directive_name))
  (directive
    (directive_name))
  (directive
    (directive_name))
  (directive
    (directive_name))
  (directive
    (directive_name))
  (directive
    (directive_name)
    (directive_arguments
      (number)
      (separator)
      (base)
      (number))))

====================
data emission directives
====================
    .byte "Hello", $0d, $00
    .byt "world"
    .word $1234, label
    .addr reset
    .faraddr far_proc
    .dword $12345678
    .asciiz "done"
    .literal "raw"

---

(source_file
  (directive
    (directive_name)
    (directive_arguments
      (string)
      (separator)
      (base)
      (number)
      (separator)
      (base)
      (number)))
  (directive
    (directive_name)
    (directive_arguments
      (string)))
  (directive
    (directive_name)
    (directive_arguments
      (base)
      (number)
      (separator)
      (identifier)))
  (directive
    (directive_name)
    (directive_arguments
      (identifier)))
  (directive
    (directive_name)
    (directive_arguments
      (identifier)))
  (directive
    (directive_name)
    (directive_arguments
      (base)
      (number)))
  (directive
    (directive_name)
    (directive_arguments
      (string)))
  (directive
    (directive_name)
    (directive_arguments
      (string))))

====================
linkage and includes
====================
    .include "hardware.inc"
    .incbin "tiles.chr"
    .import puts, irq_handler
    .export reset
    .global main
    .forceimport initlib

---

(source_file
  (directive
    (directive_name)
    (directive_arguments
      (string)))
  (directive
    (directive_name)
    (directive_arguments
      (string)))
  (directive
    (directive_name)
    (directive_arguments
      (identifier)
      (separator)
      (identifier)))
  (directive
    (directive_name)
    (directive_arguments
      (identifier)))
  (directive
    (directive_name)
    (directive_arguments
      (identifier)))
  (directive
    (directive_name)
    (directive_arguments
      (identifier))))
