====================
struct definition
====================
.struct Point
    x .byte
    y .byte
.endstruct

---

(source_file
  (struct_definition
    (struct_start
      (identifier))
    (directive_line
      (symbol_directive
        (identifier)
        (directive_name)))
    (directive_line
      (symbol_directive
        (identifier)
        (directive_name)))
    (struct_end)))

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
  (union_definition
    (union_start
      (identifier))
    (directive_line
      (symbol_directive
        (identifier)
        (directive_name)))
    (directive_line
      (symbol_directive
        (identifier)
        (directive_name)))
    (union_end))
  (directive_line
    (labeled_directive
      (label
        (identifier))
      (directive_name)
      (directive_arguments
        (identifier)))))

====================
enum values
====================
.enum Token
    tok_none
    tok_ident
.endenum

---

(source_file
  (enum_definition
    (enum_start
      (identifier))
    (generic_line
      (enum_member
        (identifier)))
    (generic_line
      (enum_member
        (identifier)))
    (enum_end)))
