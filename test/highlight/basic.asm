.segment "CODE"
; <- keyword
;        ^^^^^^ string

reset:
; <- tag
    lda #$00
;   ^^^ function.builtin
;       ^ punctuation.delimiter
;        ^ type
;         ^^ number
    sta $0200
;   ^^^ function.builtin
;       ^ type
;        ^^^^ number
    rts
;   ^^^ function.builtin
