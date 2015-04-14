grenade_left: 0
grenade_right: 0

start_grenade:
    lda @(+ sprites_x 15)
    lsr
    lsr
    lsr
    sta grenade_left
    sta grenade_right
    lda #22
    sta grenade_counter
    rts

grenade:
    lda grenade_counter
    beq +done
    dec grenade_counter

draw_grenade:
    ldy #14
l:  tya
    pha
    lda sprites_i,y
    and #deadly
    beq +n
    jsr explode
n:  pla
    tay
    dey
    bpl -l

    dec grenade_left
    inc grenade_right

    lda grenade_left
    sta scrx
    lda #128
    jsr grenade_bar
    inc scrx
    lda #0
    jsr grenade_bar

    lda grenade_right
    sta scrx
    lda #0
    jsr grenade_bar
    inc scrx
    lda #128

grenade_bar:
    sta @(++ grenade_bar_color)
    lda #22
    sta scry
l:  jsr scrcoladdr
    cpy #22
    bcs +done
    lda (scr),y
    and #foreground
    cmp #foreground
    beq +n
grenade_bar_color:
    lda #0
    sta (scr),y
    lda #white
    sta (col),y
n:  dec scry
    bpl -l
done:
    rts
