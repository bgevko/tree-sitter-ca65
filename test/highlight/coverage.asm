.segment "CODE"
; <- keyword
;        ^^^^^^ string

reset:
; <- tag
@loop:
; <- tag
    lda #<table
;   ^^^ function.builtin
;       ^ punctuation.delimiter
;        ^ operator
;         ^^^^^ variable
    sta $0200,x
;   ^^^ function.builtin
;       ^ type
;        ^^^^ number
;            ^ punctuation.delimiter
;             ^ constant.builtin
    bne @loop
;   ^^^ function.builtin
;       ^^^^^ variable

.byte "A", 'B', $00
; <- keyword
;     ^^^ string
;          ^^^ string
;               ^ type
;                ^^ number
