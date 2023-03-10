SECTION "lcd", ROMX

INCLUDE "gb/constants.inc"

lcd_off::
    ld HL, LCD_CTRL
    res 7, [HL]
    ret

lcd_on::
    ld HL, LCD_CTRL
    set 7, [HL]
    ret

wait_vblank::
    ld A, [LCD_LINE_Y]
    cp 144
    jr nz, wait_vblank
    ret

clear_bg_map::
    ld HL, $9C00

.clear_loop:
    ld [HL], B
    inc HL
    ld A, H
    cp $9F
    jr nz, .clear_loop
    ld A, L
    cp $FF
    jr nz, .clear_loop
    ret
