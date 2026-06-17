====================
processor mode directives
====================
    .p02
    .p02x
    .pc02
    .p816
    .setcpu "6502"
    .setcpu "65816"

---

(source_file
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd))
  (preprocgen (preproccmd) (string))
  (preprocgen (preproccmd) (string)))

====================
extended mnemonics
====================
    bra target
    stz $00
    wai
    stp
    jsl far_target
    rtl

---

(source_file
  (mnemonic) (operand (mem_address (identifier)))
  (mnemonic) (operand (mem_address (base) (number)))
  (mnemonic)
  (mnemonic)
  (mnemonic) (operand (mem_address (identifier)))
  (mnemonic))
