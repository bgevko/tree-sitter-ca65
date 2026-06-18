====================
struct definition
====================
.struct Point
    x .byte
    y .byte
.endstruct

---

(source_file
  (directive
    (directive_name)
    (directive_arguments
      (identifier)))
  (directive_line
    (identifier)
    (directive_name))
  (directive_line
    (identifier)
    (directive_name))
  (directive
    (directive_name)))

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
  (directive
    (directive_name)
    (directive_arguments
      (identifier)))
  (directive_line
    (identifier)
    (directive_name))
  (directive_line
    (identifier)
    (directive_name))
  (directive
    (directive_name))
  (directive_line
    (label
      (identifier))
    (directive_name)
    (identifier)))

====================
enum values
====================
.enum Token
    tok_none
    tok_ident
.endenum

---

(source_file
  (directive
    (directive_name)
    (directive_arguments
      (identifier)))
  (generic_line
    (identifier))
  (generic_line
    (identifier))
  (directive
    (directive_name)))
