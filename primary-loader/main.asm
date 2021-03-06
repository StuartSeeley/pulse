main = $351

    org $120c

    sei
    lda #$7f
    sta $912e       ; Disable and acknowledge interrupts.
    sta $912d
    sta $911e       ; Disable restore key NMIs.

l:  lda $9004
    bne -l

    ; Blank screen.
    lda #0
    sta $9002
    lda #@(+ reverse black) ; Screen and border color.
    sta $900f

    ; Copy loader someplace else and configure it.
    ldx #0
l:  lda loaded_tape_loader,x
    sta @*tape-loader-start*,x
    inx
    bne -l

    ; Start tape motor.
    lda $911c
    and #$fd
    sta $911c

    ldy #<loader_cfg_intro
    lda #>loader_cfg_intro
    jmp tape_loader_start

intro_size = @(length (fetch-file (+ "obj/eyes." (downcase (symbol-name *tv*)) ".prg")))

loader_cfg_intro:
    $00 $10
    <intro_size @(++ >intro_size)
    $02 $10
