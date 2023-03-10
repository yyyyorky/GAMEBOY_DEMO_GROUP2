SECTION "kirby", ROMX

INCLUDE "assets/kirby_map.inc"
INCLUDE "gb/constants.inc"

FADE_FACT EQU 2
FADE_FACE_OFFSET EQU 85
FLICKER_DELAY EQU $20
PAL_VISIBLE EQU %11100100
PAL_NOT_VISIBLE EQU %00000000





update_kirby::

.update_kirby_internal:
    ld HL, START_FADE
    ld A, [HL]
    cp $01
    jp z, .loop
    
    
    ld HL, TIME
    inc [HL]
    ld A,[HL]
    cp A, 0
    
    jr z, .start_fade_anim
    ld HL, FLICKER_TIMER
    ld A, [HL]
    dec [HL]
    cp $00
    jr nz, .flicker_instr_0
    ld HL, FLICKER_PAL
    ld A, [HL]
    cp PAL_VISIBLE
    jr z, .flicker_instr_not_vis

.flicker_instr_vis:
    ld HL, FLICKER_TIMER
    ld [HL], FLICKER_DELAY
    ld HL, FLICKER_PAL
    ld [HL], PAL_VISIBLE
    jr .flicker_instr_0

.flicker_instr_not_vis:
    ld HL, FLICKER_TIMER
    ld [HL], FLICKER_DELAY
    ld HL, FLICKER_PAL
    ld [HL], PAL_NOT_VISIBLE

.flicker_instr_0:

    ld A, [LCD_LINE_Y]
    cp 0
    jr nz, .flicker_instr_0
    ld HL, FLICKER_PAL
    ld A, [HL]
    ld HL, LCD_BG_PAL
    ld [HL], A

.flicker_instr_1:
    ld A, [LCD_LINE_Y]
    cp 142
    jr nz, .flicker_instr_1
    ld HL, LCD_BG_PAL
    ld [HL], %11100100

    ret
    ;jp .update_kirby_internal

    ;11100100

.start_fade_anim:
    ld HL, START_FADE
    ld [HL], $01
    call wait_vblank

.loop:
    ld A, [LCD_LINE_Y]
    cp $00
    jr nz, .loop
    ld B, $00
    ld HL, ADDR
    ; load sine SINE_TABLE offset
    ld D, [HL]
    inc HL
    ld E, [HL]
    inc [HL]
    ld A, E
    cp $FF
    jr nz, .loop_0
    ld BC, SINE_TABLE_0
    ld [HL], C

.loop_1:
    ld A, [LCD_LINE_Y]
    cp $90
    jr nz, .loop_1
    jp .update_kirby_internal

.loop_0:
    ld A, [LCD_LINE_Y]
    cp B
    jr nz, .loop_0
    inc B
    inc DE
    ld A, [DE]
    ld HL, LCD_SCROLL_X
    ld [HL], A
    ld A, B
    cp $90
    jr z, .fade
    jp .loop_0

.fade:
    ld HL, FADE_STEP
    ld A, [HL]
    cp FADE_FACE_OFFSET + (FADE_FACT * 0)
    jr z, .fade_0
    cp FADE_FACE_OFFSET + (FADE_FACT * 1)
    jr z, .fade_1
    cp FADE_FACE_OFFSET + (FADE_FACT * 2)
    jr z, .fade_2
    cp FADE_FACE_OFFSET + (FADE_FACT * 3)
    jr z, .fade_3
    cp FADE_FACE_OFFSET + (FADE_FACT * 4)
    jr z, .fade_4
    cp FADE_FACE_OFFSET + (FADE_FACT * 5)
    jr z, .fade_5
    cp FADE_FACE_OFFSET + (FADE_FACT * 6)
    jr z, .reset_fade
    jr .end_fade

.fade_0:
    ld HL, LCD_BG_PAL
    ld [HL], %11100100
    jr .end_fade
.fade_1:
    ld HL, LCD_BG_PAL
    ld [HL], %11111001
    jr .end_fade
.fade_2:
    ld HL, LCD_BG_PAL
    ld [HL], %11111001
    jr .end_fade
.fade_3:
    ld HL, LCD_BG_PAL
    ld [HL], %11111110
    jr .end_fade
.fade_4:
    ld HL, LCD_BG_PAL
    ld [HL], %11111110
    jr .end_fade
.fade_5:
    ld HL, LCD_BG_PAL
    ld [HL], %11111111
    jr .end_fade
    
.end_fade:
    ld HL, FADE_STEP
    inc [HL]
    jr .end_0

.reset_fade:
    ld HL, START_FADE
    ld [HL], $00
    ld HL, FADE_STEP
    ld [HL], $00
    ld HL, LCD_BG_PAL
    ld [HL], %11100100
    jp demo3

