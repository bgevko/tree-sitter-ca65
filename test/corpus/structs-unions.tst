====================
struct definition
====================
.struct Point
    x .byte
    y .byte
.endstruct

---

(source_file
  (preprocgen (preproccmd) (identifier))
  (directive_line (identifier) (preproccmd))
  (directive_line (identifier) (preproccmd))
  (preprocgen (preproccmd)))

====================
union and tag usage
====================
.union Value
    b .byte
    w .word
.endunion

item: .tag Value

---

(source_file
  (preprocgen (preproccmd) (identifier))
  (directive_line (identifier) (preproccmd))
  (directive_line (identifier) (preproccmd))
  (preprocgen (preproccmd))
  (directive_line (label (identifier)) (preproccmd) (identifier)))

====================
enum values
====================
.enum Token
    tok_none
    tok_ident
.endenum

---

(source_file
  (preprocgen (preproccmd) (identifier))
  (generic_line (identifier))
  (generic_line (identifier))
  (preprocgen (preproccmd)))
