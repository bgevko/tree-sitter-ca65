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
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd) (number) (separator) (base) (number)))

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
  (preprocgen (preproccmd) (string) (separator) (base) (number) (separator) (base) (number))
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd) (base) (number) (separator) (identifier))
  (preprocgen (preproccmd) (identifier))
  (preprocgen (preproccmd) (identifier))
  (preprocgen (preproccmd) (base) (number))
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd) (string)))

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
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd) (identifier) (separator) (identifier))
  (preprocgen (preproccmd) (identifier))
  (preprocgen (preproccmd) (identifier))
  (preprocgen (preproccmd) (identifier)))
