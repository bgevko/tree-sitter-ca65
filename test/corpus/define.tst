================
.define
================
.define EQUTEST $8B41

---

(source_file
  (directive
    (directive_name)
    (directive_arguments
      (identifier)
      (base)
      (number))))

================
equal
================
EQUTEST = $01A1

---

(source_file
  (assignment
    (identifier)
    (equal)
    (anything)))

================
.define ()
================
.define EQUTEST ($8B41+1)

---

(source_file
  (directive
    (directive_name)
    (directive_arguments
      (identifier)
      (bracket)
      (base)
      (number)
      (operator)
      (number)
      (bracket))))

================
equal ()
================
EQUTEST = ($01A1+CONST)

---

(source_file
  (assignment
    (identifier)
    (equal)
    (anything)))
