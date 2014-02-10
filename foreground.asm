scrbricks_i:.byte 0, 1
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 2, 3
            .byte 4, 5
            .byte $ff
scrbricks_x:.byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 22, 28
            .byte 28, 47
scrbricks_y:.byte 7, 7
            .byte 8, 8
            .byte 9, 9
            .byte 10, 10
            .byte 11, 11
            .byte 12, 12
            .byte 13, 13
            .byte 14, 14
            .byte 15, 15
            .byte 16, 16
            .byte 17, 17
            .byte 18, 18
            .byte 19, 19
            .byte 20, 20
            .byte 21, 21
            .byte 22, 22

bricks_c:   .byte 0, 0, 0, 0, 0, 0
bricks_col: .byte yellow+8, yellow+8, yellow+8,    yellow+8,    yellow+8,    yellow+8
bricks_l:   .byte 0,        <bg_t,    0,           <background, <background, <bg_t
bricks_m:   .byte <bg_tl,   <bg_tr,   <bg_l,       <bg_r,       <bg_dl,      <bg_dr
bricks_r:   .byte <bg_t,    0,        <background, 0,           <bg_t,       <background

init_foreground:
    ldy #0
    sty scrolled_bits
    sty scrolled_chars
    dey
    sty leftmost_brick
    rts

fetch_foreground_char:
    lda next_foreground_char
    inc next_foreground_char
    jmp fetch_char

draw_trailchar:
.(
    sta s
    jsr fetch_foreground_char
    lda s
    jsr blit_left_whole_char
    lda s
    jsr blit_right_whole_char
    lda d+1
    eor #framemask
    sta scr+1
    lda d
    sta scr
    ldy #7
l1: lda (d),y
    sta (scr),y
    dey
    bpl l1
    rts
.)

no_more_bricks:
#ifdef TIMING
    lda #8+blue
    sta $900f
#endif
    rts

draw_foreground:
.(
    lda #0
    ldx #bricks_col-bricks_c-1
i1: sta bricks_c,x
    dex
    bpl i1

    lda #>background
    sta s+1

    lda #foreground
    ora spriteframe
    sta next_foreground_char

    lda scrolled_bits
    and #%111
    bne n1
    inc scrolled_chars
n1: dec scrolled_bits

    lda scrolled_bits
    and #%110
    and #7
    sta blitter_shift_left
    lda #8
    sec
    sbc blitter_shift_left
    and #7
    sta blitter_shift_right

    lda #<background
    jsr draw_trailchar
    lda #<bg_t
    jsr draw_trailchar

    lda leftmost_brick
    sta counter

next_brick:
    inc counter
retry_brick:
    ldx counter
    lda scrbricks_i,x
    bmi no_more_bricks
    sta tmp2
    lda scrbricks_y,x
    sta scry
    lda scrbricks_x,x
    sec
    sbc scrolled_chars
    sta scrx
    ldx tmp2
    lda bricks_c,x
    beq draw_chars
restart_plotting_chars:
#ifdef TIMING
    lda #8+red
    sta $900f
#endif
    lda scrx
    cmp #$ff
    beq draw_right      ; Draw only right char...
    cmp #$fe
    beq new_brick       ; Replace brick...
    cmp #22
    bcs next_brick      ; Off-screen...
    jsr scrcoladdr
    lda bricks_col,x    ; Set left char and color.
    ldy #0
    sta (col),y
    lda bricks_c,x
    ldy #0
    sta (scr),y
draw_right:
    inc scrx
    lda scrx
    cmp #22
    bcs next_brick      ; Off-screen.
    jsr scraddr
    lda blitter_shift_left
    beq plot_trail      ; No shift, plot trail.
    lda bricks_c,x      ; Plot regular right char.
    clc
    adc #1
plot:
    ldy #0
    sta (scr),y
    jmp next_brick
plot_trail:
    lda bricks_r,x
    beq plot
    cmp #<background
    bne try_foreground
    lda spriteframe     ; Plot foreground char.
    ora #foreground
    jmp plot
try_foreground:
    cmp #<bg_t
    bne next_brick
    lda spriteframe
    ora #foreground+1
    jmp plot

new_brick:
    lda #23
    clc
    adc scrolled_chars
    ldx counter
    sta scrbricks_x,x
    jmp next_brick

draw_chars:
#ifdef TIMING
    lda #8+yellow
    sta $900f
#endif
    jsr fetch_foreground_char
    sta bricks_c,x
    lda blitter_shift_left
    beq s1
    lda bricks_l,x
    beq s1
    jsr blit_right_whole_char
s1: lda bricks_m,x
    jsr blit_left_whole_char
    jsr fetch_foreground_char
    lda blitter_shift_left
    beq r1
    lda bricks_m,x
    jsr blit_right_whole_char
    lda bricks_r,x
    beq r1
    jsr blit_left_whole_char
r1: ldx tmp2
    jmp restart_plotting_chars
.)