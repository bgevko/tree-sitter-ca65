====================
macro with locals and parameters
====================
.macro pushreg reg
    .local done
    pha
done:
    pla
.endmacro

    pushreg a

---

(source_file
  (macro
    (macrostart)
    (identifier)
    (identifier)
    (preprocgen (preproccmd) (identifier))
    (mnemonic)
    (label (identifier))
    (mnemonic)
    (macroend))
  (preprocgen (identifier) (identifier)))

====================
conditional assembly
====================
.if .defined(DEBUG)
    lda #1
.elseif .defined(RELEASE)
    lda #2
.else
    lda #0
.endif

---

(source_file
  (preprocgen (preproccmd) (preproccmd) (bracket) (identifier) (bracket))
  (mnemonic) (operand (value (valuetag) (number)))
  (preprocgen (preproccmd) (preproccmd) (bracket) (identifier) (bracket))
  (mnemonic) (operand (value (valuetag) (number)))
  (preprocgen (preproccmd))
  (mnemonic) (operand (value (valuetag) (number)))
  (preprocgen (preproccmd)))

====================
repeat control
====================
.repeat 4, i
    .byte i
.endrepeat

---

(source_file
  (preprocgen (preproccmd) (number) (separator) (identifier))
  (preprocgen (preproccmd) (identifier))
  (preprocgen (preproccmd)))
