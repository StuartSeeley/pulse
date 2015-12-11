screen_columns  = 22
screen_rows  = 23

loaded_intro:

    org $1a00

intro_start:
    ldx #0
    txa
l:  sta 0,x
    inx
    bne -l

    ; Load +3K RAM
    ldx #5
l:  lda loader_cfg_3k,x
    sta tape_ptr,x
    dex
    bpl -l

    jsr tape_loader_start

    lda #@(+ reverse black) ; Screen and border color.
    sta $900f
    jsr clear_screen
l:  lda $9004
    bne -l
    lda #150            ; Unblank screen.
    sta $9002
    lda #%11110010      ; Up/locase chars.
    sta $9005

    lda #white
    sta curcol

    lda #4
    sta tmp
    lda #<txt_eyes
    sta s
    lda #>txt_eyes
    sta @(++ s)
    lda #9
    sta scry
l:  lda #11
    sta scrx
    jsr strout
    jsr inc_s
    inc scry
    dec tmp
    bne -l

    lda #$ec
    sta @(+ screen 7 (* 9 22))
    lda #$e2
    sta @(+ screen 8 (* 9 22))
    sta @(+ screen 9 (* 9 22))
    lda #$fb
    sta @(+ screen 10 (* 9 22))
    lda #$61
    sta @(+ screen 7 (* 10 22))
    sta @(+ screen 7 (* 11 22))
    lda #$e1
    sta @(+ screen 10 (* 10 22))
    sta @(+ screen 10 (* 11 22))
    lda #$fc
    sta @(+ screen 7 (* 12 22))
    lda #$62
    sta @(+ screen 8 (* 12 22))
    sta @(+ screen 9 (* 12 22))
    lda #$fe
    sta @(+ screen 10 (* 12 22))

    jmp blink

tmp:    0

patch_3k_size = @(length (fetch-file (+ "obj/3k.crunched." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_3k:
    $00 $10
    <patch_3k_size @(++ >patch_3k_size)
    $02 $10

txt_eyes:
    @(ascii2petscii "East") 0
    @(ascii2petscii "Yorkshire") 0
    @(ascii2petscii "Engineering") 0
    @(ascii2petscii "Software") 0

blink:
    lda #15
    sta sound_bonus
l:  ldx #1
    jsr swait
    lda #white
    jsr set_rectangle_color
    ldx #1
    jsr swait
    lda #yellow
    jsr set_rectangle_color
    jmp -l

set_rectangle_color:
    sta @(+ colors 7 (* 9 22))
    sta @(+ colors 8 (* 9 22))
    sta @(+ colors 9 (* 9 22))
    sta @(+ colors 10 (* 9 22))
    sta @(+ colors 7 (* 10 22))
    sta @(+ colors 7 (* 11 22))
    sta @(+ colors 10 (* 10 22))
    sta @(+ colors 10 (* 11 22))
    sta @(+ colors 7 (* 12 22))
    sta @(+ colors 8 (* 12 22))
    sta @(+ colors 9 (* 12 22))
    sta @(+ colors 10 (* 12 22))
    rts

swait:
l:  lsr $9004
    bne -l
m:  lsr $9004
    beq -m
    txa
    pha
    @(asm (fetch-file "game/sound.asm"))
    pla
    tax
    dex
    bne -l
    rts