.end_0:
    ret

load_kirby_data::
    ld HL, FLICKER_TIMER
    ld [HL], FLICKER_DELAY
    ld HL, FLICKER_PAL
    ld [HL], PAL_VISIBLE
    ld HL, LCD_CTRL
    res 1, [HL]
    ld HL, FADE_STEP
    ld [HL], $00
    ld HL, ADDR
    ld BC, SINE_TABLE_0
    ld [HL], B
    inc HL
    ld [HL], C
    
    ld A,0
    ld HL, TIME
    ld [HL],A
    
    

    ld HL, LCD_CTRL
    ; disable CHR, since we don't need it for 
    ; kirby
    set 3, [HL]
    ; enable BG
    res 4, [HL]
    ; set BG palette
    ld HL, LCD_BG_PAL
    ld [HL], %11100100
        
    ; load top tile map to vram (background)
    ld DE, VRAM_MAP_BLOCK0_SIZE
    ld BC, kirby_tile_data
    ld HL, VRAM_TILES_BACKGROUND
    call memcpy
    
    ; Load tile data
    call .load_kirby_tiles
    ret

.load_kirby_tiles:
    ; We just load every line by hand.
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $0)
    ld HL, $9C00
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $1)
    ld HL, $9C20
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $2)
    ld HL, $9C40
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $3)
    ld HL, $9C60
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $4)
    ld HL, $9C80
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $5)
    ld HL, $9CA0
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $6)
    ld HL, $9CC0
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $7)
    ld HL, $9CE0
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $8)
    ld HL, $9D00
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $9)
    ld HL, $9D20
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $A)
    ld HL, $9D40
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $B)
    ld HL, $9D60
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $C)
    ld HL, $9D80
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $D)
    ld HL, $9DA0
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $E)
    ld HL, $9DC0
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $F)
    ld HL, $9DE0
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $10)
    ld HL, $9E00
    call memcpy
    ld DE, $15
    ld BC, kirby_map_data + ($14 * $11)
    ld HL, $9E20
    call memcpy
    ret

SECTION "kirby_data", ROMX[$6700]
SINE_TABLE_0:
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255,254,254,254,254,253,253,253,252,252,252,251,251,251,251,250,250,250,250,249,249,249,249,249,249,249,249,250,250,250,251,251,252,252,253,253,254,255,0,0,1,2,3,4,5,7,8,9,11,12,13,15,16,17,19,20,21,22,24,25,26,27,28,28,29,30,30,30,30,30,30,30,29,28,28,27,25,24,22,20,18,16,14,11,9,6,3,0,253,250,246,243,239,235,231,227,223,220,216,212,208,205,201,198,194,191,188,186,183,181,179,177,176,175,174,174,174,175,176,177,179,181,184,187,190,194,198,203,208,214,219,226,232,239,246,254,5,13,21,29,38,46,55,63,72,80,89,97,105,113,120,127,134,140,146,152,157,161,164,168,170,171,172,173,172,170,168,165,161,156,151,144,137,129,120,111,100,89,77,65,52,38,24,9,251,236,220,204,188,172,156,140,124,108,92,77,62,48,35,22,9,254,243,234,225,218,211,206,202,200,198,198,200,203,207,213,220,229,239,250,7,22,37,55,73,92,113,135,157,181,206,231,0,26,53,80,108,135,162,190,217,243,13,39,63,87,110,131,152,170,188,204,218,230,240,248,255,3,5,5,2,253,246,237,225,211,194,176,155,131,106,79,49,18,241,207,170,133,94,54,13,228,186,143,100,57,14,227,185,143,103,63,25,244,209,175,144,115,88,64,42,23,7,250,241,234,231,231,235,242,253,11,29,50,75,103,134,169,207,248,36,83,132,184,238,38,96,155,216,21,84,147,211,19,83,146,208,14,74,132,189,243,39,88,134,177,217,253,29,57,81,100,114,124,130,130,125,115,100,80,55,25,246,206,161,112,58,0,193,127,57,240,163,83,1,173,87,0,166,76,242,151,61,228,139,52,223,141,61,240,166,96,31,226,170,119,73,33,255,227,206,191,183,182,187,200,219,246,24,64,112,166,227,38,111,191,20,110,206,50,155,8,120,235,97,217,82,205,73,197,64,186,51,170,30,144,253,103,203,43,133,217,38,109,172,227,19,58,88,110,123,126,121,105
SECTION "kirby_var", WRAM0

ADDR: DS 2
FADE_STEP: DS 1
START_FADE: DS 1
FLICKER_PAL: DS 1
FLICKER_TIMER: DS 1
TIME: DS 1
