;SECTION "rom", ROM0

INCLUDE "gb/interrupts.inc"
INCLUDE "gb/constants.inc"
INCLUDE "gb/macros.inc"
INCLUDE "gb/hardware.inc"
;jp main

;INCLUDE "gb/header.inc"

;main::
    ;nop
    ;jp Start


;==============================================================
SECTION	"ROM Header",ROM0[$100]
ROMHeader::
	nop
	jp	Start

	NINTENDO_LOGO
	DB	"  GROUP2   "	; game title
	DB	$0000	; product code
	DB	CART_COMPATIBLE_DMG
	DW	$00	; license code
	DB	$00;CART_INDICATOR_GB
	DB	$00;CART_ROM_MBC5
	DB	$00;CART_ROM_32K
	DB	$00;CART_SRAM_NONE
	DB	$01;CART_DEST_NON_JAPANESE
	DB	$33	; licensee code
	DB	$00	; mask ROM version
	DB	$00	; complement check
	DW	$00	; cartridge checksum


;==============================================================
; starting point
;==============================================================

SECTION	"Start",ROM0[$150]

Start::
    
demo1:
    call brick

demo2:
    ld B, $00 ; clear tile id
    _RESET_
    call wait_vblank
    call lcd_off
    call load_kirby_data
    call lcd_on

.main_loop_kirby:
    call wait_vblank
    call update_kirby
    jr .main_loop_kirby

demo3::
    ld B, $00 ; clear tile id
    _RESET_
    call sem
    ld B, $00 ; clear tile id
    _RESET_
    call wait_vblank
    call lcd_off


