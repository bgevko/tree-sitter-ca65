=====================
proc base
=====================
.proc testproc
  lda   #02
.endproc

---

(source_file
  (proc
    (procstart)
    (identifier)
    (instruction
      (mnemonic)
      (immediate_operand
        (immediate
          (immediate_marker)
          (number))))
    (procend)))

=====================
proc near
=====================
.proc testproc: near
  lda   #$0B
.endproc

---

(source_file
  (proc
    (procstart)
    (identifier)
    (instruction
      (mnemonic)
      (immediate_operand
        (immediate
          (immediate_marker)
          (base)
          (number))))
    (procend)))
