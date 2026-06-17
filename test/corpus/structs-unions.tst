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
  (preprocgen (identifier) (preproccmd))
  (preprocgen (identifier) (preproccmd))
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
  (preprocgen (identifier) (preproccmd))
  (preprocgen (identifier) (preproccmd))
  (preprocgen (preproccmd))
  (label (identifier))
  (preprocgen (preproccmd) (identifier)))

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
  (preprocgen (identifier))
  (preprocgen (identifier))
  (preprocgen (preproccmd)))
