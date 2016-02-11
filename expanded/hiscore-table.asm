hiscore_entry_size = @(+ num_score_digits num_name_digits)

joystick_processed: 0
fxcol:  0

current_entry: 0
name_position: 0

hcolors:
    blue
    cyan
    white
    cyan
    blue
    purple
    red
    purple

hiscore_table:
    ldx #$ff
    txs
    stx current_entry
    inx
    stx joystick_processed
    lda #num_score_digits
    sta name_position
    jsr hide_screen
    jsr set_text_mode
    jsr clear_screen

    ; Check if a new entry is in order.
    lda #<hiscores
    sta sm
    lda #>hiscores
    sta @(++ sm)
    lda #10
    sta tmp

    ; Compare score with hiscore.
check_entry:
    ldy #0
    inc current_entry
loop:
    lda last_score,y
    cmp (sm),y
    beq +next_digit
    bcc +next_entry

    ; Move down lesser scores.
    lda sm
    cmp #<last_hiscore
    bne +n
    lda @(++ sm)
    cmp #>last_hiscore
    beq no_move
n:

    lda #<last_hiscore
    sta d
    lda #>last_hiscore
    sta @(++ d)

    lda #<second_last_hiscore
    sta col
    lda #>second_last_hiscore
    sta @(++ col)

copy:
    ldy #@(-- num_score_digits)                                                                      
l:  lda (col),y
    sta (d),y
    dey
    bpl -l

    lda col
    cmp sm
    bne +n
    lda @(++ col)
    cmp @(++ sm)
    beq +no_move
n:

    lda d
    sec
    sbc #hiscore_entry_size
    sta d
    bcs +n
    dec @(++ d)
n:

    lda col
    sec
    sbc #hiscore_entry_size
    sta col
    bcs +n
    dec @(++ col)
n:

    jmp copy

no_move:
    ; Copy new score.
    ldy #@(-- num_score_digits)
l:  lda last_score,y
    sta (sm),y
    dey
    bpl -l
    jmp +done

next_digit:
    iny
    cpy #num_score_digits
    bne -loop

next_entry:
    lda sm
    clc
    adc #hiscore_entry_size
    sta sm
    bcc +n
    inc @(++ sm)
n:  dec tmp
    bne -check_entry
    lda #$ff
    sta current_entry

done:
    ldx #0
    stx framecounter
    ldx #2
    stx framecounter_high

    jsr show_screen

    ldx #@(-- txt_fame_len)
l:  lda txt_fame,x
    sta @(+ screen (half (- 22 txt_fame_len))),x
    dex
    bpl -l

loop:
    ldx #1
    jsr wait

    ; Draw hiscore table.
    lda #<hiscores
    sta s
    lda #>hiscores
    sta @(++ s)
    lda #2
    sta scry
    lda #0
    sta tmp

l:  lda #4
    sta scrx
    lda #@(-- num_score_digits)
    jsr nstrout

    lda #14
    sta scrx
    lda #@(-- num_name_digits)
    jsr nstrout

    ; Blink currently edited name character.
    lda current_entry
    bmi +n
    cmp tmp
    bne +n
    lda framecounter
    and #%1000
    beq +n
    lda name_position
    sec
    sbc #num_score_digits
    tay
    lda #$20
    sta (scr),y
n:

    inc tmp
    inc scry
    inc scry
    lda scry
    cmp #21
    bcc -l

    ; Color effect
    ldx #0
    inc fxcol
    ldy fxcol
l:  iny
    tya
    and #7
    tay
    lda hcolors,y
    sta colors,x
    sta @(+ 256 colors),x
    dex
    bne -l

    lda current_entry
    bpl +edit

    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    and #joy_fire
    beq +done

    dec framecounter
    bne +l
    dec framecounter_high
    bne +l
done:
    jmp reenter_title

l:  jmp -loop

edit:
    inc framecounter
    lda joystick_processed
    beq +n

    lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    and #@(bit-or joy_fire (bit-or joy_up (bit-or joy_down joy_left)))
    eor #@(bit-or joy_fire (bit-or joy_up (bit-or joy_down joy_left)))
    bne -l
    lda #0          ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    bpl -l
n:  

stop:
    ; Edit new entry.
    lda #0              ; Fetch joystick status.
    sta joystick_processed
    sta $9113
    lda $9111
    tay
    and #joy_fire
    bne no_fire
    inc joystick_processed
    jmp -done

no_fire:
    ; Joystick up.
n:  tya
    and #joy_up
    bne +n
    ldy name_position
    lda (sm),y
    cmp #90
    bne +k
    lda #32
    jmp +m
k:  cmp #32
    bne +k
    lda #65
    jmp +m
k:  clc
    adc #1
m:  sta (sm),y
    inc joystick_processed
    jmp -loop

    ; Joystick down.
n:  tya
    and #joy_down
    bne +n
    ldy name_position
    lda (sm),y
    cmp #65
    bne +k
    lda #32
    jmp +m
k:  cmp #32
    bne +k
    lda #90
    jmp +m
k:  sec
    sbc #1
m:  sta (sm),y
    inc joystick_processed
    jmp -loop

    ; Joystick left.
n:  tya
    and #joy_left
    bne +n
    lda name_position
    cmp #num_score_digits
    beq +l
    dec name_position
    inc joystick_processed
    jmp -loop

    ; Joystick right.
n:  lda #0          ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    bmi +l
    lda name_position
    cmp #@(+ num_score_digits (-- num_name_digits))
    beq +l
    inc name_position
    inc joystick_processed
l:  jmp loop

nstrout:
    pha
    jsr scrcoladdr
    tya
    clc
    adc scr
    sta scr
    bcc +n
    inc @(++ scr)
n:

    pla
    pha
    tay
l:  lda (s),y
    sta (scr),y
    dey
    bpl -l

    pla
    sec
    adc s
    sta s
    bcc +n
    inc @(++ s)
n:

    rts

txt_fame:
    @(ascii2petscii "Hall Of Fame")
txt_fame_end:
txt_fame_len = @(- txt_fame_end txt_fame)

hiscores:
    @(apply #'nconc (maptimes [+ (maptimes [identity #\0] num_score_digits)
                                 (maptimes [identity #\A] num_name_digits)]
                              num_hiscore_entries))
hiscores_end:

last_hiscore = @(- hiscores_end hiscore_entry_size)
second_last_hiscore = @(- last_hiscore hiscore_entry_size)
