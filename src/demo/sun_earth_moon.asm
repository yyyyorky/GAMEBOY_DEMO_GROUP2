
; VBLANK INTERRUPT HANDLER
SECTION "Vblank", ROM0[$40]
  jp Shadow_OAM_Copy




; BEGINNING OF CODE
SECTION "sem", ROM0

INCLUDE "gb/hardware.inc"
INCLUDE "assets/graphics.inc"
INCLUDE "assets/tables.inc"
INCLUDE "assets/tables2.inc"


; CONSTANTS

; OBJECT COUNT (MAX: 40)
DEF OBJCOUNT EQU 40

; VARIABLES AND STRUCTURES STORED IN RAM
DEF SHADOW_OAM EQU _RAM 
DEF EARTHX EQU SHADOW_OAM +140
DEF EARTHY EQU SHADOW_OAM +141
DEF TIME EQU SHADOW_OAM + 142


sem::


	; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
.wait:
	ld a, [rLY]
	cp 144
	jp nz, .wait

	
; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	; Copy the tile data for background
	ld de, Tiles
	ld hl, $9000
	ld bc, TilesEnd - Tiles
CopyTiles:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTiles

	; Copy the tile data for objects
	ld de, ObjTiles
	ld hl, $8000
	ld bc, ObjTilesEnd - ObjTiles
CopyObjTiles:
	ld a, [de]
	ldi [hl], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyObjTiles

	; Copy the tilemap
	ld de, Tilemap
	ld hl, $9800
	ld bc, TilemapEnd - Tilemap
CopyTilemap:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTilemap

; clear OAM
        ld hl,_OAMRAM
        ld b, 40*4
        ld a, 0
OAM_clear_loop:
        ld [hl], a
        inc hl
        dec b
        jp nz,OAM_clear_loop

; clear SHADOW OAM
        ld hl,SHADOW_OAM
        ld b, 40*4
        ld a, 0
SHADOW_OAM_clear_loop:
        ld [hl], a
        inc hl
        dec b
        jp nz,SHADOW_OAM_clear_loop

  ; prepare OBJ1 palette 
  ld a,%11100100
  ld [rOBP1],a

  ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
  ld [rLCDC], a

  ld a, IEF_VBLANK 
  ld [rIE], a

  ld a,0
  ld [TIME],a
  ei  




; 2. MAIN LOOP
main_loop:
; UPDATE OBJECTS IN SHADOW_OAM
  ld de,SHADOW_OAM

  ld hl, sine
  ld a, [TIME]
  ld c,a
  ld b,0
  add hl, bc
  ld a,[hl] 
  add a,20 ; center circle a little more
  ld [EARTHX], a
  ld [de], a   ; get sine(time)

  inc de ; x coordinate

  ld hl, cosine
  ld a, [TIME]
  ld c,a
  ld b,0
  add hl, bc
  ld a,[hl]   ; get cos(time) 
  add a,20 ; center circle a little more
  ld [EARTHY], a
  ld [de], a

  inc de
  inc de
  inc de

  ld hl, sine2
  ld a, [TIME]
  ld c,a
  ld b,0
  add hl, bc
  ld a,[hl]
  ld b,a
  ld a,[EARTHX]
  add a,b
  add a,-15
  ld [de], a

  inc de ; x coordinate

  ld hl, cosine2
  ld a, [TIME]
  ld c,a
  ld b,0
  add hl, bc
  ld a,[hl] 
  ld b,a
  ld a,[EARTHY]
  add a,b
  add a,-15
  ld [de], a

  inc de
  ld a, 1
  ld [de], a
  inc de
  inc de



; END OF UPDATE OBJECTS IN SHADOW_OAM

  ld hl, TIME
  inc [hl]

  jp main_loop



.end:
  ret

Shadow_OAM_Copy:
  ld de, SHADOW_OAM
  ld hl, _OAMRAM
  ld b, OBJCOUNT
.loop:
  ld a, [de]
  inc e
  ld [hli], a
  ld a, [de]
  inc e
  ld [hli], a
  ld a, [de]
  inc e
  ld [hli], a
  ld a, [de]
  inc e
  ld [hli], a
  dec b
  jr nz, .loop
  reti 

