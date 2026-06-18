====================
assignments
====================
two = 2
counter .set 0
io := $d000

---

(source_file
  (assignment
    name: (identifier)
    operator: (equal)
    value: (anything))
  (directive_line
    (symbol_directive
      name: (identifier)
      directive: (directive_name)
      (directive_arguments
        (number))))
  (assignment
    name: (identifier)
    operator: (assignment_operator)
    value: (address_expression
      (base)
      (number))))

====================
member and labeled directives
====================
.struct Point
    x .byte
    y .byte
.endstruct

item: .tag Value

---

(source_file
  (directive
    name: (directive_name)
    (directive_arguments
      (identifier)))
  (directive_line
    (symbol_directive
      name: (identifier)
      directive: (directive_name)))
  (directive_line
    (symbol_directive
      name: (identifier)
      directive: (directive_name)))
  (directive
    name: (directive_name))
  (directive_line
    (labeled_directive
      label: (label
        name: (identifier))
      directive: (directive_name)
      (directive_arguments
        (identifier)))))

====================
macro call and enum member
====================
pushreg a
tok_none

---

(source_file
  (generic_line
    (macro_call
      name: (identifier)
      (argument_list
        (register))))
  (generic_line
    (enum_member
      name: (identifier))))
