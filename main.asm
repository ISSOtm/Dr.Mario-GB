

INCLUDE "constants.asm"
INCLUDE "charmap.asm"


SECTION "ROM", ROM0[$0000]

Reset:
	jp   Init

	; Uninit'd data ?
	nop
	nop
	nop
	nop
	nop

PerformDelay:
	push bc
	ld   b,$FA
	ld   b,b
	dec  b
	jr   nz,PerformDelay
	pop  bc
; 0010
	ret

	; Uninit'd data ?
	rst  $38
	cp   a
	rst  $38
	xor  a
	ld   a,a
	xor  a,$FF

CopyString:
	ld   a,[de]
	cp   a,$FF
	ret  z
	ldi  [hl],a
	inc  de
	jr   CopyString

	; Uninit'd data ?
; 0020
	rst  $28
	rst  $38
	rst  $28
	rst  $38
	ld   [wUnk_FBFE],a
	rst  $38

JumpTableBelow:
	add  a
	pop  hl
	ld   e,a
	ld   d,$00
	add  hl,de
	ld   e,[hl]
	inc  hl
; 0030
	ld   d,[hl]
	push de
	pop  hl
	jp   hl

	; Uninit'd data ?
	cp   e
	rst  $38
	rst  $38
	rst  $38
; 0038
	cp   a
	rst  $38
	cp   d
	rst  $38
	xor  a,$FF
	xor  d
	rst  $38

VBlankInt:
	jp   VBlankHandler

	; Uninit'd data ?
	rst  $38
	cp   a
	rst  $38
	cp   [hl]
	rst  $38

STATInt:
	jp   LCDHandler

	; Uninit'd data ?
	rst  $38
	cp   d
	rst  $38
	rst  $38
	rst  $38

TimerInt:
	jp   TimerHandler

	; Uninit'd data ?
	rst  $38
	xor  a
	rst  $38
	xor  a
	db   $FD

SerialInt:
	push af
	push bc
	ldh  a,[rSB]
	ldh  [hSerialRecieved],a
	ld   b,a
	ld   a,[wUnk_C4F1]
	and  a
	jr   z,.unk_008B
	ldh  a,[hUnk_FFE4]
	and  a
	jr   nz,.unk_008B
	ld   a,[wUnk_C0A5]
	and  a
	ldh  a,[hSerialRecieved]
	jr   nz,.unk_007F
	cp   a,$FE
	jr   nz,.unk_008E
	ld   a,$01
	ldh  [hUnk_FFDC],a
	ld   [wUnk_C0A5],a
	jr   .unk_008E
.unk_0007F
	ld   [wUnk_C0A4],a
	ld   [wUnk_D020],a
	xor  a
	ld   [wUnk_C0A5],a
	jr   .unk_008E
.unk_008B
	ld   a,b
	ldh  [hUnk_FFD0],a
.unk_008E
	xor  a
	ld   [wUnk_D008],a
	inc  a
	ldh  [hSerialTransferDone],a

	ldh  a,[hSerialRole]
	cp   a,SERIAL_ROLE_MASTER
	jr   z,.unk_00BF
	ldh  a,[hSerialNext]
	ldh  [rSB],a
	call Unk_0153
	ldh  a,[hSerialRecieved]
	cp   a,$F0
	jp   z,Init
	xor  a
	ldh  [rSC],a
	ld   a,$80
	ldh  [rSC],a
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_00BF
	ld   a,[wHasGameStarted]
	and  a
	jr   z,.unk_00BF
	ld   a,$E0
	ldh  [hSerialNext],a
.unk_00BF
	pop  bc
	pop  af
	reti

Unk_00C2:
	ldh  a,[hUnk_FFB5]
	ld   d,a
	ldh  a,[hUnk_FFB4]
	ld   e,a
	ld   b,$04
.unk_00CA
	rr   d
	rr   e
	dec  b
	jr   nz,.unk_00CA
	ld   a,e
	sub  a,$84
	and  a,$FE
	rlca
	rlca
	add  a,$08
	ldh  [hUnk_FFB2],a
	ldh  a,[hUnk_FFB4]
	and  a,$1F
	rla
	rla
	rla
	add  a,$08
	ldh  [hUnk_FFB3],a
	ret

Unk_00E8:
	rla
	rla
	add  a,$08
	ldh  [hUnk_FFB3],a
	ret

	; Uninit'd data ?
	rst  $38
	xor  a
	cp   a
	cp   d
	rst  $38
	db   $EB
	rst  $38
	ei
	rst  $38
	xor  [hl]
	rst  $38
	rst  $38
	rst  $38
	cp   [hl]
	rst  $38
	ei
	rst  $38


ROMEntryPoint:
	nop
	jp   EntryPoint

	NINTENDO_LOGO
	db   "DR.MARIO",0,0,0,0,0,0,0
	db   CART_COMPATIBLE_DMG ; DMG - classic gameboy
	db   $00,$00             ; new license
	db   $00                 ; SGB flag: not SGB capable
	db   CART_ROM            ; cart type: ROM
	db   CART_ROM            ; ROM size: 32 KiB
	db   CART_RAM_NONE       ; RAM size: 0 B
	db   $00                 ; destination code: Japanese
	db   $01                 ; old license: not SGB capable
	db   $00                 ; mask ROM version number
	db   $AA                 ; header check (OK)
	db   $01,$FD             ; global check (okay)

EntryPoint:
	jp   Init


Unk_0153:
	ld   bc,$D00E
	ld   a,[bc]
	and  a
	jr   nz,.unk_0167
	ldh  a,[hSerialNext]
	cp   a,$FE
	jr   nz,.unk_0164
	ld   a,$01
	jr   .unk_0165
.unk_0164
	xor  a
.unk_0165
	ld   [bc],a
	ret
.unk_0167
	ld   a,[wUnk_D046]
	ldh  [rSB],a
	jr   .unk_0164

Unk_016E:
	call Unk_2359
.waitHBlank1
	ldh  a,[rSTAT]
	and  a,$03
	jr   nz,.waitHBlank1
	ld   b,[hl]
.waitHBlank2
	ldh  a,[rSTAT]
	and  a,$03
	jr   nz,.waitHBlank2
	ld   a,[hl]
	and  b
	ret

Unk_0181: ; Adds DE to the score pointed to by hl, with a 9 99 99 99 cap
	ld   a,e
	add  [hl]
	daa
	ldi  [hl],a
	ld   a,d
	adc  [hl]
	daa
	ldi  [hl],a
	ld   a,$00
	adc  [hl]
	daa
	ldi  [hl],a
	ld   a,$00
	adc  [hl]
	daa
	ld   [hl],a
	ld   a,$01
	ldh  [hUnk_FFE0],a
	ld   a,[hl]
	swap a
	and  a,$0F
	ret  z
	ld   a,$09
	ldd  [hl],a
	ld   a,$99
	ldd  [hl],a
	ldd  [hl],a
	ld   [hl],a
	ret

VBlankHandler:
	push af
	push bc
	push de
	push hl
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_01BA
	ld   a,[wHasGameStarted]
	and  a
	jr   z,.unk_01BA
	ldh  a,[hWaitFrames]
	and  a
	jr   nz,.dontTransferSprites
.unk_01BA
	ldh  a,[hGameStatus]
	cp   a,$03
	jr   z,.dontTransferSprites
	call hDMARoutine
.dontTransferSprites
	call Unk_2E2D
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_01D4
	ld   de,$C0A3
	ld   hl,$984C
	call Unk_257B
.unk_01D4
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.skipRemovedCode
	ld   a,[wHasGameStarted]
	and  a
	jr   z,.skipRemovedCode
.skipRemovedCode
	ld   a,$01
	ldh  [hVBlankStatus],a
	pop  hl
	pop  de
	pop  bc
	pop  af
	reti

Init:
	xor  a
	ld   hl,$DFFF
	ld   c,$10
	ld   b,$00
.clearWRAM1
	ldd  [hl],a
	dec  b
	jr   nz,.clearWRAM1
	dec  c
	jr   nz,.clearWRAM1
	ld   a,$0D
	di
	ldh  [rIF],a
	ldh  [rIE],a
	xor  a
	ldh  [rSCY],a
	ldh  [rSCX],a
	ldh  [hUnk_FFA4],a
	ldh  [rSTAT],a
	ldh  [rSB],a
	ldh  [rSC],a
	ld   [wUnk_D000],a
	ld   [wUnk_D001],a
	ld   a,$80
	ldh  [rLCDC],a
.waitVBlank
	ldh  a,[rLY]
	cp   a,$94
	jr   nz,.waitVBlank
	ld   a,$03
	ldh  [rLCDC],a
	ld   a,$E1
	ldh  [rBGP],a
	ldh  [rOBP0],a
	ld   a,$E5
	ldh  [rOBP1],a
	ld   hl,$FF26
	ld   a,$80
	ldd  [hl],a
	ld   a,$FF
	ldd  [hl],a
	ld   [hl],$77
	ld   hl,rTMA
	ld   a,$BF
	ldi  [hl],a
	ld   a,$04
	ld   [hl],a
	ld   a,$01
	ld   [Bankswitch],a
	ld   sp,wStackBottom
	xor  a
	ld   hl,$DFFF
	ld   b,$00
.clearDFXX
	ldd  [hl],a
	dec  b
	jr   nz,.clearDFXX
	ld   hl,wStackBottom
	ld   c,$10
	ld   b,$00
.clearWRAM0
	ldd  [hl],a
	dec  b
	jr   nz,.clearWRAM0
	dec  c
	jr   nz,.clearWRAM0
	ld   hl,$9FFF
	ld   c,$20
	xor  a
	ld   b,$00
.clearVRAM
	ldd  [hl],a
	dec  b
	jr   nz,.clearVRAM
	dec  c
	jr   nz,.clearVRAM
	ld   hl,$FEFF
	ld   b,$00
.clearFEXX
	ldd  [hl],a
	dec  b
	jr   nz,.clearFEXX
	ld   hl,$FFFE
	ld   b,$80
.clearHRAM
	ldd  [hl],a
	dec  b
	jr   nz,.clearHRAM
	ld   c,$B6
	ld   b,$0A
	ld   hl,DMARoutine
.copyDMARoutine
	ldi  a,[hl]
	ld   [c],a
	inc  c
	dec  b
	jr   nz,.copyDMARoutine
	call Clear9800Map
	call JumpToInitMusic
	call CopyTiles
	ld   a,$0D
	ldh  [rIE],a
	ld   a,$80
	ldh  [rLCDC],a
	xor  a
	ldh  [rIF],a
	ldh  [rWY],a
	ldh  [rWX],a
	ldh  [hGameStatus],a
	ldh  [hUnk_FF9C],a
	ei

MainLoop:
	di
	ld   a,[wHasGameStarted]
	and  a
	jr   z,.skipSerialStuff
	ldh  a,[hSerialTransferDone]
	and  a
	ld   a,$00
	ldh  [hSerialTransferDone],a
	jr   nz,.unk_02BC
	ld   a,$E0
	jr   .unk_02BE
.unk_02BC
	ldh  a,[hSerialRecieved]
.unk_02BE
	ldh  [hUnk_FFD0],a
.skipSerialStuff
	ei
	call Unk_SerialRelated
	call PollJoypad
	ld   hl,wUnk_Request
	ld   a,[hl]
	and  a
	jr   z,.unk_02D3
	xor  a
	ld   [hl],a
	call Unk_3002
.unk_02D3
	call GameStatus_Dispatch
	ldh  a,[hIsDemoActive]
	and  a
	jr   nz,.unk_033A
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_0311
	ld   a,[wHasGameStarted]
	and  a
	jr   z,.unk_02F1
	ldh  a,[hUnk_FFAB]
	and  a
	jr   nz,.unk_02F1
	call Unk_0364
	call Unk_03E4
.unk_02F1
	ldh  a,[hUnk_FFDE]
	ld   [wUnk_DF8F],a
	and  a
	jr   z,.unk_0305
	cp   a,$01
	jr   z,.unk_0309
	cp   a,$02
	jr   z,.unk_030D
	ld   a,$D8
	jr   .unk_030F
.unk_0305
	ld   a,$BF
	jr   .unk_030F
.unk_0309
	ld   a,$C8
	jr   .unk_030F
.unk_030D
	ld   a,$D0
.unk_030F
	ldh  [rTMA],a
.unk_0311
	ldh  a,[hSerialRole]
	cp   a,$60
	jr   z,.unk_033A
	ldh  a,[hJoyHeld]
	and  a,$0F
	cp   a,$0F
	jr   nz,.unk_033A
	ldh  a,[hTwoPlayerMode]
	and  a
	jp   z,Init
	rst  $08
	rst  $08
	xor  a
	ldh  [hSerialTransferDone],a
	ld   a,$F0
	ldh  [rSB],a
	ld   a,$81
	ldh  [rSC],a
.unk_0332
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.unk_0332
	jp   Init

.unk_033A
	ld   hl,hUnk_FFA6
	ld   b,$02
.unk_033F
	ld   a,[hl]
	and  a
	jr   z,.unk_0344
	dec  [hl]
.unk_0344
	inc  l
	dec  b
	jr   nz,.unk_033F
	ld   hl,hUnk_FFE2
	inc  [hl]
	ld   hl,hUnk_FFE5
	inc  [hl]
	ld   hl,hUnk_FFE6
	inc  [hl]
	ld   hl,hUnk_FFE7
	inc  [hl]
.waitVBlank
	halt
	ldh  a,[hVBlankStatus]
	and  a
	jr   z,.waitVBlank
	xor  a
	ldh  [hVBlankStatus],a
	jp   MainLoop

Unk_0364:
	ldh  a,[hUnk_FFDC]
	and  a
	jr   nz,.unk_03A3
	ldh  a,[hUnk_FFD0]
	cp   a,$FD
	jr   z,.unk_0379
	cp   a,$F8
	jr   z,.unk_0394
	cp   a,$55
	ret  nc
	ldh  [hUnk_FFD3],a
	ret
.unk_0379
	xor  a
	ldh  [hUnk_FFD0],a
	ld   a,$F8
	ldh  [hUnk_FFF4],a
	ld   b,$17
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_038C
	ld   a,$01
	ldh  [hGameMode],a
	ret

.unk_038C
	ld   a,$10
	ldh  [hUnk_FFA6],a
	ld   a,b
	ldh  [hGameStatus],a
	ret
.unk_0394
	ld   a,$FD
	ldh  [hUnk_FFF4],a
	ld   b,$0F
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_038C
	ld   b,$17
	jr   .unk_038C

.unk_03A3
	ld   a,[wUnk_C0A4]
	and  a
	ret  z
	cp   a,$E0
	ret  z
	ld   b,a
.unk_03AC
	ld   a,b
	and  a,$C0
	jr   nz,.unk_03B7
	sla  b
	sla  b
	jr   .unk_03AC
.unk_03B7
	ld   c,b
	ldh  a,[hUnk_FFD9]
	ld   d,a
.unk_03BB
	ld   a,d
	and  a,$C0
	jr   nz,.unk_03D1
	ld   a,c
	and  a,$C0
	jr   z,.unk_03DE
	sla  c
	rl   d
	sla  c
	rl   d
	ld   a,c
	and  a
	jr   nz,.unk_03BB
.unk_03D1
	ld   a,d
	ldh  [hUnk_FFD9],a
	ld   [wUnk_D016],a
	xor  a
	ldh  [hUnk_FFDC],a
	ld   [wUnk_C0A4],a
	ret
.unk_03DE
	sla  c
	sla  c
	jr   .unk_03C0

Unk_03E4:
	ld   de,$D008
	ld   hl,$FFDD
	ld   a,[hl]
	cp   a,$02
	jr   z,.unk_0416
	cp   a,$01
	jr   z,.unk_0409
	ld   a,[de]
	and  a
	ret  nz
	ld   a,[wUnk_D00E]
	and  a
	jr   nz,.unk_0400
	ldh  a,[hUnk_FFD1]
	jr   .unk_0403
.unk_0400
	ld   a,[wUnk_D046]
.unk_0403
	ldh  [hSerialNext],a
	ld   a,[de]
	inc  a
	ld   [de],a
	ret

.unk_0409
	ld   a,[de]
	and  a
	ret  nz
	ld   a,$FE
	ldh  [hSerialNext],a
	ld   a,[de]
	inc  a
	ld   [de],a
	ld   [hl],$02
	ret

.unk_0416
	ld   a,[de]
	and  a
	ret  nz
	ldh  a,[hUnk_FFD8]
	ldh  [hSerialNext],a
	ld   [wUnk_D046],a
	xor  a
	ldh  [hUnk_FFD8],a
	ld   [hl],a
	inc  a
	ld   [de],a
	ldh  a,[hSerialRole]
	cp   a,$60
	ld   a,$0B
	jr   z,.unk_0430
	ld   a,$08
.unk_0430
	ld   [wUnk_DFE0],a
	ret

Unk_SerialRelated:
	ld   a,[wUnk_D03A]
	and  a
	ret  nz
	ldh  a,[hSerialRole]
	cp   a,$30
	ret  nz
	ldh  a,[hSerialNext]
	ldh  [rSB],a
	call Unk_0153
	xor  a
	ld   [wUnk_D008],a
	ld   a,[wHasGameStarted]
	and  a
	jr   nz,.unk_0450
	rst  $08
.unk_0450
	ld   a,$81
	ldh  [rSC],a
	ret

GameStatus_Dispatch:
	ldh  a,[hGameStatus]
	rst  $28

	dw InitTitleScreen
	dw ProcessTitleScreen
	dw PlayGame
	dw Unk_2FC6
	dw Unk_0EB4
	dw Unk_0FC8
	dw Unk_1139
	dw Unk_14F4
	dw Unk_1590
	dw Unk_0BE8
	dw Unk_336F
	dw Unk_0588
	dw Unk_0679
	dw Unk_0848
	dw Unk_09D6
	dw Unk_12F5
	dw Unk_13B8
	dw Unk_1432
	dw Unk_20FB
	dw Unk_1601
	dw Unk_059B
	dw Unk_21AF
	dw Unk_0DEB
	dw Unk_12AB
	dw Unk_1674
	dw Unk_3258
	dw Unk_16E8
	dw Unk_14A3
	dw Unk_20C8

InitTitleScreen:
	call ShutLCDDown
	call ClearOAMBuffer
	ld   de,TitleScreenTileMap
	call PrintTileMap
	ld   a,LCDCF_ON | LCDCF_OBJON | LCDCF_BGON
	ldh  [rLCDC],a

	xor  a
	ld   [wUnk_D03A],a
	ldh  [rSB],a
	ldh  [hSerialNext],a
	ldh  [hUnk_FFD0],a
	ldh  [hSerialRecieved],a
	ldh  [hTwoPlayerMode],a
	ld   [wHasGameStarted],a
	inc  a
	ldh  [hGameStatus],a
	ldh  [hIsDemoActive],a

	; Place heart
	ld   hl,wOAMBuffer
	ld   [hl],$70
	inc  l
	ld   [hl],$20
	inc  l
	ld   [hl],$9B
	ld   a,$03
	ldh  [hUnk_FFAD],a
	ldh  [hUnk_FFAE],a

Unk_04C9:
	ld   a,$02
	ldh  [hUnk_FFF0],a
	ld   a,$FF
	ldh  [hUnk_FFA6],a
	ld   a,$01
	ld   [wUnk_D054],a
	ld   [wUnk_DFE0],a
	ret

ProcessTitleScreen:
	ld   hl,hUnk_FFA6
	ld   a,[hl]
	and  a
	jr   nz,.unk_04FE
	ld   [hl],$FF
	ld   hl,hUnk_FFF0
	dec  [hl]
	jr   nz,.unk_04FE
	jr   .unk_04EE
	xor  a
	ldh  [hIsDemoActive],a
.unk_04EE
	xor  a
	ldh  [hTwoPlayerMode],a
	ld   a,$0A
	ldh  [hUnk_FFC2],a
	ld   a,$10
	ldh  [hUnk_FFC3],a
	ld   a,$02
	jp   .unk_0553

.unk_04FE
	rst  $08
	ld   a,$60
	ldh  [hSerialNext],a
	ldh  [rSB],a
	ld   a,$80
	ldh  [rSC],a
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.unk_051F
	xor  a
	ldh  [hSerialTransferDone],a
	ldh  a,[hUnk_FFD0]
	cp   a,SERIAL_ROLE_MASTER
	jr   z,.unk_0549
	cp   a,SERIAL_ROLE_SLAVE
	jr   z,.unk_055D
	call Unk_04C9
	ret

.unk_051F
	ldh  a,[hJoyPressed]
	ld   b,a
	ldh  a,[hTwoPlayerMode]
	bit  PADB_UP,b
	jr   nz,.unk_0583
	bit  PADB_DOWN,b
	jr   nz,.unk_057F
	bit  PADB_SELECT,b
	jr   nz,.unk_0561
	bit  PADB_START,b
	ret  z ; Stop here if START wasn't pressed

	and  a
	ld   a,$0B
	jr   z,.unk_0553

	ldh  a,[hUnk_FFD0] ; Check role sent by other GB
	cp   a,SERIAL_ROLE_MASTER
	jr   z,.unk_0549
	ld   a,SERIAL_ROLE_MASTER
	ldh  [hSerialNext],a
	ldh  [rSB],a
	ld   a,$81
	ldh  [rSC],a
	ret

.unk_0549
	ld   a,$01
	ldh  [hTwoPlayerMode],a
	ld   a,SERIAL_ROLE_SLAVE
.unk_054F
	ldh  [hSerialRole],a
	ld   a,$14
.unk_0553
	ldh  [hGameStatus],a
	xor  a
	ldh  [hUnk_FFA6],a
	ldh  [hSerialNext],a
	ldh  [hSerialRecieved],a
	ret
.unk_055D
	ld   a,SERIAL_ROLE_MASTER
	jr   .unk_054F

.unk_0561
	xor  a,$01
.unk_0563
	ldh  [hTwoPlayerMode],a
	ld   b,a
	ld   a,$01
	ld   [wUnk_D054],a
	ld   a,b
	and  a
	ld   a,$70
	jr   z,.unk_0573
	ld   a,$78
	ld   [wOAMBuffer],a
	ld   a,$01
	ld   [wUnk_DFE0],a
	call Unk_04C9
	ret

.unk_057F
	and  a
	ret  nz
	jr   .unk_0561
.unk_0583
	and  a
	ret  z
	xor  a
	jr   .unk_0563

Unk_0588:
	xor  a
	ldh  [hWaitFrames],a
	ld   a,$03
	ld   [wUnk_DFE8],a
	call Unk_21E3
	call Unk_2209
	ld   a,$0C
	ldh  [hGameStatus],a
	ret

Unk_059B:
	xor  a
	ldh  [hWaitFrames],a
	call Unk_21E3
	ld   a,$88
	ld   [wUnk_C009],a
	ld   a,$90
	ld   [wUnk_C00D],a
	ld   a,$34
	ld   [wUnk_C015],a
	ld   a,$5D
	ld   [wUnk_C021],a
	ld   a,$65
	ld   [wUnk_C025],a
	ld   a,$1C
	ld   [wUnk_C049],a
	ld   a,$24
	ld   [wUnk_C04D],a
	ld   a,$2C
	ld   [wUnk_C051],a
	ld   a,$1C
	ld   [wUnk_C061],a
	ld   a,$24
	ld   [wUnk_C065],a
	ld   a,$2C
	ld   [wUnk_C069],a
	call Unk_0664
	call Unk_2209
	ld   a,$10
	ldh  [hUnk_FFA7],a
	ld   a,$0C
	ldh  [hGameStatus],a
	ret

	; What is this data ?
	ccf
	adc  b
	nop
	nop
	ccf
	sub  b
	nop
	nop
	ld   c,c
	ldh  a,[rP1]
	nop
	ld   c,c
	ldh  a,[rP1]
	nop
	dec  sp
	inc  [hl]
	daa
	nop
	ld   c,l
	ldh  a,[hUnk_FF27]
	ld   b,b
	ld   h,d
	ld   e,h
	sbc  h
	nop
	ld   h,d
	ld   h,h
	sbc  h
	jr   nz,.unk_0676
	ldh  a,[hUnk_FF9C]
	ld   b,b
	ld   l,[hl]
	ldh  a,[hUnk_FF9C]
	ld   h,b
	adc  b
	jr   nz,.unk_0610
	nop
	adc  b
	jr   z,.unk_0614
	nop
	adc  b
	jr   nc,.unk_0618
	nop
	adc  b
	ld   c,b
	cp   a,$00
	adc  b
	ld   d,b
	cp   a,$00
	ccf
	inc  e
	ldi  [hl],a
	nop
	ccf
	inc  h
	jr   .unk_062B
	ccf
	inc  l
	ld   e,$00
	ld   c,c
	ldh  a,[hUnk_FF0C]
	nop
	ld   c,c
	ldh  a,[hUnk_FF18]
	nop
	ld   c,c
	ldh  a,[hUnk_FF16]
	nop
	ld   h,h
	inc  e
	ldi  [hl],a
	nop
	ld   h,h
	inc  h
	jr   .unk_0643
	ld   h,h
	inc  l
	ld   e,$00
	ld   l,l
	ldh  a,[hUnk_FF0C]
	nop
	ld   l,l
	ldh  a,[hUnk_FF18]
	nop
	ld   l,l
	ldh  a,[hUnk_FF16]
	rst  $38

Unk_0653:
	ldh  a,[hUnk_FFC3]
	ld   hl,$C002
	call Unk_077D
	ldh  a,[hUnk_FFC2]
	ld   hl,$C011
	call Unk_078B
	ret

Unk_0664:
	ldh  a,[hSerialRole]
	and  a
	ret  z
	ldh  a,[hUnk_FFC5]
	ld   hl,$C00A
	call Unk_077D
	ldh  a,[hUnk_FFC4]
	ld   hl,$C015
	call Unk_078B
	ret

Unk_0679:
	call Unk_06FA
	call Unk_0664
	call Unk_0653
	ldh  a,[hSerialRole]
	cp   a,$30
	jr   nz,.unk_0693
	ldh  a,[hSerialNext]
	cp   a,$18
	jr   z,.unk_06B3
	and  a,$C0
	jp   nz,Unk_07C8
	call Unk_0768
	call Unk_0B62
	ldh  a,[hSerialRole]
	cp   a,$60
	jr   z,.unk_06BE
	ldh  a,[hJoyPressed]
	bit  3,a
	jr   z,.unk_06C4
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_06B3
	ldh  a,[hUnk_FFA7]
	and  a
	ret  nz
	ld   a,$18
	ldh  [hSerialNext],a
	ret

Unk_06B3:
	call ClearOAMBuffer
	call JumpToInitMusic
	ld   a,$02
	ldh  [hGameStatus],a
	ret

Unk_06BE:
	ldh  a,[hUnk_FFD0]
	cp   a,$18
	jr   z,Unk_06B3
	ldh  a,[hJoyPressed]
	ld   b,a
	ldh  a,[hSerialRole]
	cp   a,$60
	jr   z,.unk_06DC
	ld   a,b
	and  a,$C0
	jr   z,.unk_06DC
	ldh  a,[hTwoPlayerMode]
	and  a
	jp   z,.unk_07C8
	ld   a,b
	ldh  [hSerialNext],a
	ret

.unk_06DC
	ldh  a,[hJoyHeld]
	ld   c,a
	bit  4,b
	ld   a,$10
	jr   nz,.unk_06F2
	bit  4,c
	jp   z,.unk_07B1
	ldh  a,[hUnk_FFAA]
	dec  a
	ldh  [hUnk_FFAA],a
	ret  nz
	ld   a,$08
.unk_06F2
	ldh  [hUnk_FFAA],a
	ld   b,$20
	call Unk_0753
	ret

.unk_06FA
	ldh  a,[hSerialRole]
	and  a
	ret  z
	cp   a,$30
	jr   z,.unk_0728
	ldh  a,[hUnk_FFD0]
	ld   b,a
	and  a,$C0
	jr   nz,.unk_0722
	ld   a,b
	cp   a,$30
	jr   nc,.unk_0738
	cp   a,$22
	jr   nc,.unk_0741
	cp   a,$18
	ret  z
	cp   a,$19
	ret  z
	ld   hl,$FFC4
	ld   [hl],b
	call Unk_0771
	ldh  [hUnk_FFC5],a
	ret

.unk_0722
	ldh  [hJoyPressed],a
	pop  af
	jp   .unk_07C8

.unk_0728
	ldh  a,[hUnk_FFD0]
	cp   a,$15
	jr   nc,.unk_0745
	ld   hl,$FFC4
	ld   [hl],a
	call Unk_0771
	ldh  [hUnk_FFC5],a
	ret

.unk_0738
	ld   a,$40
.unk_073A
	ldh  [hJoyPressed],a
	ld   b,a
	pop  af
	jp   .unk_07C8
.unk_0741
	ld   a,$80
	jr   .unk_073A

.unk_0745
	cp   a,$22
	ret  c
	cp   a,$25
	ret  nc
	sub  a,$20
	ldh  [hUnk_FFAE],a
	call Unk_0928
	ret

.unk_0753
	ld   hl,$FFC3
	ldd  a,[hl]
	cp   b
	ret  z
	inc  [hl]
	inc  l
	add  a,$01
	daa
	ld   [hl],a
	cp   a,$21
	ret  nz
	ld   a,$01
	ld   [wUnk_D052],a
	ret

.unk_0768
	ldh  a,[hTwoPlayerMode]
	and  a
	ret  z
	ldh  a,[hUnk_FFC2]
	ldh  [hSerialNext],a
	ret

.unk_0771
	ld   a,[hl]
	and  a
	ret  z
	ld   b,a
	xor  a
.unk_0776
	add  a,$01
	daa
	dec  b
	jr   nz,.unk_0776
	ret

.unk_077D
	ld   b,a
	and  a,$F0
	swap a
	ldi  [hl],a
	inc  l
	inc  l
	inc  l
	ld   a,b
	and  a,$0F
	ld   [hl],a
	ret

.unk_078B
	and  a
	ld   b,a
	ld   a,$34
	jr   z,.unk_0796
.unk_0791
	add  a,$04
	dec  b
	jr   nz,.unk_0791
.unk_0796
	cp   [hl]
	ret  z
	ld   [hl],a
	ld   a,$03
	ld   [wUnk_DFE0],a
	ret

.unk_079F
	call Unk_07A3
	ret

.unk_07A3
	ld   hl,$FFC3
	ldd  a,[hl]
	and  a
	ret  z
	dec  [hl]
	inc  l
	sub  a,$01
	call Unk_075D
	ret

.unk_07B1
	bit  5,b
	ld   a,$10
	jr   nz,.unk_07C2
	bit  5,c
	ret  z
	ldh  a,[hUnk_FFAA]
	dec  a
	ldh  [hUnk_FFAA],a
	ret  nz
	ld   a,$08
.unk_07C2
	ldh  [hUnk_FFAA],a
	call Unk_079F
	ret

.unk_07C8
	ld   a,$01
	ld   [wUnk_DFE0],a
	ld   hl,$9863
	ld   a,$83
	ld   bc,$0302
	call Unk_0B4C
	ld   hl,$986F
	ld   a,$85
	ld   bc,$0203
	call Unk_0B4C
	ld   hl,$9864
	ld   a,$84
	ld   b,$0B
	call Unk_0B42
	ld   hl,$98A4
	ld   a,$89
	ld   b,$0B
	call Unk_0B42
	ldh  a,[hSerialRole]
	cp   a,SERIAL_ROLE_MASTER
	jr   nz,.unk_0805
	ldh  a,[hSerialNext]
	ldh  [hJoyPressed],a
	ld   a,$19
	ldh  [hSerialNext],a
.unk_0805
	ldh  a,[hJoyPressed]
	ld   b,a
	ldh  [hJoyHeld],a
	bit  PADB_UP,b
	jp   nz,Unk_098B
	ld   hl,$9903
	ld   a,$93
	ld   bc,$0302
	call Unk_0B4C
	ld   hl,$9909
	ld   a,$95
	ld   bc,$0203
	call Unk_0B4C
	ld   hl,$9904
	ld   a,$94
	ld   b,$05
	call Unk_0B42
	ld   hl,$9944
	ld   a,$99
	ld   b,$05
	call Unk_0B42
	ld   a,$0D
	ldh  [hGameStatus],a
	ld   hl,$DFE9
	ld   a,$03
	cp   [hl]
	ret  z
	ld   [wUnk_DFE8],a
	ret

Unk_0848:
	call Unk_08A9
	call Unk_0928
	ldh  a,[hSerialRole]
	cp   a,SERIAL_ROLE_MASTER
	jr   nz,.unk_0860
	ldh  a,[hSerialNext]
	cp   a,$18
	jp   z,Unk_06B3
	and  a,$C0
	jp   nz,Unk_093D
	call Unk_090D
	call Unk_0B62
	ldh  a,[hSerialRole]
	cp   a,$60
	jr   z,.unk_087D
	ldh  a,[hJoyPressed]
	bit  3,a
	jr   z,.unk_0884
	ldh  a,[hTwoPlayerMode]
	and  a
	jp   z,Unk_06B3
	ld   a,$18
	ldh  [hSerialNext],a
	ret

Unk_087D:
	ldh  a,[hUnk_FFD0]
	cp   a,$18
	jp   z,Unk_06B3
	ldh  a,[hJoyPressed]
	ld   b,a
	ldh  a,[hSerialRole]
	cp   a,SERIAL_ROLE_SLAVE
	jr   z,.unk_089C ; Slave ignores Up and Down
	ld   a,b
	and  a,PADF_UP | PADF_DOWN
	jr   z,.unk_089C
	ldh  a,[hTwoPlayerMode]
	and  a
	jp   z,Unk_093D
	ld   a,b ; Send inputs to slave
	ldh  [hSerialNext],a
	ret

.unk_089C
	bit  PADB_RIGHT,b
	jr   nz,.unk_08A5
	bit  PADB_LEFT,b
	jr   nz,Unk_0918
	ret

.unk_08A5
	call Unk_0901
	ret

Unk_08A9:
	ldh  a,[hSerialRole]
	and  a
	ret  z
	cp   a,SERIAL_ROLE_MASTER
	jr   z,.unk_08D5
	ldh  a,[hUnk_FFD0]
	ld   b,a
	and  a,$C0
	jr   nz,.unk_08CE
	ld   a,b
	cp   a,$15
	jr   c,.unk_08F5
	cp   a,$18
	ret  z
	cp   a,$19
	ret  z
	cp   a,$30
	jr   nc,.unk_08FD
	sub  a,$20
	ld   hl,hUnk_FFAE
	ld   [hl],a
	ret

.unk_08CE
	ld   a,b
	ldh  [hJoyPressed],a
	pop  af
	jp   Unk_093D

.unk_08D5
	ldh  a,[hUnk_FFD0]
	cp   a,$20
	jr   c,.unk_08E5
	cp   a,$25
	ret  nc
	sub  a,$20
	ld   hl,hUnk_FFAE
	ld   [hl],a
	ret

.unk_08E5
	cp   a,$15
	ret  nc
	ld   hl,$FFC4
	ld   [hl],a
	call Unk_0771
	ldh  [hUnk_FFC5],a
	call Unk_0664
	ret

.unk_08F5
	ld   a,$40
.unk_08F7
	ldh  [hJoyPressed],a
	ld   b,a
	pop  af
	jr   .unk_093D

.unk_08FD
	ld   a,$80
	jr   .unk_08F7

Unk_0901:
	ld   hl,hUnk_FFAD
	dec  [hl]
	ld   a,[hl]
	cp   a,$01
	ret  nz
	ld   a,$04
	ld   [hl],a
	ret

Unk_090D:
	ldh  a,[hTwoPlayerMode]
	and  a
	ret  z
	ldh  a,[hUnk_FFAD]
	add  a,$20
	ldh  [hSerialNext],a
	ret

Unk_0918:
	call Unk_091C
	ret

Unk_091C:
	ld   hl,hUnk_FFAD
	inc  [hl]
	ld   a,[hl]
	cp   a,$05
	ret  nz
	ld   a,$02
	ld   [hl],a
	ret

Unk_0928:
	ldh  a,[hUnk_FFAD]
	ld   hl,$C019
	call Unk_0B20
	ldh  a,[hTwoPlayerMode]
	and  a
	ret  z
	ldh  a,[hUnk_FFAE]
	ld   hl,$C021
	call Unk_0B20
	ret

Unk_093D:
	ld   a,$01
	ld   [wUnk_DFE0],a
	ld   hl,$9903
	ld   a,$83
	ld   bc,$0302
	call Unk_0B4C
	ld   hl,$9909
	ld   a,$85
	ld   bc,$0203
	call Unk_0B4C
	ld   hl,$9904
	ld   a,$84
	ld   b,$05
	call Unk_0B42
	ld   hl,$9944
	ld   a,$89
	ld   b,$05
	call Unk_0B42
	ldh  a,[hSerialRole]
	cp   a,SERIAL_ROLE_MASTER
	jr   nz,.unk_097A
	ldh  a,[hSerialNext]
	ldh  [hJoyPressed],a
	ld   a,$19
	ldh  [hSerialNext],a
.unk_097A
	ldh  a,[hJoyPressed]
	ld   b,a
	ldh  [hJoyHeld],a
	bit  PADB_DOWN,b
	jr   z,.unk_098B
	call Unk_221B
	ld   a,$0C
	ldh  [hGameStatus],a
	ret

.unk_098B
	ld   hl,$9983
	ld   a,$93
	ld   bc,$0302
	call Unk_0B4C
	ld   hl,$9989
	ld   a,$95
	ld   bc,$0203
	call Unk_0B4C
	ld   hl,$9984
	ld   a,$94
	ld   b,$05
	call Unk_0B42
	ld   hl,$99C4
	ld   a,$99
	ld   b,$05
	call Unk_0B42
	ld   a,$0E
	ldh  [hGameStatus],a
	ret

Unk_09BA:
	ld   hl,$DFE9
	ld   b,$01
	ldh  a,[hUnk_FFC1]
	and  a
	jr   z,.unk_09CF
	inc  b
	cp   a,$01
	jr   z,.unk_09CF
	ld   a,$07
	ld   [wUnk_DFE8],a
	ret

.unk_09CF
	ld   a,b
	cp   [hl]
	ret  z
	ld   [wUnk_DFE8],a
	ret

Unk_09D6:
	call Unk_09BA
	ldh  a,[hSerialRole]
	cp   a,SERIAL_ROLE_MASTER
	jr   nz,.unk_09EB
	ldh  a,[hSerialNext]
	cp   a,$18
	jp   z,Unk_06B3
	and  a,$C0
	jp   nz,Unk_0AA6
.unk_09EB
	call Unk_0A4F
	call Unk_0AA2
	call Unk_0B62
	ldh  a,[hSerialRole]
	cp   a,SERIAL_ROLE_SLAVE
	jr   z,.unk_0A0B
	ldh  a,[hJoyPressed]
	bit  3,a
	jr   z,.unk_0A13
	ldh  a,[hTwoPlayerMode]
	and  a
	jp   z,Unk_06B3
	ld   a,$18
	ldh  [hSerialNext],a
	ret

.unk_0A0B
	ldh  a,[hUnk_FFD0]
	cp   a,$18
	jp   z,Unk_06B3
	ret

.unk_0A13
	ldh  a,[hJoyPressed]
	ld   b,a
	and  a,$C0
	jr   z,.unk_0A24
	ldh  a,[hTwoPlayerMode]
	and  a
	jp   z,Unk_0AA6
	ld   a,b
	ldh  [hSerialNext],a
	ret

.unk_0A24
	bit  PADB_RIGHT,b
	jr   nz,.unk_0A2D
	bit  PADB_LEFT,b
	jr   nz,.unk_0A3D
	ret

.unk_0A2D
	ld   a,$03
	ld   [wUnk_DFE0],a
	ld   hl,$FFC1
	inc  [hl]
	ld   a,[hl]
	cp   a,$03
	ret  nz
	xor  a
	ld   [hl],a
	ret

.unk_0A3D
	ld   a,$03
	ld   [wUnk_DFE0],a
	ld   hl,$FFC1
	ld   a,[hl]
	and  a
	jr   z,.unk_0A4B
	dec  [hl]
	ret

.unk_0A4B
	ld   a,$02
	ld   [hl],a
	ret

Unk_0A4F:
	ldh  a,[hSerialRole]
	and  a
	ret  z
	cp   a,$30
	jr   z,.unk_0A79
	ldh  a,[hUnk_FFD0]
	ld   b,a
	and  a,$C0
	jr   nz,.unk_0A90
	ld   a,b
	cp   a,$19
	jr   z,.unk_0A76
	cp   a,$25
	ret  c
	ldh  [hSerialNext],a
	sub  a,$30
	ld   hl,$FFC1
	cp   [hl]
	ret  z
	ld   [hl],a
	ld   a,$03
	ld   [wUnk_DFE0],a
	ret

.unk_0A76
	ldh  [hSerialNext],a
	ret

.unk_0A79
	ldh  a,[hUnk_FFD0]
	cp   a,$15
	jp   c,Unk_08E5
	cp   a,$22
	jr   c,.unk_0A89
	cp   a,$25
	jp   c,Unk_0745
.unk_0A89
	ldh  a,[hUnk_FFC1]
	add  a,$30
	ldh  [hSerialNext],a
	ret

.unk_0A90
	ld   a,b
	ldh  [hJoyPressed],a
	pop  af
	jr   .unk_0AA6

.unk_0A98
	ld   a,$40
	ldh  [hJoyPressed],a
	ld   b,a
	pop  af
	jr   .unk_0AA6

.unk_0A9E
	ld   a,$80
	jr   .unk_0A98

.unk_0AA2
	call Unk_0AF5
	ret

.unk_0AA6
	ld   a,$01
	ld   [wUnk_DFE0],a
	ld   hl,$9983
	ld   a,$83
	ld   bc,$0302
	call Unk_0B4C
	ld   hl,$9989
	ld   a,$85
	ld   bc,$0203
	call Unk_0B4C
	ld   hl,$9984
	ld   a,$84
	ld   b,$05
	call Unk_0B42
	ld   hl,$99C4
	ld   a,$89
	ld   b,$05
	call Unk_0B42
	ldh  a,[hSerialRole]
	cp   a,SERIAL_ROLE_MASTER
	jr   nz,.unk_0AE3
	ldh  a,[hSerialNext]
	ldh  [hJoyPressed],a
	ld   a,$19
	ldh  [hSerialNext],a
.unk_0AE3
	ldh  a,[hJoyPressed]
	ld   b,a
	ldh  [hJoyHeld],a
	bit  PADB_UP,b
	jp   nz,Unk_080F
	call Unk_221B
	ld   a,$0C
	ldh  [hGameStatus],a
	ret

Unk_0AF5:
	ldh  a,[hUnk_FFC1]
	ld   hl,$C029
	ld   bc,$8003
	cp   a,$02
	jr   z,.unk_0B0A
	ld   bc,$5005
	cp   a,$01
	jr   z,.unk_0B0A
	ld   b,$20
.unk_0B0A
	ld   a,b
	ld   de,$0004
.unk_0B0E
	ld   [hl],a
	add  a,$08
	add  hl,de
	dec  c
	jr   nz,.unk_0B0E
	ldh  a,[hUnk_FFC1]
	cp   a,$02
	ret  nz
	ld   a,$F0
	ld   [hl],a
	add  hl,de
	ld   [hl],a
	ret

Unk_0B20:
	ld   b,$3C
	cp   a,$04
	jr   z,.unk_0B2E
	ld   b,$5C
	cp   a,$03
	jr   z,.unk_0B2E
	ld   b,$78
.unk_0B2E
	ld   a,b
	ld   b,$02
.unk_0B31
	cp   [hl]
	ret  z
	ldi  [hl],a
	inc  l
	inc  l
	inc  l
	add  a,$08
	dec  b
	jr   nz,.unk_0B31
	ld   a,$03
	ld   [wUnk_DFE0],a
	ret

FillVRAM:
	di
	call WaitVRAM
	ldi  [hl],a
	dec  b
	jr   nz,FillVRAM
	ei
	ret

Unk_0B4C:
	di
	ld   de,$0020
	call WaitVRAM
	ld   [hl],a
	add  hl,de
	add  b
	call WaitVRAM
	ld   [hl],a
	add  hl,de
	add  c
	call WaitVRAM
	ld   [hl],a
	ei
	ret

Unk_0B62:
	ldh  a,[hUnk_FFA6]
	and  a
	ret  nz
	ld   a,$09
	ldh  [hUnk_FFA6],a
	ld   hl,$C02B
	ld   b,$05
.unk_0B6F
	ld   a,[hl]
	xor  a,$80
	ldi  [hl],a
	inc  l
	inc  l
	inc  l
	dec  b
	jr   nz,.unk_0B6F
	ret

WaitVRAM:
	push af
.waitVRAM
	ldh  a,[rSTAT]
	and  a,$03
	jr   nz,.waitVRAM
	pop  af
	ret

Unk_0B83:
	ld   hl,$C808
.unk_0B86
	ld   [hl],$FF
	inc  l
	ld   a,l
	cp   a,$80
	jr   nz,.unk_0B86
	ret

PlayGame:
	call ShutLCDDown
	call ClearOAMBuffer
	; Copy charset
	ld   de,$8000
	ld   hl,Tiles
	ld   bc,$0300
	call Copy

	ld   de,$3A2C
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_0BAC
	ld   de,$38C4
.unk_0BAC
	push de
	call PrintTileMap
	pop  de
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_0BD7
	xor  a
	ld   [wUnk_C0A0],a
	ld   [wUnk_C0A1],a
	ld   [wUnk_C0A2],a
	ld   [wUnk_C0A3],a
	ld   [wUnk_9852],a
	ld   hl,$9C00
	call Unk_20CC
	ld   de,.pauseTiles
	ld   hl,$9D02
	call Unk_0D90
	jr   .unk_0BE8

.unk_0BD7
	ld   hl,$9C00
	ld   de,$3CFC
	call Unk_20E2
	ld   a,$00
	ldh  [rWY],a
	ld   a,$5F
	ldh  [rWX],a
.unk_0BE8
	ldh  a,[rLCDC]
	and  a,$80
	jr   z,.LCDOff
	call ShutLCDDown
.LCDOff
	call Unk_0B83
	call Unk_1E39
	ld   hl,$C200
	ld   de,$2083
	rst  $18
	ld   hl,$C210
	ld   de,$209B
	ldh  a,[hIsDemoActive]
	and  a
	jr   nz,.unk_0C0C
	ld   de,$208B
.unk_0C0C
	rst  $18
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_0C1B
	ld   hl,$C050
	ld   de,.data_0CE2
	call Unk_2794
.unk_0C1B
	ldh  a,[hIsDemoActive]
	and  a
	jr   nz,.unk_0C33
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_0C2A
	ld   a,$80
	ld   [wUnk_C210],a
.unk_0C2A
	call Unk_1185
	call Unk_1185
	call Unk_1185
.unk_0C33
	ld   hl,$C200
	ld   [hl],$80
	call Unk_2017
	call Unk_25D2
	xor  a
	ldh  [hUnk_FF98],a
	ldh  [hUnk_FFFD],a
	ld   a,$03
	ldh  [hUnk_FFA6],a
	ldh  a,[hUnk_FFAD]
	ld   b,$00
	cp   a,$04
	jr   z,.unk_0C57
	ld   b,$09
	cp   a,$03
	jr   z,.unk_0C57
	ld   b,$14
.unk_0C57
	ldh  a,[hUnk_FFC3]
	cp   a,$21
	jr   c,.unk_0C61
	sub  a,$20
	add  b
	ld   b,a
.unk_0C61
	ld   a,b
	ldh  [hUnk_FFAC],a
	call Unk_0DB8
	ld   hl,$9971
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_0C79
	ldh  a,[hUnk_FFC3]
	ld   b,a
	call Unk_0D25
	ld   a,$01
	ldh  [hUnk_FFE0],a
.unk_0C79
	ld   a,$83
	ldh  [rLCDC],a
	ldh  a,[hIsDemoActive]
	and  a
	jr   nz,.unk_0CCB
	ldh  a,[hSerialRole]
	cp   a,$30
	jr   nz,.unk_0C9D
	call Unk_11E1
	call Unk_11E1
	call Unk_11E1
	ld   b,$80
	ld   hl,$C300
.unk_0C96
	call Unk_11E1
	ldi  [hl],a
	dec  b
	jr   nz,.unk_0C96
.unk_0C9D
	ldh  a,[hUnk_FFC2]
	cp   a,$15
	jr   c,.unk_0CA5
	ld   a,$14
.unk_0CA5
	ld   b,a
	ld   de,$FFC6
	call Unk_0D6A
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_0CC0
	ldh  a,[hUnk_FFC4]
	ld   b,a
	ld   hl,$FFC8
	ld   de,$FFC7
	call Unk_0D6A
	call Unk_0D75
.unk_0CC0
	ld   bc,$0316
	call Unk_0D82
	ld   hl,wUnk_D03A
	inc  [hl]
	ret

.unk_0CCB
	call DemoRelatedCopy
	ld   a,[wUnk_C300]
	ld   [wUnk_C203],a
	ld   [wUnk_C213],a
	jr   .unk_0C9D

.pauseTiles
	;   pill    P   A   U   S   E    pill  end
	db   $8F,$13,$14,$1A,$21,$23,$5E,$8F,$FD

.data_0CE2:
	db   $78,$68,$FF,$00,$80,$68,$FF,$00,$78,$70,$FF,$00,$80,$70,$FF,$00,$78,$8C,$FF,$00,$80,$8C,$FF,$00,$78,$94,$FF,$00,$80,$94,$FF,$00,$FD

DemoRelatedCopy: ; 0D03
	ld   hl,$C300
	ld   de,.data
	rst  $18
	ret
.data
	db   $10,$10,$04,$00,$00,$12,$0A,$10,$0C,$14,$14,$00,$08,$08,$12,$12,$0C,$06,$08,$0A,$12,$10,$04,$00,$08,$FF

PrintBCD: ; 0D25
	ld   a,b
	and  a,$F0
	swap a
	ld   c,a
	call WaitVRAM
	ld   [hl],c
	inc  l
	ld   a,b
	and  a,$0F
	ld   c,a
	call WaitVRAM
	ld   [hl],c
	ret

Unk_0D39:
	ld   hl,$98CC
	ldh  a,[hUnk_FFAD]
	call .unk_0D4A
	ld   hl,$98D0
	ldh  a,[hUnk_FFAE]
	call .unk_0D4A
	ret

.unk_0D4A
	cp   a,$02
	jr   z,.unk_0D5B
	cp   a,$03
	jr   z,.unk_0D61
	ld   [hl],$15
	inc  l
	ld   [hl],$18
	inc  l
	ld   [hl],$20
	ret
.unk_0D5B
	ld   [hl],$11
	inc  l
	ld   [hl],$12
	ret
.unk_0D61
	ld   [hl],$16
	inc  l
	ld   [hl],$0E
	inc  l
	ld   [hl],$0D
	ret

Unk_0D6A:
	ld   a,b
	inc  a
	ld   c,a
	ld   b,$03
.unk_0D6F
	add  c
	dec  b
	jr   nz,.unk_0D6F
	ld   [de],a
	ret

Unk_0D75:
	ld   a,[de]
	srl  a
	srl  a
	ldi  [hl],a
	srl  a
	ldi  [hl],a
	srl  a
	ld   [hl],a
	ret

Unk_0D82:
	ldh  a,[hTwoPlayerMode]
	and  a
	ld   a,b
	jr   z,.unk_0D89
	ld   a,c
.unk_0D89
	ldh  [hGameStatus],a
	ret

Unk_0D8C:
	ld   b,$80
	jr   Unk_0D92
Unk_0D90:
	ld   b,$08

Unk_0D92:
	push hl
.unk_0D93
	ld   a,[de]
	cp   a,$FD
	jr   z,.unk_0DA6
	ldi  [hl],a
	inc  de
	dec  b
	jr   nz,.unk_0D93
	pop  hl
	push de
	ld   de,$0020
	add  hl,de
	pop  de
	jr   Unk_0D92
.unk_0DA6
	pop  hl
	ret

Data_0DA8:
	db $8F,$19,$0A,$1E,$1C,$0E,$8F,$FD

Unk_0DB0:
	ld   hl,$FFAC
	ld   a,[hl]
	cp   a,$23
	ret  z
	inc  [hl]
Unk_0DB8:
	ldh  a,[hUnk_FFAC]
	ld   e,a
	ld   hl,.unk_data
	ld   d,$00
	add  hl,de
	ld   a,[hl]
	ldh  [hFramesTillDrop],a
	ldh  [hFramesTillDrop_Reload],a
	ret

.unk_data
	db $27,$25,$23,$21,$1F,$1D,$1B,$19,$17,$15,$14,$13,$12,$11,$10,$0F,$0E,$0D,$0C,$0B,$0A,$09,$09,$08,$08,$07,$07,$06,$06,$05,$05,$05,$05,$05,$05,$05

Unk_0DEB:
	xor  a
	ldh  [rIF],a
	ld   a,IEF_SERIAL
	ldh  [rIE],a
	ldh  a,[hSerialRole]
	cp   a,SERIAL_ROLE_MASTER
	jr   nz,.slave
.unk_0DF8
	rst  $08
	rst  $08
	ld   a,$99
	ldh  [rSB],a
	ld   a,$81
	ldh  [rSC],a
	xor  a
	ldh  [hSerialTransferDone],a
.waitTransferDone1
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.waitTransferDone1
	ldh  a,[hUnk_FFD0]
	cp   a,$66
	jr   nz,.unk_0DF8
	ld   hl,$C300
	ld   b,$80
.unk_0E15
	ldi  a,[hl]
	rst  $08
	ldh  [rSB],a
	ld   a,$81
	ldh  [rSC],a
	xor  a
	ldh  [hSerialTransferDone],a
.waitTransferDone2
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.waitTransferDone2
	inc  b
	jr   nz,.unk_0E15
.unk_0E28
	rst  $08
	rst  $08
	ld   a,$33
	ldh  [rSB],a
	ld   a,$81
	ldh  [rSC],a
	xor  a
	ldh  [hSerialTransferDone],a
.waitTransferDone3
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.waitTransferDone3
	ldh  a,[hUnk_FFD0]
	cp   a,$77
	jr   nz,.unk_0E28
	jr   .unk_0E8B

.slave
	ld   a,$66
	ldh  [rSB],a
	ldh  [hSerialNext],a
	ld   a,$80
	ldh  [rSC],a
	xor  a
	ldh  [hSerialTransferDone],a
.waitTransferDone4
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.waitTransferDone4
	ldh  a,[hUnk_FFD0]
	cp   a,$99
	jr   nz,.slave
	ld   b,$80
	ld   hl,$C300
.unk_0E5F
	ldh  [rSB],a
	ld   a,$80
	ldh  [rSC],a
	xor  a
	ldh  [hSerialTransferDone],a
.waitTransferDone5
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.waitTransferDone5
	ldh  a,[hUnk_FFD0]
	ldi  [hl],a
	inc  b
	jr   nz,.unk_0E5F
.unk_0E73
	ld   a,$77
	ldh  [rSB],a
	ldh  [hSerialNext],a
	ld   a,$80
	ldh  [rSC],a
	xor  a
	ldh  [hSerialTransferDone],a
.waitTransferDone6
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.waitTransferDone6
	ldh  a,[hUnk_FFD0]
	cp   a,$33
	jr   nz,.unk_0E73

.unk_0E8B
	xor  a
	ldh  [rIF],a
	ld   a,$0D
	ldh  [rIE],a
	xor  a
	ldh  [hUnk_FFB0],a
	ldh  [hSerialTransferDone],a
	ld   [wUnk_D03A],a
	call Unk_1185
	call Unk_1185
	call Unk_1185
	ld   a,$80
	ld   [wUnk_C200],a
	xor  a
	ld   [wUnk_C210],a
	call Unk_2017
	ld   a,$03
	ldh  [hGameStatus],a
	ret

Unk_0EB4:
	ld   a,$01
	ld   [wHasGameStarted],a
	call Unk_1E98
	ldh  a,[hUnk_FFAB]
	and  a
	ret  nz
	call Unk_0F1C
	call Unk_0F42
	call Unk_1D6C
	call Unk_1223
	call Unk_1F95
	call Unk_3495
	call Unk_0EE4
	call Unk_279C
	call Unk_0FBA
	call Unk_0FB1
	ld   a,$01
	ld   [wHasGameStarted],a
	ret

Unk_0EE4:
	ldh  a,[hUnk_FFCE]
	and  a
	ret  z
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	ld   hl,$C048
	ld   de,$0004
	ld   a,$3D
	ldi  [hl],a
	ld   a,$8C
	ld   [hl],a
	ld   l,$42
	ld   bc,$D051
	ld   a,[bc]
	xor  a,$01
	ld   [bc],a
	jr   nz,.unk_0F10
	ld   a,$06
	ld   [hl],a
	add  hl,de
	ld   a,$08
	ld   [hl],a
	add  hl,de
	ld   a,$FF
	ld   [hl],a
	ret

.unk_0F10
	ld   a,$3D
	ld   [hl],a
	add  hl,de
	ld   a,$3F
	ld   [hl],a
	add  hl,de
	ld   a,$3E
	ld   [hl],a
	ret

Unk_0F1C:
	ldh  a,[hIsDemoActive]
	and  a
	ret  z
	rst  $08
	ldh  a,[hUnk_FFD0]
	cp   a,$30
	jr   z,.unk_0F3F
	cp   a,$37
	jr   z,.unk_0F3F
	xor  a
	ldh  [rSB],a
	ld   a,$80
	ldh  [rSC],a
	ldh  a,[hJoyPressed]
	bit  PADB_START,a
	ret  z
	ld   a,$37
	ldh  [rSB],a
	ld   a,$81
	ldh  [rSC],a
.unk_0F3F
	pop  af
	jr   .unk_0F88

.unk_0F42:
	ldh  a,[hIsDemoActive]
	and  a
	ret  z
	ld   a,[wUnk_C4EA]
	and  a
	jr   z,.unk_0F52
	dec  a
	ld   [wUnk_C4EA],a
	jr   .unk_0F77

.unk_0F52
	ld   a,[wUnk_C4EB]
	ld   h,a
	ld   a,[wUnk_C4EC]
	ld   l,a
	ldi  a,[hl]
	cp   a,$FC
	jr   z,.unk_0F88
	ld   b,a
	ldh  a,[hUnk_FFED]
	xor  b
	and  b
	ldh  [hJoyPressed],a
	ld   a,b
	ldh  [hUnk_FFED],a
	ldi  a,[hl]
	ld   [wUnk_C4EA],a
	ld   a,h
	ld   [wUnk_C4EB],a
	ld   a,l
	ld   [wUnk_C4EC],a
	jr   .unk_0F7A

.unk_0F77
	xor  a
	ldh  [hJoyPressed],a
.unk_0F7A
	ldh  a,[hJoyHeld]
	ldh  [hUnk_FFEE],a
	ldh  a,[hUnk_FFED]
	ldh  [hJoyHeld],a
	ret

.unk_0F83
	xor  a
	ldh  [hUnk_FFED],a
	jr   .unk_0F77

.unk_0F88
	xor  a
	ldh  [hGameStatus],a
	ldh  [hUnk_FFC2],a
	ldh  [hUnk_FFC3],a
	ld   [wUnk_C0A0],a
	ld   [wUnk_C0A1],a
	ld   [wUnk_C0A2],a
	ld   [wUnk_C0A3],a
	ldh  [hUnk_FFED],a
	ldh  [hUnk_FFEE],a
	ld   [wUnk_C4EB],a
	ld   [wUnk_C4EC],a
	ldh  [hUnk_FFB0],a
	ld   [wHasGameStarted],a
	ld   [wUnk_D00D],a
	ld   [wUnk_C4EA],a
	ret

Unk_0FB1:
	ldh  a,[hIsDemoActive]
	and  a
	ret  z
	ldh  a,[hUnk_FFEE]
	ldh  [hJoyHeld],a
	ret

Unk_0FBA:
	ldh  a,[hGameMode]
	and  a
	ret  z
	xor  a
	ldh  [hUnk_FF98],a
	ldh  [hGameMode],a
	ld   a,$05
	ldh  [hGameStatus],a
	ret

Unk_0FC8:
	xor  a
	ldh  [hUnk_FF98],a
	ld   [wHasGameStarted],a
	ld   [wUnk_D00D],a
	ld   a,$80
	ld   [wUnk_C200],a
	ld   [wUnk_C210],a
	call Unk_2017
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_0FE6
	call Unk_22C2
	jr   .unk_0FE9

.unk_0FE6
	call Unk_22CD
.unk_0FE9
	call Unk_2288
	call Unk_226C
	call Unk_22D8
	ld   a,$10
	ldh  [hWaitFrames],a
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_1019
	ld   hl,wUnk_D000
	inc  [hl]
	call Unk_105C
	ld   hl,wUnk_D001
	call Unk_1081
	ld   a,$01
	ld   [wUnk_D04B],a
	call Unk_1025
	ld   a,$10
	ldh  [hUnk_FFA7],a
	ld   a,$12
	ldh  [hGameStatus],a
	ret

.unk_1019
	call Unk_3495
	ld   b,$30
	call Unk_0753
	ld   a,$10
	jr   .unk_1016
	ld   hl,$C020
	ld   de,$102F
	call Unk_2794
	ret

Data_102F:
	db $70,$28,$FF,$10,$78,$28,$1C,$10,$78,$30,$1D,$10,$68,$30,$10,$10,$70,$30,$1A,$10,$80,$30,$18,$10,$68,$38,$11,$10,$70,$38,$1B,$10,$78,$38,$1E,$10,$80,$38,$19,$10,$78,$40,$1F,$10,$FD

Unk_105C:
	ld   a,[hl]
	and  a
	ret  z
	ld   c,a
.unk_1060
	ld   b,c
	ld   hl,$C070
	ld   de,PerformDelay
.unk_1067
	add  hl,de
	dec  b
	jr   nz,.unk_1067
	push hl
	ld   hl,$10C7
	ld   b,c
.unk_1070
	add  hl,de
	dec  b
	jr   nz,.unk_1070
	pop  de
	ld   b,$08
.unk_1077
	ldi  a,[hl]
	ld   [de],a
	inc  de
	dec  b
	jr   nz,.unk_1077
	dec  c
	jr   nz,.unk_1060
	ret

Unk_1081:
	ld   a,[hl]
	and  a
	ret  z
	ld   c,a
.unk_1085
	ld   b,c
	ld   hl,$BFF8
	ld   de,PerformDelay
.unk_108C
	add  hl,de
	dec  b
	jr   nz,.unk_108C
	push hl
	ld   hl,$10DF
	ld   b,c
.unk_1095
	add  hl,de
	dec  b
	jr   nz,.unk_1095
	pop  de
	ld   b,$08
.unk_109C
	ldi  a,[hl]
	ld   [de],a
	inc  de
	dec  b
	jr   nz,.unk_109C
	dec  c
	jr   nz,.unk_1085
	ret

	ld   hl,$C002
	ld   de,$0004
	call Unk_10B5
	ld   l,$7A
	call Unk_10B5
	ret

	ld   b,$06
	ld   a,$FF
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_10B9
	ret

	ld   b,$08
	ld   hl,$C052
	ld   de,$0004
	ld   a,$FF
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_10C9
	ret

	adc  h
	ld   [hl],c
	adc  e
	nop
	adc  h
	ld   a,c
	adc  e
	jr   nz,.unk_1058
	ld   [hl],c
	adc  e
	nop
	add  b
	ld   a,c
	adc  e
	jr   nz,.unk_1154
	ld   [hl],c
	adc  e
	nop
	ld   [hl],h
	ld   a,c
	adc  e
	jr   nz,.unk_1074
	add  a
	adc  e
	nop
	adc  h
	adc  a
	adc  e
	jr   nz,.unk_1070
	add  a
	adc  e
	nop
	add  b
	adc  a
	adc  e
	jr   nz,.unk_116C
	add  a
	adc  e
	nop
	ld   [hl],h
	adc  a
	adc  e
	jr   nz,.unk_1116
	ld   [de],a
	inc  e
	inc  e
	-
	inc  c
	dec  d
	ld   c,$0A
	dec  de
	-
	ldi  [hl],a
	jr   .unk_112B
	cp   a,$20
	ld   [de],a
	rla
	dec  h
	-
	ldi  [hl],a
	jr   .unk_1134
	cp   a,$15
	jr   .unk_1136
	dec  e
	-
	add  hl,de
	ld   e,$1C
	ld   de,$1CFD
	dec  e
	ld   a,[bc]
	dec  de
	dec  e
	dec  h
	-
	add  hl,de
	dec  d
	ld   c,$0A
	inc  e
	ld   c,$FD
	jr   nz,.unk_113B
	ld   [de],a
	dec  e
	-
	dec  c
	dec  de
	ld   a,[bc]
	jr   nz,.unk_1136
	xor  a
	ldh  [hUnk_FF98],a
	ld   [wHasGameStarted],a
	ld   [wUnk_D00D],a
	ld   a,$80
	ld   [wUnk_C200],a
	ld   [wUnk_C210],a
	call Unk_2017
	ld   hl,wUnk_D000
	call Unk_105C
	ld   hl,wUnk_D001
	call Unk_1081
	ldh  a,[hUnk_FFF4]
	cp   a,$FD
	jr   z,.unk_1164
	call Unk_22C2
	jr   .unk_116A
	call Unk_22B7
	call Unk_136C
	call Unk_22A4
	call Unk_22D8
	ld   a,$01
	ld   [wUnk_D04B],a
	call Unk_135D
	ld   a,$10
	ldh  [hWaitFrames],a
	ld   a,$10
	ldh  [hUnk_FFA7],a
	ld   a,$12
	ldh  [hGameStatus],a
	ret

	ld   hl,$C200
	ld   [hl],$00
	inc  l
	ld   [hl],$20
	inc  l
	ld   [hl],$30
	inc  l
	ld   a,[wUnk_C213]
	ld   [hl],a
	and  a,$FC
	ld   c,a
	ldh  a,[hIsDemoActive]
	and  a
	jr   nz,.unk_11A2
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_11B5
	ld   h,$C3
	ldh  a,[hUnk_FFB0]
	ld   l,a
	ld   e,[hl]
	inc  hl
	ld   a,l
	cp   a,$80
	jr   nz,.unk_11B0
	ld   l,$00
	ld   a,l
	ldh  [hUnk_FFB0],a
	jr   .unk_11CB
	ld   h,$03
	call Unk_1204
	ld   d,a
	ldh  a,[hUnk_FFAF]
	ld   e,a
	dec  h
	jr   z,.unk_11C8
	or   d
	or   c
	and  a,$FC
	cp   c
	jr   z,.unk_11B7
	ld   a,d
	ldh  [hUnk_FFAF],a
	ld   a,e
	ld   [wUnk_C213],a
	ld   a,$3B
	ld   [wUnk_C211],a
	ld   a,$6A
	ld   [wUnk_C212],a
	call Unk_203D
	ldh  a,[hFramesTillDrop_Reload]
	ldh  [hFramesTillDrop],a
	ret

	push hl
	push bc
	ldh  a,[hUnk_FFFE]
	and  a,$FC
	ld   c,a
	ld   h,$03
	call Unk_1204
	ld   d,a
	ldh  a,[hUnk_FFAF]
	ld   e,a
	dec  h
	jr   z,.unk_11FB
	or   d
	or   c
	and  a,$FC
	cp   c
	jr   z,.unk_11EA
	ld   a,d
	ldh  [hUnk_FFAF],a
	ld   a,e
	ldh  [hUnk_FFFE],a
	pop  bc
	pop  hl
	ret

	ldh  a,[rDIV]
	ld   b,a
	xor  a
	dec  b
	ret  z
	inc  a
	inc  a
	cp   a,$18
	jr   z,.unk_1207
	jr   .unk_1208
	ret

	ldh  a,[hUnk_FFA7]
	and  a
	jr   nz,.unk_123F
	ldh  a,[hUnk_FF98]
	and  a
	jr   nz,.unk_123F
	ld   a,$03
	ldh  [hUnk_FFA7],a
	jr   .unk_1251
	ld   hl,$C200
	ldi  a,[hl]
	cp   a,$80
	ret  z
	ld   a,[hl]
	cp   a,$20
	jr   z,.unk_1270
	ldh  a,[hJoyHeld]
	and  a,$B0
	cp   a,$80
	jr   z,.unk_1213
	ldh  a,[hFramesTillDrop]
	and  a
	jr   z,.unk_1243
	dec  a
	ldh  [hFramesTillDrop],a
	call Unk_202A
	ret

	ldh  a,[hUnk_FF98]
	cp   a,$02
	ret  z
	ldh  a,[hFramesTillDrop_Reload]
	ldh  [hFramesTillDrop],a
	ld   a,$07
	ld   [wUnk_DFE0],a
	ld   hl,$C201
	ld   a,[hl]
	ldh  [hUnk_FFA0],a
	add  a,$08
	ld   [hl],a
	call Unk_202A
	call Unk_1F61
	and  a
	ret  z
	ldh  a,[hUnk_FFA0]
	ld   hl,$C201
	ld   [hl],a
	call Unk_202A
	ld   a,$01
	ldh  [hUnk_FF98],a
	ret

	call Unk_202A
	call Unk_1F61
	and  a
	jr   nz,.unk_127B
	jr   .unk_122F
	ld   a,$01
	ldh  [hUnk_FFC0],a
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_128E
	ld   a,$FD
	ldh  [hSerialNext],a
	ldh  [hUnk_FFF4],a
	xor  a
	ld   [wUnk_D00E],a
	ld   a,$01
	ldh  [hUnk_FF98],a
	call Unk_1F95
	call JumpToInitMusic
	ld   b,$0F
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_12A1
	ld   b,$17
	ld   a,b
	ldh  [hGameStatus],a
	ld   a,$02
	ld   [wUnk_DFF0],a
	pop  af
	ret

	xor  a
	ld   [wHasGameStarted],a
	ld   [wUnk_D00D],a
	ld   a,$E3
	ldh  [rLCDC],a
	call Unk_10BF
	call Unk_12E5
	ldh  a,[hUnk_FFF4]
	ldh  [hSerialNext],a
	ldh  a,[hUnk_FFD0]
	cp   a,$FD
	jr   z,.unk_12C9
	cp   a,$F8
	ret  nz
	ld   hl,$FFF4
	ldh  a,[hUnk_FFD0]
	cp   [hl]
	jr   z,.unk_12E0
	ld   a,[hl]
	cp   a,$FD
	jr   z,.unk_12DB
	ld   a,$05
	ldh  [hGameStatus],a
	ret

	ld   a,$0F
	ldh  [hGameStatus],a
	ret

	ld   a,$06
	ldh  [hGameStatus],a
	ret

	ld   hl,$C082
	ld   b,$06
	ld   de,$0004
	ld   a,$FF
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_12EF
	ret

	xor  a
	ldh  [hUnk_FF98],a
	ld   [wHasGameStarted],a
	ld   [wUnk_D00D],a
	ld   a,$80
	ld   [wUnk_C200],a
	ld   [wUnk_C210],a
	call Unk_2017
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_1313
	call Unk_22B7
	jr   .unk_1316
	call Unk_22CD
	call Unk_2296
	call Unk_227A
	call Unk_22D8
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_1329
	call Unk_136C
	jr   .unk_132C
	call Unk_37B4
	ld   a,$10
	ldh  [hWaitFrames],a
	ld   b,$10
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_1356
	ld   hl,wUnk_D001
	inc  [hl]
	call Unk_1081
	ld   hl,wUnk_D000
	call Unk_105C
	ld   a,$01
	ld   [wUnk_D04B],a
	call Unk_135D
	ld   a,$10
	ldh  [hUnk_FFA7],a
	ld   b,$12
	ld   a,b
	ldh  [hGameStatus],a
	ret

	ld   a,$08
	ld   [wUnk_DFE8],a
	jr   .unk_1352
	ld   hl,$C023
	ld   de,$0004
	ld   b,$0B
	set  7,[hl]
	add  hl,de
	dec  b
	jr   nz,.unk_1365
	ret

	ld   hl,$C83A
	ld   de,$1376
	call Unk_0D8C
	ret

	-
	-
	-
	-
	cp   a,$FE
	cp   a,$FE
	-
	rst  $28
	xor  a,$FC
	cp   a,$FE
	cp   a,$FE
	-
	xor  a,$EF
	-
	cp   a,$FE
	cp   a,$FE
	-
	-
	-
	-
	-
	ld   hl,$C068
	ld   de,$13B3
	rst  $18
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	ld   hl,$D01F
	ld   a,[hl]
	xor  a,$01
	ld   [hl],a
	jr   z,.unk_13AC
	call Unk_26DA
	ret

	ld   hl,$C05A
	call Unk_37FB
	ret

	ld   [hl],b
	inc  [hl]
	adc  h
	nop
	rst  $38
	ldh  a,[hUnk_FFC0]
	and  a
	jr   nz,.unk_13D2
	call Unk_3495
	call Unk_141D
	ld   hl,$D042
	ld   a,[hl]
	and  a
	jr   nz,.unk_13D0
	inc  [hl]
	ld   a,$04
	ld   [wUnk_DFE8],a
	jr   .unk_13D5
	call Unk_37B4
	call Unk_279C
	ldh  a,[hWaitFrames]
	and  a
	ret  nz
	ldh  a,[hUnk_FFC0]
	and  a
	call nz,Unk_378E
	ldh  a,[hJoyPressed]
	bit  3,a
	ret  z
	call Unk_0B83
	ldh  a,[hUnk_FFC0]
	and  a
	jr   nz,.unk_13FC
	ld   a,$10
	ldh  [hWaitFrames],a
	ld   hl,hGameStatus
	inc  [hl]
	xor  a
	ld   [wUnk_D042],a
	ret

	xor  a
	ld   [wUnk_D01F],a
	ldh  [hUnk_FFC0],a
	ldh  [hUnk_FF98],a
	call Unk_1E39
	ld   a,$81
	ldh  [rLCDC],a
	ld   a,$0B
	ldh  [hGameStatus],a
	ldh  a,[hUnk_FFC3]
	cp   a,$21
	ret  c
	ld   a,$14
	ldh  [hUnk_FFC2],a
	ld   a,$20
	ldh  [hUnk_FFC3],a
	ret

	ld   a,[wUnk_DFE9]
	and  a
	ret  nz
	ld   a,[wUnk_D050]
	and  a
	ret  nz
	ld   a,$0C
	ld   [wUnk_DFE0],a
	ld   a,$01
	ld   [wUnk_D050],a
	ret

	call Unk_279C
	ldh  a,[hWaitFrames]
	and  a
	ret  nz
	ld   b,$09
	ldh  a,[hUnk_FFAD]
	cp   a,$04
	jr   z,.unk_1497
	cp   a,$03
	jr   z,.unk_1467
	jr   .unk_1471
	ld   a,$09
	ld   [wUnk_DFE8],a
	ld   a,b
	ldh  [hGameStatus],a
	xor  a
	ld   [wUnk_D01F],a
	ldh  [hUnk_FFC0],a
	ldh  [hUnk_FF98],a
	ld   [wUnk_D050],a
	ldh  [hUnk_FFF9],a
	ld   [wUnk_D052],a
	call Unk_1E39
	ld   a,$81
	ldh  [rLCDC],a
	ret

	ld   a,[wUnk_D052]
	and  a
	jr   z,.unk_144C
	ld   b,$07
	jr   .unk_1447
	ldh  a,[hUnk_FFC3]
	cp   a,$06
	jr   z,.unk_1487
	cp   a,$11
	jr   z,.unk_148B
	cp   a,$16
	jr   z,.unk_148F
	ld   a,[wUnk_D052]
	and  a
	jr   nz,.unk_1493
	jr   .unk_144C
	ld   b,$08
	jr   .unk_1447
	ld   b,$13
	jr   .unk_1447
	ld   b,$18
	jr   .unk_1447
	ld   b,$1A
	jr   .unk_1447
	ldh  a,[hUnk_FFC3]
	ld   a,[wUnk_D052]
	and  a
	jr   z,.unk_144C
	ld   b,$1B
	jr   .unk_1447
	ldh  a,[hUnk_FFF9]
	and  a
	jr   nz,.unk_14AC
	call Unk_18D1
	ret

	ldh  a,[hJoyPressed]
	bit  3,a
	jp   nz,Unk_156C
	call Unk_1ADD
	call Unk_1952
	call Unk_197A
	ldh  a,[hUnk_FFF9]
	cp   a,$02
	jr   z,.unk_14CE
	cp   a,$03
	jr   z,.unk_14EB
	cp   a,$04
	ret  z
	ld   hl,$FFF9
	inc  [hl]
	ret

	ld   de,$1C38
	ld   hl,$C501
	call Unk_2794
	ld   a,$02
	ld   l,$24
	ldi  [hl],a
	xor  a
	ld   [hl],a
	ld   l,$37
	ld   a,$15
	ldi  [hl],a
	ld   a,$18
	ldi  [hl],a
	ld   a,$20
	ld   [hl],a
	jr   .unk_1541
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	call Unk_18FB
	ret

	ldh  a,[hUnk_FFF9]
	and  a
	jr   nz,.unk_1500
	call Unk_18D1
	call Unk_19D7
	ret

	ldh  a,[hJoyPressed]
	bit  3,a
	jr   nz,.unk_156C
	call Unk_1ADD
	call Unk_1952
	call Unk_197A
	ldh  a,[hUnk_FFF9]
	cp   a,$02
	jr   z,.unk_1546
	cp   a,$03
	jr   z,.unk_1563
	cp   a,$04
	ret  z
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	call Unk_1B0E
	ld   hl,$C00D
	ld   a,[hl]
	cp   a,$F1
	jr   z,.unk_1541
	cp   a,$A0
	call z,Unk_1929
	ld   a,[hl]
	cp   a,$50
	call z,Unk_192F
	ld   de,$0004
	ld   b,e
	dec  [hl]
	add  hl,de
	dec  b
	jr   nz,.unk_153B
	ret

	ld   hl,$FFF9
	inc  [hl]
	ret

	ld   de,$1C38
	ld   hl,$C501
	call Unk_2794
	ld   a,$02
	ld   l,$24
	ldi  [hl],a
	xor  a
	ld   [hl],a
	ld   l,$37
	ld   a,$16
	ldi  [hl],a
	ld   a,$0E
	ldi  [hl],a
	ld   a,$0D
	ld   [hl],a
	jr   .unk_1541
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	call Unk_18FB
	ret

	xor  a
	ldh  [hUnk_FFF9],a
	call ShutLCDDown
	ld   hl,$459E
	ld   de,$8800
	ld   bc,$0520
	call Copy
	ld   de,$38C4
	call PrintTileMap
	call ClearOAMBuffer
	ld   a,$83
	ldh  [rLCDC],a
	ld   a,$09
	ldh  [hGameStatus],a
	ret

	ldh  a,[hUnk_FFF9]
	and  a
	jr   nz,.unk_159C
	call Unk_18D1
	call Unk_19F2
	ret

	ldh  a,[hJoyPressed]
	bit  3,a
	jr   nz,.unk_156C
	call Unk_1ADD
	call Unk_1952
	call Unk_197A
	ldh  a,[hUnk_FFF9]
	cp   a,$02
	jr   z,.unk_15E3
	cp   a,$03
	jr   z,.unk_15F8
	cp   a,$04
	ret  z
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	call Unk_1B1C
	ld   hl,$C00D
	ld   a,[hl]
	cp   a,$F1
	jr   z,.unk_15DE
	cp   a,$A0
	call z,Unk_1929
	ld   a,[hl]
	cp   a,$50
	call z,Unk_192F
	ld   de,$0004
	ld   b,$04
	dec  [hl]
	add  hl,de
	dec  b
	jr   nz,.unk_15D8
	ret

	ld   hl,$FFF9
	inc  [hl]
	ret

	ld   de,$1C38
	ld   hl,$C501
	call Unk_2794
	xor  a
	ld   l,$24
	ldi  [hl],a
	ld   a,$05
	ld   [hl],a
	call Unk_18F2
	jr   .unk_15DE
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	call Unk_18FB
	ret

	ldh  a,[hUnk_FFF9]
	and  a
	jr   nz,.unk_160D
	call Unk_18D1
	call Unk_1A0D
	ret

	ldh  a,[hJoyPressed]
	bit  3,a
	jp   nz,Unk_156C
	call Unk_1ADD
	call Unk_1952
	call Unk_197A
	ldh  a,[hUnk_FFF9]
	cp   a,$02
	jr   z,.unk_1656
	cp   a,$03
	jr   z,.unk_166B
	cp   a,$04
	ret  z
	ldh  a,[hUnk_FFE2]
	and  a,$03
	ret  nz
	call Unk_1B2A
	ld   hl,$C00D
	ld   a,[hl]
	cp   a,$F2
	jr   z,.unk_1651
	cp   a,$A0
	call z,Unk_1929
	ld   a,[hl]
	cp   a,$50
	call z,Unk_192F
	ld   de,$0004
	ld   b,$04
	dec  [hl]
	dec  [hl]
	add  hl,de
	dec  b
	jr   nz,.unk_164A
	ret

	ld   hl,$FFF9
	inc  [hl]
	ret

	ld   de,$1C38
	ld   hl,$C501
	call Unk_2794
	ld   a,$01
	ld   l,$24
	ldi  [hl],a
	xor  a
	ld   [hl],a
	call Unk_18F2
	jr   .unk_1651
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	call Unk_18FB
	ret

	ldh  a,[hUnk_FFF9]
	and  a
	jr   nz,.unk_1680
	call Unk_18D1
	call Unk_1A28
	ret

	ldh  a,[hJoyPressed]
	bit  3,a
	jp   nz,Unk_156C
	call Unk_1ADD
	call Unk_1952
	call Unk_197A
	ldh  a,[hUnk_FFF9]
	cp   a,$02
	jr   z,.unk_16C9
	cp   a,$03
	jr   z,.unk_16DF
	cp   a,$04
	ret  z
	ldh  a,[hUnk_FFE2]
	and  a,$03
	ret  nz
	call Unk_1B47
	ld   hl,$C00D
	ld   a,[hl]
	cp   a,$EA
	jr   z,.unk_16C4
	cp   a,$A0
	call z,Unk_1929
	ld   a,[hl]
	cp   a,$50
	call z,Unk_192F
	ld   de,$0004
	ld   b,$04
	dec  [hl]
	dec  [hl]
	add  hl,de
	dec  b
	jr   nz,.unk_16BD
	ret

	ld   hl,$FFF9
	inc  [hl]
	ret

	ld   de,$1C38
	ld   hl,$C501
	call Unk_2794
	ld   a,$01
	ld   l,$24
	ldi  [hl],a
	ld   a,$05
	ld   [hl],a
	call Unk_18F2
	jr   .unk_16C4
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	call Unk_18FB
	ret

	call Unk_1952
	call Unk_197A
	ldh  a,[hUnk_FFF9]
	cp   a,$0B
	jr   nc,.unk_1700
	call Unk_1ADD
	ldh  a,[hUnk_FFF9]
	and  a
	jr   nz,.unk_1700
	call Unk_18D1
	ret

	ldh  a,[hJoyPressed]
	bit  3,a
	jp   nz,Unk_156C
	ldh  a,[hUnk_FFF9]
	cp   a,$02
	jr   z,.unk_1753
	cp   a,$03
	jr   z,.unk_175C
	cp   a,$04
	jr   z,.unk_176B
	cp   a,$05
	jr   z,.unk_1778
	cp   a,$06
	jr   z,.unk_1781
	cp   a,$07
	jp   z,Unk_1790
	cp   a,$08
	jp   z,Unk_17B6
	cp   a,$09
	jp   z,Unk_17C8
	cp   a,$0A
	jp   z,Unk_1842
	cp   a,$0B
	jp   z,Unk_186D
	cp   a,$0C
	jp   z,Unk_1897
	ld   de,$1C38
	ld   hl,$C501
	call Unk_2794
	ld   a,$02
	ld   l,$24
	ldi  [hl],a
	xor  a
	ld   [hl],a
	call Unk_18F2
	ld   hl,$FFF9
	inc  [hl]
	ret

	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	call Unk_18FB
	ret

	xor  a
	ld   [wUnk_D009],a
	ld   hl,$D068
	ld   a,$98
	ldi  [hl],a
	ld   a,$7F
	ld   [hl],a
	jr   .unk_174E
	ld   hl,$C500
	ld   b,$3C
	ld   a,$FF
	ldi  [hl],a
	dec  b
	jr   nz,.unk_1772
	jr   .unk_174E
	ldh  a,[hUnk_FFE2]
	and  a,$01
	ret  nz
	call Unk_18FB
	ret

	ld   hl,$D060
	inc  [hl]
	ld   a,[hl]
	cp   a,$A0
	ret  nz
	xor  a
	ld   [hl],a
	call Unk_1A43
	jr   .unk_174E
	call Unk_1B68
	ldh  a,[hUnk_FFE2]
	and  a,$03
	ret  nz
	ld   hl,$C00D
	ld   a,[hl]
	cp   a,$50
	jr   z,.unk_17AF
	cp   a,$90
	call z,Unk_1929
	ld   de,$0004
	ld   b,e
	dec  [hl]
	add  hl,de
	dec  b
	jr   nz,.unk_17A9
	ret

	ld   a,$02
	ld   [wUnk_DFF8],a
	jr   .unk_174E
	call Unk_1999
	ld   a,[wUnk_D065]
	cp   a,$0E
	jr   nc,.unk_17C1
	ret

	xor  a
	ld   [bc],a
	call Unk_1A5E
	jr   .unk_174E
	call Unk_1999
	ldh  a,[hUnk_FFE2]
	and  a,$03
	ret  nz
	ld   hl,wOAMBuffer
	ld   a,[hl]
	ld   de,$0004
	cp   a,$48
	jr   c,.unk_17EE
	ld   hl,$D05F
	ld   a,[hl]
	xor  a,$01
	ld   [hl],a
	ret  nz
	ld   hl,wOAMBuffer
	ld   b,$03
	dec  [hl]
	add  hl,de
	dec  b
	jr   nz,.unk_17E8
	ret

	call Unk_1B85
	push hl
	ld   hl,$C01D
	ld   b,$15
	ld   c,e
	ld   a,[hl]
	cp   a,$70
	call z,Unk_1C17
	cp   a,$5C
	call z,Unk_1BFA
	cp   a,$54
	call z,Unk_1C04
	cp   a,$4C
	call z,Unk_1C10
	cp   a,$40
	call z,Unk_1C27
	cp   a,$D0
	jr   z,.unk_1828
	jr   nc,.unk_181C
	cp   a,$40
	jr   nc,.unk_181E
	ld   c,$02
	ld   a,[hl]
	sub  c
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_181E
	pop  hl
	jr   .unk_17DB
	pop  hl
	ld   a,$03
	ld   [wUnk_DFF8],a
	ld   a,$FF
	ld   [wUnk_C082],a
	ld   [wUnk_C086],a
	ld   hl,$C01C
	ld   de,$1932
	call Unk_2794
	jp   Unk_174E
	call Unk_1BB9
	ld   hl,$C00D
	ld   a,[hl]
	cp   a,$F0
	jr   nc,.unk_185B
	ld   de,$0004
	ld   b,$06
	ld   a,[hl]
	add  a,$01
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_1852
	ret

	ld   hl,$C001
	ld   b,$26
	ld   de,$0004
	ld   a,$F0
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_1865
	jp   Unk_174E
	ldh  a,[rDIV]
	and  a,$07
	inc  a
	ld   de,$0004
	ld   hl,$1AB9
	add  hl,de
	dec  a
	jr   nz,.unk_1878
	push hl
	pop  bc
	ld   a,[wUnk_D066]
	ld   l,a
	add  a,$04
	cp   a,$98
	jr   nz,.unk_1889
	xor  a
	ld   [wUnk_D066],a
	ld   h,$C0
	ld   a,[bc]
	ldi  [hl],a
	inc  bc
	dec  e
	jr   nz,.unk_188E
	jp   Unk_174E
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	call Unk_1BD6
	ld   hl,$C001
	ld   de,$0004
	ld   b,$26
	ld   a,[hl]
	cp   a,$F0
	jr   z,.unk_18BE
	dec  [hl]
	dec  [hl]
	inc  l
	ldd  a,[hl]
	cp   a,$C8
	jr   nc,.unk_18BE
	dec  [hl]
	dec  [hl]
	ldh  a,[rDIV]
	and  a,$01
	jr   z,.unk_18BE
	dec  [hl]
	dec  [hl]
	add  hl,de
	dec  b
	jr   nz,.unk_18A7
	ld   hl,$D067
	inc  [hl]
	ld   a,[hl]
	cp   a,$06
	ret  nz
	xor  a
	ld   [hl],a
	ld   hl,$FFF9
	dec  [hl]
	ret

	call ShutLCDDown
	ld   hl,$559E
	ld   de,$8800
	ld   bc,$0520
	call Copy
	ld   de,$3B94
	call PrintTileMap
	call Unk_193B
	ld   a,$83
	ldh  [rLCDC],a
	ld   hl,$FFF9
	inc  [hl]
	ret

	ld   l,$38
	ld   a,$11
	ldi  [hl],a
	ld   a,$12
	ld   [hl],a
	ret

	ld   hl,$D009
	inc  [hl]
	ld   a,[hl]
	cp   a,$3C
	jr   z,.unk_1924
	ld   hl,$D068
	ldi  a,[hl]
	ld   d,a
	ld   e,[hl]
	inc  de
	ld   a,e
	cp   a,$94
	jr   z,.unk_191B
	cp   a,$D4
	jr   z,.unk_191F
	ldd  [hl],a
	ld   [hl],d
	ld   a,$03
	ldh  [hUnk_FF9D],a
	ret

	ld   a,$C0
	jr   .unk_1914
	ld   a,$00
	inc  d
	jr   .unk_1914
	ld   hl,$FFF9
	inc  [hl]
	ret

	ld   a,$01
	ld   [wUnk_D00A],a
	ret

	xor  a
	jr   .unk_192B
	<corrupted stop>
	ret  nc
	nop
	jr   .unk_1980
	pop  de
	nop
	-
	ld   hl,wOAMBuffer
	ld   de,$1945
	call Unk_2794
	ret

	sub  h
	ld   c,h
	ret  nz
	nop
	sub  h
	ld   d,h
	pop  bc
	nop
	sub  h
	ld   e,h
	jp   nz,Unk_FD00
	ldh  a,[hUnk_FFE2]
	and  a,$03
	ret  nz
	ld   hl,$C098
	ld   bc,$D063
	ld   a,[bc]
	and  a
	jr   nz,.unk_196A
	inc  a
	ld   [bc],a
	ld   de,$1975
	call Unk_2794
	ret

	inc  a
	ld   [bc],a
	cp   a,$38
	jr   nz,.unk_1972
	xor  a
	ld   [bc],a
	dec  [hl]
	dec  [hl]
	ret

	sub  b
	jr   c,.unk_1908
	nop
	-
	ldh  a,[hUnk_FFE2]
	and  a,$03
	ret  nz
	ld   hl,$C09C
	ld   bc,$D063
	ld   a,[bc]
	cp   a,$20
	jr   nz,.unk_1991
	ld   de,$1994
	call Unk_2794
	ret

	dec  [hl]
	dec  [hl]
	ret

	sub  b
	add  b
	sub  b
	nop
	-
	ld   hl,$C080
	ld   bc,$D064
	ld   a,[bc]
	and  a
	jr   nz,.unk_19AC
	inc  a
	ld   [bc],a
	ld   de,$19CE
	call Unk_2794
	ret

	inc  a
	ld   [bc],a
	ld   d,a
	ld   a,[wUnk_D065]
	cp   d
	jr   nz,.unk_19C2
	xor  a
	ld   [bc],a
	ld   a,d
	cp   a,$0E
	jr   z,.unk_19C2
	inc  a
	ld   [wUnk_D065],a
	xor  a
	ld   [bc],a
	ld   e,$08
	ld   a,[hl]
	add  e
	ldi  [hl],a
	inc  l
	inc  l
	inc  l
	ld   a,[hl]
	add  e
	ld   [hl],a
	ret

	jr   nz,.unk_1A24
	cp   a,$00
	jr   nc,.unk_1A28
	cp   a,$00
	-
	ld   hl,$C00C
	ld   de,$19E1
	call Unk_2794
	ret

	ld   d,b
	ldh  a,[hUnk_FF94]
	nop
	ld   d,b
	ld   hl,[sp+$95]
	nop
	ld   e,b
	ldh  a,[hUnk_FF96]
	nop
	ld   e,b
	ld   hl,[sp+$97]
	nop
	-
	ld   hl,$C00C
	ld   de,$19FC
	call Unk_2794
	ret

	ld   b,b
	ldh  a,[hUnk_FF98]
	nop
	ld   b,b
	ld   hl,[sp+$99]
	nop
	ld   c,b
	ldh  a,[hFramesTillDrop_Reload]
	nop
	ld   c,b
	ld   hl,[sp+$9B]
	nop
	-
	ld   hl,$C00C
	ld   de,$1A17
	call Unk_2794
	ret

	ld   a,h
	ldh  a,[hUnk_FF91]
	nop
	ld   a,h
	ld   hl,[sp+$91]
	jr   nz,.unk_19A4
	ldh  a,[hUnk_FF92]
	nop
	add  h
	ld   hl,[sp+$93]
	jr   nz,.unk_1A25
	ld   hl,$C00C
	ld   de,$1A32
	call Unk_2794
	ret

	jr   .unk_1A1C
	sbc  l
	nop
	<corrupted stop>
	and  b
	nop
	jr   .unk_1A2C
	sbc  [hl]
	nop
	jr   .unk_1A38
	sbc  a
	nop
	-
	ld   hl,$C00C
	ld   de,$1A4D
	call Unk_2794
	ret

	<corrupted stop>
	jp   z,Unk_1000
	ld   hl,[sp+$CA]
	jr   nz,.unk_1A6E
	ldh  a,[hUnk_FFBF]
	nop
	jr   .unk_1A53
	cp   a
	jr   nz,.unk_1A5B
	ld   hl,$C01C
	ld   de,$1A68
	call Unk_2794
	ret

	jr   nc,.unk_1A32
	and  d
	nop
	jr   c,.unk_1A36
	or   d
	nop
	ld   b,b
	ret  z
	xor  c
	nop
	jr   nc,.unk_1A46
	and  e
	nop
	jr   c,.unk_1A4A
	or   e
	nop
	ld   b,b
	ret  nc
	xor  d
	nop
	jr   nc,.unk_1A5A
	and  h
	nop
	jr   c,.unk_1A5E
	or   h
	nop
	ld   b,b
	ret  c
	xor  e
	nop
	jr   nc,.unk_1A6E
	and  l
	nop
	jr   c,.unk_1A72
	or   l
	nop
	ld   b,b
	ldh  [hUnk_FFAC],a
	nop
	jr   nc,.unk_1A82
	and  [hl]
	nop
	jr   c,.unk_1A86
	or   [hl]
	nop
	ld   b,b
	add  sp,$AD
	nop
	jr   nc,.unk_1A96
	and  a
	nop
	jr   c,.unk_1A9A
	or   a
	nop
	ld   b,b
	ldh  a,[hUnk_FFAE]
	nop
	jr   nc,.unk_1AAA
	xor  b
	nop
	jr   c,.unk_1AAE
	cp   b
	nop
	ld   b,b
	ld   hl,[sp+$AF]
	nop
	-
	jr   z,.unk_1A97
	add  a,$00
	jr   c,.unk_1A9B
	add  a,$00
	ld   b,b
	ret  c
	ret  z
	nop
	ld   c,b
	ret  c
	add  a,$00
	ld   e,b
	ret  c
	add  a,$00
	ld   h,b
	ret  c
	ret  z
	nop
	ld   l,b
	ret  c
	add  a,$00
	ld   a,b
	ret  c
	add  a,$00
	ld   a,[wUnk_C00A]
	cp   a,$FF
	ret  z
	ld   b,$0F
	ld   a,[wUnk_D00A]
	and  a
	jr   z,.unk_1AED
	ld   b,$03
	ldh  a,[hUnk_FFE2]
	and  b
	ret  nz
	ld   hl,$C002
	ld   de,$0004
	ld   b,$03
	ld   a,[hl]
	cp   a,$C0
	jr   z,.unk_1B06
	dec  [hl]
	dec  [hl]
	dec  [hl]
	add  hl,de
	dec  b
	jr   nz,.unk_1AFE
	ret

	inc  [hl]
	inc  [hl]
	inc  [hl]
	add  hl,de
	dec  b
	jr   nz,.unk_1B06
	ret

	ld   hl,$C01A
	ld   a,[hl]
	cp   a,$97
	jr   z,.unk_1B19
	ld   [hl],$97
	ret

	ld   [hl],$85
	ret

	ld   hl,$C016
	ld   b,$9C
	ld   a,[hl]
	cp   a,$9A
	jr   z,.unk_1B28
	ld   b,$9A
	ld   [hl],b
	ret

	ld   hl,$D005
	inc  [hl]
	ld   a,[hl]
	cp   a,$02
	ret  nz
	xor  a
	ld   [hl],a
	ld   hl,$C016
	ld   de,$0004
	ld   a,[hl]
	cp   a,$92
	jr   z,.unk_1B43
	dec  [hl]
	add  hl,de
	inc  [hl]
	ret

	inc  [hl]
	add  hl,de
	dec  [hl]
	ret

	ld   hl,$D006
	inc  [hl]
	ld   a,[hl]
	cp   a,$02
	ret  nz
	xor  a
	ld   [hl],a
	ld   hl,$C012
	ld   de,$0004
	ld   a,[hl]
	cp   a,$A0
	jr   z,.unk_1B62
	ld   [hl],$A0
	add  hl,de
	ld   [hl],$9E
	ret

	ld   [hl],$FF
	add  hl,de
	ld   [hl],$A1
	ret

	ld   hl,$D05B
	inc  [hl]
	ld   a,[hl]
	cp   a,$03
	ret  nz
	xor  a
	ld   [hl],a
	ld   hl,$C00E
	ld   de,$0004
	ld   a,[hl]
	cp   a,$CB
	jr   z,.unk_1B81
	inc  [hl]
	add  hl,de
	inc  [hl]
	ret

	dec  [hl]
	add  hl,de
	dec  [hl]
	ret

	ld   hl,$D061
	inc  [hl]
	ld   a,[hl]
	cp   a,$02
	ret  nz
	xor  a
	ld   [hl],a
	ld   hl,$C05A
	ld   de,$0004
	ld   bc,$1BAB
	ld   a,[hl]
	cp   a,$A7
	jr   z,.unk_1B9F
	jr   .unk_1BA2
	ld   bc,$1BB2
	ld   a,[bc]
	cp   a,$FD
	ret  z
	ld   [hl],a
	add  hl,de
	inc  bc
	jr   .unk_1BA2
	and  a
	or   a
	xor  [hl]
	xor  b
	cp   b
	xor  a
	-
	cp   c
	cp   e
	cp   l
	cp   d
	cp   h
	cp   [hl]
	-
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	ld   hl,$C01E
	ld   de,$0004
	ld   a,[hl]
	cp   a,$D0
	jr   z,.unk_1BD0
	ld   a,$D0
	ld   [hl],a
	add  hl,de
	inc  a
	ld   [hl],a
	ret

	ld   a,$FF
	ld   [hl],a
	add  hl,de
	ld   [hl],a
	ret

	ld   hl,$C002
	ld   de,$0004
	ld   b,$26
	ld   a,[hl]
	cp   a,$C6
	jr   z,.unk_1BF7
	cp   a,$C7
	jr   z,.unk_1BF1
	cp   a,$C8
	jr   z,.unk_1BF7
	cp   a,$C9
	jr   z,.unk_1BF1
	jr   .unk_1BF2
	dec  [hl]
	add  hl,de
	dec  b
	jr   nz,.unk_1BDE
	ret

	inc  [hl]
	jr   .unk_1BF2
	push af
	push hl
	ld   hl,$C00A
	ld   [hl],$FF
	pop  hl
	pop  af
	ret

	push af
	push hl
	ld   a,$0E
	ld   [wUnk_DFE0],a
	ld   hl,$C006
	jr   .unk_1BFF
	push af
	push hl
	ld   hl,$C002
	jr   .unk_1BFF
	push af
	push hl
	ld   hl,$C022
	ld   a,$B0
	ldi  [hl],a
	inc  l
	inc  l
	inc  l
	inc  a
	ld   [hl],a
	pop  hl
	pop  af
	ret

	push af
	push hl
	ld   hl,$C022
	ld   a,$B2
	ldi  [hl],a
	inc  l
	inc  l
	inc  l
	ld   a,$A9
	ld   [hl],a
	pop  hl
	pop  af
	ret

	rst  $38
	rst  $38
	inc  c
	jr   .unk_1C54
	<corrupted stop>
	ld   a,[bc]
	dec  e
	ld   e,$15
	ld   a,[bc]
	dec  e
	ld   [de],a
	jr   .unk_1C5F
	inc  e
	dec  h
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rra
	ld   [de],a
	dec  de
	ld   e,$1C
	rst  $38
	dec  d
	ld   c,$1F
	ld   c,$15
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  e
	add  hl,de
	ld   c,$0E
	dec  c
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	-
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	ld   de,$FF12
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	dec  d
	ld   c,$1F
	ld   c,$15
	rst  $38
	nop
	dec  b
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rla
	ld   [de],a
	inc  c
	ld   c,$FF
	inc  c
	dec  d
	ld   c,$0A
	dec  de
	rst  $38
	rst  $38
	rst  $38
	-
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	ld   de,$FF12
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	dec  d
	ld   c,$1F
	ld   c,$15
	rst  $38
	ld   bc,rP1
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rla
	ld   [de],a
	inc  c
	ld   c,$FF
	inc  c
	dec  d
	ld   c,$0A
	dec  de
	rst  $38
	rst  $38
	rst  $38
	-
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	ld   de,$FF12
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	dec  d
	ld   c,$1F
	ld   c,$15
	rst  $38
	ld   bc,rTIMA
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rla
	ld   [de],a
	inc  c
	ld   c,$FF
	inc  c
	dec  d
	ld   c,$0A
	dec  de
	rst  $38
	rst  $38
	rst  $38
	-
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	ld   de,$FF12
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	dec  d
	ld   c,$1F
	ld   c,$15
	rst  $38
	ld   [bc],a
	nop
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rla
	ld   [de],a
	inc  c
	ld   c,$FF
	inc  c
	dec  d
	ld   c,$0A
	dec  de
	rst  $38
	rst  $38
	rst  $38
	-
	ld   b,$0A
	ld   a,[de]
	ld   [hl],a
	inc  l
	inc  e
	dec  b
	jr   nz,.unk_1D5F
	ldh  a,[hUnk_FFE3]
	inc  a
	ldh  [hUnk_FFE3],a
	ret

	ld   hl,$C200
	ld   a,[hl]
	cp   a,$80
	ret  z
	ld   l,$03
	ld   a,[hl]
	ldh  [hUnk_FFA0],a
	ldh  a,[hJoyPressed]
	ld   b,a
	bit  0,b
	jr   nz,.unk_1D91
	bit  1,b
	jr   z,.unk_1DCF
	ld   a,[hl]
	and  a,$03
	jr   z,.unk_1D8B
	dec  [hl]
	jr   .unk_1D9F
	ld   a,[hl]
	or   a,$03
	ld   [hl],a
	jr   .unk_1D9F
	ld   a,[hl]
	and  a,$03
	cp   a,$03
	jr   z,.unk_1D9B
	inc  [hl]
	jr   .unk_1D9F
	ld   a,[hl]
	and  a,$FC
	ld   [hl],a
	ld   a,$02
	ld   [wUnk_DFE0],a
	call Unk_202A
	call Unk_1F61
	and  a
	jr   z,.unk_1DCF
	ld   hl,$C202
	ld   a,[hl]
	ldh  [hUnk_FFA1],a
	sub  a,$08
	ld   [hl],a
	call Unk_202A
	call Unk_1F61
	and  a
	jr   z,.unk_1DCF
	xor  a
	ld   [wUnk_DFE0],a
	ld   hl,$C203
	ldh  a,[hUnk_FFA0]
	ldd  [hl],a
	ldh  a,[hUnk_FFA1]
	ld   [hl],a
	call Unk_202A
	ld   hl,$C202
	ldh  a,[hJoyPressed]
	ld   b,a
	ldh  a,[hJoyHeld]
	ld   c,a
	ld   a,[hl]
	ldh  [hUnk_FFA0],a
	bit  4,b
	ld   a,$10
	jr   nz,.unk_1DED
	bit  4,c
	jr   z,.unk_1E12
	ldh  a,[hUnk_FFAA]
	dec  a
	ldh  [hUnk_FFAA],a
	ret  nz
	ld   a,$06
	ldh  [hUnk_FFAA],a
	ld   a,[hl]
	add  a,$08
	ld   [hl],a
	call Unk_202A
	ld   a,$03
	ld   [wUnk_DFE0],a
	call Unk_1F61
	and  a
	ret  z
	ld   hl,$C202
	xor  a
	ld   [wUnk_DFE0],a
	ldh  a,[hUnk_FFA0]
	ld   [hl],a
	call Unk_202A
	ld   a,$01
	ldh  [hUnk_FFAA],a
	ret

	bit  5,b
	ld   a,$10
	jr   nz,.unk_1E24
	bit  5,c
	jr   z,.unk_1E0F
	ldh  a,[hUnk_FFAA]
	dec  a
	ldh  [hUnk_FFAA],a
	ret  nz
	ld   a,$06
	ldh  [hUnk_FFAA],a
	ld   a,[hl]
	sub  a,$08
	ld   [hl],a
	ld   a,$03
	ld   [wUnk_DFE0],a
	call Unk_202A
	call Unk_1F61
	and  a
	ret  z
	jr   .unk_1E00
	ld   hl,$C018
	ld   b,$60
	jr   .unk_1E45
ClearOAMBuffer:
	ld   hl,wOAMBuffer
	ld   b,$A0
	xor  a
	ldi  [hl],a
	dec  b
	jr   nz,.unk_1E46
	ret

	ld   hl,$99C2
	ld   de,$1E70
	ld   c,$04
	ld   b,$0A
	push hl
	ld   a,[de]
	ld   [hl],a
	push hl
	ld   a,h
	add  a,$30
	ld   h,a
	ld   a,[de]
	ld   [hl],a
	pop  hl
	inc  l
	inc  de
	dec  b
	jr   nz,.unk_1E56
	pop  hl
	push de
	ld   de,$0020
	add  hl,de
	pop  de
	dec  c
	jr   nz,.unk_1E53
	ret

	add  l
	cpl
	add  d
	add  [hl]
	add  e
	cpl
	cpl
	add  b
	add  d
	add  l
	cpl
	add  d
	add  h
	add  d
	add  e
	cpl
	add  e
	cpl
	add  a
	cpl
	cpl
	add  l
	cpl
	add  e
	cpl
	add  [hl]
	add  d
	add  b
	add  c
	cpl
	add  e
	cpl
	add  [hl]
	add  e
	cpl
	add  l
	cpl
	add  l
	cpl
	cpl
	ldh  a,[hIsDemoActive]
	and  a
	ret  nz
	ldh  a,[hJoyPressed]
	bit  3,a
	jp   z,Unk_1F01
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_1EC8
	ld   hl,rLCDC
	ldh  a,[hUnk_FFAB]
	xor  a,$01
	ldh  [hUnk_FFAB],a
	jr   z,.unk_1EBE
	ld   a,[hl]
	res  1,[hl]
	set  3,[hl]
	ld   a,$01
	ld   [wUnk_DF7F],a
	ret

	res  3,[hl]
	set  1,[hl]
	ld   a,$02
	ld   [wUnk_DF7F],a
	ret

	ldh  a,[hSerialRole]
	cp   a,$30
	ret  nz
	ldh  a,[hUnk_FFAB]
	xor  a,$01
	ldh  [hUnk_FFAB],a
	jr   z,.unk_1F25
	call Unk_1EE9
	jr   .unk_1F0B
	ldh  a,[hUnk_FFAB]
	and  a
	jr   nz,.unk_1F18
	ldh  a,[hUnk_FFD0]
	cp   a,$90
	ret  nz
	call Unk_1EE9
	jr   .unk_1F18
	ld   a,$01
	ldh  [hUnk_FFAB],a
	ld   [wUnk_DF7F],a
	ld   hl,$984C
	ld   de,$0DA8
	ld   a,[de]
	cp   a,$FD
	ret  z
	call Unk_1F56
	inc  de
	inc  hl
	jr   .unk_1EF6
	ldh  a,[hTwoPlayerMode]
	and  a
	ret  z
	ldh  a,[hSerialRole]
	cp   a,$30
	jr   nz,.unk_1EDA
	ldh  a,[hUnk_FFAB]
	and  a
	ret  z
	ld   a,$90
	ldh  [hSerialNext],a
	call Unk_2C4F
	pop  hl
	ret

	xor  a
	ldh  [hSerialNext],a
	ldh  a,[hUnk_FFD0]
	cp   a,$90
	jr   z,.unk_1F37
	cp   a,$E0
	jr   z,.unk_1F37
	ld   a,$02
	ld   [wUnk_DF7F],a
	xor  a
	ldh  [hUnk_FFAB],a
	ld   hl,$984C
	ld   de,$1F4E
	call Unk_1EF6
	ret

	call Unk_2C4F
	pop  hl
	ret

	ld   hl,$98EE
	ld   c,$05
	ld   de,$0DA8
	ld   a,[de]
	call Unk_1F56
	inc  de
	inc  l
	dec  c
	jr   nz,.unk_1F44
	ret

	dec  c
	cpl
	ld   d,$0A
	dec  de
	ld   [de],a
	jr   .unk_1F53
	di
	ld   b,a
	ldh  a,[rSTAT]
	and  a,$03
	jr   nz,.unk_1F58
	ld   [hl],b
	ei
	ret

	ld   b,$02
	ld   hl,$C010
	ldi  a,[hl]
	cp   a,$98
	jr   nc,.unk_1F90
	sub  a,$18
	ld   e,a
	ldi  a,[hl]
	cp   a,$11
	jr   c,.unk_1F90
	cp   a,$58
	jr   nc,.unk_1F90
	cp   a,$18
	jr   z,.unk_1F80
	sub  a,$08
	inc  e
	jr   .unk_1F77
	ld   d,$C8
	ld   a,[de]
	cp   a,$FF
	jr   nz,.unk_1F90
	inc  l
	inc  l
	dec  b
	jr   nz,.unk_1F66
	xor  a
	ldh  [hUnk_FF9B],a
	ret

	ld   a,$01
	ldh  [hUnk_FF9B],a
	ret

	ldh  a,[hUnk_FF98]
	cp   a,$01
	ret  nz
	ld   hl,$C010
	ld   b,$02
	ldi  a,[hl]
	ldh  [hUnk_FFB2],a
	ldi  a,[hl]
	ldh  [hUnk_FFB3],a
	push hl
	push bc
	call Unk_2359
	push hl
	pop  de
	pop  bc
	pop  hl
	ld   a,d
	cp   a,$98
	jr   nz,.unk_1FD2
	ld   a,e
	and  a,$F0
	cp   a,$20
	jr   z,.unk_1FDC
	cp   a,$40
	jr   nz,.unk_1FD2
	ld   a,e
	cp   a,$45
	jr   z,.unk_1FD2
	cp   a,$46
	jr   z,.unk_1FD2
	ld   a,[hl]
	and  a,$F0
	cp   a,$B0
	jr   nz,.unk_1FD2
	ld   a,[hl]
	add  a,$10
	ld   [hl],a
	di
	ldh  a,[rSTAT]
	and  a,$03
	jr   nz,.unk_1FD3
	ld   a,[hl]
	ld   [de],a
	ei
	inc  l
	inc  l
	dec  b
	jr   nz,.unk_1F9F
	ld   b,$01
	ld   hl,$C010
	call Unk_1F66
	ld   hl,$C012
	ld   a,e
	and  a,$F8
	jr   z,.unk_1FF3
	ld   a,[hl]
	ld   [de],a
	ld   b,$01
	ld   hl,$C014
	call Unk_1F66
	ld   hl,$C016
	ld   a,e
	db   $E6
Bankswitch:
	ld   hl,[sp+$28]
	ld   [bc],a
	ld   a,[hl]
	ld   [de],a
	ld   hl,$C200
	ld   [hl],$80
	call Unk_202A
	ld   a,$02
	ldh  [hUnk_FF98],a
	ld   a,$01
	ld   [wUnk_DFF8],a
	ret

	ld   a,$02
	ldh  [hUnk_FF8F],a
	ld   a,$10
	ldh  [hUnk_FF8E],a
	ld   a,$C0
	ldh  [hUnk_FF8D],a
	ld   hl,$C200
	call Unk_2390
	ret

	ld   a,$01
	ldh  [hUnk_FF8F],a
	ld   a,$10
	ldh  [hUnk_FF8E],a
	ld   a,$C0
	ldh  [hUnk_FF8D],a
	ld   hl,$C200
	call Unk_2390
	ret

	ld   a,$01
	ldh  [hUnk_FF8F],a
	ld   a,$18
	ldh  [hUnk_FF8E],a
	ld   a,$C0
	ldh  [hUnk_FF8D],a
	ld   hl,$C210
	call Unk_2390
	ret

	ld   b,$20
	ld   a,$8E
	ld   de,$0020
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_2057
	ret
TimerHandler:
	ei
	push af
	ld   a,[wUnk_D054]
	and  a
	jr   nz,.unk_206A
	ldh  a,[hIsDemoActive]
	and  a
	jr   nz,.unk_2079
	xor  a
	ld   [wUnk_D054],a
	push bc
	push de
	push hl
	call JumpTo
	pop  hl
	pop  de
	pop  bc
	pop  af
	reti
	xor  a
	ld   [wUnk_DFE0],a
	ld   [wUnk_DFF8],a
	jr   .unk_206A
LCDHandler:
	reti
	nop
	jr   nz,.unk_20B6
	nop
	nop
	nop
	nop
	rst  $38
	nop
	dec  sp
	ld   l,d
	nop
	nop
	nop
	nop
	rst  $38
	nop
	inc  d
	jr   nc,.unk_2097
	nop
	nop
	nop
	rst  $38
	nop
	dec  sp
	ld   l,d
	stop
	nop
	nop
	rst  $38
Clear9800Map:
	ld   hl,$9BFF
	ld   bc,$0400
	ld   a,$FF
	ldd  [hl],a
	dec  bc
	ld   a,b
	or   c
	jr   nz,.unk_20A9
	ret
Copy:
	ldi  a,[hl]
	ld   [de],a
	inc  de
	dec  bc
	ld   a,b
	or   c
	jr   nz,Copy
	ret
CopyTiles:
	ld   hl,Tiles
	ld   de,$8000
	ld   bc,$17FF
	call Copy
	ret

	ret
PrintTileMap:
	ld   hl,$9800
	ld   b,$12
	push hl
	ld   c,$14
	ld   a,[de]
	ldi  [hl],a
	inc  de
	dec  c
	jr   nz,.unk_20D1
	pop  hl
	push de
	ld   de,$0020
	add  hl,de
	pop  de
	dec  b
	jr   nz,.unk_20CE
	ret

	ld   hl,$9C00
	ld   b,$18
	push hl
	ld   c,$09
	ld   a,[de]
	ldi  [hl],a
	inc  de
	dec  c
	jr   nz,.unk_20EA
	pop  hl
	push de
	ld   de,$0020
	add  hl,de
	pop  de
	dec  b
	jr   nz,.unk_20E7
	ret

	ld   de,$DFE8
	xor  a
	ldh  [hUnk_FFDE],a
	ld   a,[wUnk_D042]
	and  a
	jr   nz,.unk_211F
	ld   a,$04
	ld   [de],a
	ld   hl,wUnk_D000
	ldi  a,[hl]
	cp   a,$03
	jr   z,.unk_2117
	ld   a,[hl]
	cp   a,$03
	jr   nz,.unk_211A
	ld   a,$06
	ld   [de],a
	ld   a,$01
	ld   [wUnk_D042],a
	call Unk_279C
	ldh  a,[hWaitFrames]
	and  a
	ret  nz
	ldh  a,[hUnk_FFF4]
	cp   a,$FD
	jr   nz,.unk_2131
	call Unk_1393
	jr   .unk_2134
	call Unk_2181
	ldh  a,[hSerialRole]
	cp   a,$30
	jr   z,.unk_2141
	ldh  a,[hUnk_FFD0]
	cp   a,$E8
	jr   z,.unk_214E
	ret

	ldh  a,[hJoyPressed]
	cp   a,$08
	ret  nz
	ldh  a,[hUnk_FFA7]
	and  a
	ret  nz
	ld   a,$E8
	ldh  [hSerialNext],a
	ld   a,$83
	ldh  [rLCDC],a
	call Unk_10A6
	xor  a
	ld   [wUnk_D04B],a
	call Unk_2172
	call JumpToInitMusic
	call Unk_1E39
	call Unk_0B83
	ld   a,$10
	ldh  [hWaitFrames],a
	ld   a,$15
	ldh  [hGameStatus],a
	xor  a
	ld   [wUnk_D042],a
	ret

	ld   hl,$C023
	ld   de,$0004
	ld   b,$0A
	res  7,[hl]
	add  hl,de
	dec  b
	jr   nz,.unk_217A
	ret

	ldh  a,[hUnk_FFE2]
	and  a,$0F
	ret  nz
	ld   hl,$C022
	ld   de,$0004
	ld   bc,$D03F
	ld   a,[bc]
	xor  a,$01
	ld   [bc],a
	jr   z,.unk_21A2
	call Unk_1025
	ret

	ld   a,[bc]
	cp   a,$FD
	ret  z
	ld   [hl],a
	add  hl,de
	inc  bc
	jr   .unk_2199
	ld   bc,$21AB
	jr   .unk_2199
	rst  $38
	inc  e
	dec  e
	-
	inc  a
	ld   l,$2F
	-
	xor  a
	ldh  [hUnk_FF98],a
	ldh  [hUnk_FFC0],a
	call Unk_279C
	ldh  a,[hWaitFrames]
	and  a
	ret  nz
	ld   b,$14
	ld   a,[wUnk_D000]
	cp   a,$03
	jp   nc,Unk_21D1
	ld   a,[wUnk_D001]
	cp   a,$03
	jp   nc,Unk_21D1
	ld   b,$09
	jr   .unk_21DC
	ld   hl,wUnk_D000
	xor  a
	ldi  [hl],a
	ld   [hl],a
	push bc
	call ClearOAMBuffer
	pop  bc
	ld   a,b
	ldh  [hGameStatus],a
	call Unk_1E39
	ret

	call ShutLCDDown
	xor  a
	ldh  [hIsDemoActive],a
	ld   de,$8000
	ld   hl,$4D9E
	ld   bc,$0300
	call Copy
	ld   de,$5ABE
	call PrintTileMap
	ldh  a,[hTwoPlayerMode]
	inc  a
	ld   [wUnk_9844],a
	ld   hl,wOAMBuffer
	ld   de,$05E7
	rst  $18
	ret

	call Unk_0653
	call Unk_0928
	call Unk_0AF5
	ld   a,$83
	ldh  [rLCDC],a
	xor  a
	ldh  [hSerialNext],a
	ldh  [hUnk_FFD0],a
	ld   hl,$9863
	ld   a,$93
	ld   bc,$0302
	call Unk_0B4C
	ld   hl,$986F
	ld   a,$95
	ld   bc,$0203
	call Unk_0B4C
	ld   hl,$9864
	ld   a,$94
	ld   b,$0B
	call Unk_0B42
	ld   hl,$98A4
	ld   a,$99
	ld   b,$0B
	call Unk_0B42
	ld   hl,$DFE9
	ld   a,$03
	cp   [hl]
	ret  z
	ld   [wUnk_DFE8],a
	ret
ShutLCDDown:
	ldh  a,[rIE]
	ldh  [hUnk_FFA1],a
	res  0,a
	ldh  [rIE],a
	ldh  a,[rLY]
	cp   a,$91
	jr   nz,.unk_2258
	ldh  a,[rLCDC]
	and  a,$7F
	ldh  [rLCDC],a
	xor  a
	ldh  [rIF],a
	ldh  a,[hUnk_FFA1]
	ldh  [rIE],a
	ret

	ldh  a,[hTwoPlayerMode]
	and  a
	ret  nz
	ld   hl,$C859
	ld   de,$1104
	call Unk_0D90
	ret

	ldh  a,[hTwoPlayerMode]
	and  a
	ret  nz
	ld   hl,$C85A
	ld   de,$10FF
	call Unk_0D90
	ret

	ldh  a,[hTwoPlayerMode]
	and  a
	ret  z
	ld   hl,$C848
	ld   de,$110A
	call Unk_0D90
	ret

	ldh  a,[hTwoPlayerMode]
	and  a
	ret  z
	ld   hl,$C830
	ld   de,$1113
	call Unk_0D90
	ret

	ld   hl,$C84A
	ldh  a,[hUnk_FFF4]
	cp   a,$FD
	jr   nz,.unk_22B0
	ld   hl,$C832
	ld   de,$1134
	call Unk_0D90
	ret

	ld   hl,$C828
	ld   b,$58
	ld   a,$FE
	call Unk_2687
	ret

	ld   hl,$C840
	ld   b,$40
	ld   a,$FE
	call Unk_2687
	ret

	ld   hl,$C850
	ld   b,$30
	ld   a,$FE
	call Unk_2687
	ret

	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_2309
	ldh  a,[hSerialRole]
	cp   a,$60
	jr   z,.unk_22F6
	ld   hl,$C872
	ld   de,$111C
	call Unk_0D90
	ld   hl,$C879
	ld   de,$1121
	call Unk_0D90
	ret

	ld   hl,$C871
	ld   de,$1128
	call Unk_0D90
	ld   hl,$C87A
	ld   de,$112F
	call Unk_0D90
	ret

	ld   hl,$C869
	ld   de,$111C
	call Unk_0D90
	ld   hl,$C872
	ld   de,$1121
	call Unk_0D90
	ret
PollJoypad:
	ld   a,$20
	ldh  [rP1],a
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rP1]
	cpl
	and  a,$0F
	swap a
	ld   b,a
	ld   a,$10
	ldh  [rP1],a
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rP1]
	cpl
	and  a,$0F
	or   b
	ld   c,a
	ldh  a,[hJoyHeld]
	xor  c
	and  c
	ldh  [hJoyPressed],a
	ld   a,c
	ldh  [hJoyHeld],a
	ld   a,$30
	ldh  [rP1],a
	ret

	ldh  a,[hUnk_FFB2]
	sub  a,$10
	srl  a
	srl  a
	srl  a
	ld   de,Reset
	ld   e,a
	ld   hl,$9800
	ld   b,$20
	add  hl,de
	dec  b
	jr   nz,.unk_236C
	ldh  a,[hUnk_FFB3]
	sub  a,$08
	srl  a
	srl  a
	srl  a
	ld   de,Reset
	ld   e,a
	add  hl,de
	ld   a,h
	ldh  [hUnk_FFB5],a
	ld   a,l
	ldh  [hUnk_FFB4],a
	ret
DMARoutine:
	ld   a,$C0
	ldh  [rDMA],a
	ld   a,$28
	dec  a
	jr   nz,.unk_238C
	ret

	ld   a,h
	ldh  [hUnk_FF96],a
	ld   a,l
	ldh  [hUnk_FF97],a
	ld   a,[hl]
	and  a
	jr   z,.unk_23B7
	cp   a,$80
	jr   z,.unk_23B5
	ldh  a,[hUnk_FF96]
	ld   h,a
	ldh  a,[hUnk_FF97]
	ld   l,a
	ld   de,$0010
	add  hl,de
	ldh  a,[hUnk_FF8F]
	dec  a
	ldh  [hUnk_FF8F],a
	ret  z
	jr   .unk_2390
	xor  a
	ldh  [hUnk_FF95],a
	jr   .unk_239E
	ldh  [hUnk_FF95],a
	ld   b,$07
	ld   de,$FF86
	ldi  a,[hl]
	ld   [de],a
	inc  de
	dec  b
	jr   nz,.unk_23BC
	ldh  a,[hUnk_FF89]
	ld   hl,$246B
	rlca
	ld   e,a
	ld   d,$00
	add  hl,de
	ld   e,[hl]
	inc  hl
	ld   d,[hl]
	ld   a,[de]
	ld   l,a
	inc  de
	ld   a,[de]
	ld   h,a
	inc  de
	ld   a,[de]
	ldh  [hUnk_FF90],a
	inc  de
	ld   a,[de]
	ldh  [hUnk_FF91],a
	ld   e,[hl]
	inc  hl
	ld   d,[hl]
	inc  hl
	ldh  a,[hUnk_FF8C]
	ldh  [hUnk_FF94],a
	ld   a,[hl]
	cp   a,$FF
	jr   z,.unk_23B0
	cp   a,$FD
	jr   nz,.unk_23FB
	ldh  a,[hUnk_FF8C]
	xor  a,$20
	ldh  [hUnk_FF94],a
	inc  hl
	ld   a,[hl]
	jr   .unk_23FF
	inc  de
	inc  de
	jr   .unk_23DF
	cp   a,$FE
	jr   z,.unk_23F7
	ldh  [hUnk_FF89],a
	ldh  a,[hUnk_FF87]
	ld   b,a
	ld   a,[de]
	ld   c,a
	ldh  a,[hUnk_FF8B]
	bit  6,a
	jr   nz,.unk_2412
	ldh  a,[hUnk_FF90]
	add  b
	adc  c
	jr   .unk_241C
	ld   a,b
	push af
	ldh  a,[hUnk_FF90]
	ld   b,a
	pop  af
	sub  b
	sbc  c
	sbc  a,$08
	ldh  [hUnk_FF93],a
	ldh  a,[hUnk_FF88]
	ld   b,a
	inc  de
	ld   a,[de]
	inc  de
	ld   c,a
	ldh  a,[hUnk_FF8B]
	bit  5,a
	jr   nz,.unk_2431
	ldh  a,[hUnk_FF91]
	add  b
	adc  c
	jr   .unk_243B
	ld   a,b
	push af
	ldh  a,[hUnk_FF91]
	ld   b,a
	pop  af
	sub  b
	sbc  c
	sbc  a,$08
	ldh  [hUnk_FF92],a
	push hl
	ldh  a,[hUnk_FF8D]
	ld   h,a
	ldh  a,[hUnk_FF8E]
	ld   l,a
	ldh  a,[hUnk_FF95]
	and  a
	jr   z,.unk_244D
	ld   a,$FF
	jr   .unk_244F
	ldh  a,[hUnk_FF93]
	ldi  [hl],a
	ldh  a,[hUnk_FF92]
	ldi  [hl],a
	ldh  a,[hUnk_FF89]
	ldi  [hl],a
	ldh  a,[hUnk_FF94]
	ld   b,a
	ldh  a,[hUnk_FF8B]
	or   b
	ld   b,a
	ldh  a,[hUnk_FF8A]
	or   b
	ldi  [hl],a
	ld   a,h
	ldh  [hUnk_FF8D],a
	ld   a,l
	ldh  [hUnk_FF8E],a
	pop  hl
	jp   Unk_23DF
	sbc  e
	inc  h
	sbc  a
	inc  h
	and  e
	inc  h
	and  a
	inc  h
	xor  e
	inc  h
	xor  a
	inc  h
	or   e
	inc  h
	or   a
	inc  h
	cp   e
	inc  h
	cp   a
	inc  h
	jp   Unk_C724
	inc  h
	sla  h
	rst  $08
	inc  h
	-
	inc  h
	rst  $10
	inc  h
	-
	inc  h
	rst  $18
	inc  h
	-
	inc  h
	rst  $20
	inc  h
	-
	inc  h
	rst  $28
	inc  h
	di
	inc  h
	rst  $30
	inc  h
	ei
	inc  h
	rst  $38
	nop
	nop
	dec  h
	rst  $30
	nop
	dec  b
	dec  h
	rst  $38
	nop
	ld   a,[bc]
	dec  h
	rst  $30
	nop
	rrca
	dec  h
	rst  $38
	nop
	inc  d
	dec  h
	rst  $30
	nop
	add  hl,de
	dec  h
	rst  $38
	nop
	ld   e,$25
	rst  $30
	nop
	inc  hl
	dec  h
	rst  $38
	nop
	jr   z,.unk_24E6
	rst  $30
	nop
	dec  l
	dec  h
	rst  $38
	nop
	ldd  [hl],a
	dec  h
	rst  $30
	nop
	scf
	dec  h
	rst  $38
	nop
	inc  a
	dec  h
	rst  $30
	nop
	ld   b,c
	dec  h
	rst  $38
	nop
	ld   b,[hl]
	dec  h
	rst  $30
	nop
	ld   c,e
	dec  h
	rst  $38
	nop
	ld   d,b
	dec  h
	rst  $30
	nop
	ld   d,l
	dec  h
	rst  $38
	nop
	ld   e,d
	dec  h
	rst  $30
	nop
	ld   e,a
	dec  h
	rst  $38
	nop
	ld   h,h
	dec  h
	rst  $30
	nop
	ld   l,c
	dec  h
	rst  $38
	nop
	ld   l,[hl]
	dec  h
	rst  $30
	nop
	ld   [hl],e
	dec  h
	add  b
	sub  b
	rst  $38
	ld   [hl],a
	dec  h
	and  b
	or   b
	rst  $38
	ld   [hl],e
	dec  h
	add  b
	sub  b
	rst  $38
	ld   [hl],a
	dec  h
	and  b
	or   b
	rst  $38
	ld   [hl],e
	dec  h
	add  b
	sub  c
	rst  $38
	ld   [hl],a
	dec  h
	and  b
	or   c
	rst  $38
	ld   [hl],e
	dec  h
	add  c
	sub  b
	rst  $38
	ld   [hl],a
	dec  h
	and  c
	or   b
	rst  $38
	ld   [hl],e
	dec  h
	add  b
	sub  d
	rst  $38
	ld   [hl],a
	dec  h
	and  b
	or   d
	rst  $38
	ld   [hl],e
	dec  h
	add  d
	sub  b
	rst  $38
	ld   [hl],a
	dec  h
	and  d
	or   b
	rst  $38
	ld   [hl],e
	dec  h
	add  c
	sub  c
	rst  $38
	ld   [hl],a
	dec  h
	and  c
	or   c
	rst  $38
	ld   [hl],e
	dec  h
	add  c
	sub  c
	rst  $38
	ld   [hl],a
	dec  h
	and  c
	or   c
	rst  $38
	ld   [hl],e
	dec  h
	add  c
	sub  d
	rst  $38
	ld   [hl],a
	dec  h
	and  c
	or   d
	rst  $38
	ld   [hl],e
	dec  h
	add  d
	sub  c
	rst  $38
	ld   [hl],a
	dec  h
	and  d
	or   c
	rst  $38
	ld   [hl],e
	dec  h
	add  d
	sub  d
	rst  $38
	ld   [hl],a
	dec  h
	and  d
	or   d
	rst  $38
	ld   [hl],e
	dec  h
	add  d
	sub  d
	rst  $38
	ld   [hl],a
	dec  h
	and  d
	or   d
	rst  $38
	nop
	nop
	nop
	ld   [Reset],sp
	ld   [wUnk_F000],sp
	ldh  [hUnk_FFA7],a
	ret  z
	ld   a,[de]
	dec  e
	and  a,$0F
	jr   z,.unk_258C
	ldi  [hl],a
	ld   c,$03
	ld   a,$01
	jr   .unk_2590
	inc  l
	ld   c,$03
	xor  a
	ldh  [hUnk_FFE0],a
	ld   a,[de]
	ld   b,a
	swap a
	and  a,$0F
	jr   nz,.unk_25C2
	ldh  a,[hUnk_FFE0]
	and  a
	ld   a,$00
	jr   nz,.unk_25A3
	ld   a,$FE
	ldi  [hl],a
	ld   a,b
	and  a,$0F
	jr   nz,.unk_25CA
	ldh  a,[hUnk_FFE0]
	and  a
	ld   a,$00
	jr   nz,.unk_25B9
	ld   a,$01
	cp   c
	ld   a,$00
	jr   z,.unk_25B9
	ld   a,$FE
	ldi  [hl],a
	dec  e
	dec  c
	jr   nz,.unk_2592
	xor  a
	ldh  [hUnk_FFE0],a
	ret

	push af
	ld   a,$01
	ldh  [hUnk_FFE0],a
	pop  af
	jr   .unk_25A3
	push af
	ld   a,$01
	ldh  [hUnk_FFE0],a
	pop  af
	jr   .unk_25B9
	ld   hl,$98B2
	ld   de,$2729
	ld   b,$03
	ldh  a,[hUnk_FFAD]
	cp   a,$04
	jr   z,.unk_25EA
	ld   de,$272C
	cp   a,$03
	jr   z,.unk_25EA
	ld   de,$272F
	ld   a,[de]
	ld   [hl],a
	push de
	ld   de,$0020
	add  hl,de
	pop  de
	inc  de
	dec  b
	jr   nz,.unk_25EA
	call Unk_268C
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_2609
	call Unk_2696
	call Unk_26DA
	call Unk_270E
	jr   .unk_2615
	ld   hl,wUnk_D000
	call Unk_2732
	ld   hl,wUnk_D001
	call Unk_2757
	ld   hl,$C800
	ld   b,$80
	ld   a,$FF
	call Unk_2687
	xor  a
	ldh  [hUnk_FF9D],a
	ldh  [hUnk_FF9C],a
	ldh  [hUnk_FF9F],a
	ldh  [hUnk_FFC6],a
	ldh  [hUnk_FFC7],a
	ldh  [hUnk_FFC8],a
	ldh  [hUnk_FFC9],a
	ldh  [hUnk_FFCA],a
	ldh  [hUnk_FFCE],a
	ldh  [hUnk_FFD1],a
	ldh  [hUnk_FFD2],a
	ldh  [hUnk_FFD3],a
	ldh  [hUnk_FFD4],a
	ldh  [hUnk_FFD5],a
	ldh  [hUnk_FFD6],a
	ldh  [hUnk_FFD7],a
	ldh  [hUnk_FFD8],a
	ldh  [hUnk_FFD9],a
	ld   a,$80
	ldh  [hUnk_FFDA],a
	xor  a
	ldh  [hUnk_FFDB],a
	ldh  [hUnk_FFDC],a
	ldh  [hUnk_FFDD],a
	ldh  [hUnk_FFDE],a
	ldh  [hUnk_FFE5],a
	ldh  [hUnk_FFE6],a
	ldh  [hUnk_FFE7],a
	ldh  [hUnk_FFE8],a
	ldh  [hWaitFrames],a
	ldh  [hUnk_FFF0],a
	ldh  [hUnk_FFF3],a
	ldh  [hUnk_FFF4],a
	ldh  [hUnk_FFF5],a
	ldh  [hUnk_FFF6],a
	ldh  [hUnk_FFF7],a
	ldh  [hUnk_FFF8],a
	ldh  [hUnk_FFF9],a
	ldh  [hUnk_FFFA],a
	ldh  [hUnk_FFFB],a
	ldh  [hUnk_FFFC],a
	ld   hl,$D002
	xor  a
	ld   b,$63
	call Unk_2687
	ld   a,$03
	ldi  [hl],a
	xor  a
	ldi  [hl],a
	ldi  [hl],a
	ld   a,$98
	ldi  [hl],a
	ld   a,$7F
	ldi  [hl],a
	ret

	ldi  [hl],a
	dec  b
	jr   nz,.unk_2687
	ret

	ld   hl,$C020
	ld   de,$26A0
	call Unk_2794
	ret

	ld   hl,$C048
	ld   de,$26C9
	call Unk_2794
	ret

	dec  [hl]
	ld   [hl],h
	rst  $38
	<corrupted stop>
	ld   [hl],h
	inc  b
	<corrupted stop>
	ld   a,h
	ld   [bc],a
	<corrupted stop>
	ld   a,h
	dec  b
	<corrupted stop>
	ld   a,h
	nop
	<corrupted stop>
	ld   a,h
	rlca
	<corrupted stop>
	add  h
	ld   bc,$3510
	add  h
	inc  bc
	<corrupted stop>
	add  h
	ld   b,$10
	ld   b,l
	add  h
	ld   [wUnk_FD10],sp
	adc  l
	ld   l,e
	jr   nz,.unk_26DD
	adc  l
	ld   [hl],e
	ld   hl,$9510
	ld   l,e
	jr   nc,.unk_26E5
	sub  l
	ld   [hl],e
	ld   sp,$FD10
	ld   hl,$C058
	ld   de,$26EC
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_26E8
	ld   de,$26FD
	call Unk_2794
	ret

	adc  l
	ld   a,e
	ld   b,b
	<corrupted stop>
	add  e
	ld   b,c
	<corrupted stop>
	ld   a,e
	ld   d,b
	<corrupted stop>
	add  e
	ld   d,c
	<corrupted stop>
	ld   [hl],l
	jr   c,.unk_2740
	<corrupted stop>
	ld   b,b
	ld   b,c
	<corrupted stop>
	jr   c,.unk_2758
	<corrupted stop>
	ld   b,b
	ld   d,c
	<corrupted stop>
	ld   hl,$C068
	ld   de,$2718
	call Unk_2794
	ret

	adc  l
	adc  e
	ld   h,b
	<corrupted stop>
	sub  e
	ld   h,c
	<corrupted stop>
	adc  e
	ld   [hl],b
	<corrupted stop>
	sub  e
	ld   [hl],c
	<corrupted stop>
	dec  d
	jr   .unk_274C
	ld   d,$0E
	dec  c
	ld   de,$FE12
	ld   a,[hl]
	and  a
	ret  z
	ld   c,a
	ld   b,c
	ld   hl,$C07C
	ld   de,$0004
	add  hl,de
	dec  b
	jr   nz,.unk_273D
	push hl
	ld   hl,$2778
	ld   b,c
	add  hl,de
	dec  b
	jr   nz,.unk_2746
	pop  de
	ld   b,$04
	ldi  a,[hl]
	ld   [de],a
	inc  de
	dec  b
	jr   nz,.unk_274D
	dec  c
	jr   nz,.unk_2736
	ret

	ld   a,[hl]
	and  a
	ret  z
	ld   c,a
	ld   b,c
	ld   hl,$C088
	ld   de,$0004
	add  hl,de
	dec  b
	jr   nz,.unk_2762
	push hl
	ld   hl,$2784
	ld   b,c
	add  hl,de
	dec  b
	jr   nz,.unk_276B
	pop  de
	ld   b,$04
	ldi  a,[hl]
	ld   [de],a
	inc  de
	dec  b
	jr   nz,.unk_2772
	dec  c
	jr   nz,.unk_275B
	ret

	ld   h,b
	ld   l,b
	inc  l
	nop
	ld   h,b
	ld   [hl],b
	inc  l
	nop
	ld   h,b
	ld   a,b
	inc  l
	nop
	ld   h,b
	adc  b
	inc  l
	nop
	ld   h,b
	sub  b
	inc  l
	nop
	ld   h,b
	sbc  b
	inc  l
	nop
	ld   a,[de]
	cp   a,$FD
	ret  z
	ldi  [hl],a
	inc  de
	jr   .unk_2794
	ldh  a,[hUnk_FFC0]
	and  a
	jr   nz,.unk_27B3
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_27AC
	ld   a,[wHasGameStarted]
	and  a
	jr   nz,.unk_27B7
	ldh  a,[hUnk_FF98]
	cp   a,$02
	jp   z,Unk_282A
	call Unk_2C4F
	ret

	ld   hl,$FFD3
	ldh  a,[hUnk_FF98]
	cp   a,$02
	jr   nz,.unk_27D7
	ldh  a,[hUnk_FFCE]
	and  a
	jr   nz,.unk_27D7
	ldh  a,[hUnk_FFC4]
	cp   a,$05
	jr   c,.unk_27D7
	ldh  a,[hUnk_FFDE]
	and  a
	jr   z,.unk_27D7
	ld   a,$01
	ld   [wUnk_DF8B],a
	ldh  [hUnk_FFCE],a
	call Unk_0771
	inc  l
	ld   [hl],a
	ld   de,$0004
	ld   hl,$C052
	ldh  a,[hUnk_FFD2]
	call Unk_27EE
	ldh  a,[hUnk_FFD4]
	call Unk_27EE
	jr   .unk_27AC
	ld   b,a
	swap a
	and  a,$0F
	call Unk_27FD
	ld   a,b
	and  a,$0F
	call Unk_27FD
	ret

	cp   a,$08
	jr   nc,.unk_280B
	cp   a,$04
	jr   nc,.unk_2813
	ld   c,$4C
	call Unk_281B
	ret

	ld   c,$68
	sub  a,$08
	call Unk_281B
	ret

	ld   c,$6C
	sub  a,$04
	call Unk_281B
	ret

	and  a
	jr   z,.unk_2822
	inc  c
	dec  a
	jr   .unk_281B
	ld   [hl],c
	add  hl,de
	ld   a,c
	add  a,$10
	ld   [hl],a
	add  hl,de
	ret

	call Unk_282E
	ret

	ldh  a,[hUnk_FF9C]
	rst  $28
	ld   b,c
	jr   z,.unk_283D
	ldi  a,[hl]
	ld   b,e
	dec  hl
	reti
	dec  hl
	ld   a,a
	inc  l
	ei
	inc  l
	ld   b,$2D
	ldi  [hl],a
	ld   l,$F0
	or   c
	and  a
	jr   z,.unk_2879
	ld   de,wUnk_DF8A
	ld   hl,$C80B
	ldi  a,[hl]
	cp   a,$FF
	jr   nz,.unk_2872
	ld   a,[hl]
	cp   a,$FF
	jr   nz,.unk_2872
	ld   l,$13
	ldi  a,[hl]
	cp   a,$FF
	jr   nz,.unk_2872
	ld   a,[hl]
	cp   a,$FF
	jr   nz,.unk_2872
	ld   l,$1B
	ldi  a,[hl]
	cp   a,$FF
	jr   nz,.unk_2872
	ld   a,[hl]
	cp   a,$FF
	jr   nz,.unk_2872
	xor  a
	ld   [de],a
	jr   .unk_2879
	ld   a,[de]
	and  a
	jr   nz,.unk_2879
	ld   a,$01
	ld   [de],a
	ld   hl,$C808
	call Unk_29DC
	ld   l,$10
	call Unk_28CB
	ld   l,$18
	call Unk_29DC
	ld   l,$20
	call Unk_28CB
	ld   l,$28
	call Unk_29DC
	ld   l,$30
	call Unk_28CB
	ld   l,$38
	call Unk_29DC
	ld   l,$40
	call Unk_28CB
	ld   l,$48
	call Unk_29DC
	ld   l,$50
	call Unk_28CB
	ld   l,$58
	call Unk_29DC
	ld   l,$60
	call Unk_28CB
	ld   l,$68
	call Unk_29DC
	ld   l,$70
	call Unk_28CB
	ld   l,$78
	call Unk_29DC
	ld   a,$01
	ldh  [hUnk_FF9C],a
	ret

	inc  l
	ld   a,l
	and  a,$0F
	cp   a,$05
	ret  nc
	ld   a,[hl]
	cp   a,$FF
	jr   z,.unk_28CA
	and  a,$0F
	ld   b,a
	ld   c,$00
	inc  c
	inc  l
	ld   a,l
	and  a,$0F
	cp   a,$08
	jr   z,.unk_28EA
	ld   a,[hl]
	and  a,$0F
	cp   b
	jr   z,.unk_28DB
	ld   a,c
	cp   a,$04
	jr   c,.unk_28CB
	call Unk_28F9
	push hl
	call Unk_29C8
	pop  hl
	jr   .unk_28CB
	ld   a,$01
	ldh  [hUnk_FF9F],a
	ld   a,l
	sub  c
	ld   l,a
	call Unk_2907
	dec  c
	jr   nz,.unk_2900
	ret

	ld   a,[hl]
	cp   a,$E0
	jr   c,.unk_2916
	jr   z,.unk_291B
	cp   a,$E1
	jr   z,.unk_294C
	cp   a,$E2
	jr   z,.unk_2968
	ld   a,$0F
	and  [hl]
	ldi  [hl],a
	ret

	push hl
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_2935
	ld   hl,$FFD5
	dec  [hl]
	ldh  a,[hUnk_FFDB]
	bit  2,a
	jr   z,.unk_2931
	set  7,a
	ldh  [hUnk_FFDB],a
	jr   .unk_2935
	set  2,a
	ldh  [hUnk_FFDB],a
	ld   hl,$FFD1
	dec  [hl]
	inc  l
	ld   a,[hl]
	sub  a,$01
	daa
	ld   [hl],a
	ld   hl,$D00F
	inc  [hl]
	pop  hl
	ld   a,$F0
	or   [hl]
	ldi  [hl],a
	call Unk_2984
	ret

	push hl
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_2935
	ld   hl,$FFD6
	dec  [hl]
	ldh  a,[hUnk_FFDB]
	bit  1,a
	jr   z,.unk_2962
	set  6,a
	ldh  [hUnk_FFDB],a
	jr   .unk_2935
	set  1,a
	ldh  [hUnk_FFDB],a
	jr   .unk_2935
	push hl
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_2935
	ld   hl,$FFD7
	dec  [hl]
	ldh  a,[hUnk_FFDB]
	bit  0,a
	jr   z,.unk_297E
	set  5,a
	ldh  [hUnk_FFDB],a
	jr   .unk_2935
	set  0,a
	ldh  [hUnk_FFDB],a
	jr   .unk_2935
	push af
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_29B1
	push bc
	push de
	push hl
	ld   e,$00
	ldh  a,[hUnk_FFAD]
	cp   a,$02
	jr   z,.unk_29B3
	cp   a,$03
	jr   z,.unk_29B7
	ld   d,$01
	call Unk_29BB
	ld   hl,$C0A0
	call Unk_0181
	ld   hl,$FFE8
	inc  [hl]
	ld   a,[hl]
	cp   a,$06
	jr   c,.unk_29AE
	dec  [hl]
	pop  hl
	pop  de
	pop  bc
	pop  af
	ret

	ld   d,$03
	jr   .unk_299B
	ld   d,$02
	jr   .unk_299B
	ldh  a,[hUnk_FFE8]
	and  a
	ret  z
	ld   b,a
	ld   a,d
	add  d
	daa
	ld   d,a
	dec  b
	jr   nz,.unk_29C1
	ret

	and  a,$0F
	ld   b,a
	inc  b
	ld   hl,$FFD8
	ld   a,[hl]
	and  a,$C0
	ret  nz
	sla  [hl]
	sla  [hl]
	ld   a,[hl]
	or   b
	ld   [hl],a
	ret

	inc  l
	ld   a,l
	and  a,$0F
	ret  z
	cp   a,$0D
	ret  nc
	ld   a,[hl]
	cp   a,$FF
	jr   z,.unk_29DB
	and  a,$0F
	ld   b,a
	ld   c,$00
	inc  c
	inc  l
	ld   a,l
	and  a,$0F
	jr   z,.unk_29FA
	ld   a,[hl]
	and  a,$0F
	cp   b
	jr   z,.unk_29ED
	ld   a,c
	cp   a,$04
	jr   c,.unk_29DC
	call Unk_28F9
	push hl
	call Unk_29C8
	pop  hl
	jr   .unk_29DC
	ld   de,PerformDelay
	ld   hl,$C808
	call Unk_2A85
	ld   l,$09
	call Unk_2A85
	ld   l,$0A
	call Unk_2A85
	ld   l,$0B
	call Unk_2A85
	ld   l,$0C
	call Unk_2A85
	ld   l,$0D
	call Unk_2A85
	ld   l,$0E
	call Unk_2A85
	ld   l,$0F
	call Unk_2A85
	ld   hl,$FF9F
	ld   a,[hl]
	and  a
	jr   nz,.unk_2A66
	xor  a
	ldh  [hUnk_FFE8],a
	ldh  a,[hUnk_FFD8]
	and  a,$FC
	jr   z,.unk_2A51
	ld   b,a
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_2A6D
	ld   a,$01
	ldh  [hUnk_FFDD],a
	jr   .unk_2A54
	xor  a
	ldh  [hUnk_FFD8],a
	ld   a,$06
	ldh  [hUnk_FF9C],a
	ld   hl,$FFF3
	inc  [hl]
	ld   a,[hl]
	cp   a,$0A
	ret  nz
	xor  a
	ld   [hl],a
	call Unk_0DB0
	ret

	xor  a
	ld   [hl],a
	ld   a,$02
	ldh  [hUnk_FF9C],a
	ret

	ld   c,$08
	ld   a,b
	and  a,$F0
	jr   nz,.unk_2A7A
	ld   a,c
	ld   [wUnk_DFE0],a
	jr   .unk_2A51
	ld   c,$0B
	and  a,$C0
	jr   z,.unk_2A74
	ld   c,$0D
	jr   .unk_2A74
	add  hl,de
	ld   a,l
	cp   a,$68
	ret  nc
	ld   a,[hl]
	cp   a,$FF
	jr   z,.unk_2A84
	and  a,$0F
	ld   b,a
	ld   c,$00
	inc  c
	add  hl,de
	ld   a,l
	cp   a,$80
	jr   nc,.unk_2AA0
	ld   a,[hl]
	and  a,$0F
	cp   b
	jr   z,.unk_2A93
	ld   a,c
	cp   a,$04
	jr   c,.unk_2A85
	call Unk_2AAF
	push hl
	call Unk_29C8
	pop  hl
	jr   .unk_2A85
	ld   a,$01
	ldh  [hUnk_FF9F],a
	ld   b,e
	ld   a,l
	sub  c
	dec  b
	jr   nz,.unk_2AB5
	ld   l,a
	call Unk_2AC1
	dec  c
	jr   nz,.unk_2ABA
	ret

	ld   a,[hl]
	cp   a,$E0
	jr   c,.unk_2AD0
	jr   z,.unk_2AD6
	cp   a,$E1
	jr   z,.unk_2B0B
	cp   a,$E2
	jr   z,.unk_2B27
	ld   a,$0F
	and  [hl]
	ld   [hl],a
	add  hl,de
	ret

	push hl
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_2AF0
	ld   hl,$FFD5
	dec  [hl]
	ldh  a,[hUnk_FFDB]
	bit  2,a
	jr   z,.unk_2AEC
	set  7,a
	ldh  [hUnk_FFDB],a
	jr   .unk_2AF0
	set  2,a
	ldh  [hUnk_FFDB],a
	ld   hl,$FFD1
	dec  [hl]
	inc  l
	ld   a,[hl]
	sub  a,$01
	daa
	ld   [hl],a
	pop  hl
	ld   a,$F0
	or   [hl]
	ld   [hl],a
	push af
	add  hl,de
	call Unk_2984
	ld   a,$01
	ld   [wUnk_D041],a
	pop  af
	ret

	push hl
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_2AF0
	ld   hl,$FFD6
	dec  [hl]
	ldh  a,[hUnk_FFDB]
	bit  1,a
	jr   z,.unk_2B21
	set  6,a
	ldh  [hUnk_FFDB],a
	jr   .unk_2AF0
	set  1,a
	ldh  [hUnk_FFDB],a
	jr   .unk_2AF0
	push hl
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_2AF0
	ld   hl,$FFD7
	dec  [hl]
	ldh  a,[hUnk_FFDB]
	bit  0,a
	jr   z,.unk_2B3D
	set  5,a
	ldh  [hUnk_FFDB],a
	jr   .unk_2AF0
	set  0,a
	ldh  [hUnk_FFDB],a
	jr   .unk_2AF0
	ld   hl,$C800
	ld   b,$80
	ld   c,b
	push hl
	call Unk_2B6A
	pop  hl
	call Unk_2B7A
	ld   b,$05
	ld   hl,$D041
	ld   a,[hl]
	and  a
	jr   z,.unk_2B5D
	xor  a
	ld   [hl],a
	inc  b
	ld   a,b
	ld   [wUnk_DFE0],a
	ld   a,$10
	ldh  [hWaitFrames],a
	ld   a,$03
	ldh  [hUnk_FF9C],a
	ret

	ldi  a,[hl]
	and  a,$F0
	call z,Unk_2B74
	dec  c
	jr   nz,.unk_2B6A
	ret

	dec  l
	ld   a,[hl]
	add  a,$D0
	ldi  [hl],a
	ret

	ldi  a,[hl]
	and  a,$F0
	cp   a,$80
	jr   z,.unk_2B91
	cp   a,$90
	jr   z,.unk_2B9F
	cp   a,$A0
	jr   z,.unk_2BB1
	cp   a,$B0
	jr   z,.unk_2BC5
	dec  b
	jr   nz,.unk_2B7A
	ret

	ld   a,[hl]
	and  a,$F0
	cp   a,$90
	jr   z,.unk_2B8D
	dec  l
	ld   a,[hl]
	add  a,$40
	ldi  [hl],a
	jr   .unk_2B8D
	push hl
	dec  l
	dec  l
	ld   a,[hl]
	pop  hl
	and  a,$F0
	cp   a,$80
	jr   z,.unk_2B8D
	dec  l
	ld   a,[hl]
	add  a,$30
	ldi  [hl],a
	jr   .unk_2B8D
	push hl
	ld   a,l
	add  a,$07
	ld   l,a
	ld   a,[hl]
	pop  hl
	and  a,$F0
	cp   a,$B0
	jr   z,.unk_2B8D
	dec  l
	ld   a,[hl]
	add  a,$20
	ldi  [hl],a
	jr   .unk_2B8D
	push hl
	ld   a,l
	sub  a,$09
	ld   l,a
	ld   a,[hl]
	pop  hl
	and  a,$F0
	cp   a,$A0
	jr   z,.unk_2B8D
	dec  l
	ld   a,[hl]
	add  a,$10
	ldi  [hl],a
	jr   .unk_2B8D
	call Unk_2C4F
	ld   a,[hl]
	and  a
	ret  nz
	ldh  a,[hUnk_FFD1]
	and  a
	jr   nz,.unk_2BFA
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_2C31
	ld   a,$F8
	ldh  [hSerialNext],a
	ldh  [hUnk_FFF4],a
	xor  a
	ld   [wUnk_D00E],a
	ldh  [hUnk_FF9C],a
	ld   a,$17
	ldh  [hGameStatus],a
	ret

	ldh  a,[hUnk_FFC4]
	cp   a,$05
	jr   c,.unk_2C1E
	ldh  a,[hUnk_FFD3]
	ld   b,$03
	ld   hl,$FFCA
	cp   [hl]
	jr   z,.unk_2C1B
	jr   c,.unk_2C1B
	dec  b
	dec  hl
	cp   [hl]
	jr   z,.unk_2C1B
	jr   c,.unk_2C1B
	dec  b
	dec  hl
	cp   [hl]
	jr   z,.unk_2C1B
	jr   c,.unk_2C1B
	dec  b
	ld   a,b
	ldh  [hUnk_FFDE],a
	ld   hl,$C800
	ld   b,$80
	ld   c,$FF
	call Unk_2C38
	ld   a,$05
	ldh  [hUnk_FF9C],a
	ld   a,$10
	ldh  [hWaitFrames],a
	ret

	xor  a
	ldh  [hUnk_FF9C],a
	inc  a
	ldh  [hGameMode],a
	ret

	ldi  a,[hl]
	and  a,$F0
	cp   a,$D0
	call z,Unk_2C49
	cp   a,$F0
	call z,Unk_2C49
	dec  b
	jr   nz,.unk_2C38
	ret

	dec  l
	ld   a,$FF
	ld   [hl],c
	inc  l
	ret

	ld   hl,hWaitFrames
	ld   a,[hl]
	and  a
	ret  z
	xor  a
	ldh  [hUnk_FF9D],a
	ld   a,[hl]
	dec  a
	ld   c,a
	ld   hl,$9822
	ld   de,$0020
	add  hl,de
	dec  a
	jr   nz,.unk_2C61
	ld   a,h
	ld   [wUnk_D023],a
	ld   a,l
	ld   [wUnk_D024],a
	xor  a
	ld   b,$08
	add  b
	dec  c
	jr   nz,.unk_2C70
	ld   [wUnk_D026],a
	ld   a,$02
	ldh  [hUnk_FF9D],a
	ld   hl,hWaitFrames
	ret

	ld   b,$78
	ld   c,$FF
	ldh  a,[hUnk_FFF7]
	and  a
	jr   nz,.unk_2CA5
	ld   hl,$C87F
	ld   a,[hl]
	cp   c
	call z,Unk_2CB4
	dec  l
	dec  b
	jr   nz,.unk_2C8B
	ld   hl,$FFF5
	ld   a,[hl]
	and  a
	jr   z,.unk_2CB0
	xor  a
	ld   [hl],a
	ld   a,$01
	ldh  [hUnk_FFF7],a
	ld   a,$10
	ldh  [hWaitFrames],a
	call Unk_2C4F
	ldh  a,[hWaitFrames]
	and  a
	ret  nz
	xor  a
	ldh  [hUnk_FFF7],a
	ret

	xor  a
	ldh  [hUnk_FF9C],a
	ret

	push hl
	ld   a,l
	sub  a,$08
	ld   l,a
	ld   a,[hl]
	cp   a,$FF
	jr   z,.unk_2CDA
	cp   a,$83
	jr   c,.unk_2CDA
	and  a,$F0
	cp   a,$E0
	jr   z,.unk_2CDA
	cp   a,$90
	jr   z,.unk_2CE1
	ld   a,$04
	ld   [wUnk_DFE0],a
	ld   a,[hl]
	ld   [hl],c
	pop  hl
	ld   [hl],a
	ld   a,$01
	ldh  [hUnk_FFF5],a
	ret

	pop  hl
	ret

	pop  hl
	ld   a,$FF
	ld   [hl],a
	ret

	pop  hl
	dec  l
	ld   a,[hl]
	cp   a,$FF
	ret  nz
	push hl
	ld   a,l
	sub  a,$08
	ld   l,a
	ld   d,[hl]
	ld   [hl],c
	inc  l
	ld   e,[hl]
	ld   [hl],c
	pop  hl
	ld   [hl],d
	inc  l
	ld   [hl],e
	dec  l
	ld   a,$01
	ldh  [hUnk_FFF5],a
	ret

	call Unk_2C4F
	ld   a,[hl]
	and  a
	ret  nz
	ld   a,$04
	ldh  [hUnk_FF9C],a
	ret

	ld   hl,$FFD9
	ld   d,$C8
	ld   a,[hl]
	and  a,$FC
	jr   z,.unk_2D3C
	and  a,$F0
	jr   z,.unk_2D48
	and  a,$C0
	jr   z,.unk_2D73
	ld   bc,$2E06
	ldh  a,[rDIV]
	and  a,$01
	jr   z,.unk_2D24
	ld   bc,$2E0A
	call Unk_2DB0
	call Unk_2DB0
	call Unk_2DB0
	call Unk_2DB0
	xor  a
	ldh  [hUnk_FFD9],a
	ld   a,$07
	ldh  [hUnk_FF9C],a
	ld   a,$03
	ldh  [hWaitFrames],a
	ret

	xor  a
	ldh  [hUnk_FFD9],a
	ldh  [hUnk_FF98],a
	ldh  [hUnk_FF9C],a
	ld   a,$0A
	ldh  [hGameStatus],a
	ret

	ldh  a,[rDIV]
	and  a,$03
	jr   z,.unk_2D5B
	cp   a,$01
	jr   z,.unk_2D60
	cp   a,$02
	jr   z,.unk_2D65
	ld   bc,$2E20
	jr   .unk_2D68
	ld   bc,$2E1A
	jr   .unk_2D68
	ld   bc,$2E1C
	jr   .unk_2D68
	ld   bc,$2E1E
	call Unk_2DA1
	call Unk_2DB0
	call Unk_2DB0
	jr   .unk_2D30
	ldh  a,[rDIV]
	and  a,$03
	jr   z,.unk_2D86
	cp   a,$01
	jr   z,.unk_2D8B
	cp   a,$02
	jr   z,.unk_2D90
	ld   bc,$2E17
	jr   .unk_2D93
	ld   bc,$2E0E
	jr   .unk_2D93
	ld   bc,$2E11
	jr   .unk_2D93
	ld   bc,$2E14
	call Unk_2DA1
	call Unk_2DB0
	call Unk_2DB0
	call Unk_2DB0
	jr   .unk_2D30
	ld   a,[hl]
	ld   e,a
	ld   a,e
	and  a,$C0
	jr   nz,.unk_2DAE
	sla  e
	sla  e
	jr   .unk_2DA3
	ld   [hl],e
	ret

	ld   a,[bc]
	ld   e,a
	rlc  [hl]
	rlc  [hl]
	ld   a,[hl]
	and  a,$03
	dec  a
	add  a,$C0
	ld   [de],a
	push af
	push bc
	push de
	push hl
	call Unk_2DD0
	call Unk_2DE2
	call Unk_2DF5
	pop  hl
	pop  de
	pop  bc
	pop  af
	inc  bc
	ret

	inc  e
	ld   a,e
	cp   a,$10
	ret  z
	ld   a,[de]
	and  a,$F0
	cp   a,$90
	ret  nz
	ld   a,[de]
	and  a,$0F
	add  a,$C0
	ld   [de],a
	ret

	dec  e
	dec  e
	ld   a,e
	cp   a,$07
	ret  z
	ld   a,[de]
	and  a,$F0
	cp   a,$80
	ret  nz
	ld   a,[de]
	and  a,$0F
	add  a,$C0
	ld   [de],a
	ret

	ld   a,$09
	add  e
	ld   e,a
	ld   a,[de]
	and  a,$F0
	cp   a,$B0
	ret  nz
	ld   a,[de]
	and  a,$0F
	add  a,$C0
	ld   [de],a
	ret

	ld   [wUnk_0C0A],sp
	ld   c,$09
	dec  bc
	dec  c
	rrca
	ld   [wUnk_0C0A],sp
	add  hl,bc
	dec  bc
	dec  c
	ld   a,[bc]
	inc  c
	ld   c,$0B
	dec  c
	rrca
	ld   [wUnk_090C],sp
	dec  c
	ld   a,[bc]
	ld   c,$0B
	rrca
	call Unk_2C4F
	ld   a,[hl]
	and  a
	ret  nz
	ld   a,$04
	ldh  [hUnk_FF9C],a
	ret

	ld   hl,$FF9D
	ld   a,[hl]
	and  a
	call nz,Unk_2F2D
	xor  a
	ldh  [hUnk_FF9D],a
	ldh  a,[hUnk_FFF9]
	and  a
	jr   nz,.unk_2E70
	ld   a,[wUnk_D00D]
	and  a
	jp   z,Unk_2ED2
	ldh  a,[hUnk_FFE2]
	and  a,$07
	cp   a,$03
	jp   nc,Unk_2ED2
	ld   de,$FFF8
	ld   a,[de]
	add  a,$10
	cp   a,$60
	jr   nz,.unk_2E58
	xor  a
	ld   [de],a
	ld   c,a
	ld   b,$00
	ld   hl,$4B9E
	add  hl,bc
	ld   d,$8E
	cp   a,$30
	jr   c,.unk_2E6A
	add  a,$10
	and  a,$3F
	ld   e,a
	call Unk_2F24
	jr   .unk_2ED2
	ldh  a,[hUnk_FFE2]
	and  a,$07
	jr   nz,.unk_2ED2
	ld   hl,$D056
	ld   a,[hl]
	and  a
	jr   z,.unk_2E8C
	cp   a,$01
	jr   z,.unk_2EAD
	cp   a,$02
	jr   z,.unk_2EB3
	xor  a
	ld   [hl],a
	call Unk_2F11
	jr   .unk_2ED2
	inc  [hl]
	ld   hl,$566E
	ld   de,$88D0
	call Unk_2F24
	ld   hl,$567E
	ld   de,$88E0
	call Unk_2F24
	ld   hl,$568E
	ld   de,$88F0
	call Unk_2F24
	call Unk_2EFE
	jr   .unk_2ED2
	inc  [hl]
	call Unk_2F11
	jr   .unk_2ED2
	inc  [hl]
	ld   hl,$5A5E
	ld   de,$88D0
	call Unk_2F24
	ld   hl,$5A6E
	ld   de,$88E0
	call Unk_2F24
	ld   hl,$5A7E
	ld   de,$88F0
	call Unk_2F24
	call Unk_2EFE
	ld   a,[wHasGameStarted]
	and  a
	jr   z,.unk_2EEF
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   nz,.unk_2EEF
	ld   hl,$FFD2
	ld   a,[hl]
	ld   b,a
	and  a,$F0
	swap a
	ld   hl,$99B1
	ldi  [hl],a
	ld   a,b
	and  a,$0F
	ld   [hl],a
	ret

	ld   a,[wUnk_D04B]
	and  a
	ret  z
	call Unk_2F83
	call Unk_2F90
	call Unk_2FA1
	ret

	ld   hl,$559E
	ld   de,$8800
	call Unk_2F24
	ld   hl,$55AE
	ld   de,$8810
	call Unk_2F24
	ret

	ld   hl,$55AE
	ld   de,$8800
	call Unk_2F24
	ld   hl,$559E
	ld   de,$8810
	call Unk_2F24
	ret

	ld   b,$10
	ldi  a,[hl]
	ld   [de],a
	inc  de
	dec  b
	jr   nz,.unk_2F26
	ret

	ld   a,[hl]
	rst  $28
	scf
	cpl
	jr   c,.unk_2F62
	ld   c,[hl]
	cpl
	ld   l,h
	cpl
	ret

	ld   a,[wUnk_D00C]
	and  a
	ret  z
	ld   hl,$D036
	ldi  a,[hl]
	ld   d,a
	ld   a,[hl]
	ld   e,a
	ld   a,[wUnk_D035]
	ld   [de],a
	ld   [de],a
	xor  a
	ld   [wUnk_D00C],a
	ret

	ld   hl,$D023
	ldi  a,[hl]
	ld   b,a
	ldi  a,[hl]
	ld   c,a
	ld   d,$C8
	inc  hl
	ld   e,[hl]
	push bc
	pop  hl
	ld   b,$08
	ld   a,[de]
	ldi  [hl],a
	inc  e
	dec  b
	jr   nz,.unk_2F5D
	ld   hl,hWaitFrames
	dec  [hl]
	ld   a,[hl]
	dec  a
	ret  nz
	ld   [hl],a
	ret

	ld   hl,$D068
	ldi  a,[hl]
	ld   d,a
	ld   e,[hl]
	ld   a,[wUnk_D009]
	ld   l,a
	ld   h,$C5
	ld   a,[hl]
	ld   [de],a
	cp   a,$FF
	ret  z
	ld   a,$01
	ld   [wUnk_DFE0],a
	ret

	ld   hl,$9CA1
	ldh  a,[hUnk_FFC3]
	ld   b,a
	ldh  a,[hUnk_FFC5]
	ld   c,a
	call Unk_2FAE
	ret

	ld   hl,$9CE1
	ldh  a,[hUnk_FFAD]
	call Unk_0D4A
	ld   hl,$9CE5
	ldh  a,[hUnk_FFAE]
	call Unk_0D4A
	ret

	ld   hl,$9D21
	ldh  a,[hUnk_FFD2]
	ld   b,a
	ldh  a,[hUnk_FFD4]
	ld   c,a
	call Unk_2FAE
	ret

	ld   a,b
	swap a
	and  a,$0F
	ldi  [hl],a
	ld   a,b
	and  a,$0F
	ldi  [hl],a
	inc  l
	inc  l
	inc  l
	ld   a,c
	swap a
	and  a,$0F
	ldi  [hl],a
	ld   a,c
	and  a,$0F
	ld   [hl],a
	ret

	ld   a,$01
	ld   [wUnk_D021],a
	ld   [wUnk_D00D],a
	ldh  a,[hIsDemoActive]
	and  a
	jr   nz,.unk_301E
	ldh  a,[hSerialRole]
	cp   a,$60
	jr   nz,.unk_2FE1
	ldh  a,[hUnk_FFC2]
	ld   b,a
	ldh  a,[hUnk_FFC4]
	cp   b
	jr   z,.unk_304B
	ldh  a,[hUnk_FFC6]
	ld   hl,$FFD1
	cp   [hl]
	jr   nz,.unk_3058
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_2FF6
	ldh  a,[hUnk_FFC2]
	ld   b,a
	ldh  a,[hUnk_FFC4]
	cp   b
	jr   z,.unk_3046
	call Unk_3002
	ld   a,$0A
	ldh  [hGameStatus],a
	xor  a
	ld   [wHasGameStarted],a
	ret

	ldh  a,[hIsDemoActive]
	and  a
	jr   nz,.unk_3013
	ld   b,$01
	ldh  a,[hUnk_FFC1]
	and  a
	jr   z,.unk_3019
	inc  b
	cp   a,$01
	jr   z,.unk_3019
	ld   a,$07
	ld   [wUnk_DFE8],a
	ret

	ld   a,b
	ld   [wUnk_DFE8],a
	ret

	ld   de,$5E00
	ld   hl,$C4EB
	ld   a,d
	ldi  [hl],a
	ld   [hl],e
	ld   a,$01
	ldh  [hUnk_FFB0],a
	call Unk_30FA
	ldh  a,[hUnk_FFC6]
	ld   hl,$FFD1
	ld   [hl],a
	call Unk_0771
	ldh  [hUnk_FFD2],a
	ld   a,$0F
	ldh  [hUnk_FFD5],a
	inc  a
	ldh  [hUnk_FFD6],a
	ld   a,$0D
	ldh  [hUnk_FFD7],a
	jr   .unk_2FF6
	ld   a,$19
	ldh  [hGameStatus],a
	ret

	ldh  a,[hUnk_FFC6]
	ld   hl,$FFD1
	ld   [hl],a
	call Unk_0771
	ldh  [hUnk_FFD2],a
	jr   .unk_3046
	ld   a,[wUnk_D03A]
	and  a
	jr   nz,.unk_3071
	ldh  a,[hSerialRole]
	cp   a,$30
	jr   nz,.unk_3071
	ldh  a,[hUnk_FFC2]
	ld   b,a
	ldh  a,[hUnk_FFC4]
	cp   b
	jr   nz,.unk_3071
	ld   a,$01
	ld   [wUnk_D03A],a
	ld   a,[wUnk_D00C]
	and  a
	ret  nz
	ld   hl,$311B
	ldh  a,[hUnk_FFC2]
	ld   e,a
	ld   d,$00
	add  hl,de
	ld   b,[hl]
	ld   hl,$3134
	add  hl,de
	ld   c,[hl]
	ldh  a,[rDIV]
	ld   d,a
	swap a
	and  b
	ld   e,a
	ld   a,d
	and  c
	add  e
	ld   e,a
	ld   a,$7F
	sub  e
	ld   e,a
	ld   d,$00
	ld   hl,$C800
	add  hl,de
	call Unk_314D
	ld   hl,$FFDA
	ld   a,[hl]
	and  a,$F0
	ld   [hl],a
	ld   hl,$D010
	ld   a,[hl]
	and  a
	jr   nz,.unk_30C2
	inc  de
	ld   a,e
	cp   a,$80
	jr   nc,.unk_30BD
	ld   hl,$D004
	inc  [hl]
	cp   a,$10
	jr   z,.unk_30BD
	push de
	pop  hl
	jr   .unk_309A
	xor  a
	ld   [wUnk_D004],a
	ret

	xor  a
	ld   [hl],a
	ld   [wUnk_D004],a
	ld   a,[de]
	ld   [wUnk_D035],a
	ldh  a,[hTwoPlayerMode]
	and  a
	jr   z,.unk_30D9
	ldh  a,[hUnk_FFC2]
	ld   b,a
	ldh  a,[hUnk_FFC4]
	cp   b
	jp   z,Unk_2FE1
	call Unk_3809
	ld   a,$01
	ldh  [hUnk_FF9D],a
	ld   [wUnk_D00C],a
	ret

	ld   de,$310A
	ld   h,$C8
	ld   a,[de]
	cp   a,$FC
	jr   z,.unk_30F5
	ld   l,a
	inc  de
	ld   a,[de]
	ld   [hl],a
	inc  de
	jr   .unk_30E9
	ld   a,$10
	ldh  [hWaitFrames],a
	ret

	ld   de,$5F80
	ld   hl,$C800
	ld   b,$80
	ld   a,[de]
	ldi  [hl],a
	inc  de
	dec  b
	jr   nz,.unk_3102
	jr   .unk_30F5
	ld   b,[hl]
	pop  hl
	ld   c,c
	ldh  [hUnk_FF4E],a
	pop  hl
	ld   d,h
	ld   [c],a
	ld   e,l
	ld   [c],a
	ld   h,h
	ldh  [hUnk_FF79],a
	ldh  [hUnk_FF7B],a
	pop  hl
	-
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	rrca
	rrca
	rrca
	rrca
	rrca
	rrca
	rrca
	rrca
	rrca
	rrca
	rrca
	rrca
	rrca
	rrca
	rrca
	rla
	rla
	rra
	rra
	daa
	daa
	daa
	cpl
	cpl
	cpl
	push hl
	push hl
	pop  de
	pop  bc
	ld   a,[bc]
	cp   a,$FF
	ret  nz
	push bc
	call Unk_31D5
	pop  bc
	push bc
	call Unk_31E1
	pop  bc
	push bc
	call Unk_31ED
	pop  bc
	call Unk_31F5
	ldh  a,[hUnk_FFDA]
	and  a,$07
	cp   a,$07
	ret  z
	ld   hl,$D002
	ld   a,d
	ldi  [hl],a
	ld   [hl],e
	ld   hl,$D010
	inc  [hl]
	ld   hl,$D007
	ldh  a,[hUnk_FFDA]
	bit  6,a
	jr   nz,.unk_31AF
	bit  5,a
	jr   nz,.unk_31C2
	call Unk_321A
	ld   a,[hl]
	and  a
	jr   nz,.unk_3196
	call Unk_3238
	ld   a,[hl]
	and  a
	jr   nz,.unk_3196
	call Unk_3248
	xor  a
	ld   [hl],a
	ld   hl,$FFDA
	bit  5,[hl]
	jr   nz,.unk_31A7
	bit  6,[hl]
	jr   nz,.unk_31AB
	ld   a,$40
	ld   [hl],a
	ret

	ld   a,$80
	ld   [hl],a
	ret

	ld   a,$20
	ld   [hl],a
	ret

	call Unk_3238
	ld   a,[hl]
	and  a
	jr   nz,.unk_3196
	call Unk_3248
	ld   a,[hl]
	and  a
	jr   nz,.unk_3196
	call Unk_321A
	jr   .unk_3196
	call Unk_3248
	ld   a,[hl]
	and  a
	jr   nz,.unk_3196
	call Unk_321A
	ld   a,[hl]
	and  a
	jr   nz,.unk_3196
	call Unk_3238
	jr   .unk_3196
	ld   a,c
	and  a,$07
	cp   a,$06
	ret  nc
	inc  c
	inc  c
	call Unk_3200
	ret

	ld   a,c
	and  a,$07
	cp   a,$02
	ret  c
	dec  c
	dec  c
	call Unk_3200
	ret

	ld   a,c
	sub  a,$10
	ld   c,a
	call Unk_3200
	ret

	ld   a,c
	cp   a,$70
	ret  nc
	add  a,$10
	ld   c,a
	call Unk_3200
	ret

	ld   hl,$FFDA
	ld   a,[bc]
	cp   a,$E0
	jr   z,.unk_3211
	cp   a,$E1
	jr   z,.unk_3214
	cp   a,$E2
	jr   z,.unk_3217
	ret

	set  2,[hl]
	ret

	set  1,[hl]
	ret

	set  0,[hl]
	ret

	ldh  a,[hUnk_FFDA]
	bit  2,a
	ret  nz
	inc  [hl]
	ld   a,$E0
	ld   [de],a
	push hl
	ld   hl,$FFD5
	inc  [hl]
	ld   hl,$FFD1
	inc  [hl]
	inc  l
	ld   a,[hl]
	add  a,$01
	daa
	ld   [hl],a
	ld   hl,$D00F
	inc  [hl]
	pop  hl
	ret

	ldh  a,[hUnk_FFDA]
	bit  1,a
	ret  nz
	inc  [hl]
	ld   a,$E1
	ld   [de],a
	push hl
	ld   hl,$FFD6
	inc  [hl]
	jr   .unk_3228
	ldh  a,[hUnk_FFDA]
	bit  0,a
	ret  nz
	inc  [hl]
	ld   a,$E2
	ld   [de],a
	push hl
	ld   hl,$FFD7
	inc  [hl]
	jr   .unk_3228
	rst  $08
	rst  $08
	xor  a
	ldh  [rIF],a
	ld   a,$08
	ldh  [rIE],a
	xor  a
	ld   [wUnk_D03A],a
	ldh  [rSB],a
	ldh  [hSerialNext],a
	ldh  [hUnk_FFD0],a
	ldh  [hUnk_FFD5],a
	ldh  [hUnk_FFD6],a
	ldh  [hUnk_FFD7],a
	ldh  a,[hSerialRole]
	cp   a,$60
	jp   z,Unk_32F1
	rst  $08
	rst  $08
	ld   a,$E0
	ldh  [rSB],a
	ld   a,$81
	ldh  [rSC],a
	xor  a
	ldh  [hUnk_FFD0],a
	ldh  [hSerialTransferDone],a
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.unk_3287
	ldh  a,[hUnk_FFD0]
	cp   a,$D0
	jr   nz,.unk_3278
	rst  $08
	rst  $08
	ld   a,$C0
	ldh  [rSB],a
	ld   a,$81
	ldh  [rSC],a
	xor  a
	ldh  [hUnk_FFD0],a
	ldh  [hSerialTransferDone],a
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.unk_32A1
	ldh  a,[hUnk_FFD0]
	cp   a,$D0
	jr   nz,.unk_3292
	ld   hl,$C800
	ld   b,$80
	rst  $08
	ldi  a,[hl]
	ldh  [rSB],a
	call Unk_334C
	ld   a,$81
	ldh  [rSC],a
	xor  a
	ldh  [hUnk_FFD0],a
	ldh  [hSerialTransferDone],a
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.unk_32C1
	dec  b
	jr   nz,.unk_32B1
	rst  $08
	rst  $08
	ld   a,$C1
	ldh  [rSB],a
	ld   a,$81
	ldh  [rSC],a
	xor  a
	ldh  [hUnk_FFD0],a
	ldh  [hSerialTransferDone],a
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.unk_32D8
	ldh  a,[hUnk_FFD0]
	cp   a,$D1
	jr   nz,.unk_32C9
	ld   a,$10
	ldh  [hWaitFrames],a
	xor  a
	ldh  [rIF],a
	ld   a,$0D
	ldh  [rIE],a
	jp   Unk_2FF6
	rst  $08
	ld   a,$D0
	ldh  [rSB],a
	ldh  [hSerialNext],a
	ld   a,$80
	ldh  [rSC],a
	xor  a
	ldh  [hUnk_FFD0],a
	ldh  [hSerialTransferDone],a
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.unk_3301
	ldh  a,[hUnk_FFD0]
	cp   a,$C0
	jr   nz,.unk_32F1
	ld   b,$80
	ld   hl,$C800
	ldh  [rSB],a
	ldh  [hUnk_FFD0],a
	ld   a,$80
	ldh  [rSC],a
	xor  a
	ldh  [hUnk_FFD0],a
	ldh  [hSerialTransferDone],a
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.unk_331E
	ldh  a,[hUnk_FFD0]
	cp   a,$C0
	jr   z,.unk_3311
	ldi  [hl],a
	call Unk_334C
	dec  b
	jr   nz,.unk_3315
	ld   a,$D1
	ldh  [rSB],a
	ldh  [hSerialNext],a
	ld   a,$80
	ldh  [rSC],a
	xor  a
	ldh  [hUnk_FFD0],a
	ldh  [hSerialTransferDone],a
	ldh  a,[hSerialTransferDone]
	and  a
	jr   z,.unk_333F
	ldh  a,[hUnk_FFD0]
	cp   a,$C1
	jr   nz,.unk_3330
	jr   .unk_32E3
	push hl
	cp   a,$E1
	jr   z,.unk_3362
	cp   a,$E2
	jr   z,.unk_3369
	cp   a,$E0
	jr   z,.unk_335B
	pop  hl
	ret

	ld   hl,$FFD5
	inc  [hl]
	jp   Unk_336D
	ld   hl,$FFD6
	inc  [hl]
	jp   Unk_336D
	ld   hl,$FFD7
	inc  [hl]
	pop  hl
	ret

	ld   a,[wHasGameStarted]
	and  a
	jr   z,.unk_337C
	call Unk_1E98
	ldh  a,[hUnk_FFAB]
	and  a
	ret  nz
	call Unk_0F1C
	call Unk_279C
	ldh  a,[hWaitFrames]
	and  a
	ret  nz
	call Unk_3495
	call Unk_0EE4
	ld   a,[wUnk_D021]
	and  a
	jr   z,.unk_33A3
	ld   hl,$D022
	inc  [hl]
	ld   a,[hl]
	cp   a,$50
	ret  nz
	xor  a
	ld   [hl],a
	ld   [wUnk_D021],a
	inc  a
	ld   [wHasGameStarted],a
	ld   hl,hUnk_FFAD
	ld   a,[hl]
	ld   b,a
	cp   a,$02
	jr   z,.unk_33AD
	dec  b
	ld   de,$D014
	ld   a,[de]
	inc  a
	ld   [de],a
	cp   b
	ret  nz
	xor  a
	ld   [de],a
	ld   bc,$D012
	ld   de,$0004
	ld   hl,$C022
	ld   a,[bc]
	inc  a
	ld   [bc],a
	cp   a,$01
	jr   z,.unk_33D6
	cp   a,$02
	jr   z,.unk_33E7
	cp   a,$0D
	jr   z,.unk_33FB
	call Unk_341A
	call Unk_2017
	ret

	ld   a,$09
	ld   [hl],a
	add  hl,de
	ld   a,$0B
	ld   [hl],a
	add  hl,de
	ld   a,$0A
	ld   [hl],a
	add  hl,de
	ld   a,$0C
	ld   [hl],a
	jr   .unk_33CF
	ld   a,$0D
	ld   [hl],a
	add  hl,de
	ld   a,$FF
	ld   [hl],a
	add  hl,de
	ld   a,$0E
	ld   [hl],a
	add  hl,de
	ld   a,$0F
	ld   [hl],a
	add  hl,de
	xor  a
	ld   [hl],a
	jr   .unk_33CF
	xor  a
	ld   [bc],a
	ld   [wUnk_D013],a
	ld   a,$FF
	ld   [hl],a
	add  hl,de
	ld   a,$04
	ld   [hl],a
	add  hl,de
	ld   a,$02
	ld   [hl],a
	add  hl,de
	ld   a,$05
	ld   [hl],a
	add  hl,de
	xor  a
	ld   [hl],a
	call Unk_1185
	ld   a,$04
	ldh  [hGameStatus],a
	ret

	push hl
	ld   hl,$3444
	ld   a,[wUnk_D013]
	ld   c,a
	add  a,$02
	ld   [wUnk_D013],a
	ld   b,$00
	add  hl,bc
	push hl
	pop  bc
	ld   hl,$C211
	ld   a,[bc]
	ldi  [hl],a
	inc  bc
	ld   a,[bc]
	ldi  [hl],a
	call Unk_3439
	pop  hl
	ret

	dec  [hl]
	ld   a,[hl]
	and  a,$03
	cp   a,$03
	ret  nz
	ld   a,[hl]
	add  e
	ld   [hl],a
	ret

	ld   l,$66
	jr   nz,.unk_34A2
	ld   e,$58
	rla
	ld   d,c
	ld   a,[de]
	ld   d,b
	ld   d,$47
	ld   a,[de]
	ld   b,[hl]
	rla
	ccf
	inc  e
	ccf
	ld   a,[de]
	dec  [hl]
	jr   nz,.unk_348E
	jr   nz,.unk_348C
	xor  a
	ld   [wUnk_D015],a
	ld   [wUnk_D01C],a
	ld   [wUnk_D019],a
	ld   hl,$FFDB
	res  7,[hl]
	call Unk_2696
	ret

	xor  a
	ld   [wUnk_D017],a
	ld   [wUnk_D01D],a
	ld   [wUnk_D01A],a
	ld   hl,$FFDB
	res  6,[hl]
	call Unk_26DA
	ret

	xor  a
	ld   [wUnk_D018],a
	ld   [wUnk_D01E],a
	ld   [wUnk_D01B],a
	ld   hl,$FFDB
	res  5,[hl]
	call Unk_270E
	ret

	ldh  a,[hTwoPlayerMode]
	and  a
	ret  nz
	ldh  a,[hUnk_FFDB]
	bit  7,a
	call nz,Unk_345C
	ldh  a,[hUnk_FFDB]
	bit  6,a
	call nz,Unk_346F
	ldh  a,[hUnk_FFDB]
	bit  5,a
	call nz,Unk_3482
	ld   hl,$FFFA
	ld   a,[hl]
	cp   a,$03
	jr   z,.unk_34CE
	cp   a,$01
	jp   z,Unk_3623
	cp   a,$02
	jp   z,Unk_3632
	ldh  a,[hUnk_FFDB]
	bit  2,a
	jr   nz,.unk_34CB
	call Unk_350D
	jr   .unk_34CE
	call Unk_35A3
	ld   hl,$FFFB
	ld   a,[hl]
	cp   a,$03
	jr   z,.unk_34EE
	cp   a,$01
	jp   z,Unk_36C6
	cp   a,$02
	jp   z,Unk_36D5
	ldh  a,[hUnk_FFDB]
	bit  1,a
	jr   nz,.unk_34EB
	call Unk_354F
	jr   .unk_34EE
	call Unk_3642
	ld   hl,$FFFC
	ld   a,[hl]
	cp   a,$03
	ret  z
	cp   a,$01
	jp   z,Unk_3745
	cp   a,$02
	jp   z,Unk_3754
	ldh  a,[hUnk_FFDB]
	bit  0,a
	jr   nz,.unk_3509
	call Unk_3579
	ret

	call Unk_36E5
	ret

	ld   a,[wUnk_DF88]
	ld   b,a
	ld   hl,hUnk_FFE5
	ld   a,[hl]
	cp   b
	ret  c
	xor  a
	ld   [hl],a
	ld   hl,$D015
	inc  [hl]
	ld   a,[hl]
	ld   hl,$C04A
	ld   de,$0004
	ld   b,e
	cp   a,$01
	jr   z,.unk_353E
	cp   a,$02
	jr   z,.unk_3548
	cp   a,$03
	jr   z,.unk_354C
	xor  a
	ld   [wUnk_D015],a
	ld   c,e
	ld   a,[hl]
	sub  c
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_3536
	ret

	ld   c,$02
	ld   a,[hl]
	add  c
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_3540
	ret

	ld   c,$02
	jr   .unk_3536
	ld   c,e
	jr   .unk_3540
	ld   a,[wUnk_DF88]
	ld   b,a
	ld   hl,hUnk_FFE6
	ld   a,[hl]
	cp   b
	ret  c
	xor  a
	ld   [hl],a
	ld   hl,$D017
	inc  [hl]
	ld   a,[hl]
	ld   hl,$C05A
	ld   de,$0004
	ld   b,e
	cp   a,$01
	jr   z,.unk_353E
	cp   a,$02
	jr   z,.unk_3548
	cp   a,$03
	jr   z,.unk_354C
	xor  a
	ld   [wUnk_D017],a
	jr   .unk_3535
	ld   a,[wUnk_DF88]
	ld   b,a
	ld   hl,hUnk_FFE7
	ld   a,[hl]
	cp   b
	ret  c
	xor  a
	ld   [hl],a
	ld   hl,$D018
	inc  [hl]
	ld   a,[hl]
	ld   hl,$C06A
	ld   de,$0004
	ld   b,e
	cp   a,$01
	jr   z,.unk_353E
	cp   a,$02
	jr   z,.unk_3548
	cp   a,$03
	jr   z,.unk_354C
	xor  a
	ld   [wUnk_D018],a
	jr   .unk_3535
	ldh  a,[hUnk_FFE2]
	and  a,$01
	ret  nz
	ld   hl,$D01C
	inc  [hl]
	ld   a,[hl]
	ld   hl,$C048
	ld   de,$0004
	ld   b,e
	cp   a,$04
	jr   c,.unk_35DA
	jr   z,.unk_35E3
	cp   a,$08
	jr   c,.unk_35F6
	cp   a,$20
	jr   c,.unk_35FF
	xor  a
	ld   [wUnk_D015],a
	ld   [wUnk_D01C],a
	ld   [wUnk_D019],a
	ld   hl,$FFDB
	res  2,[hl]
	ldh  a,[hUnk_FFD5]
	and  a
	jr   z,.unk_3618
	call Unk_2696
	ret

	ld   a,[hl]
	sub  a,$02
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_35DA
	ret

	inc  l
	inc  l
	ld   a,[hl]
	and  a,$F0
	add  a,$06
	ld   [hl],a
	add  hl,de
	inc  a
	ld   [hl],a
	add  hl,de
	add  a,$0F
	ld   [hl],a
	add  hl,de
	inc  a
	ld   [hl],a
	ret

	ld   a,[hl]
	add  a,$02
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_35F6
	ret

	ldh  a,[hUnk_FFE2]
	and  a,$03
	jr   z,.unk_360A
	ld   hl,$D01C
	dec  [hl]
	ret

	ld   hl,$D019
	ld   a,[hl]
	xor  a,$01
	ld   [hl],a
	ld   hl,$C04A
	jr   z,.unk_35DA
	jr   .unk_35F6
	ld   hl,$C04A
	call Unk_3764
	ld   a,$01
	ldh  [hUnk_FFFA],a
	ret

	ld   hl,$D027
	inc  [hl]
	ld   a,[hl]
	cp   a,$03
	ret  nz
	xor  a
	ld   [hl],a
	ld   a,$02
	ldh  [hUnk_FFFA],a
	ret

	ld   a,$03
	ld   [hl],a
	ld   hl,$C048
	call Unk_377A
	ld   hl,$C04A
	call Unk_3782
	ret

	ldh  a,[hUnk_FFE2]
	and  a,$01
	ret  nz
	ld   hl,$D01D
	inc  [hl]
	ld   a,[hl]
	ld   hl,$C058
	ld   de,$0004
	ld   b,e
	cp   a,$04
	jp   c,Unk_35DA
	jp   z,Unk_35E3
	cp   a,$08
	jp   c,Unk_35F6
	cp   a,$20
	jr   c,.unk_367C
	xor  a
	ld   [wUnk_D017],a
	ld   [wUnk_D01D],a
	ld   [wUnk_D01A],a
	ld   hl,$FFDB
	res  1,[hl]
	ldh  a,[hUnk_FFD6]
	and  a
	jr   z,.unk_36BB
	call Unk_26DA
	ret

	ldh  a,[hUnk_FFE2]
	and  a,$03
	jr   z,.unk_3687
	ld   hl,$D01D
	dec  [hl]
	ret

	ld   hl,$D01A
	ld   a,[hl]
	xor  a,$01
	ld   [hl],a
	ld   hl,$C05A
	jr   z,.unk_36A7
	ld   b,$02
	ld   a,[hl]
	inc  a
	ldi  [hl],a
	set  5,[hl]
	dec  l
	add  hl,de
	ld   a,[hl]
	dec  a
	ldi  [hl],a
	set  5,[hl]
	dec  l
	add  hl,de
	dec  b
	jr   nz,.unk_3695
	ret

	ld   b,$02
	ld   a,[hl]
	dec  a
	ldi  [hl],a
	res  5,[hl]
	dec  l
	add  hl,de
	ld   a,[hl]
	inc  a
	ldi  [hl],a
	res  5,[hl]
	dec  l
	add  hl,de
	dec  b
	jr   nz,.unk_36A9
	ret

	ld   hl,$C05A
	call Unk_3764
	ld   a,$01
	ldh  [hUnk_FFFB],a
	ret

	ld   hl,$D028
	inc  [hl]
	ld   a,[hl]
	cp   a,$03
	ret  nz
	xor  a
	ld   [hl],a
	ld   a,$02
	ldh  [hUnk_FFFB],a
	ret

	ld   a,$03
	ld   [hl],a
	ld   hl,$C058
	call Unk_377A
	ld   hl,$C05A
	call Unk_3782
	ret

	ldh  a,[hUnk_FFE2]
	and  a,$01
	ret  nz
	ld   hl,$D01E
	inc  [hl]
	ld   a,[hl]
	ld   hl,$C068
	ld   de,$0004
	ld   b,e
	cp   a,$04
	jp   c,Unk_35DA
	jp   z,Unk_35E3
	cp   a,$08
	jp   c,Unk_35F6
	cp   a,$20
	jr   c,.unk_371F
	xor  a
	ld   [wUnk_D018],a
	ld   [wUnk_D01E],a
	ld   [wUnk_D01B],a
	ld   hl,$FFDB
	res  0,[hl]
	ldh  a,[hUnk_FFD7]
	and  a
	jr   z,.unk_373A
	call Unk_270E
	ret

	ldh  a,[hUnk_FFE2]
	and  a,$03
	jr   z,.unk_372A
	ld   hl,$D01E
	dec  [hl]
	ret

	ld   hl,$D01B
	ld   a,[hl]
	xor  a,$01
	ld   [hl],a
	ld   hl,$C06A
	jp   z,Unk_36A7
	jp   Unk_3693
	ld   hl,$C06A
	call Unk_3764
	ld   a,$01
	ldh  [hUnk_FFFC],a
	ret

	ld   hl,$D029
	inc  [hl]
	ld   a,[hl]
	cp   a,$03
	ret  nz
	xor  a
	ld   [hl],a
	ld   a,$02
	ldh  [hUnk_FFFC],a
	ret

	ld   a,$03
	ld   [hl],a
	ld   hl,$C068
	call Unk_377A
	ld   hl,$C06A
	call Unk_3782
	ret

	ld   de,$0004
	ld   a,$48
	ld   [hl],a
	add  hl,de
	inc  a
	ld   [hl],a
	add  hl,de
	add  a,$0F
	ld   [hl],a
	add  hl,de
	inc  a
	ld   [hl],a
	ld   a,$0C
	ld   [wUnk_DFE0],a
	ret

	ld   b,$10
	xor  a
	ldi  [hl],a
	dec  b
	jr   nz,.unk_377D
	ret

	ld   de,$0004
	ld   b,e
	ld   a,$FF
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_3788
	ret

	ldh  a,[hTwoPlayerMode]
	and  a
	ret  nz
	ld   hl,$C020
	ld   a,$3D
	ldi  [hl],a
	ld   a,$8C
	ldi  [hl],a
	ld   de,$37AA
	ld   b,$0A
	ld   a,[de]
	ldi  [hl],a
	inc  l
	inc  l
	inc  l
	inc  de
	dec  b
	jr   nz,.unk_37A0
	ret

	rla
	inc  d
	ld   [de],a
	dec  d
	<corrupted stop>
	ld   de,$1613
	add  hl,de
	ldh  a,[hUnk_FFE2]
	and  a,$07
	ret  nz
	ld   hl,$D01F
	ld   a,[hl]
	xor  a,$01
	ld   [hl],a
	jr   z,.unk_37DA
	ldh  a,[hUnk_FFD5]
	and  a
	jr   z,.unk_37CA
	call Unk_2696
	ldh  a,[hUnk_FFD6]
	and  a
	jr   z,.unk_37D2
	call Unk_26DA
	ldh  a,[hUnk_FFD7]
	and  a
	ret  z
	call Unk_270E
	ret

	ldh  a,[hUnk_FFD5]
	and  a
	jr   z,.unk_37E5
	ld   hl,$C04A
	call Unk_37FB
	ldh  a,[hUnk_FFD6]
	and  a
	jr   z,.unk_37F0
	ld   hl,$C05A
	call Unk_37FB
	ldh  a,[hUnk_FFD7]
	and  a
	ret  z
	ld   hl,$C06A
	call Unk_37FB
	ret

	ld   bc,$040A
	ld   de,$0004
	ld   a,[hl]
	add  c
	ld   [hl],a
	add  hl,de
	dec  b
	jr   nz,.unk_3801
	ret

	ld   hl,$D002
	ldi  a,[hl]
	ld   d,a
	ld   a,[hl]
	ld   e,a
	cp   a,$78
	jr   nc,.unk_384F
	cp   a,$70
	jr   nc,.unk_3862
	cp   a,$68
	jr   nc,.unk_3869
	cp   a,$60
	jr   nc,.unk_3870
	cp   a,$58
	jr   nc,.unk_3877
	cp   a,$50
	jr   nc,.unk_387E
	cp   a,$48
	jr   nc,.unk_3885
	cp   a,$40
	jr   nc,.unk_388C
	cp   a,$38
	jr   nc,.unk_3893
	cp   a,$30
	jr   nc,.unk_389A
	cp   a,$28
	jr   nc,.unk_38A1
	cp   a,$20
	jr   nc,.unk_38A8
	cp   a,$18
	jr   nc,.unk_38AF
	jr   .unk_38B6
	cp   a,$10
	jr   nc,.unk_38B6
	cp   a,$08
	jr   nc,.unk_38BD
	ret

	ld   b,$78
	ld   hl,$9A02
	sub  b
	ld   e,a
	ld   d,$00
	add  hl,de
	ld   a,h
	ld   [wUnk_D036],a
	ld   a,l
	ld   [wUnk_D037],a
	ret

	ld   b,$70
	ld   hl,$99E2
	jr   .unk_3854
	ld   b,$68
	ld   hl,$99C2
	jr   .unk_3854
	ld   b,$60
	ld   hl,$99A2
	jr   .unk_3854
	ld   b,$58
	ld   hl,$9982
	jr   .unk_3854
	ld   b,$50
	ld   hl,$9962
	jr   .unk_3854
	ld   b,$48
	ld   hl,$9942
	jr   .unk_3854
	ld   b,$40
	ld   hl,$9922
	jr   .unk_3854
	ld   b,$38
	ld   hl,$9902
	jr   .unk_3854
	ld   b,$30
	ld   hl,$98E2
	jr   .unk_3854
	ld   b,$28
	ld   hl,$98C2
	jr   .unk_3854
	ld   b,$20
	ld   hl,$98A2
	jr   .unk_3854
	ld   b,$18
	ld   hl,$9882
	jr   .unk_3854
	ld   b,$10
	ld   hl,$9862
	jr   .unk_3854
	ld   b,$08
	ld   hl,$9842
	jr   .unk_3854
	ccf
	ccf
	ccf
	jr   c,.unk_3902
	ld   c,a
	ld   c,a
	inc  a
	dec  a
	ccf
	ccf
	ld   d,[hl]
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   e,b
	ccf
	jr   nc,.unk_390C
	ld   sp,$4E3A
	ld   c,[hl]
	dec  sp
	ld   sp,$3231
	ld   e,c
	cp   a,$1C
	inc  c
	jr   .unk_3904
	ld   c,$FE
	ld   e,d
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   e,c
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$5A
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   e,e
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,l
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	ld   c,b
	ld   c,h
	ld   c,h
	ld   c,h
	ld   c,c
	ccf
	ld   h,[hl]
	ccf
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	cp   a,$FE
	cp   a,$FE
	cp   a,$3F
	cp   a,$3F
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	cp   a,$FE
	cp   a,$FE
	cp   a,$3F
	cp   a,$3F
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	ld   c,d
	ld   c,l
	ld   c,l
	ld   c,l
	ld   c,e
	ccf
	cp   a,$3F
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	ccf
	ld   d,b
	ld   d,c
	ld   d,c
	ld   d,c
	ld   d,d
	ld   h,a
	ccf
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   b,b
	ld   b,c
	ld   d,e
	ld   d,h
	ld   d,h
	ld   d,h
	ld   d,l
	ld   b,c
	ld   b,d
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   b,e
	cp   a,$15
	ld   c,$1F
	ld   c,$15
	cp   a,$44
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   b,e
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$44
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   b,e
	cp   a,$1F
	ld   [de],a
	dec  de
	ld   e,$1C
	cp   a,$44
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   b,e
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$44
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   b,l
	ld   b,[hl]
	ld   b,[hl]
	ld   b,[hl]
	ld   b,[hl]
	ld   b,[hl]
	ld   b,[hl]
	ld   b,[hl]
	ld   b,a
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	ld   c,b
	ld   c,h
	ld   c,h
	ld   c,h
	ld   c,h
	ld   c,h
	ld   c,c
	ccf
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$3F
	ccf
	dec  [hl]
	ld   [hl],$36
	ld   [hl],$36
	ld   [hl],$36
	ld   [hl],$36
	scf
	ccf
	ld   c,d
	ld   c,l
	ld   c,l
	ld   c,l
	ld   c,l
	ld   c,l
	ld   c,e
	ccf
	ccf
	ccf
	ccf
	jr   c,.unk_3A6A
	ld   c,a
	ld   c,a
	inc  a
	dec  a
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	jr   nc,.unk_3A74
	ld   sp,$4E3A
	ld   c,[hl]
	dec  sp
	ld   sp,$3231
	ld   d,[hl]
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   e,b
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   e,c
	dec  c
	cpl
	ld   d,$0A
	dec  de
	ld   [de],a
	jr   .unk_3AC2
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   e,e
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,l
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	ld   c,b
	ld   c,h
	ld   c,h
	ld   c,h
	ld   c,c
	ccf
	ld   h,[hl]
	ccf
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	cp   a,$FE
	cp   a,$FE
	cp   a,$3F
	cp   a,$3F
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	cp   a,$FE
	cp   a,$FE
	cp   a,$3F
	cp   a,$3F
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	ld   c,d
	ld   c,l
	ld   c,l
	ld   c,l
	ld   c,e
	ccf
	cp   a,$3F
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ld   h,a
	ccf
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   d,[hl]
	ld   d,a
	ld   d,a
	ld   d,a
	ld   l,b
	ld   d,a
	ld   d,a
	ld   d,a
	ld   e,b
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   e,c
	cp   a,$FE
	cp   a,$6A
	cp   a,$FE
	cp   a,$5A
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   e,e
	ld   e,h
	ld   e,h
	ld   e,h
	ld   l,c
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,l
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   d,[hl]
	ld   d,a
	ld   d,a
	ld   e,b
	ccf
	ld   h,b
	ld   h,c
	ld   h,d
	ccf
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   e,c
	cp   a,$FE
	ld   e,d
	ccf
	ld   [hl],b
	ld   [hl],c
	ld   [hl],d
	ccf
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   e,c
	cp   a,$FE
	ld   e,d
	ccf
	ld   [hl],e
	cp   a,$74
	ccf
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ld   e,e
	ld   e,h
	ld   e,h
	ld   e,l
	ccf
	ld   h,e
	ld   h,h
	ld   h,l
	ccf
	ccf
	inc  sp
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	inc  [hl]
	ccf
	ldi  [hl],a
	jr   .unk_3B99
	ccf
	inc  c
	jr   .unk_3B95
	ccf
	ccf
	dec  [hl]
	ld   [hl],$36
	ld   [hl],$36
	ld   [hl],$36
	ld   [hl],$36
	scf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	add  b
	add  c
	add  b
	add  c
	add  b
	add  c
	add  b
	add  c
	add  b
	add  c
	add  b
	add  c
	add  b
	add  c
	add  b
	add  c
	add  b
	add  c
	add  b
	add  c
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	adc  l
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	adc  [hl]
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	adc  l
	rst  $38
	adc  a
	adc  l
	rst  $38
	rst  $38
	adc  l
	rst  $38
	rst  $38
	adc  l
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	adc  [hl]
	rst  $38
	adc  a
	adc  [hl]
	rst  $38
	rst  $38
	adc  [hl]
	rst  $38
	rst  $38
	adc  [hl]
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	adc  a
	adc  a
	rst  $38
	rst  $38
	adc  l
	rst  $38
	adc  a
	adc  l
	rst  $38
	rst  $38
	adc  l
	rst  $38
	rst  $38
	adc  l
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	adc  a
	adc  a
	rst  $38
	rst  $38
	adc  [hl]
	rst  $38
	rst  $08
	adc  [hl]
	adc  d
	adc  d
	add  d
	adc  d
	add  [hl]
	add  h
	adc  d
	adc  d
	adc  e
	adc  d
	adc  e
	adc  d
	rst  $08
	rst  $08
	adc  d
	adc  d
	adc  l
	adc  d
	adc  e
	add  d
	add  [hl]
	add  a
	adc  e
	adc  h
	adc  b
	adc  c
	add  e
	adc  e
	adc  e
	adc  h
	adc  e
	adc  h
	add  [hl]
	add  a
	adc  e
	adc  h
	add  d
	adc  e
	adc  h
	adc  h
	adc  b
	adc  c
	adc  h
	adc  h
	adc  e
	adc  h
	adc  h
	adc  h
	adc  e
	adc  h
	adc  h
	adc  h
	adc  b
	adc  c
	adc  h
	adc  e
	adc  e
	adc  h
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ld   d,[hl]
	ld   d,a
	ld   d,a
	ld   d,a
	ld   l,b
	ld   d,a
	ld   d,a
	ld   d,a
	ld   e,b
	ld   e,c
	ldi  [hl],a
	jr   .unk_3D30
	ld   l,d
	inc  c
	jr   .unk_3D2C
	ld   e,d
	ld   l,l
	ld   l,e
	ld   l,e
	ld   l,e
	ld   l,h
	ld   l,e
	ld   l,e
	ld   l,e
	ld   l,[hl]
	ld   e,c
	cp   a,$15
	ld   c,$1F
	ld   c,$15
	cp   a,$5A
	ld   e,c
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$5A
	ld   e,c
	cp   a,$1C
	add  hl,de
	ld   c,$0E
	dec  c
	cp   a,$5A
	ld   e,c
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$5A
	ld   e,c
	cp   a,$1F
	ld   [de],a
	dec  de
	ld   e,$1C
	cp   a,$5A
	ld   e,c
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$5A
	ld   e,e
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,l
	ccf
	ld   d,[hl]
	ld   d,a
	ld   d,a
	ld   l,b
	ld   d,a
	ld   d,a
	ld   e,b
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	ld   l,d
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	ld   l,d
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	ld   l,d
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	ld   l,d
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	ld   l,d
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,e
	ld   e,h
	ld   e,h
	ld   l,c
	ld   e,h
	ld   e,h
	ld   e,l
	ccf

Tiles:
	INCBIN "tiles.bin"

	ldh  a,[rIE]
	nop
	rst  $38
	ldh  [rIE],a
	nop
	rst  $38
	ret  nz
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	ldh  [rIE],a
	nop
	rst  $20
	inc  [hl]
	rst  $20
	inc  l
	rst  $20
	inc  [hl]
	rst  $20
	inc  l
	rst  $20
	inc  [hl]
	rst  $20
	inc  l
	rst  $20
	inc  [hl]
	rst  $20
	inc  l
	ld   bc,$020F
	ld   c,$02
	ld   c,$02
	ld   c,$01
	pop  af
	rra
	rst  $38
	ld   h,b
	ldh  [hUnk_FF5F],a
	ret  nz
	rst  $38
	rst  $38
	nop
	nop
	rst  $38
	nop
	rst  $38
	nop
	ld   a,[hl]
	nop
	ld   a,[hl]
	nop
	rst  $38
	nop
	rst  $38
	nop
	add  b
	adc  a
	ld   b,b
	ld   c,a
	ld   b,b
	ld   c,a
	ld   b,b
	ld   c,a
	add  b
	ldh  a,[hUnk_FFF8]
	ld   hl,[sp+$06]
	ld   b,$FA
	ld   [bc],a
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	ld   e,a
	ld   b,b
	ld   h,b
	ldh  [hUnk_FF1F],a
	rst  $38
	nop
	ldh  a,[rP1]
	ldh  a,[rIE]
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	nop
	nop
	rst  $38
	rst  $38
	nop
	ldh  a,[rP1]
	ldh  a,[hUnk_FFFD]
	ld   bc,$01FD
	-
	ld   bc,$03FA
	ld   b,$06
	ld   hl,[sp+$F8]
	nop
	ldh  a,[rP1]
	ldh  a,[rP1]
	rrca
	nop
	rrca
	inc  a
	inc  bc
	ld   a,[hl]
	ld   bc,$00FF
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	ld   a,[hl]
	add  b
	inc  a
	ret  nz
	nop
	ldh  a,[rP1]
	ldh  a,[rP1]
	rrca
	nop
	rrca
	rst  $38
	rst  $38
	nop
	rst  $38
	rst  $38
	nop
	nop
	rst  $38
	nop
	rst  $38
	-
	rst  $20
	-
	rst  $20
	nop
	rst  $38
	nop
	rst  $38
	rst  $38
	nop
	nop
	rst  $38
	rst  $38
	rst  $38
	nop
	ldh  a,[rP1]
	ldh  a,[hUnk_FFDB]
	inc  h
	-
	inc  h
	-
	inc  h
	-
	inc  h
	-
	inc  h
	-
	inc  h
	-
	inc  h
	-
	inc  h
	rst  $38
	nop
	rst  $38
	nop
	nop
	rst  $38
	rst  $38
	nop
	nop
	rst  $38
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	-
	inc  h
	-
	inc  h
	jr   .unk_544B
	rst  $38
	nop
	nop
	rst  $38
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	add  hl,hl
	scf
	add  hl,hl
	scf
	jr   z,.unk_54AB
	add  hl,hl
	ld   [hl],$28
	rst  $30
	jr   z,.unk_5471
	add  hl,hl
	rst  $30
	add  hl,hl
	rst  $30
	sub  h
	rst  $28
	sub  h
	rst  $28
	inc  d
	rst  $28
	sub  h
	ld   l,a
	inc  d
	-
	inc  d
	-
	sub  h
	-
	sub  h
	-
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	-
	ld   bc,$01FD
	-
	ld   bc,$01FD
	-
	ld   bc,$01FD
	-
	ld   bc,$01FD
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	cp   a
	add  b
	-
	ld   bc,$01FD
	-
	ld   bc,$01FD
	-
	ld   bc,$01FD
	-
	ld   bc,$01FD
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	ld   bc,$01FF
	rst  $38
	ld   bc,$01FF
	rst  $38
	ld   bc,$00FF
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	ld   de,$11FF
	rst  $38
	rst  $38
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	<corrupted stop>
	ld   de,$11FF
	rst  $38
	rst  $38
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	ld   bc,$01FF
	rst  $38
	ld   de,$11FF
	rst  $38
	rst  $38
	rst  $38
	ld   bc,$01FF
	rst  $38
	ld   bc,$01FF
	rst  $38
	ld   bc,$00FF
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	rst  $38
	rst  $38
	ld   de,$11FF
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	rst  $38
	rst  $38
	ld   de,$11FF
	rst  $38
	<corrupted stop>
	<corrupted stop>
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	rst  $38
	rst  $38
	ld   de,$11FF
	rst  $38
	ld   bc,$01FF
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	nop
	rrca
	nop
	rrca
	nop
	rrca
	jp   Unk_C30C
	jr   nc,.unk_5560
	<corrupted stop>
	<corrupted stop>
	<corrupted stop>
	ld   [wUnk_08E7],sp
	rst  $20
	ld   [wUnk_08E7],sp
	rst  $20
	<corrupted stop>
	<corrupted stop>
	<corrupted stop>
	<corrupted stop>
	ld   [wUnk_08E7],sp
	rst  $20
	ld   [wUnk_0CC3],sp
	jp   Unk_0030
	ldh  a,[rP1]
	ldh  a,[rP1]
	ldh  a,[rIE]
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $20
	nop
	add  c
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $38
	nop
	rst  $20
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	xor  c
	ld   [wUnk_085A],sp
	or   e
	jr   .unk_5617
	jr   .unk_5590
	ld   [wUnk_00A6],sp
	ld   [hl],l
	nop
	sbc  e
	nop
	nop
	ret  nz
	inc  b
	ldh  [rP1],a
	ld   [hl],b
	dec  b
	ld   [hl],b
	ret  nc
	ret  c
	add  sp,$E0
	ld   [bc],a
	nop
	sub  b
	nop
	ld   [wUnk_2808],sp
	inc  c
	adc  c
	jr   .unk_5611
	ld   [wUnk_C01A],sp
	ld   [wUnk_0570],sp
	ld   hl,[sp+$00]
	inc  d
	ret  z
	jr   c,.unk_5621
	ldh  a,[hUnk_FFF8]
	ld   hl,[sp+$FC]
	inc  [hl]
	-
	ld   d,h
	ld   hl,[sp+$38]
	ldh  a,[hUnk_FFF0]
	nop
	nop
	ld   c,d
	nop
	dec  h
	nop
	cp   d
	nop
	-
	nop
	ld   a,b
	inc  bc
	ret  nc
	rlca
	jr   nz,.unk_561B
	sub  b
	add  hl,bc
	ld   d,d
	nop
	dec  l
	nop
	jp   c,Unk_A500
	nop
	add  hl,de
	ldh  [hUnk_FF0E],a
	ld   [hl],b
	inc  bc
	ld   hl,[sp+$02]
	inc  d
	ld   b,b
	add  hl,sp
	ld   b,b
	ld   a,e
	ld   b,b
	ld   a,a
	add  b
	-
	add  b
	-
	ld   [hl],b
	ld   a,a
	cp   a
	rra
	dec  c
	nop
	nop
	-
	inc  bc
	cp   [hl]
	ld   [bc],a
	sbc  [hl]
	rlca
	or   a
	sbc  a,$DE
	rst  $38
	rst  $38
	-
	cp   h
	inc  d
	nop
	and  h
	nop
	ld   d,d
	nop
	dec  h
	nop
	jp   c,Unk_5700
	nop
	xor  l
	nop
	jp   nc,Unk_6D00
	nop
	or   a
	nop
	ld   l,d
	nop
	or   l
	nop
	ld   e,d
	nop
	push hl
	nop
	ld   e,e
	nop
	rst  $28
	nop
	ld   a,d
	nop
	rst  $10
	nop
	ld   a,a
	nop
	-
	nop
	cp   a
	nop
	rst  $30
	nop
	cp   l
	nop
	rst  $38
	nop
	rst  $38
	nop
	ld   [wUnk_1008],sp
	jr   .unk_5683
	jr   .unk_5685
	jr   .unk_5687
	jr   .unk_5681
	ld   [wUnk_0C04],sp
	inc  b
	inc  c
	inc  b
	inc  c
	inc  b
	inc  c
	ld   [wUnk_1018],sp
	jr   nc,.unk_5697
	jr   nc,.unk_5699
	jr   nc,.unk_569B
	<corrupted stop>
	jr   .unk_568F
	ld   [wUnk_0800],sp
	nop
	inc  b
	nop
	inc  b
	nop
	inc  b
	nop
	inc  b
	nop
	ld   [wUnk_0800],sp
	nop
	nop
	nop
	nop
	jr   .unk_56BC
	inc  a
	inc  h
	inc  a
	inc  h
	jr   .unk_56C2
	nop
	nop
	nop
	nop
	ld   h,b
	jr   nz,.unk_5671
	ld   b,b
	ret  nc
	ld   b,b
	ret  c
	ld   c,b
	ld   hl,[sp+$58]
	cp   [hl]
	ld   a,b
	ld   b,[hl]
	ldd  [hl],a
	jr   nc,.unk_56CF
	rra
	rra
	ld   l,l
	ld   l,a
	cp   c
	cp   a
	or   d
	cp   a
	ld   e,h
	ld   e,a
	ld   d,a
	ld   d,a
	nop
	nop
	nop
	nop
	rra
	rra
	dec  c
	rrca
	add  hl,sp
	ccf
	ld   d,d
	ld   e,a
	ld   e,h
	ld   e,a
	daa
	daa
	jr   z,.unk_5704
	ld   [PerformDelay],sp
	nop
	rlca
	rlca
	rra
	jr   .unk_5724
	jr   nz,.unk_5766
	ld   b,e
	ld   a,l
	ld   b,[hl]
	ei
	adc  h
	ei
	adc  l
	nop
	nop
	ldh  [hUnk_FFE0],a
	ldh  a,[hUnk_FF10]
	ld   hl,[sp+$08]
	-
	add  h
	-
	ld   b,h
	-
	ld   c,h
	-
	adc  h
	ei
	adc  h
	-
	add  a
	cp   a
	jp   Unk_417F
	ld   e,a
	ld   h,c
	daa
	add  hl,sp
	jr   .unk_572B
	rlca
	rlca
	ret  z
	jr   c,.unk_5750
	rst  $38
	rst  $38
	ld   hl,[sp+$FF]
	inc  sp
	rst  $38
	ld   d,b
	rst  $38
	ld   sp,$FEFE
	nop
	nop
	nop
	nop
	rra
	rra
	inc  a
	inc  hl
	ld   e,h
	ld   l,e
	ld   e,h
	ld   h,d
	add  b
	rst  $38
	ld   h,b
	ld   e,a
	ld   hl,[sp+$87]
	jr   nc,.unk_5760
	ld   [hl],b
	ld   d,b
	ldh  [hUnk_FFE0],a
	ld   [hl],$F6
	add  hl,bc
	ld   a,a
	ld   bc,$01AD
	rst  $38
	ld   [hl],c
	adc  l
	ld   [hl],a
	ld   c,b
	ld   h,a
	ld   e,b
	ld   [hl],a
	ld   c,b
	ccf
	jr   nz,.unk_5786
	jr   nz,.unk_5768
	<corrupted stop>
	inc  c
	inc  bc
	inc  bc
	cp   a,$06
	ld   hl,[sp+$08]
	cp   b
	ld   c,b
	ld   hl,[sp+$08]
	ldh  a,[hUnk_FF10]
	-
	inc  e
	-
	ld   h,h
	sbc  b
	sbc  b
	ld   [hl],e
	ld   c,h
	ld   a,c
	ld   b,[hl]
	ld   a,a
	ld   b,b
	ccf
	jr   nz,.unk_57A6
	jr   nz,.unk_5788
	<corrupted stop>
	inc  c
	inc  bc
	inc  bc
	nop
	nop
	rra
	inc  bc
	ld   a,a
	ld   l,d
	ld   e,$63
	nop
	rra
	nop
	nop
	nop
	nop
	nop
	nop
	ldh  a,[hUnk_FF10]
	-
	inc  a
	rst  $38
	rst  $38
	inc  bc
	rst  $38
	nop
	rst  $38
	jr   z,.unk_578A
	stop
	nop
	nop
	nop
	nop
	ld   c,h
	inc  c
	ret  c
	ret  c
	ldh  a,[hUnk_FFF0]
	jr   .unk_5790
	adc  h
	inc  c
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld   b,$06
	rra
	add  hl,de
	ld   a,[hl]
	ld   h,d
	-
	adc  h
	nop
	nop
	-
	-
	rst  $38
	ld   a,a
	-
	ccf
	ldh  a,[hUnk_FF1F]
	ld   hl,[sp+$88]
	ld   a,h
	ld   h,h
	inc  e
	inc  e
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rlca
	rlca
	rra
	jr   .unk_580C
	jr   nz,.unk_57CF
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rst  $38
	rst  $38
	rst  $38
	inc  de
	rst  $38
	ld   [wUnk_C4FF],sp
	nop
	nop
	nop
	nop
	nop
	nop
	inc  bc
	inc  bc
	-
	rst  $38
	ld   sp,$C4CE
	ei
	ret

	halt
	rrca
	rrca
	ld   a,$32
	ld   a,[hl]
	ld   c,[hl]
	rst  $38
	sub  e
	ld   a,a
	call nz,Unk_FB3F
	ld   c,$FF
	and  b
	rst  $18
	nop
	nop
	nop
	nop
	ld   bc,$0201
	inc  bc
	add  d
	add  e
	push hl
	rst  $20
	jr   c,.unk_580B
	cp   d
	-
	inc  a
	inc  a
	cp   a,$C2
	-
	inc  b
	ld   hl,[sp+$18]
	ld   hl,[sp+$88]
	ldh  a,[hUnk_FFF0]
	adc  [hl]
	adc  [hl]
	pop  af
	rst  $38
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldh  a,[hUnk_FFC0]
	ld   hl,[sp+$00]
	-
	sub  h
	rrca
	ld   [wUnk_0407],sp
	inc  bc
	inc  bc
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rst  $38
	ret

	rst  $38
	add  hl,bc
	rst  $38
	inc  de
	rst  $38
	rst  $20
	ld   a,a
	ld   a,a
	inc  bc
	inc  bc
	nop
	nop
	nop
	nop
	dec  e
	rst  $38
	adc  h
	rst  $38
	rst  $18
	rst  $30
	ld   a,a
	ldh  a,[rIE]
	pop  bc
	rst  $38
	ldh  [hUnk_FF1F],a
	jr   .unk_586C
	rrca
	adc  c
	rst  $38
	ld   d,d
	rst  $38
	jp   Unk_BDFF
	rst  $38
	rst  $38
	rst  $38
	rst  $28
	rst  $38
	rst  $38
	ld   [hl],c
	rst  $08
	rst  $08
	ld   c,h
	rst  $38
	ld   d,d
	rst  $38
	ldd  a,[hl]
	rst  $38
	-
	rst  $38
	-
	rst  $38
	ld   a,[c]
	di
	ld   bc,$0001
	nop
	jr   nc,.unk_587F
	ei
	rst  $38
	ld   a,a
	cp   a,$43
	jp   Unk_B070
	-
	call z,Unk_82FE
	ld   a,[hl]
	ld   a,[hl]
	ld   a,[hl]
	ret  nz
	-
	add  b
	ld   hl,[sp+$10]
	ldh  a,[rP1]
	ret  nz
	ret  nz
	nop
	nop
	nop
	nop
	nop
	nop
	ccf
	ld   hl,$313F
	rrca
	ld   [wUnk_0C0F],sp
	inc  bc
	ld   [bc],a
	inc  bc
	inc  bc
	inc  bc
	inc  bc
	rlca
	dec  b
	rrca
	add  hl,bc
	rra
	ld   [de],a
	ccf
	inc  h
	ccf
	jr   c,.unk_58BE
	rlca
	nop
	nop
	nop
	nop
	nop
	nop
	ccf
	ld   hl,$313F
	ccf
	jr   z,.unk_5904
	inc  l
	ccf
	ld   h,$1F
	inc  de
	rra
	add  hl,de
	rrca
	rrca
	rst  $38
	ld   h,h
	rst  $38
	push hl
	rst  $38
	call nz,Unk_0CFF
	rst  $38
	rra
	rst  $38
	jr   .unk_58DA
	<corrupted stop>
	pop  hl
	ld   [c],a
	ccf
	-
	ccf
	ld   [c],a
	cp   l
	ldh  [hUnk_FFBF],a
	ldh  [hUnk_FF3F],a
	ldh  [hUnk_FF7F],a
	ret  c
	rst  $38
	sbc  d
	rst  $38
	ld   c,l
	ei
	ld   b,b
	cp   a
	ld   [wUnk_42F7],sp
	rst  $38
	nop
	rst  $38
	inc  b
	rst  $38
	ld   d,b
	rst  $38
	ld   [bc],a
	rst  $38
	ld   c,b
	cp   a
	ld   bc,$AAFF
	ld   [hl],a
	ld   [bc],a
	rst  $38
	jr   nz,.unk_58E7
	nop
	rst  $38
	add  h
	rst  $38
	<corrupted stop>
	call nc,Unk_64EB
	rst  $38
	ldd  [hl],a
	-
	rra
	rst  $38
	adc  b
	rst  $30
	and  c
	rst  $38
	rrca
	rst  $38
	sbc  a,$FF
	ld   a,h
	ldh  [hUnk_FF3E],a
	and  a,$1E
	ld   hl,[sp+$FF]
	ldh  [hUnk_FF3F],a
	ldh  a,[hUnk_FFBF]
	ldh  a,[rIE]
	pop  af
	ld   a,$EE
	inc  a
	inc  a
	cp   a,$C2
	-
	inc  b
	ld   hl,[sp+$18]
	ld   hl,[sp+$88]
	ldh  a,[hUnk_FFF0]
	add  e
	add  e
	rst  $38
	cp   a,$00
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ret  nz
	nop
	-
	rst  $18
	ld   h,h
	rst  $38
	ld   [hl],$FB
	rra
	rst  $38
	sub  b
	rst  $28
	and  c
	rst  $38
	rrca
	rst  $38
	push de
	rst  $38
	ldh  [rLCDC],a
	ldh  a,[hJoyHeld]
	ldh  a,[hJoyHeld]
	ldh  a,[hUnk_FFE0]
	ldh  a,[hUnk_FF90]
	ldh  a,[hUnk_FFC0]
	ldh  a,[hUnk_FFC0]
	ldh  a,[hUnk_FF90]
	dec  sp
	rst  $38
	rst  $38
	cp   a,$7F
	-
	ld   c,a
	adc  a,$74
	or   h
	-
	call z,Unk_82FE
	ld   a,[hl]
	ld   a,[hl]
	ldh  a,[hUnk_FFE0]
	ldh  [rP1],a
	ldh  [hJoyHeld],a
	add  b
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rst  $38
	rst  $38
	ccf
	ccf
	ccf
	jr   z,.unk_59B4
	inc  d
	rrca
	ld   c,$03
	inc  bc
	nop
	nop
	nop
	nop
	nop
	nop
	jr   z,.unk_59CA
	ld   a,h
	ld   a,h
	cp   a,$D6
	cp   a,$AA
	cp   a,$D6
	ld   a,h
	ld   a,h
	nop
	nop
	jr   z,.unk_59D8
	ld   a,h
	ld   a,h
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	ld   a,h
	ld   a,h
	nop
	nop
	sub  d
	sub  d
	ld   a,h
	ld   l,h
	cp   a,$82
	cp   a,$C6
	cp   a,$82
	cp   a,$82
	ld   a,h
	ld   a,h
	nop
	nop
	xor  a,$EE
	ld   a,h
	ld   a,h
	cp   a,$FE
	cp   a,$D6
	cp   a,$AA
	cp   a,$D6
	ld   a,h
	ld   a,h
	nop
	nop
	nop
	nop
	jr   z,.unk_5A0A
	ld   a,h
	ld   a,h
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	ld   a,h
	ld   a,h
	nop
	nop
	nop
	nop
	sub  d
	sub  d
	ld   a,h
	ld   l,h
	ld   a,h
	ld   b,h
	cp   a,$82
	cp   a,$82
	ld   a,h
	ld   a,h
	nop
	nop
	nop
	nop
	jr   nz,.unk_5A02
	ld   a,b
	add  hl,hl
	rst  $38
	rst  $18
	ld   a,b
	ld   a,c
	nop
	stop
	nop
	nop
	nop
	nop
	nop
	jr   nz,.unk_5A12
	ld   a,b
	ldi  a,[hl]
	cp   a,$DE
	ld   a,b
	ld   a,d
	nop
	stop
	nop
	nop
	nop
	inc  b
	inc  b
	jr   c,.unk_5A2A
	jr   nc,.unk_5A44
	ldd  a,[hl]
	ld   [wUnk_FCFE],sp
	ldd  a,[hl]
	jr   c,.unk_5A3B
	<corrupted stop>
	ld   [wUnk_0404],sp
	jr   c,.unk_5A3A
	jr   nc,.unk_5A54
	inc  a
	ld   [wUnk_F8FC],sp
	inc  a
	jr   c,.unk_5A4B
	<corrupted stop>
	ld   [Reset],sp
	inc  bc
	inc  bc
	inc  c
	rrca
	<corrupted stop>
	add  hl,hl
	ld   [hl],$20
	ccf
	rst  $38
	rst  $38
	rst  $38
	xor  d
	nop
	nop
	inc  bc
	inc  bc
	inc  c
	rrca
	<corrupted stop>
	add  hl,hl
	ld   [hl],$20
	ccf
	rst  $38
	rst  $38
	rst  $38
	ld   d,l
	ld   [wUnk_0418],sp
	inc  c
	inc  b
	inc  c
	inc  b
	inc  c
	ld   [wUnk_0818],sp
	jr   c,.unk_5A7B
	jr   nc,.unk_5A7D
	jr   nc,.unk_5A7F
	jr   nc,.unk_5A81
	<corrupted stop>
	jr   .unk_5A7D
	jr   .unk_5A7F
	jr   .unk_5A81
	jr   .unk_5A8B
	<corrupted stop>
	stop
	inc  b
	nop
	inc  b
	nop
	ld   [wUnk_0800],sp
	nop
	ld   [wUnk_0800],sp
	nop
	inc  b
	nop
	inc  b
	inc  h
	ld   [wUnk_1042],sp
	ld   b,$10
	xor  c
	ld   [wUnk_0808],sp
	ld   h,[hl]
	nop
	sbc  b
	nop
	and  l
	nop
	nop
	nop
	nop
	jr   c,.unk_5AAB
	inc  [hl]
	nop
	ld   c,$00
	nop
	nop
	nop
	nop
	nop
	nop
	inc  a
	jr   nz,.unk_5B00
	nop
	ld   h,b
	nop
	nop
	nop
	ld   [bc],a
	nop
	inc  c
	ld   [wUnk_0014],sp
	jr   .unk_5ABD
	nop
	ccf
	ld   d,[hl]
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   e,b
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	cp   a,$FE
	add  hl,de
	dec  d
	ld   a,[bc]
	ldi  [hl],a
	ld   c,$1B
	cp   a,$10
	ld   a,[bc]
	ld   d,$0E
	cp   a,$5A
	ccf
	ccf
	ld   e,c
	cp   a,$83
	add  h
	add  h
	add  h
	add  h
	add  h
	add  h
	add  h
	add  h
	add  h
	add  h
	add  h
	add  l
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$86
	rra
	ld   [de],a
	dec  de
	ld   e,$1C
	cp   a,$15
	ld   c,$1F
	ld   c,$15
	add  a
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$88
	adc  c
	adc  c
	adc  c
	adc  c
	adc  c
	adc  c
	adc  c
	adc  c
	adc  c
	adc  c
	adc  c
	adc  d
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	cp   a,$75
	halt
	halt
	ld   [hl],a
	halt
	ld   a,b
	halt
	halt
	ld   [hl],a
	halt
	ld   a,b
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	cp   a,$79
	ld   a,d
	ld   a,d
	ld   a,e
	ld   a,d
	ld   a,h
	ld   a,d
	ld   a,d
	ld   a,e
	ld   a,d
	ld   a,h
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$83
	add  h
	add  h
	add  h
	add  h
	add  h
	add  l
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$86
	inc  e
	add  hl,de
	ld   c,$0E
	dec  c
	add  a
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$88
	adc  c
	adc  c
	adc  c
	adc  c
	adc  c
	adc  d
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	cp   a,$FE
	dec  d
	jr   .unk_5BC3
	cp   a,$16
	ld   c,$0D
	cp   a,$11
	ld   [de],a
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$83
	add  h
	add  h
	add  h
	add  h
	add  h
	add  l
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$86
	ld   d,$1E
	inc  e
	ld   [de],a
	inc  c
	add  a
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$88
	adc  c
	adc  c
	adc  c
	adc  c
	adc  c
	adc  d
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$0F
	ld   c,$1F
	ld   c,$1B
	cp   a,$0C
	ld   de,$1512
	dec  d
	cp   a,$18
	rrca
	rrca
	ld   e,d
	ccf
	ccf
	ld   e,c
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	cp   a,$FE
	ld   e,d
	ccf
	ccf
	ld   e,e
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,l
	ccf
TitleScreenTileMap:
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ld   d,[hl]
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   d,a
	ld   e,b
	ccf
	ccf
	ld   e,c
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	ld   e,d
	ccf
	ccf
	ld   e,c
	and  e
	and  h
	and  l
	and  [hl]
	and  a
	xor  b
	xor  c
	xor  d
	xor  e
	xor  h
	xor  l
	xor  [hl]
	xor  a
	and  a,$E7
	add  sp,$5A
	ccf
	ccf
	ld   e,c
	or   e
	or   h
	or   l
	or   [hl]
	or   a
	cp   b
	cp   c
	cp   d
	cp   e
	cp   h
	cp   l
	cp   [hl]
	cp   a
	or   a,$F7
	ld   hl,[sp+$5A]
	ccf
	ccf
	ld   e,c
	jp   Unk_C5C4
	add  a,$C7
	ret  z
	ret

	jp   z,Unk_CCCB
	call Unk_CFCE
	jp   hl
	ld   [wUnk_5AEB],a
	ccf
	ccf
	ld   e,c
	-
	call nc,Unk_D6D5
	rst  $10
	ret  c
	reti
	jp   c,Unk_DCDB
	-
	sbc  a,$DF
	ld   sp,hl
	ld   a,[wUnk_5AFB]
	ccf
	ccf
	ld   e,c
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	-
	ld   e,d
	ccf
	ccf
	ld   e,e
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,h
	ld   e,l
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	cp   a,$01
	cp   a,$19
	dec  d
	ld   a,[bc]
	ldi  [hl],a
	ld   c,$1B
	cp   a,$10
	ld   a,[bc]
	ld   d,$0E
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	cp   a,$02
	cp   a,$19
	dec  d
	ld   a,[bc]
	ldi  [hl],a
	ld   c,$1B
	cp   a,$10
	ld   a,[bc]
	ld   d,$0E
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	cp   a,$2E
	cp   a,$01
	add  hl,bc
	add  hl,bc
	nop
	cp   a,$FE
	jr   z,.unk_5D88
	ldi  a,[hl]
	dec  hl
	inc  l
	dec  l
	cp   a,$3F
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	cp   a,$02
	cp   a,$19
	dec  d
	ld   a,[bc]
	ldi  [hl],a
	ld   c,$1B
	cp   a,$10
	ld   a,[bc]
	ld   d,$0E
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	cp   a,$2E
	cp   a,$01
	add  hl,bc
	add  hl,bc
	nop
	cp   a,$FE
	jr   z,.unk_5DEE
	ldi  a,[hl]
	dec  hl
	inc  l
	dec  l
	cp   a,$3F
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	ccf
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld   c,b
	jr   nz,.unk_5E0A
	nop
	inc  b
	jr   nz,.unk_5E0E
	nop
	ld   [wUnk_0802],sp
	nop
	inc  b
	ld   [bc],a
	ld   a,[bc]
	nop
	inc  e
	jr   nz,.unk_5E19
	nop
	inc  bc
	jr   nz,.unk_5E1D
	nop
	nop
	ld   [bc],a
	rlca
	nop
	inc  b
	ld   [bc],a
	add  hl,bc
	nop
	rrca
	add  b
	dec  b
	nop
	inc  d
	ld   [bc],a
	dec  b
	nop
	dec  b
	ld   [bc],a
	ld   b,$00
	nop
	add  b
	ld   c,$00
	ld   a,[bc]
	<corrupted stop>
	nop
	ld   b,d
	add  b
	dec  b
	nop
	dec  de
	<corrupted stop>
	nop
	rrca
	add  b
	stop
	ld   d,h
	jr   nz,.unk_5E4A
	nop
	ld   [bc],a
	jr   nz,.unk_5E4E
	nop
	jr   nz,.unk_5DCB
	ld   [wUnk_3B00],sp
	jr   nz,.unk_5E53
	ldi  [hl],a
	ld   bc,$0702
	nop
	ld   b,$20
	dec  b
	nop
	rlca
	add  b
	inc  de
	nop
	ld   d,a
	<corrupted stop>
	nop
	inc  bc
	<corrupted stop>
	nop
	inc  bc
	<corrupted stop>
	nop
	inc  b
	ld   [bc],a
	rlca
	nop
	dec  b
	ld   [bc],a
	rlca
	nop
	inc  bc
	add  b
	ld   [wUnk_0700],sp
	ld   [bc],a
	ld   a,[bc]
	nop
	inc  bc
	add  b
	rrca
	nop
	jr   z,.unk_5E81
	add  hl,bc
	<corrupted stop>
	nop
	inc  b
	<corrupted stop>
	nop
	ld   de,$0580
	nop
	inc  h
	<corrupted stop>
	nop
	ld   b,d
	ld   [bc],a
	add  hl,bc
	nop
	ld   bc,$0510
	nop
	dec  b
	<corrupted stop>
	nop
	dec  b
	<corrupted stop>
	nop
	rrca
	add  b
	ld   [wUnk_0C00],sp
	<corrupted stop>
	nop
	inc  bc
	<corrupted stop>
	nop
	jr   nc,.unk_5ECD
	inc  bc
	nop
	inc  b
	jr   nz,.unk_5EB5
	nop
	inc  l
	add  b
	rrca
	nop
	scf
	jr   nz,.unk_5EC1
	nop
	inc  de
	add  b
	ld   c,$00
	ld   d,$20
	dec  b
	nop
	ldi  a,[hl]
	add  b
	ld   a,[bc]
	nop
	ld   b,b
	ld   [bc],a
	dec  b
	nop
	ld   de,$0801
	nop
	ld   bc,$0F80
	nop
	ld   d,d
	jr   nz,.unk_5EDB
	nop
	inc  b
	jr   nz,.unk_5EDF
	nop
	ld   bc,$0D20
	nop
	ld   bc,$0802
	nop
	inc  b
	ld   [bc],a
	ld   [wUnk_0300],sp
	add  b
	ld   [wUnk_0710],sp
	ld   [de],a
	ld   [wUnk_1510],sp
	nop
	ld   [wUnk_0D80],sp
	nop
	ld   [hl],$02
	ld   b,$00
	dec  b
	ld   [bc],a
	ld   [wUnk_0600],sp
	add  b
	dec  bc
	nop
	ld   e,$20
	dec  b
	nop
	ld   b,$20
	inc  b
	nop
	ldi  [hl],a
	ld   [bc],a
	inc  bc
	ld   [de],a
	inc  b
	stop
	nop
	daa
	ld   [bc],a
	ld   a,[bc]
	nop
	cpl
	jr   nz,.unk_5F1C
	nop
	ld   b,$02
	add  hl,bc
	nop
	ld   d,a
	ld   bc,$000C
	ld   b,c
	jr   nz,.unk_5F29
	nop
	ld   b,$20
	ld   [wUnk_0200],sp
	jr   nz,.unk_5F33
	ldi  [hl],a
	ld   bc,$0502
	nop
	inc  bc
	ld   [bc],a
	add  hl,bc
	nop
	dec  d
	jr   nz,.unk_5F38
	nop
	ld   a,[bc]
	jr   nz,.unk_5F40
	nop
	rlca
	jr   nz,.unk_5F43
	nop
	rrca
	add  b
	dec  c
	nop
	sub  c
	add  b
	inc  c
	nop
	ld   sp,$0802
	nop
	nop
	jr   nz,.unk_5F54
	nop
	ld   b,$20
	dec  b
	nop
	rlca
	jr   nz,.unk_5F5C
	nop
	rrca
	add  b
	ld   c,$00
	rlca
	jr   nz,.unk_5F64
	nop
	dec  bc
	ld   [bc],a
	rlca
	nop
	inc  b
	ld   [bc],a
	rlca
	add  b
	dec  d
	nop
	ld   d,b
	ld   [bc],a
	ld   [bc],a
	ld   [de],a
	inc  bc
	ld   [bc],a
	nop
	-
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	pop  hl
	rst  $38
	rst  $38
	pop  hl
	pop  hl
	ldh  [hUnk_FFE0],a
	rst  $38
	rst  $38
	pop  hl
	ldh  [hUnk_FFE0],a
	ld   [c],a
	pop  hl
	ldh  [hUnk_FFE2],a
	rst  $38
	ldh  [hUnk_FFE0],a
	ld   [c],a
	rst  $38
	rst  $38
	rst  $38
	ldh  [hUnk_FFE2],a
	ld   [c],a
	ld   [c],a
	pop  hl
	ldh  [rIE],a
	pop  hl
	rst  $38
	ld   [c],a
	pop  hl
	pop  hl
	rst  $38
	ld   [c],a
	rst  $38
	ldh  [hUnk_FFE2],a
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	pop  hl
	rst  $38
	ld   [c],a
	pop  hl
	ldh  [rIE],a
	ld   [c],a
	rst  $38
	pop  hl
	pop  hl
	rst  $38
	ldh  [hUnk_FFE0],a
	rst  $38
	pop  hl
	rst  $38
	ldh  [hGameStatus],a
	pop  hl
	ld   [c],a
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	rst  $38
	ldh  [hUnk_FFE2],a
	rst  $38
	rst  $38
	ld   bc,$2A61
	ld   h,c
	add  l
	ld   h,b
	cp   b
	ld   h,e
	ld   b,h
	ld   h,e
	ld   sp,hl
	ld   h,d
	pop  bc
	ld   h,b
	scf
	ld   h,d
	ld   [hl],c
	ld   h,c
	sbc  d
	ld   h,b
	ld   e,a
	ld   h,d
	add  [hl]
	ld   h,e
	ld   de,$DB62
	ld   h,b
	ld   de,$3A61
	ld   h,c
	ld   c,[hl]
	ld   h,c
	ld   c,[hl]
	ld   h,c
	ld   d,b
	ld   h,e
	dec  b
	ld   h,e
	ld   c,[hl]
	ld   h,c
	add  l
	ld   h,d
	add  b
	ld   h,c
	and  a
	ld   h,b
	add  l
	ld   h,d
	sub  d
	ld   h,e
	add  l
	ld   h,d
	-
	ld   h,b
	cp   a,$63
	rst  $10
	ld   h,e
	ret  z
	ld   h,e
	ld   b,$64
	rst  $18
	ld   h,e
	cp   b
	ld   h,[hl]
	xor  b
	ld   l,h
	or   e
	ld   l,h
	cp   [hl]
	ld   l,h
	ret

	ld   l,h
	call nc,Unk_DF6C
	ld   l,h
	ld   [wUnk_F56C],a
	ld   l,h
	nop
	ld   l,l
	dec  bc
	ld   l,l
	ld   a,[wUnk_DFE1]
	jr   .unk_6063
	ld   a,[wUnk_DFE1]
	cp   a,$0C
	ret  z
	cp   a,$08
	ret  z
	cp   a,$0A
	ret  z
	cp   a,$0B
	ret  z
	cp   a,$0D
	ret  z
	ret

	ld   a,[wUnk_DFE1]
	cp   a,$04
	ret  z
	ld   a,[wUnk_DFE1]
	cp   a,$05
	ret  z
	cp   a,$06
	ret  z
	ret

	ld   c,b
	cp   h
	sub  b
	daa
	rst  $00
	call Unk_605D
	ret  z
	call Unk_6070
	ret  z
	ld   a,$02
	ld   hl,$6080
	jp   Unk_647F
	nop
	ld   l,$E0
	ldh  a,[hUnk_FFC5]
	ld   hl,wUnk_DFAF
	res  7,[hl]
	ld   a,$08
	ld   hl,$6095
	jp   Unk_647F
	call Unk_64ED
	and  a
	ret  nz
	ld   hl,$DFE4
	inc  [hl]
	ld   a,[hl]
	cp   a,$09
	jp   z,Unk_6153
	ld   hl,$6095
	jp   Unk_64B8
	nop
	cp   l
	sub  c
	adc  c
	rst  $00
	call Unk_605D
	ret  z
	call Unk_6076
	ret  z
	ld   a,$01
	ld   hl,$60BC
	jp   Unk_647F
	dec  a
	add  b
	ldh  a,[hUnk_FF10]
	push bc
	ld   a,$80
	ldh  a,[hUnk_FFE0]
	push bc
	ld   a,$05
	ld   hl,$60D1
	jp   Unk_647F
	call Unk_64ED
	and  a
	ret  nz
	ld   hl,$DFE4
	inc  [hl]
	ld   a,[hl]
	cp   a,$02
	jr   z,.unk_6153
	ld   hl,$60D6
	jp   Unk_64B8
	nop
	push af
	ret  nc
	ld   [hl],b
	rst  $00
	nop
	push af
	jr   nz,.unk_6170
	rst  $00
	call Unk_605D
	ret  z
	call Unk_6070
	ret  z
	ld   a,$05
	ld   hl,$60F7
	jp   Unk_647F
	call Unk_64ED
	and  a
	ret  nz
	ld   hl,$DFE4
	inc  [hl]
	ld   a,[hl]
	cp   a,$02
	jr   z,.unk_6153
	ld   hl,$60FC
	jp   Unk_64B8
	nop
	cp   b
	add  b
	ld   h,e
	rst  $00
	call Unk_605D
	ret  z
	call Unk_6070
	ret  z
	ld   a,$04
	ld   hl,$6125
	jp   Unk_647F
	call Unk_64ED
	and  a
	ret  nz
	ld   hl,$DFE4
	ld   a,[hl]
	cp   a,$01
	jr   z,.unk_6153
	inc  [hl]
	ld   hl,$6125
	jp   Unk_64B8
	call Unk_64ED
	and  a
	ret  nz
	xor  a
	ld   [wUnk_DFE1],a
	ldh  [hUnk_FF10],a
	ld   a,$08
	ldh  [hUnk_FF12],a
	ld   a,$80
	ldh  [hUnk_FF14],a
	ld   hl,wUnk_DF9F
	res  7,[hl]
	ret

	nop
	add  b
	sub  c
	xor  h
	add  a
	nop
	add  b
	sub  c
	sbc  l
	add  a
	call Unk_6058
	ret  z
	ld   hl,wUnk_DFAF
	res  7,[hl]
	ld   hl,$6167
	jp   Unk_647F
	ld   hl,$DFE4
	inc  [hl]
	ld   a,[hl]
	cp   a,$04
	jr   z,.unk_619A
	cp   a,$0B
	jr   z,.unk_61A0
	cp   a,$0F
	jr   z,.unk_619A
	cp   a,$30
	jp   z,Unk_6197
	ret

	jp   Unk_6153
	ld   hl,$616C
	jp   Unk_64B8
	ld   hl,$6167
	jp   Unk_64B8
	nop
	or   b
	ldh  a,[hUnk_FFAC]
	rst  $00
	xor  h
	xor  h
	nop
	or   [hl]
	xor  h
	nop
	and  d
	nop
	sbc  l
	nop
	nop
	nop
	add  e
	nop
	nop
	rst  $38
	or   b
	ldh  a,[hUnk_FFAD]
	rst  $00
	xor  l
	xor  l
	nop
	or   a
	xor  l
	nop
	and  e
	nop
	sbc  [hl]
	nop
	nop
	nop
	add  h
	nop
	nop
	rst  $38
	nop
	add  b
	ldh  a,[hUnk_FF97]
	rst  $00
	adc  d
	ld   c,a
	nop
	and  a
	nop
	and  a
	nop
	rst  $38
	add  b
	ldh  a,[hUnk_FF98]
	rst  $00
	adc  e
	ld   d,b
	nop
	ld   [hl],e
	nop
	ld   [hl],e
	nop
	rst  $38
	nop
	add  b
	ldh  a,[hUnk_FF9D]
	rst  $00
	add  b
	ldh  a,[hUnk_FF9E]
	rst  $00
	add  e
	sbc  l
	add  e
	sbc  l
	add  e
	sbc  l
	add  e
	sbc  l
	add  e
	sbc  l
	add  e
	sbc  l
	add  e
	sbc  l
	add  e
	rst  $38
	add  h
	sbc  [hl]
	add  h
	sbc  [hl]
	add  h
	sbc  [hl]
	add  h
	sbc  [hl]
	add  h
	sbc  [hl]
	add  h
	sbc  [hl]
	add  h
	sbc  [hl]
	add  h
	rst  $38
	ld   hl,wUnk_DFAF
	set  7,[hl]
	ld   hl,$61ED
	call Unk_64BF
	ld   a,$04
	ld   hl,$61E8
	call Unk_647F
	ld   a,$F1
	ld   [wUnk_DFE6],a
	ld   a,$61
	ld   [wUnk_DFE7],a
	ld   a,$01
	ld   [wUnk_DFEE],a
	ld   a,$62
	jr   .unk_625B
	ld   hl,wUnk_DFAF
	set  7,[hl]
	ld   hl,$61BB
	call Unk_64BF
	ld   a,$04
	ld   hl,$61A6
	call Unk_647F
	ld   a,$AB
	ld   [wUnk_DFE6],a
	ld   a,$61
	ld   [wUnk_DFE7],a
	ld   a,$BF
	ld   [wUnk_DFEE],a
	ld   a,$61
	ld   [wUnk_DFEF],a
	ret

	ld   hl,wUnk_DFAF
	set  7,[hl]
	ld   hl,$61DC
	call Unk_64BF
	ld   a,$06
	ld   hl,$61CF
	call Unk_647F
	ld   a,$D4
	ld   [wUnk_DFE6],a
	ld   a,$61
	ld   [wUnk_DFE7],a
	ld   a,$E0
	ld   [wUnk_DFEE],a
	ld   a,$61
	jr   .unk_625B
	call Unk_64ED
	and  a
	ret  nz
	ld   hl,$DFE4
	ld   c,[hl]
	inc  [hl]
	ld   b,$00
	ld   a,[wUnk_DFE6]
	ld   l,a
	ld   a,[wUnk_DFE7]
	ld   h,a
	add  hl,bc
	ld   a,[hl]
	cp   a,$FF
	jp   z,Unk_62CB
	ld   d,a
	ld   a,[wUnk_DFEE]
	ld   l,a
	ld   a,[wUnk_DFEF]
	ld   h,a
	add  hl,bc
	ld   a,[hl]
	ld   e,a
	ld   c,$08
	cp   a,$00
	jr   z,.unk_62B4
	ld   c,$F2
	ld   a,d
	ldh  [hUnk_FF13],a
	ld   a,c
	ldh  [hUnk_FF12],a
	ld   a,[wUnk_61AA]
	ldh  [hUnk_FF14],a
	ld   a,e
	ldh  [hUnk_FF18],a
	ld   a,c
	ldh  [hUnk_FF17],a
	ld   a,[wUnk_61D2]
	ldh  [hUnk_FF19],a
	ret

	ld   a,[wUnk_DFE1]
	cp   a,$0D
	jr   z,.unk_62D8
	call Unk_6471
	jp   Unk_6153
	ld   a,$0A
	ld   [wUnk_DFE8],a
	jr   .unk_62D2
	inc  [hl]
	add  b
	rst  $20
	add  b
	add  a,$97
	add  a
	add  a
	ld   [hl],a
	ld   h,a
	ld   d,a
	ld   b,a
	scf
	jr   nz,.unk_62FE
	nop
	adc  b
	sub  b
	sbc  b
	and  b
	xor  b
	or   b
	cp   b
	ret  nz
	ret  z
	ret  nc
	call Unk_605D
	ret  z
	ld   a,$05
	ld   hl,$62DF
	jp   Unk_647F
	call Unk_64ED
	and  a
	ret  nz
	ld   hl,$DFE4
	ld   c,[hl]
	inc  [hl]
	ld   b,$00
	ld   hl,$62E4
	add  hl,bc
	ld   a,[hl]
	and  a
	jp   z,Unk_6153
	ld   e,a
	ld   hl,$62EF
	add  hl,bc
	ld   a,[hl]
	ld   d,a
	ld   b,$86
	ld   c,$12
	ld   a,e
	ld   [c],a
	inc  c
	ld   a,d
	ld   [c],a
	inc  c
	ld   a,b
	ld   [c],a
	ret

	ld   l,$80
	and  h
	dec  d
	add  a
	sub  h
	add  h
	ld   h,h
	ld   b,h
	dec  h
	jr   nz,.unk_634A
	stop
	inc  d
	inc  de
	ld   [de],a
	ld   de,$1010
	<corrupted stop>
	call Unk_605D
	ret  z
	ld   a,$03
	ld   hl,$632E
	jp   Unk_647F
	call Unk_64ED
	and  a
	ret  nz
	ld   hl,$DFE4
	ld   c,[hl]
	inc  [hl]
	ld   b,$00
	ld   hl,$6333
	add  hl,bc
	ld   a,[hl]
	and  a
	jp   z,Unk_6153
	ld   e,a
	ld   hl,$633C
	add  hl,bc
	ld   a,[hl]
	ld   d,a
	ld   b,$87
	jr   .unk_6323
	ld   h,$80
	and  h
	ld   b,b
	add  a
	sub  h
	add  h
	ld   h,h
	ld   b,h
	dec  h
	jr   nz,.unk_638C
	stop
	ld   c,b
	ld   d,b
	ld   e,b
	ld   h,b
	ld   l,b
	ld   [hl],b
	ld   [hl],h
	ld   a,b
	call Unk_6058
	ret  z
	ld   a,$04
	ld   hl,$6370
	jp   Unk_647F
	call Unk_64ED
	and  a
	ret  nz
	ld   hl,$DFE4
	ld   c,[hl]
	inc  [hl]
	ld   b,$00
	ld   hl,$6375
	add  hl,bc
	ld   a,[hl]
	and  a
	jp   z,Unk_6153
	ld   e,a
	ld   hl,$637E
	add  hl,bc
	ld   a,[hl]
	ld   d,a
	ld   b,$87
	jp   Unk_6323
	sbc  h
	or   a
	ldh  [hUnk_FF34],a
	call nz,Unk_5DCD
	ld   h,b
	ret  z
	call Unk_6076
	ret  z
	ld   a,$03
	ld   hl,$63B3
	jp   Unk_647F
	jp   Unk_640B
	nop
	ld   h,b
	ld   a,[de]
	add  b
	dec  c
	ld   c,$0F
	inc  e
	dec  e
	ld   e,$1D
	inc  e
	ld   a,$03
	ld   hl,$63CB
	jp   Unk_647F
	call Unk_64ED
	and  a
	ret  nz
	ld   hl,$DFFC
	ld   a,[hl]
	and  a,$07
	ld   c,a
	inc  [hl]
	ld   b,$00
	ld   hl,$63CF
	add  hl,bc
	ld   a,[hl]
	ldh  [hUnk_FF22],a
	ld   a,$80
	ldh  [hUnk_FF23],a
	ret

	nop
	pop  hl
	ld   d,[hl]
	add  b
	ld   a,$18
	ld   hl,$63FA
	jp   Unk_647F
	call Unk_64ED
	and  a
	ret  nz
	xor  a
	ld   [wUnk_DFF9],a
	ld   a,$08
	ldh  [hUnk_FF21],a
	ld   a,$80
	ldh  [hUnk_FF23],a
	ld   hl,wUnk_DFCF
	res  7,[hl]
	ret

	xor  a
	ld   [wUnk_DFF1],a
	ldh  [hUnk_FF1A],a
	ld   hl,wUnk_DFBF
	res  7,[hl]
	ld   hl,wUnk_DF9F
	res  7,[hl]
	ld   hl,wUnk_DFAF
	res  7,[hl]
	ld   hl,wUnk_DFCF
	res  7,[hl]
	ld   a,[wUnk_DFE9]
	cp   a,$05
	jr   z,.unk_6443
	ld   hl,$6BF3
	jr   .unk_646D
	ld   hl,$6BD3
	jr   .unk_646D
	push hl
	ld   [wUnk_DFF1],a
	ld   hl,wUnk_DFBF
	set  7,[hl]
	xor  a
	ld   [wUnk_DFF4],a
	ld   [wUnk_DFF5],a
	ld   [wUnk_DFF6],a
	ldh  [hUnk_FF1A],a
	ld   hl,wUnk_DF9F
	set  7,[hl]
	ld   hl,wUnk_DFAF
	set  7,[hl]
	ld   hl,wUnk_DFCF
	set  7,[hl]
	pop  hl
	call Unk_64FA
	ret

	ld   a,$08
	ldh  [hUnk_FF17],a
	ld   a,$80
	ldh  [hUnk_FF19],a
	ld   hl,wUnk_DFAF
	res  7,[hl]
	ret

	push af
	dec  e
	ld   a,[wUnk_DF71]
	ld   [de],a
	inc  e
	pop  af
	inc  e
	ld   [de],a
	dec  e
	xor  a
	ld   [de],a
	inc  e
	inc  e
	ld   [de],a
	inc  e
	ld   [de],a
	push hl
	ld   a,e
	cp   a,$E5
	jr   z,.unk_64A0
	cp   a,$F5
	jr   z,.unk_64A8
	cp   a,$FD
	jr   z,.unk_64B0
	ret

	ld   hl,wUnk_DF9F
	set  7,[hl]
	pop  hl
	jr   .unk_64B8
	ld   hl,wUnk_DFBF
	set  7,[hl]
	pop  hl
	jr   .unk_64C6
	ld   hl,wUnk_DFCF
	set  7,[hl]
	pop  hl
	jr   .unk_64CD
	push bc
	ld   c,$10
	ld   b,$05
	jr   .unk_64D2
	push bc
	ld   c,$16
	ld   b,$04
	jr   .unk_64D2
	push bc
	ld   c,$1A
	ld   b,$05
	jr   .unk_64D2
	push bc
	ld   c,$20
	ld   b,$04
	ldi  a,[hl]
	ld   [c],a
	inc  c
	dec  b
	jr   nz,.unk_64D2
	pop  bc
	ret

	inc  e
	ld   [wUnk_DF71],a
	inc  e
	dec  a
	sla  a
	ld   c,a
	ld   b,$00
	add  hl,bc
	ld   c,[hl]
	inc  hl
	ld   b,[hl]
	ld   l,c
	ld   h,b
	ld   a,h
	ret

	push de
	ld   l,e
	ld   h,d
	inc  [hl]
	ldi  a,[hl]
	cp   [hl]
	jr   nz,.unk_64F8
	dec  l
	xor  a
	ld   [hl],a
	pop  de
	ret

	push bc
	ld   c,$30
	ldi  a,[hl]
	ld   [c],a
	inc  c
	ld   a,c
	cp   a,$40
	jr   nz,.unk_64FD
	pop  bc
	ret
InitMusic:
	ld   a,$FF
	ldh  [hUnk_FF25],a
	ld   a,$03
	ld   [wUnk_DF78],a
	xor  a
	ld   [wUnk_DFE9],a
	xor  a
	ld   [wUnk_DFE1],a
	ld   [wUnk_DFF1],a
	ld   [wUnk_DFF9],a
	ld   [wUnk_DF9F],a
	ld   [wUnk_DFAF],a
	ld   [wUnk_DFBF],a
	ld   [wUnk_DFCF],a
	ld   [wUnk_DF7E],a
	ld   [wUnk_DF7F],a
	ld   [wUnk_DF8F],a
	ld   [wUnk_DF8D],a
	ld   [wUnk_DF8E],a
	ld   [wUnk_DF8A],a
	ld   [wUnk_DF8B],a
	ld   a,$08
	ldh  [hUnk_FF12],a
	ldh  [hUnk_FF17],a
	ldh  [hUnk_FF21],a
	ld   a,$80
	ldh  [hUnk_FF14],a
	ldh  [hUnk_FF19],a
	ldh  [hUnk_FF23],a
	xor  a
	ldh  [hUnk_FF10],a
	ldh  [hUnk_FF1A],a
	ret

	ld   de,wUnk_DFE0
	ld   a,[de]
	and  a
	jr   z,.unk_6563
	ld   hl,$6000
	call Unk_64DA
	jp   hl
	inc  e
	ld   a,[de]
	and  a
	jr   z,.unk_656F
	ld   hl,$601C
	call Unk_64DE
	jp   hl
	ret

	ld   de,$DFF8
	ld   a,[de]
	and  a
	jr   z,.unk_657E
	ld   hl,$6038
	call Unk_64DA
	jp   hl
	inc  e
	ld   a,[de]
	and  a
	jr   z,.unk_658A
	ld   hl,$603E
	call Unk_64DE
	jp   hl
	ret

	dec  c
	dec  bc
	dec  c
	ld   a,[bc]
	ld   a,[bc]
	ld   a,[bc]
	ld   a,[bc]
	rrca
	ld   a,[bc]
	ld   a,[bc]
	dec  b
	jp   InitMusic
	cp   a,$FF
	jr   z,.unk_6596
	cp   a,$0B
	ret  nc
	push af
	push hl
	ld   hl,$658B
	ld   c,a
	ld   b,$00
	add  hl,bc
	ld   a,[hl]
	ld   [wUnk_DF88],a
	pop  hl
	pop  af
	ld   [hl],a
	ld   b,a
	ld   hl,$6044
	and  a,$1F
	call Unk_64DE
	call Unk_6711
	call Unk_66B9
	ret

	ld   a,[wUnk_DF7F]
	cp   a,$01
	jr   z,.unk_6641
	cp   a,$02
	jp   z,Unk_667A
	ld   a,[wUnk_DF7E]
	and  a
	jp   nz,Unk_6684
	ld   hl,$DFE8
	ldi  a,[hl]
	and  a
	jr   nz,.unk_663C
	ld   a,[wUnk_DF8B]
	and  a
	jr   z,.unk_65E5
	ld   a,$0A
	ld   [wUnk_DFE0],a
	ld   a,[wUnk_DFE0]
	cp   a,$08
	jr   z,.unk_6618
	cp   a,$0A
	jr   z,.unk_6618
	cp   a,$0B
	jr   z,.unk_6618
	ld   a,[wUnk_DFE1]
	cp   a,$08
	jr   z,.unk_6618
	cp   a,$0A
	jr   z,.unk_6618
	cp   a,$0B
	jr   z,.unk_6618
	ld   a,[wUnk_DF8A]
	and  a
	jr   z,.unk_6618
	ld   c,$09
	ld   a,[wUnk_DFE1]
	cp   a,$09
	jr   nz,.unk_6614
	ld   c,$00
	ld   a,c
	ld   [wUnk_DFE0],a
	call Unk_6555
	ld   a,[wUnk_DFE8]
	cp   a,$0A
	jr   z,.unk_65D3
	call Unk_6570
	call Unk_68A7
	xor  a
	ld   [wUnk_DFE0],a
	ld   [wUnk_DFE8],a
	ld   [wUnk_DFF0],a
	ld   [wUnk_DFF8],a
	ld   [wUnk_DF7F],a
	ld   [wUnk_DF8B],a
	ret

	call Unk_6599
	jr   .unk_6625
	call Unk_653F
	xor  a
	ld   [wUnk_DFE1],a
	ld   [wUnk_DFF1],a
	ld   [wUnk_DFF9],a
	ld   hl,wUnk_DF9F
	res  7,[hl]
	ld   hl,wUnk_DFAF
	res  7,[hl]
	ld   hl,wUnk_DFBF
	res  7,[hl]
	ld   hl,wUnk_DFCF
	res  7,[hl]
	ld   hl,$6BF3
	call Unk_64FA
	ld   a,$30
	ld   [wUnk_DF7E],a
	ld   hl,$669C
	call Unk_64BF
	jr   .unk_6628
	ld   hl,$66A0
	jr   .unk_6670
	xor  a
	ld   [wUnk_DF7E],a
	ld   [wUnk_DF8B],a
	jp   Unk_65D3
	ld   hl,wUnk_DF7E
	dec  [hl]
	ld   a,[hl]
	cp   a,$28
	jr   z,.unk_6675
	cp   a,$20
	jr   z,.unk_666D
	cp   a,$18
	jr   z,.unk_6675
	cp   a,$10
	jr   nz,.unk_6628
	inc  [hl]
	jr   .unk_6628
	or   d
	-
	add  e
	rst  $00
	or   d
	-
	pop  bc
	rst  $00
	ld   a,$80
	ldh  [hUnk_FF26],a
	ld   a,$77
	ldh  [hUnk_FF24],a
	ld   a,$FF
	ldh  [hUnk_FF25],a
	ld   hl,$DF00
	ld   [hl],$00
	inc  l
	jr   nz,.unk_66B3
	ret

	ld   a,[wUnk_DFE9]
	ld   hl,$6C80
	dec  a
	jr   z,.unk_66C8
	inc  hl
	inc  hl
	inc  hl
	inc  hl
	jr   .unk_66BF
	ldi  a,[hl]
	ld   [wUnk_DF78],a
	ldi  a,[hl]
	ld   [wUnk_DF7A],a
	ldi  a,[hl]
	ld   [wUnk_DF7C],a
	ldh  [hUnk_FF25],a
	ldi  a,[hl]
	ld   [wUnk_DF7D],a
	xor  a
	ld   [wUnk_DF79],a
	ld   [wUnk_DF7B],a
	ret

	ld   hl,wUnk_DF78
	ldi  a,[hl]
	cp   a,$01
	ret  z
	inc  [hl]
	ldi  a,[hl]
	cp   [hl]
	ret  nz
	dec  l
	ld   [hl],$00
	inc  l
	inc  l
	inc  [hl]
	inc  l
	ldd  a,[hl]
	bit  0,[hl]
	jp   z,Unk_66FD
	inc  l
	inc  l
	ld   a,[hl]
	ldh  [hUnk_FF25],a
	ret

	ldi  a,[hl]
	ld   c,a
	ld   a,[hl]
	ld   b,a
	ld   a,[bc]
	ld   [de],a
	inc  e
	inc  bc
	ld   a,[bc]
	ld   [de],a
	ret

	ldi  a,[hl]
	ld   [de],a
	inc  e
	ldi  a,[hl]
	ld   [de],a
	ret

	call Unk_6514
	ld   de,$DF80
	ld   b,$00
	ldi  a,[hl]
	ld   [de],a
	inc  e
	call Unk_670B
	ld   de,$DF90
	call Unk_670B
	ld   de,$DFA0
	call Unk_670B
	ld   de,$DFB0
	call Unk_670B
	ld   de,$DFC0
	call Unk_670B
	ld   hl,$DF90
	ld   de,$DF94
	call Unk_6700
	ld   hl,$DFA0
	ld   de,$DFA4
	call Unk_6700
	ld   hl,$DFB0
	ld   de,$DFB4
	call Unk_6700
	ld   hl,$DFC0
	ld   de,$DFC4
	call Unk_6700
	ld   bc,$0410
	ld   hl,$DF92
	ld   [hl],$01
	ld   a,c
	add  l
	ld   l,a
	dec  b
	jr   nz,.unk_6761
	xor  a
	ld   [wUnk_DF9E],a
	ld   [wUnk_DFAE],a
	ld   [wUnk_DFBE],a
	ret

	push hl
	xor  a
	ldh  [hUnk_FF1A],a
	ld   l,e
	ld   h,d
	call Unk_64FA
	pop  hl
	jr   .unk_67AA
	call Unk_67B0
	call Unk_67C5
	ld   e,a
	call Unk_67B0
	call Unk_67C5
	ld   d,a
	call Unk_67B0
	call Unk_67C5
	ld   c,a
	inc  l
	inc  l
	ld   [hl],e
	inc  l
	ld   [hl],d
	inc  l
	ld   [hl],c
	dec  l
	dec  l
	dec  l
	dec  l
	push hl
	ld   hl,$DF70
	ld   a,[hl]
	pop  hl
	cp   a,$03
	jr   z,.unk_6774
	call Unk_67B0
	jp   Unk_68D8
	push de
	ldi  a,[hl]
	ld   e,a
	ldd  a,[hl]
	ld   d,a
	inc  de
	ld   a,e
	ldi  [hl],a
	ld   a,d
	ldd  [hl],a
	pop  de
	ret

	push de
	ldi  a,[hl]
	ld   e,a
	ldd  a,[hl]
	ld   d,a
	inc  de
	inc  de
	jr   .unk_67B6
	ldi  a,[hl]
	ld   c,a
	ldd  a,[hl]
	ld   b,a
	ld   a,[bc]
	ld   b,a
	ret

	pop  hl
	jr   .unk_67FB
	ld   a,[wUnk_DF70]
	cp   a,$03
	jr   nz,.unk_67E6
	ld   a,[wUnk_DFB8]
	bit  7,a
	jr   z,.unk_67E6
	ld   a,[hl]
	cp   a,$06
	jr   nz,.unk_67E6
	ld   a,$40
	ldh  [hUnk_FF1C],a
	push hl
	ld   a,l
	add  a,$09
	ld   l,a
	ld   a,[hl]
	and  a
	jr   nz,.unk_67CC
	ld   a,l
	add  a,$04
	ld   l,a
	bit  7,[hl]
	jr   nz,.unk_67CC
	pop  hl
	call Unk_6A32
	dec  l
	dec  l
	jp   Unk_6A04
	dec  l
	dec  l
	dec  l
	dec  l
	call Unk_67BC
	ld   a,l
	add  a,$04
	ld   e,a
	ld   d,h
	call Unk_6700
	cp   a,$00
	jr   z,.unk_6832
	cp   a,$FF
	jr   z,.unk_681B
	inc  l
	jp   Unk_68D6
	dec  l
	push hl
	call Unk_67BC
	call Unk_67C5
	ld   e,a
	call Unk_67B0
	call Unk_67C5
	ld   d,a
	pop  hl
	ld   a,e
	ldi  [hl],a
	ld   a,d
	ldd  [hl],a
	jr   .unk_6807
	ld   hl,$DFE9
	ld   a,[hl]
	cp   a,$0A
	jr   nz,.unk_683F
	ld   a,$01
	ld   [wUnk_Request],a
	ld   [hl],$00
	call InitMusic
	ret

	call Unk_67B0
	call Unk_67C5
	ld   [wUnk_DF81],a
	call Unk_67B0
	call Unk_67C5
	ld   [wUnk_DF82],a
	jr   .unk_6862
	call Unk_67B0
	call Unk_67C5
	ld   [wUnk_DF80],a
	call Unk_67B0
	jr   .unk_68D8
	call Unk_67B0
	call Unk_67C5
	push hl
	ld   a,l
	add  a,$0B
	ld   l,a
	ld   c,[hl]
	ld   a,b
	or   c
	ld   [hl],a
	ld   b,h
	ld   c,l
	dec  c
	dec  c
	pop  hl
	ldi  a,[hl]
	ld   e,a
	ldd  a,[hl]
	ld   d,a
	inc  de
	ld   a,e
	ldi  [hl],a
	ld   a,d
	ldd  [hl],a
	ld   a,d
	ld   [bc],a
	dec  c
	ld   a,e
	ld   [bc],a
	jr   .unk_68D8
	push hl
	ld   a,l
	add  a,$0B
	ld   l,a
	ld   a,[hl]
	dec  [hl]
	ld   a,[hl]
	and  a,$7F
	jr   z,.unk_68A4
	ld   b,h
	ld   c,l
	dec  c
	dec  c
	dec  c
	pop  hl
	ld   a,[bc]
	ldi  [hl],a
	inc  c
	ld   a,[bc]
	ldd  [hl],a
	jr   .unk_68D8
	pop  hl
	jr   .unk_6862
	ld   hl,$DFE9
	ld   a,[hl]
	and  a
	ret  z
	ld   hl,wUnk_DF8D
	ld   a,[wUnk_DF8F]
	cp   a,$03
	jr   nz,.unk_68BE
	inc  [hl]
	jr   nz,.unk_68C1
	inc  l
	inc  [hl]
	jr   .unk_68C1
	xor  a
	ldi  [hl],a
	ld   [hl],a
	call Unk_66E2
	ld   a,$01
	ld   [wUnk_DF70],a
	ld   hl,$DF90
	inc  l
	ldi  a,[hl]
	and  a
	jp   z,Unk_67FB
	dec  [hl]
	jp   nz,Unk_67CF
	inc  l
	inc  l
	call Unk_67C5
	cp   a,$00
	jp   z,Unk_6800
	cp   a,$9D
	jp   z,Unk_6780
	cp   a,$9E
	jp   z,Unk_6845
	cp   a,$9F
	jp   z,Unk_6859
	cp   a,$9B
	jp   z,Unk_6867
	cp   a,$9C
	jp   z,Unk_688B
	and  a,$F0
	cp   a,$A0
	jr   nz,.unk_6919
	ld   a,b
	and  a,$0F
	ld   c,a
	ld   b,$00
	push hl
	ld   de,$DF81
	ld   a,[de]
	ld   l,a
	inc  e
	ld   a,[de]
	ld   h,a
	add  hl,bc
	ld   a,[hl]
	pop  hl
	dec  l
	ldi  [hl],a
	call Unk_67B0
	call Unk_67C5
	ld   c,b
	ld   b,$00
	call Unk_67B0
	ld   a,[wUnk_DF70]
	cp   a,$04
	jp   z,Unk_6984
	push hl
	ld   a,l
	add  a,$05
	ld   l,a
	ld   e,l
	ld   d,h
	inc  l
	inc  l
	ld   a,c
	cp   a,$01
	jr   z,.unk_697F
	ld   [hl],$00
	ld   a,[wUnk_DF80]
	and  a
	jr   z,.unk_6949
	ld   l,a
	ld   h,$00
	bit  7,l
	jr   z,.unk_6946
	ld   h,$FF
	add  hl,bc
	ld   b,h
	ld   c,l
	ld   a,[wUnk_DF8F]
	and  a
	jr   z,.unk_6972
	inc  bc
	inc  bc
	cp   a,$01
	jr   z,.unk_6972
	inc  bc
	inc  bc
	cp   a,$02
	jr   z,.unk_6972
	cp   a,$03
	jr   c,.unk_6972
	inc  bc
	inc  bc
	ld   a,[wUnk_DF8E]
	and  a
	jr   z,.unk_6972
	cp   a,$1F
	jr   c,.unk_696D
	ld   a,$1F
	inc  bc
	inc  bc
	dec  a
	jr   nz,.unk_696D
	ld   hl,$6B12
	add  hl,bc
	ldi  a,[hl]
	ld   [de],a
	inc  e
	ld   a,[hl]
	ld   [de],a
	pop  hl
	jp   Unk_699B
	ld   [hl],$01
	pop  hl
	jr   .unk_699B
	push hl
	ld   de,$DFC6
	ld   hl,$6BA4
	add  hl,bc
	ldi  a,[hl]
	ld   [de],a
	inc  e
	ld   a,e
	cp   a,$CB
	jr   nz,.unk_698C
	ld   c,$20
	ld   hl,$DFC4
	jr   .unk_69D2
	push hl
	ld   a,[wUnk_DF70]
	cp   a,$01
	jr   z,.unk_69CD
	cp   a,$02
	jr   z,.unk_69C9
	ld   c,$1A
	ld   a,[wUnk_DFBF]
	bit  7,a
	jr   nz,.unk_69B5
	xor  a
	ld   [c],a
	ld   a,$80
	ld   [c],a
	inc  c
	inc  l
	inc  l
	inc  l
	inc  l
	ldi  a,[hl]
	ld   e,a
	ld   d,$00
	ld   a,[wUnk_DFB8]
	bit  7,a
	jr   z,.unk_69DE
	ld   d,$EF
	jr   .unk_69DE
	ld   c,$16
	jr   .unk_69D2
	ld   c,$10
	ld   a,$00
	inc  c
	inc  l
	inc  l
	inc  l
	ldd  a,[hl]
	and  a
	jr   nz,.unk_6A22
	ldi  a,[hl]
	ld   e,a
	inc  l
	ldi  a,[hl]
	ld   d,a
	push hl
	inc  l
	inc  l
	ldi  a,[hl]
	and  a
	jr   z,.unk_69E7
	ld   e,$08
	inc  l
	inc  l
	ld   [hl],$00
	inc  l
	ld   a,[hl]
	pop  hl
	bit  7,a
	jr   nz,.unk_69FF
	ld   a,d
	ld   [c],a
	inc  c
	ld   a,e
	ld   [c],a
	inc  c
	ldi  a,[hl]
	ld   [c],a
	inc  c
	ld   a,[hl]
	or   a,$C0
	ld   [c],a
	pop  hl
	dec  l
	ldd  a,[hl]
	ldd  [hl],a
	dec  l
	ld   de,$DF70
	ld   a,[de]
	cp   a,$04
	jr   z,.unk_6A15
	inc  a
	ld   [de],a
	ld   a,$10
	add  l
	ld   l,a
	jp   Unk_68CC
	ld   hl,$DF9E
	inc  [hl]
	ld   hl,$DFAE
	inc  [hl]
	ld   hl,$DFBE
	inc  [hl]
	ret

	ld   b,$00
	push hl
	pop  hl
	inc  l
	jr   .unk_69DB
	ld   a,b
	srl  a
	ld   l,a
	ld   h,$00
	add  hl,de
	ld   e,[hl]
	ret

	push hl
	ld   a,l
	add  a,$06
	ld   l,a
	ld   a,[hl]
	and  a,$0F
	jr   z,.unk_6A54
	ld   [wUnk_DF71],a
	ld   a,[wUnk_DF70]
	ld   c,$13
	cp   a,$01
	jr   z,.unk_6A56
	ld   c,$18
	cp   a,$02
	jr   z,.unk_6A56
	ld   c,$1D
	cp   a,$03
	jr   z,.unk_6A56
	pop  hl
	ret

	inc  l
	ldi  a,[hl]
	ld   e,a
	ld   a,[hl]
	ld   d,a
	push de
	ld   a,l
	add  a,$04
	ld   l,a
	ld   b,[hl]
	ld   a,[wUnk_DF71]
	cp   a,$01
	jr   z,.unk_6A7A
	cp   a,$02
	jr   z,.unk_6A75
	cp   a,$03
	jr   z,.unk_6A70
	ld   hl,$FFFE
	jr   .unk_6A96
	ld   de,$6A9F
	jr   .unk_6A7D
	ld   de,$6ABD
	call Unk_6A29
	bit  0,b
	jr   nz,.unk_6A86
	swap e
	ld   a,e
	and  a,$0F
	bit  3,a
	jr   z,.unk_6A93
	ld   h,$FF
	or   a,$F0
	jr   .unk_6A95
	ld   h,$00
	ld   l,a
	pop  de
	add  hl,de
	ld   a,l
	ld   [c],a
	inc  c
	ld   a,h
	ld   [c],a
	jr   .unk_6A54
	nop
	rst  $38
	rst  $38
	cp   a,$EE
	-
	-
	call c,Unk_CCCC
	call z,Unk_BBBB
	cp   e
	cp   d
	xor  d
	xor  d
	xor  d
	xor  d
	sbc  c
	sbc  c
	sbc  c
	sbc  c
	sbc  c
	sbc  c
	sbc  c
	sbc  c
	sbc  c
	sbc  c
	sbc  c
	nop
	nop
	nop
	nop
	nop
	nop
	stop
	rrca
	nop
	nop
	ld   de,$0F00
	ldh  a,[rSB]
	ld   [de],a
	<corrupted stop>
	rst  $28
	ld   bc,$1012
	rst  $38
	rst  $28
	ld   bc,$1012
	rst  $38
	rst  $28
	ld   bc,$1012
	rst  $38
	rst  $28
	ld   bc,$1012
	rst  $38
	rst  $28
	ld   bc,$1012
	rst  $38
	rst  $28
	ld   bc,$1012
	rst  $38
	rst  $28
	ld   bc,$1012
	rst  $38
	rst  $28
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rrca
	inc  l
	nop
	sbc  h
	nop
	ld   b,$01
	ld   l,e
	ld   bc,$01C9
	inc  hl
	ld   [bc],a
	ld   [hl],a
	ld   [bc],a
	add  a,$02
	ld   [de],a
	inc  bc
	ld   d,[hl]
	inc  bc
	sbc  e
	inc  bc
	jp   c,Unk_1603
	inc  b
	ld   c,[hl]
	inc  b
	add  e
	inc  b
	or   l
	inc  b
	push hl
	inc  b
	ld   de,$3B05
	dec  b
	ld   h,e
	dec  b
	adc  c
	dec  b
	xor  h
	dec  b
	adc  a,$05
	-
	dec  b
	ld   a,[bc]
	ld   b,$27
	ld   b,$42
	ld   b,$5B
	ld   b,$72
	ld   b,$89
	ld   b,$9E
	ld   b,$B2
	ld   b,$C4
	ld   b,$D6
	ld   b,$E7
	ld   b,$F7
	ld   b,$06
	rlca
	inc  d
	rlca
	ld   hl,$2D07
	rlca
	add  hl,sp
	rlca
	ld   b,h
	rlca
	ld   c,a
	rlca
	ld   e,c
	rlca
	ld   h,d
	rlca
	ld   l,e
	rlca
	ld   [hl],e
	rlca
	ld   a,e
	rlca
	add  e
	rlca
	adc  d
	rlca
	sub  b
	rlca
	sub  a
	rlca
	sbc  l
	rlca
	and  d
	rlca
	and  a
	rlca
	xor  h
	rlca
	or   c
	rlca
	or   [hl]
	rlca
	cp   d
	rlca
	cp   [hl]
	rlca
	pop  bc
	rlca
	call nz,Unk_C807
	rlca
	rlc  a
	adc  a,$07
	pop  de
	rlca
	call nc,Unk_D607
	rlca
	reti
	rlca
	-
	rlca
	-
	rlca
	rst  $18
	rlca
	nop
	nop
	nop
	nop
	nop
	ret  nz
	ld   h,c
	nop
	ldd  a,[hl]
	nop
	ret  nz
	or   c
	nop
	add  hl,hl
	ld   bc,$A1C0
	nop
	jr   nz,.unk_6BBC
	ret  nz
	and  c
	nop
	-
	ld   e,[hl]
	ret  nz
	ld   [hl],c
	nop
	nop
	ccf
	ret  nz
	inc  hl
	inc  sp
	ld   b,l
	ld   h,a
	adc  c
	xor  e
	call Unk_FEEF
	call c,Unk_98BA
	adc  d
	xor  b
	ldd  [hl],a
	<corrupted stop>
	inc  hl
	ld   b,l
	ld   h,a
	adc  c
	xor  e
	call Unk_FEEF
	call c,Unk_98BA
	halt
	ld   d,h
	ldd  [hl],a
	<corrupted stop>
	inc  hl
	ld   d,[hl]
	ld   a,b
	sbc  c
	sbc  b
	halt
	ld   h,a
	sbc  d
	rst  $18
	cp   a,$C9
	add  l
	ld   [hl],a
	ld   [hl],a
	ld   [hl],a
	ld   de,$5623
	ld   a,b
	sbc  c
	sbc  b
	halt
	ld   h,a
	sbc  d
	rst  $18
	cp   a,$C9
	add  l
	ld   b,d
	ld   de,$1131
	ld   [de],a
	ldi  [hl],a
	inc  sp
	inc  [hl]
	ld   b,h
	ld   d,l
	ld   d,l
	ld   h,[hl]
	ld   h,[hl]
	ld   h,[hl]
	ld   h,[hl]
	ld   h,[hl]
	ld   de,$3222
	add  a
	ld   h,[hl]
	ld   h,l
	ld   d,l
	ld   d,h
	ld   b,h
	ld   b,e
	ldd  [hl],a
	ldi  [hl],a
	ld   de,$6611
	ld   h,c
	ld   de,$6666
	ld   bc,$0402
	ld   [wUnk_2010],sp
	ld   b,$0C
	jr   .unk_6C2D
	inc  bc
	ld   b,$0C
	jr   .unk_6C62
	add  hl,bc
	ld   [de],a
	inc  h
	inc  b
	ld   [wUnk_0402],sp
	ld   [wUnk_2010],sp
	ld   b,b
	inc  c
	jr   .unk_6C70
	dec  b
	nop
	ld   bc,$0503
	ld   a,[bc]
	inc  d
	jr   z,.unk_6C99
	rrca
	ld   e,$3C
	inc  bc
	ld   b,$0C
	jr   .unk_6C81
	ld   h,b
	ld   [de],a
	inc  h
	ld   c,b
	ld   [wUnk_0110],sp
	inc  b
	ld   [bc],a
	inc  bc
	rlca
	ld   c,$1C
	jr   c,.unk_6CD0
	dec  d
	ldi  a,[hl]
	ld   d,h
	add  hl,bc
	ld   [de],a
	ld   bc,$0402
	ld   [wUnk_2010],sp
	ld   b,b
	add  b
	jr   .unk_6C9F
	ld   h,b
	ld   a,[bc]
	dec  d
	ld   bc,$C002
	inc  b
	add  hl,bc
	ld   [de],a
	inc  h
	ld   c,b
	sub  b
	dec  de
	ld   [hl],$6C
	inc  c
	jr   .unk_6C82
	jr   .unk_6C82
	ei
	ld   bc,$FF18
	-
	ld   bc,$ED20
	or   a
	ld   bc,$DE60
	-
	ld   bc,$DEFF
	rst  $38
	ld   bc,$FE18
	cp   [hl]
	ld   bc,rLCDC
	rst  $30
	ld   bc,$ED18
	rst  $20
	ld   bc,$FF20
	rst  $30
	ld   bc,$FF20
	rst  $30
	nop
	ld   c,h
	ld   l,h
	pop  hl
	ld   l,l
	rst  $30
	ld   l,l
	dec  c
	ld   l,[hl]
	inc  hl
	ld   l,[hl]
	nop
	ld   e,d
	ld   l,h
	ld   [wUnk_0472],a
	ld   [hl],e
	ld   a,[de]
	ld   [hl],e
	inc  l
	ld   [hl],e
	nop
	ld   c,h
	ld   l,h
	ld   [wUnk_1479],sp
	ld   a,c
	jr   nz,.unk_6D40
	inc  l
	ld   a,c
	nop
	ld   c,h
	ld   l,h
	and  d
	ld   a,d
	and  [hl]
	ld   a,d
	xor  b
	ld   a,d
	xor  d
	ld   a,d
	nop
	ld   c,h
	ld   l,h
	ld   b,$7B
	ld   a,[bc]
	ld   a,e
	inc  c
	ld   a,e
	ld   c,$7B
	nop
	ld   c,h
	ld   l,h
	ld   c,c
	ld   a,e
	ld   d,a
	ld   a,e
	ld   h,e
	ld   a,e
	ld   l,l
	ld   a,e
	nop
	ld   c,h
	ld   l,h
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld   c,h
	ld   l,h
	sbc  h
	ld   a,l
	and  b
	ld   a,l
	and  d
	ld   a,l
	and  h
	ld   a,l
	nop
	ld   h,a
	ld   l,h
	-
	ld   a,l
	inc  c
	ld   a,[hl]
	inc  l
	ld   a,[hl]
	ld   c,h
	ld   a,[hl]
	nop
	inc  l
	ld   l,h
	ld   d,$6D
	ld   a,[de]
	ld   l,l
	inc  e
	ld   l,l
	ld   e,$6D
	jr   nz,.unk_6D85
	nop
	nop
	ld   h,d
	ld   l,l
	sbc  c
	ld   l,l
	add  a,$6D
	sbc  l
	ld   [hl],d
	nop
	add  b
	and  e
	inc  a
	inc  a
	inc  a
	and  d
	ld   [hl],$A3
	inc  a
	inc  a
	and  d
	ld   [hl],$3C
	ld   [hl],$A3
	inc  a
	and  e
	ldd  a,[hl]
	ldd  a,[hl]
	ldd  a,[hl]
	and  d
	ldd  [hl],a
	and  e
	ldd  a,[hl]
	ldd  a,[hl]
	and  d
	ldd  [hl],a
	ldd  a,[hl]
	ldd  [hl],a
	and  e
	ldd  a,[hl]
	and  e
	inc  a
	inc  a
	inc  a
	and  d
	ld   [hl],$A3
	inc  a
	inc  a
	and  d
	ld   [hl],$3C
	ld   [hl],$A3
	inc  a
	and  d
	ld   b,b
	ld   c,[hl]
	ld   bc,$AA4E
	ld   c,[hl]
	ld   c,d
	ld   c,b
	and  d
	ld   e,b
	ldd  a,[hl]
	ld   bc,$A43A
	ldd  [hl],a
	nop
	sbc  l
	sub  d
	nop
	add  b
	and  e
	ld   c,d
	ld   c,d
	ld   c,d
	and  d
	ld   bc,$014A
	and  a
	ld   c,d
	and  e
	ld   c,d
	ld   c,d
	and  e
	ld   c,b
	ld   c,b
	ld   c,b
	and  d
	ld   bc,$0148
	and  a
	ld   c,b
	and  e
	ld   c,b
	ld   c,b
	ld   c,d
	ld   c,d
	ld   c,d
	and  d
	ld   bc,$014A
	and  a
	ld   c,d
	and  e
	ld   c,d
	ld   c,d
	and  d
	ld   c,b
	ld   d,h
	ld   bc,$AA54
	ld   d,h
	ld   d,d
	ld   c,[hl]
	and  h
	ld   c,d
	ld   bc,$9D00
	di
	ld   l,e
	jr   nz,.unk_6D42
	ld   [hl],$A7
	inc  l
	ld   [hl],$A3
	ld   bc,$362C
	and  h
	ldd  [hl],a
	and  a
	ldi  [hl],a
	ldd  [hl],a
	and  e
	ld   bc,$3222
	and  h
	ld   [hl],$A7
	inc  l
	ld   [hl],$A3
	ld   bc,$362C
	and  a
	ld   b,b
	and  d
	ld   b,b
	xor  d
	ld   b,b
	ld   b,h
	ld   c,b
	and  e
	ld   c,d
	ld   b,b
	and  h
	ldd  [hl],a
	nop
	sbc  e
	ld   b,$A2
	ld   b,$06
	and  e
	dec  bc
	and  d
	ld   b,$06
	and  e
	dec  bc
	sbc  h
	and  a
	ld   b,$A2
	ld   b,$AA
	dec  bc
	dec  bc
	dec  bc
	and  e
	ld   b,$06
	and  h
	dec  bc
	nop
	ld   l,$72
	add  hl,sp
	ld   l,[hl]
	xor  d
	ld   l,a
	ld   h,$71
	rst  $10
	ld   l,a
	cp   l
	ld   [hl],c
	cp   l
	ld   [hl],c
	ld   l,d
	ld   [hl],d
	sub  h
	ld   [hl],d
	rst  $38
	rst  $38
	-
	ld   l,l
	ccf
	ld   [hl],d
	or   l
	ld   l,[hl]
	add  hl,de
	ld   [hl],b
	ld   d,e
	ld   [hl],c
	ld   a,$70
	sub  a,$71
	sub  a,$71
	ld   l,d
	ld   [hl],d
	xor  l
	ld   [hl],d
	rst  $38
	rst  $38
	ld   sp,hl
	ld   l,l
	ld   d,b
	ld   [hl],d
	dec  l
	ld   l,a
	ld   a,d
	ld   [hl],b
	ld   [hl],h
	ld   [hl],c
	and  a
	ld   [hl],b
	rst  $28
	ld   [hl],c
	rst  $28
	ld   [hl],c
	ld   a,b
	ld   [hl],d
	pop  bc
	ld   [hl],d
	rst  $38
	rst  $38
	rrca
	ld   l,[hl]
	ld   h,c
	ld   [hl],d
	ld   a,d
	ld   l,a
	xor  a,$70
	or   b
	ld   [hl],c
	ld   a,[wUnk_0470]
	ld   [hl],d
	add  hl,de
	ld   [hl],d
	add  [hl]
	ld   [hl],d
	pop  de
	ld   [hl],d
	rst  $38
	rst  $38
	dec  h
	ld   l,[hl]
	sbc  l
	ld   [hl],c
	nop
	add  b
	and  d
	ld   [hl],$3A
	ld   [hl],$3A
	ldd  a,[hl]
	jr   c,.unk_6E7B
	ldd  [hl],a
	ld   [hl],$3A
	ld   [hl],$36
	ldd  a,[hl]
	ld   bc,$919D
	nop
	add  b
	and  b
	ld   bc,$2628
	inc  h
	ldi  [hl],a
	jr   nz,.unk_6E59
	ld   bc,$719D
	nop
	add  b
	and  d
	ld   [hl],$3A
	jr   c,.unk_6E9C
	ldd  a,[hl]
	jr   c,.unk_6E9B
	ldd  a,[hl]
	sbc  l
	add  c
	nop
	add  b
	sbc  e
	inc  b
	and  c
	jr   z,.unk_6E97
	and  d
	jr   z,.unk_6E0E
	sbc  l
	ld   [hl],c
	nop
	add  b
	and  d
	ld   [hl],$3A
	ld   [hl],$3A
	ldd  a,[hl]
	jr   c,.unk_6EB4
	ldd  [hl],a
	ld   [hl],$3A
	ld   [hl],$36
	ldd  a,[hl]
	ld   bc,$0101
	ld   [hl],$3A
	ld   [hl],$3A
	ldd  a,[hl]
	ldd  a,[hl]
	ldd  a,[hl]
	ldd  a,[hl]
	sbc  l
	dec  sp
	nop
	add  b
	and  b
	ld   bc,$0172
	ld   h,[hl]
	ld   bc,$6001
	ld   bc,$4A01
	ld   bc,$365C
	ld   bc,$0101
	ld   a,[hl]
	ld   [hl],d
	ld   l,d
	ld   b,h
	ld   bc,$663E
	ld   bc,$4C50
	ld   c,b
	ld   b,h
	ld   b,[hl]
	ld   b,b
	ld   bc,$0001
	sbc  l
	add  c
	nop
	add  b
	and  d
	ld   e,[hl]
	ld   h,b
	ld   e,[hl]
	ld   h,b
	ld   e,h
	ld   e,b
	ld   e,b
	ld   e,h
	ld   e,[hl]
	ld   h,b
	ld   e,h
	ld   e,b
	ld   e,b
	ld   bc,$919D
	nop
	add  b
	and  b
	ld   bc,$0E10
	inc  c
	ld   a,[bc]
	ld   [wUnk_0101],sp
	sbc  l
	add  c
	nop
	add  b
	and  d
	ld   e,[hl]
	ld   h,b
	ld   e,[hl]
	ld   h,b
	ld   e,h
	ld   e,b
	ld   e,b
	ld   e,h
	sbc  l
	and  c
	nop
	add  b
	and  c
	jr   .unk_6F01
	and  d
	jr   .unk_6E8D
	ld   a,[de]
	ld   a,[de]
	and  d
	ld   a,[de]
	and  c
	inc  e
	inc  e
	and  d
	inc  e
	and  c
	ld   e,$1E
	and  d
	ld   e,$9D
	add  c
	nop
	add  b
	and  d
	ld   e,[hl]
	ld   h,b
	ld   e,[hl]
	ld   h,b
	ld   e,h
	ld   e,b
	ld   e,b
	ld   e,h
	ld   e,[hl]
	ld   h,b
	ld   e,h
	ld   e,b
	ld   e,b
	ld   bc,$0101
	ld   e,[hl]
	ld   h,b
	ld   e,[hl]
	ld   h,b
	ld   e,h
	ld   e,b
	ld   e,b
	ld   e,h
	sbc  l
	ld   [hl],d
	nop
	add  b
	and  c
	ld   a,[hl]
	ld   [hl],d
	ld   l,d
	ld   l,b
	ld   bc,$6672
	ld   bc,$4C50
	ld   bc,$0144
	ld   bc,$0101
	nop
	sbc  l
	di
	ld   l,e
	and  b
	and  d
	ld   e,b
	ld   e,b
	ld   e,[hl]
	ld   h,b
	ld   c,d
	ld   c,d
	ld   d,b
	ld   d,d
	ld   e,b
	ld   e,b
	ld   e,[hl]
	ld   h,b
	ld   c,d
	ld   bc,$0101
	ld   e,b
	ld   e,b
	ld   e,[hl]
	ld   h,b
	ld   c,d
	ld   c,d
	ld   d,b
	ld   d,d
	and  c
	jr   z,.unk_6F75
	and  d
	jr   z,.unk_6EF1
	inc  l
	inc  l
	and  d
	inc  l
	and  c
	ld   l,$2E
	and  d
	ld   l,$A1
	jr   nc,.unk_6F8C
	and  d
	jr   nc,.unk_6F01
	ld   e,b
	ld   e,b
	ld   e,[hl]
	ld   h,b
	ld   c,d
	ld   c,d
	ld   d,b
	ld   d,d
	ld   e,b
	ld   e,b
	ld   e,[hl]
	ld   h,b
	ld   c,d
	ld   bc,$0101
	ld   e,b
	ld   e,b
	ld   e,[hl]
	ld   h,b
	ld   c,d
	ld   c,d
	ld   d,b
	ld   d,d
	and  l
	ld   bc,$9B00
	ld   b,$A1
	dec  bc
	ld   b,$0B
	ld   bc,$A39C
	ld   bc,$9B15
	inc  b
	and  c
	dec  bc
	ld   b,$0B
	ld   bc,$A39C
	ld   a,[de]
	dec  d
	ld   a,[de]
	dec  d
	sbc  e
	ld   b,$A1
	dec  bc
	ld   b,$0B
	ld   bc,$A39C
	dec  d
	ld   bc,$049B
	and  c
	dec  bc
	ld   b,$0B
	ld   bc,$A89C
	dec  d
	and  e
	ld   a,[de]
	nop
	sbc  l
	ld   [hl],c
	nop
	add  b
	and  c
	ld   b,b
	ld   b,b
	and  d
	ld   b,b
	ld   b,b
	ld   b,b
	inc  a
	ld   b,[hl]
	ld   b,h
	inc  a
	and  c
	ld   b,b
	ld   b,b
	and  d
	ld   b,b
	ld   b,b
	ld   b,b
	ld   b,h
	ld   bc,$0101
	and  c
	ld   b,b
	ld   b,b
	and  d
	ld   b,b
	ld   b,b
	ld   b,b
	inc  a
	ld   b,[hl]
	ld   b,h
	inc  a
	inc  l
	ld   bc,$3E01
	ld   b,b
	ld   bc,$013C
	sbc  l
	ld   [hl],c
	nop
	add  b
	and  c
	jr   z,.unk_7006
	and  d
	ldd  [hl],a
	jr   nc,.unk_7010
	inc  l
	ld   bc,$929D
	nop
	nop
	and  e
	inc  h
	sbc  l
	ld   [hl],c
	nop
	add  b
	and  c
	jr   z,.unk_7019
	and  d
	ldd  [hl],a
	jr   nc,.unk_7023
	inc  l
	ld   bc,$929D
	nop
	nop
	and  e
	ld   h,$9D
	ld   [hl],c
	nop
	add  b
	and  c
	jr   z,.unk_702C
	and  d
	jr   z,.unk_702F
	jr   z,.unk_702D
	inc  h
	inc  h
	inc  h
	inc  h
	ld   bc,$0124
	ldi  [hl],a
	ld   bc,$929D
	nop
	ret  nz
	ld   a,[de]
	ld   bc,$9D00
	add  c
	nop
	add  b
	and  d
	ld   d,b
	ld   d,d
	ld   d,b
	ld   d,d
	ld   c,[hl]
	ld   c,d
	ld   c,d
	ld   b,h
	ld   d,b
	ld   d,d
	ld   c,[hl]
	ld   c,d
	ld   c,d
	ld   bc,$0101
	ld   d,b
	ld   d,d
	ld   d,b
	ld   d,d
	ld   c,[hl]
	ld   c,d
	ld   c,d
	ld   b,h
	ld   a,$44
	ld   c,b
	ld   c,[hl]
	ld   c,d
	ld   bc,$0148
	sbc  l
	sub  c
	nop
	add  b
	and  d
	ld   d,b
	ld   d,d
	ld   c,[hl]
	ld   c,d
	ld   c,d
	ld   bc,$A29D
	nop
	nop
	and  e
	inc  c
	sbc  l
	sub  c
	nop
	add  b
	and  d
	ld   d,b
	ld   d,d
	ld   c,[hl]
	ld   c,d
	ld   c,d
	ld   bc,$A29D
	nop
	nop
	and  e
	ld   c,$9D
	sub  c
	nop
	add  b
	and  d
	ld   d,b
	ld   d,d
	ld   d,b
	ld   d,d
	ld   c,[hl]
	ld   c,d
	ld   c,d
	ld   b,h
	ld   c,d
	ld   bc,$014E
	ld   c,d
	ld   bc,$A29D
	nop
	ret  nz
	ld   [bc],a
	ld   bc,$A200
	ldd  [hl],a
	ldd  [hl],a
	jr   c,.unk_70B9
	and  c
	inc  h
	inc  h
	and  d
	inc  h
	ldi  a,[hl]
	inc  l
	ldd  [hl],a
	ldd  [hl],a
	jr   c,.unk_70C4
	and  c
	inc  h
	inc  h
	and  d
	ldi  a,[hl]
	inc  l
	inc  [hl]
	ldd  [hl],a
	ldd  [hl],a
	jr   c,.unk_70CF
	and  c
	inc  h
	inc  h
	and  d
	inc  h
	ldi  a,[hl]
	inc  l
	ld   [hl],$36
	ld   a,$44
	and  c
	ld   b,b
	ld   b,b
	and  d
	ld   b,b
	ld   b,b
	ld   b,b
	sbc  l
	di
	ld   l,e
	and  b
	and  c
	ldd  [hl],a
	ldd  [hl],a
	and  d
	ldd  [hl],a
	jr   c,.unk_70EC
	inc  a
	ld   bc,$F39D
	ld   l,e
	jr   nz,.unk_705C
	inc  h
	sbc  l
	di
	ld   l,e
	and  b
	and  c
	ldd  [hl],a
	ldd  [hl],a
	and  d
	ldd  [hl],a
	jr   c,.unk_70FF
	inc  a
	ld   bc,$F39D
	ld   l,e
	jr   nz,.unk_706F
	ld   h,$9D
	di
	ld   l,e
	and  b
	and  c
	ldd  a,[hl]
	ldd  a,[hl]
	and  d
	ldd  a,[hl]
	ldd  a,[hl]
	ldd  a,[hl]
	ld   [hl],$36
	ld   [hl],$36
	sbc  e
	ld   [bc],a
	and  c
	ld   b,b
	ld   b,b
	ld   b,b
	ld   bc,$A29C
	ldd  [hl],a
	ld   bc,$F39D
	ld   l,e
	jr   nz,.unk_708F
	ldd  [hl],a
	nop
	sbc  e
	ld   [wUnk_15A1],sp
	ld   b,$0B
	ld   bc,$061A
	dec  d
	ld   bc,$9B9C
	ld   [bc],a
	and  c
	dec  d
	ld   b,$0B
	ld   bc,$061A
	dec  d
	ld   bc,$1AA1
	ld   bc,$0101
	dec  d
	ld   bc,$0101
	sbc  h
	sbc  e
	ld   [bc],a
	and  c
	dec  d
	ld   b,$0B
	ld   bc,$061A
	dec  d
	ld   bc,$A39C
	dec  d
	ld   a,[de]
	and  d
	dec  d
	and  c
	dec  d
	dec  d
	and  e
	ld   a,[de]
	nop
	sbc  l
	ld   [hl],d
	nop
	ret  nz
	sbc  e
	inc  bc
	and  d
	ldd  [hl],a
	jr   z,.unk_7162
	ld   [hl],$32
	jr   z,.unk_7174
	jr   z,.unk_70D2
	inc  a
	inc  h
	ldd  [hl],a
	ld   [hl],$32
	inc  h
	jr   nc,.unk_7162
	sbc  e
	inc  bc
	and  d
	ldd  [hl],a
	jr   z,.unk_7176
	ld   [hl],$32
	jr   z,.unk_7188
	jr   z,.unk_70E6
	inc  a
	inc  h
	ldd  [hl],a
	ld   [hl],$32
	inc  h
	jr   nc,.unk_7176
	nop
	sbc  l
	sub  [hl]
	nop
	pop  bc
	and  h
	ldi  [hl],a
	and  e
	ld   e,$28
	and  l
	ld   a,[de]
	and  h
	inc  l
	and  e
	jr   z,.unk_7195
	and  l
	inc  h
	and  h
	ldi  [hl],a
	and  e
	ld   e,$28
	and  l
	ld   a,[de]
	and  h
	inc  l
	and  e
	jr   z,.unk_71A1
	and  l
	ldd  [hl],a
	nop
	sbc  e
	ld   [bc],a
	and  d
	ldd  [hl],a
	ldd  [hl],a
	ld   b,b
	and  c
	ldd  [hl],a
	ldd  [hl],a
	and  d
	jr   nc,.unk_71B0
	ld   b,b
	and  c
	jr   nc,.unk_71B4
	and  d
	inc  l
	inc  l
	ld   b,b
	and  c
	inc  l
	inc  l
	and  d
	jr   z,.unk_71B6
	ld   b,b
	and  c
	jr   z,.unk_71BA
	and  d
	inc  h
	inc  h
	inc  a
	and  c
	inc  h
	inc  h
	and  d
	ldi  [hl],a
	ldi  [hl],a
	inc  a
	and  c
	ldi  [hl],a
	ldi  [hl],a
	and  d
	ld   [hl],$36
	ld   [hl],$A1
	ld   [hl],$36
	and  d
	jr   z,.unk_71D2
	jr   z,.unk_714D
	jr   z,.unk_71D6
	sbc  h
	nop
	sbc  e
	<corrupted stop>
	ld   b,$06
	dec  bc
	ld   bc,$0610
	ld   b,$06
	sbc  h
	nop
	sbc  l
	add  c
	nop
	ret  nz
	sbc  e
	inc  bc
	and  d
	ld   [bc],a
	ld   [bc],a
	ld   [wUnk_0C0A],sp
	inc  c
	ld   c,$10
	sbc  h
	jr   nz,.unk_71D5
	inc  e
	ld   a,[de]
	jr   .unk_71E9
	inc  d
	ld   [de],a
	nop
	sbc  l
	add  c
	nop
	ret  nz
	sbc  e
	inc  bc
	and  d
	ld   [bc],a
	ld   [bc],a
	ld   [wUnk_0C0A],sp
	inc  c
	ld   c,$10
	sbc  h
	jr   nz,.unk_7206
	inc  e
	ld   a,[de]
	jr   .unk_7202
	inc  d
	ld   [de],a
	nop
	sbc  e
	inc  bc
	and  d
	ld   a,[de]
	ld   a,[de]
	jr   nz,.unk_7218
	inc  h
	inc  h
	ld   h,$28
	sbc  h
	jr   c,.unk_7233
	inc  [hl]
	ldd  [hl],a
	jr   nc,.unk_722F
	inc  l
	ldi  a,[hl]
	nop
	sbc  e
	ld   [bc],a
	and  d
	dec  d
	dec  d
	ld   b,$01
	ld   b,$01
	ld   b,$01
	dec  d
	ld   b,$1A
	ld   a,[de]
	ld   bc,$0601
	<corrupted stop>
	nop
	sbc  e
	ld   [bc],a
	and  d
	dec  d
	ld   b,$1A
	ld   a,[de]
	dec  d
	dec  d
	ld   a,[de]
	<corrupted stop>
	ld   b,$1A
	ld   a,[de]
	dec  d
	ld   bc,$101A
	sbc  h
	nop
	sbc  l
	ld   [hl],c
	nop
	add  b
	sbc  e
	ld   [bc],a
	and  d
	<corrupted stop>
	ld   d,$18
	ld   a,[de]
	jr   .unk_7252
	inc  d
	sbc  h
	nop
	sbc  l
	ld   [hl],c
	nop
	add  b
	sbc  e
	ld   [bc],a
	and  d
	<corrupted stop>
	ld   d,$18
	ld   a,[de]
	jr   .unk_7263
	inc  d
	sbc  h
	nop
	sbc  l
	di
	ld   l,e
	jr   nz,.unk_71F0
	ld   [bc],a
	and  d
	jr   z,.unk_7281
	ld   l,$30
	ldd  [hl],a
	jr   nc,.unk_728C
	inc  l
	sbc  h
	nop
	sbc  e
	ld   [bc],a
	and  d
	dec  d
	dec  d
	xor  b
	ld   bc,$009C
	sbc  e
	inc  bc
	and  d
	<corrupted stop>
	xor  b
	ld   bc,$A29C
	ld   [de],a
	ld   bc,$01A8
	nop
	sbc  e
	inc  bc
	and  d
	jr   z,.unk_72A3
	xor  b
	ld   bc,$A29C
	ldi  a,[hl]
	ld   bc,$01A8
	nop
	sbc  e
	inc  bc
	and  d
	dec  d
	dec  d
	xor  b
	ld   bc,$A39C
	dec  d
	ld   bc,$1501
	nop
	sbc  l
	ld   h,d
	nop
	add  b
	sbc  e
	ld   b,$A1
	ld   e,b
	ld   e,b
	ld   c,[hl]
	ld   c,[hl]
	ld   b,b
	ld   b,b
	ld   c,[hl]
	ld   c,[hl]
	sbc  h
	sbc  l
	ld   [hl],b
	nop
	add  c
	xor  b
	ld   b,b
	and  e
	ld   bc,$9D00
	ld   [hl],b
	nop
	add  c
	and  h
	ld   c,b
	ld   c,[hl]
	ld   b,b
	ld   b,h
	ld   b,b
	ld   [hl],$9D
	add  b
	nop
	add  c
	xor  b
	ld   c,[hl]
	and  e
	ld   bc,$9D00
	di
	ld   l,e
	ld   hl,$58A4
	ld   d,h
	ld   d,d
	ld   d,b
	ld   c,d
	ld   c,b
	xor  b
	ld   b,[hl]
	and  e
	ld   bc,$9B00
	inc  bc
	and  d
	ld   bc,$1A0B
	ld   b,$01
	ld   b,$1A
	dec  d
	sbc  h
	xor  c
	ld   bc,$1A15
	dec  d
	ld   a,[de]
	dec  d
	ld   a,[de]
	dec  d
	ld   a,[de]
	and  e
	dec  d
	nop
	ld   b,b
	ld   [hl],e
	jp   c,Unk_3E73
	ld   [hl],h
	ld   a,[hl]
	ld   [hl],h
	adc  [hl]
	ld   [hl],h
	inc  bc
	ld   [hl],a
	-
	ld   [hl],a
	ld   a,[wUnk_B577]
	ld   a,b
	ld   a,l
	ld   [hl],l
	add  [hl]
	ld   [hl],l
	rst  $38
	rst  $38
	-
	ld   [hl],d
	ld   h,d
	ld   [hl],e
	and  a
	ld   [hl],h
	dec  bc
	ld   [hl],l
	ld   c,e
	ld   [hl],l
	ld   h,h
	ld   [hl],l
	dec  l
	ld   [hl],a
	or   a,$77
	and  l
	ld   a,b
	add  d
	ld   [hl],l
	rst  $38
	rst  $38
	ld   b,$73
	add  h
	ld   [hl],e
	ld   a,$76
	ld   [hl],b
	halt
	add  b
	halt
	ld   d,a
	ld   [hl],a
	add  a,$78
	dec  b
	halt
	rst  $38
	rst  $38
	inc  e
	ld   [hl],e
	cp   d
	ld   [hl],e
	sbc  c
	halt
	or   h
	halt
	call z,Unk_EE76
	halt
	sbc  a
	ld   [hl],a
	ld   [wUnk_BB78],a
	ld   [hl],l
	rst  $38
	rst  $38
	ld   l,$73
	sbc  l
	ld   [hl],c
	nop
	add  b
	and  d
	ld   bc,$016A
	ld   bc,$016A
	ld   bc,$6801
	ld   bc,$6801
	ld   bc,$0101
	ld   bc,$6601
	ld   bc,$6601
	ld   bc,$0101
	ld   h,d
	ld   bc,$01A8
	nop
	sbc  l
	add  c
	nop
	add  b
	and  d
	ld   bc,$0170
	ld   bc,$0170
	ld   bc,$6E01
	ld   bc,$6E01
	ld   bc,$0101
	ld   bc,$6C01
	ld   bc,$6C01
	ld   bc,$0101
	ld   l,d
	ld   bc,$01A8
	nop
	sbc  l
	di
	ld   l,e
	and  b
	and  d
	ld   b,h
	ld   b,h
	ld   c,d
	ld   b,h
	and  c
	ldd  a,[hl]
	ldd  a,[hl]
	and  d
	ldd  a,[hl]
	ld   b,b
	ld   b,d
	ld   b,h
	ld   b,h
	ld   c,d
	ld   b,h
	ldd  a,[hl]
	ld   bc,$0101
	ld   bc,$4A44
	ld   b,h
	and  c
	ldd  a,[hl]
	ldd  a,[hl]
	and  d
	ldd  a,[hl]
	ld   b,b
	ldd  a,[hl]
	xor  b
	ld   b,h
	sbc  l
	di
	ld   l,e
	ld   hl,$3AA0
	jr   c,.unk_73E7
	inc  [hl]
	ldd  [hl],a
	jr   nc,.unk_73E3
	inc  l
	ld   bc,$01AB
	nop
	and  e
	ld   b,$15
	ld   b,$15
	ld   b,$15
	and  d
	ld   b,$15
	dec  d
	ld   bc,$06A3
	dec  d
	ld   b,$15
	and  d
	dec  bc
	dec  d
	ld   a,[de]
	and  c
	ld   bc,$A11A
	ld   a,[de]
	ld   a,[de]
	and  d
	ld   bc,$011A
	nop
	sbc  l
	ld   [hl],c
	nop
	add  b
	and  d
	ld   bc,$0152
	ld   bc,$0152
	ld   bc,$5201
	ld   bc,$5201
	ld   bc,$0101
	ld   bc,$5201
	ld   bc,$5201
	ld   bc,$0101
	ld   c,[hl]
	ld   bc,$5201
	ld   bc,$0101
	ld   bc,$5201
	ld   bc,$5201
	ld   bc,$0101
	ld   d,d
	ld   bc,$5201
	ld   bc,$0101
	ld   bc,$5201
	ld   bc,$5201
	ld   bc,$0101
	sbc  l
	sub  c
	nop
	add  e
	xor  h
	ldi  [hl],a
	and  b
	ldi  [hl],a
	jr   nz,.unk_7441
	ld   e,$A0
	ld   e,$AC
	inc  e
	and  b
	inc  e
	inc  e
	ld   a,[de]
	xor  h
	ld   a,[de]
	and  b
	jr   .unk_7447
	ld   d,$16
	and  b
	inc  d
	inc  d
	xor  h
	ld   [de],a
	and  b
	ld   [de],a
	<corrupted stop>
	jr   .unk_73E3
	ld   bc,$9D00
	ld   [hl],c
	nop
	add  e
	and  d
	ld   bc,$4A52
	ld   d,d
	ld   c,d
	and  a
	ld   bc,$44A2
	ld   b,h
	ld   c,d
	ld   b,h
	ld   c,d
	and  a
	ld   bc,$01A2
	ld   d,d
	ld   c,d
	ld   d,d
	ld   e,b
	ld   bc,$4E56
	and  l
	ld   d,h
	and  d
	ld   bc,$52A1
	ld   d,d
	and  d
	ld   c,d
	ld   d,d
	ld   c,d
	and  a
	ld   bc,$44A2
	ld   b,h
	ld   c,d
	ld   b,h
	ldd  a,[hl]
	and  a
	ld   bc,$01A2
	ld   d,d
	ld   c,d
	ld   d,d
	ld   e,b
	ld   bc,$4E56
	ld   d,d
	ld   bc,$01A8
	nop
	sbc  l
	ld   [hl],b
	nop
	add  c
	and  l
	inc  d
	<corrupted stop>
	xor  b
	inc  c
	and  c
	inc  c
	ld   bc,$0101
	nop
	sbc  l
	ld   [hl],c
	nop
	add  b
	sbc  e
	inc  b
	and  d
	ld   bc,$0174
	ld   bc,$0174
	ld   bc,$7401
	ld   bc,$7401
	ld   bc,$0101
	ld   bc,$009C
	sbc  l
	add  c
	nop
	add  b
	and  d
	ld   bc,$015C
	ld   bc,$015C
	ld   bc,$5C01
	ld   bc,$5C01
	ld   bc,$0101
	ld   bc,$5C01
	ld   bc,$5C01
	ld   bc,$0101
	ld   e,b
	ld   bc,$5C01
	ld   bc,$0101
	ld   bc,$5C01
	ld   bc,$5C01
	ld   bc,$0101
	ld   e,h
	ld   bc,$5C01
	ld   bc,$0101
	ld   bc,$5C01
	ld   bc,$5C01
	ld   bc,$0101
	sbc  l
	sub  c
	nop
	add  b
	xor  h
	ldi  [hl],a
	and  b
	ldi  [hl],a
	jr   nz,.unk_750E
	ld   e,$A0
	ld   e,$AC
	inc  e
	and  b
	inc  e
	inc  e
	ld   a,[de]
	xor  h
	ld   a,[de]
	and  b
	jr   .unk_7514
	ld   d,$16
	and  b
	inc  d
	inc  d
	xor  h
	ld   [de],a
	and  b
	ld   [de],a
	<corrupted stop>
	jr   .unk_74B0
	ld   bc,$9D00
	add  c
	nop
	add  b
	and  d
	ld   bc,$4A52
	ld   d,d
	ld   c,d
	and  a
	ld   bc,$44A2
	ld   b,h
	ld   c,d
	ld   b,h
	ld   c,d
	and  a
	ld   bc,$01A2
	ld   d,d
	ld   c,d
	ld   d,d
	ld   e,b
	ld   bc,$4E56
	and  l
	ld   d,h
	and  d
	ld   bc,$52A1
	ld   d,d
	and  d
	ld   c,d
	ld   d,d
	ld   c,d
	and  a
	ld   bc,$44A2
	ld   b,h
	ld   c,d
	ld   b,h
	ldd  a,[hl]
	and  a
	ld   bc,$01A2
	ld   d,d
	ld   c,d
	ld   d,d
	ld   e,b
	ld   bc,$4E56
	ld   d,d
	ld   bc,$01A8
	nop
	sbc  l
	ld   [hl],c
	nop
	add  b
	sbc  e
	rlca
	and  c
	ld   b,h
	ld   e,h
	ld   b,h
	ld   b,h
	ld   e,h
	ld   b,h
	ld   b,h
	ld   e,h
	sbc  h
	ld   b,h
	ld   e,h
	ld   b,h
	ld   b,h
	ld   e,h
	ld   bc,$0101
	nop
	sbc  l
	add  c
	nop
	add  b
	sbc  e
	inc  b
	and  d
	ld   bc,$747A
	ld   l,d
	ld   a,h
	ld   bc,$6A74
	ld   a,[hl]
	ld   [hl],h
	ld   l,d
	ld   a,h
	ld   bc,$0101
	ld   bc,$009C
	sbc  l
	ld   [hl],d
	nop
	add  b
	nop
	sbc  l
	add  c
	nop
	add  b
	sbc  e
	ld   [wUnk_12A2],sp
	inc  d
	inc  d
	inc  d
	sbc  h
	sbc  e
	ld   [bc],a
	and  c
	inc  d
	inc  d
	and  d
	inc  d
	ld   a,[de]
	ld   e,$A1
	jr   nz,.unk_75BA
	and  d
	jr   nz,.unk_75BB
	ld   a,[de]
	inc  d
	inc  d
	ld   a,[de]
	ld   bc,$1414
	ld   a,[de]
	ld   bc,$14A1
	inc  d
	and  d
	inc  d
	ld   a,[de]
	ld   e,$A1
	jr   nz,.unk_75D0
	and  d
	jr   nz,.unk_75D1
	ld   a,[de]
	and  e
	inc  d
	ld   bc,$0101
	sbc  h
	nop
	sbc  e
	inc  bc
	and  d
	dec  d
	ld   bc,$1501
	dec  d
	ld   bc,$0101
	sbc  h
	dec  d
	ld   bc,$1501
	and  c
	ld   a,[de]
	ld   a,[de]
	ld   bc,$1515
	ld   a,[de]
	ld   a,[de]
	ld   a,[de]
	sbc  e
	ld   [bc],a
	and  d
	dec  d
	ld   b,$1A
	and  c
	ld   b,$0B
	and  d
	dec  d
	dec  d
	ld   a,[de]
	dec  bc
	dec  d
	dec  d
	ld   a,[de]
	and  c
	ld   bc,$A201
	dec  d
	dec  d
	ld   a,[de]
	ld   bc,$0615
	ld   a,[de]
	and  c
	ld   b,$0B
	and  d
	dec  d
	dec  d
	ld   a,[de]
	dec  bc
	dec  d
	ld   bc,$A101
	dec  d
	ld   b,$A2
	dec  d
	ld   bc,$0101
	sbc  h
	nop
	sbc  l
	di
	ld   l,e
	and  b
	sbc  e
	ld   [wUnk_2AA2],sp
	inc  l
	inc  l
	inc  l
	sbc  h
	sbc  e
	ld   [bc],a
	and  c
	inc  l
	inc  l
	and  d
	inc  l
	ldd  [hl],a
	ld   [hl],$A1
	jr   c,.unk_7655
	and  d
	jr   c,.unk_7656
	ldd  [hl],a
	inc  l
	inc  l
	ldd  [hl],a
	ld   bc,$2C2C
	ldd  [hl],a
	ld   bc,$2CA1
	inc  l
	and  d
	inc  l
	ldd  [hl],a
	ld   [hl],$A1
	jr   c,.unk_766B
	and  d
	jr   c,.unk_766C
	ldd  [hl],a
	and  e
	inc  l
	ld   bc,$0101
	sbc  h
	nop
	sbc  l
	di
	ld   l,e
	and  b
	sbc  e
	inc  b
	and  d
	inc  l
	inc  l
	ldd  [hl],a
	inc  l
	and  c
	ldi  [hl],a
	ldi  [hl],a
	and  d
	ldi  [hl],a
	jr   z,.unk_767A
	inc  l
	inc  l
	ldd  [hl],a
	inc  l
	ldi  [hl],a
	ld   bc,$0101
	ld   bc,$322C
	inc  l
	and  c
	ldi  [hl],a
	ldi  [hl],a
	and  d
	ldi  [hl],a
	jr   z,.unk_7685
	and  c
	inc  l
	inc  l
	and  d
	inc  l
	ldd  [hl],a
	inc  l
	ldd  [hl],a
	ld   bc,$0101
	sbc  h
	nop
	sbc  l
	-
	ld   l,e
	ld   hl,$2CA5
	ldd  [hl],a
	ld   [hl],$A8
	jr   c,.unk_761C
	jr   c,.unk_767E
	ld   bc,$0001
	sbc  l
	di
	ld   l,e
	and  b
	sbc  e
	inc  b
	and  d
	inc  l
	inc  l
	ldd  [hl],a
	ldd  [hl],a
	inc  l
	ld   bc,$0101
	ld   bc,$322C
	ldd  [hl],a
	inc  l
	ld   bc,$0101
	sbc  h
	nop
	sbc  e
	rlca
	and  d
	dec  d
	ld   b,$1A
	ld   b,$15
	ld   b,$1A
	ld   b,$9C
	dec  d
	ld   b,$1A
	and  c
	ld   b,$1A
	and  c
	ld   a,[de]
	ld   a,[de]
	ld   a,[de]
	ld   a,[de]
	and  d
	ld   a,[de]
	ld   bc,$9B00
	rlca
	and  d
	dec  d
	ld   b,$1A
	ld   b,$15
	ld   b,$1A
	ld   b,$9C
	dec  d
	ld   b,$1A
	dec  bc
	and  c
	ld   a,[de]
	ld   a,[de]
	and  d
	ld   b,$1A
	ld   bc,$9B00
	ld   [bc],a
	and  d
	ld   b,$06
	dec  d
	ld   b,$06
	ld   b,$15
	ld   b,$9C
	sbc  e
	inc  b
	dec  d
	ld   b,$9C
	and  d
	dec  d
	dec  d
	dec  d
	and  c
	dec  d
	ld   a,[de]
	and  c
	ld   a,[de]
	ld   a,[de]
	ld   a,[de]
	ld   a,[de]
	ld   a,[de]
	ld   bc,$0101
	nop
	sbc  e
	inc  b
	and  d
	dec  d
	ld   b,$1A
	dec  d
	dec  d
	ld   b,$1A
	ld   b,$15
	ld   b,$1A
	dec  d
	dec  d
	ld   bc,$0101
	sbc  h
	nop
	sbc  l
	ld   [hl],c
	nop
	add  b
	sbc  e
	inc  bc
	and  d
	ld   bc,$0152
	ld   bc,$0152
	ld   bc,$5201
	ld   bc,$5201
	ld   bc,$A301
	ld   e,h
	sbc  h
	and  d
	ld   bc,$0152
	ld   bc,$0152
	ld   bc,$525C
	ld   bc,$5201
	ld   bc,$0101
	ld   bc,$9D00
	add  c
	nop
	add  b
	sbc  e
	inc  bc
	and  d
	ld   bc,$015C
	ld   bc,$015C
	ld   bc,$5C01
	ld   bc,$5C01
	ld   bc,$A301
	ld   c,[hl]
	sbc  h
	and  d
	ld   bc,$015C
	ld   bc,$015C
	ld   bc,$5C01
	ld   bc,$5C01
	ld   bc,$0101
	ld   bc,$9B00
	inc  bc
	and  l
	ld   bc,$9D9C
	di
	ld   l,e
	ld   hl,$01A8
	and  b
	ld   a,$3C
	ldd  a,[hl]
	jr   c,.unk_779E
	inc  [hl]
	ldd  [hl],a
	jr   nc,.unk_776D
	xor  e
	ld   bc,$F39D
	ld   l,e
	and  b
	and  c
	inc  l
	inc  l
	and  d
	inc  l
	inc  l
	ldd  [hl],a
	inc  l
	inc  l
	inc  l
	ldi  [hl],a
	and  c
	inc  l
	inc  l
	and  d
	inc  l
	inc  l
	ldd  [hl],a
	inc  l
	ld   l,$2C
	ld   l,$A1
	inc  l
	inc  l
	and  d
	inc  l
	inc  l
	ldd  [hl],a
	inc  l
	inc  l
	inc  l
	ldi  [hl],a
	and  c
	inc  l
	inc  l
	and  d
	inc  l
	inc  l
	ldd  [hl],a
	ld   bc,$0101
	ld   bc,$A200
	dec  d
	ld   b,$1A
	ld   b,$15
	ld   b,$1A
	dec  bc
	dec  d
	ld   b,$1A
	dec  d
	dec  d
	ld   bc,$1AA1
	ld   a,[de]
	and  d
	ld   bc,$0615
	ld   a,[de]
	ld   b,$15
	ld   b,$1A
	dec  bc
	dec  d
	ld   b,$A0
	ld   a,[de]
	ld   a,[de]
	xor  e
	ld   bc,$1AA0
	ld   a,[de]
	xor  e
	ld   bc,$15A2
	xor  c
	ld   bc,$1A1A
	xor  e
	ld   bc,$15A9
	dec  d
	dec  d
	xor  e
	ld   bc,$039B
	and  c
	dec  d
	ld   b,$A2
	ld   bc,$061A
	dec  d
	ld   b,$1A
	ld   b,$9C
	and  d
	dec  d
	ld   b,$1A
	dec  d
	ld   bc,$0101
	ld   bc,$9D00
	jr   nz,.unk_77F0
	jp   Unk_01AA
	xor  h
	ld   bc,$9D00
	ld   [hl],b
	nop
	add  c
	sbc  e
	ld   [wUnk_62A1],sp
	ld   e,h
	sbc  h
	and  c
	ld   h,[hl]
	ld   d,[hl]
	ld   e,b
	ld   e,d
	ld   e,h
	ld   h,b
	ld   h,d
	ld   h,b
	ld   bc,$666A
	ld   h,d
	ld   h,b
	ld   e,h
	ld   e,b
	ld   d,[hl]
	and  d
	ld   e,b
	and  b
	ld   d,[hl]
	ld   d,d
	xor  e
	ld   bc,$4EA0
	ld   b,h
	xor  e
	ld   bc,$40A3
	and  c
	ld   bc,$3A4A
	ld   a,$40
	ld   b,h
	ld   c,b
	ld   b,h
	ld   d,d
	ld   c,b
	ld   c,d
	ld   c,[hl]
	ld   d,d
	ld   d,[hl]
	ld   e,b
	ld   d,[hl]
	ld   bc,$4A5C
	ld   c,[hl]
	ld   d,d
	ld   d,[hl]
	ld   e,b
	ld   d,[hl]
	ld   e,h
	ld   e,h
	ld   bc,$0148
	ld   c,d
	ld   bc,$524E
	ld   c,[hl]
	ld   d,d
	ld   bc,$56A3
	and  c
	ld   e,h
	ld   e,h
	ld   bc,$0148
	ld   c,d
	ld   bc,$524E
	ld   c,[hl]
	ld   d,d
	ld   bc,$56A3
	xor  c
	ld   d,[hl]
	ld   h,d
	ld   h,[hl]
	xor  e
	ld   bc,$64A9
	ld   h,d
	ld   h,b
	xor  e
	ld   bc,$5EA9
	ld   e,h
	ld   e,d
	xor  e
	ld   bc,$58A9
	ld   d,[hl]
	ld   d,h
	xor  e
	ld   bc,$52A9
	ld   d,b
	ld   c,[hl]
	xor  e
	ld   bc,$4CA9
	ld   c,d
	ld   c,b
	xor  e
	ld   bc,$46A1
	ld   b,h
	ld   b,d
	ld   b,b
	and  b
	ld   a,$3C
	xor  e
	ld   bc,$3AA0
	jr   c,.unk_7832
	ld   bc,$36A0
	inc  [hl]
	xor  e
	ld   bc,$32A0
	jr   nc,.unk_783C
	ld   bc,$5CA6
	and  c
	ld   h,[hl]
	and  d
	ld   h,h
	ld   h,b
	ld   e,h
	ld   h,b
	ld   d,[hl]
	ld   e,b
	ld   e,h
	ld   h,[hl]
	ld   h,h
	and  h
	ld   h,[hl]
	and  d
	ld   bc,$A600
	ld   h,b
	and  c
	ld   l,[hl]
	and  d
	ld   l,d
	ld   l,b
	ld   h,h
	ld   l,b
	and  e
	ld   e,h
	ld   h,b
	ld   l,d
	and  h
	halt
	nop
	and  [hl]
	ld   h,b
	and  c
	ld   l,[hl]
	and  d
	ld   l,d
	ld   l,b
	ld   h,h
	ld   l,b
	and  e
	ld   e,h
	ld   e,h
	ld   l,d
	xor  d
	halt
	ld   bc,$9B00
	ld   b,$A1
	ld   [hl],$36
	ld   bc,$0101
	sbc  l
	di
	ld   l,e
	ld   hl,$26A6
	and  e
	jr   z,.unk_7903
	and  c
	ldd  [hl],a
	ld   bc,$0130
	inc  l
	jr   nc,.unk_78E0
	ld   bc,$0101
	inc  a
	ld   a,$01
	ld   [hl],$01
	ld   e,$9C
	nop
	sbc  e
	ld   b,$A1
	dec  d
	dec  d
	ld   b,$01
	ld   a,[de]
	dec  d
	and  d
	ld   b,$15
	ld   b,$1A
	ld   b,$15
	ld   b,$1A
	dec  d
	and  c
	dec  d
	ld   bc,$1A1A
	ld   bc,$011A
	ld   a,[de]
	sbc  h
	nop
	jr   c,.unk_7983
	ld   h,b
	ld   a,c
	ld   h,b
	ld   a,c
	cp   h
	ld   a,c
	rst  $38
	rst  $38
	ld   a,[bc]
	ld   a,c
	ld   b,e
	ld   a,c
	adc  [hl]
	ld   a,c
	adc  [hl]
	ld   a,c
	call Unk_FF79
	rst  $38
	ld   d,$79
	ld   c,[hl]
	ld   a,c
	sbc  a,$79
	sbc  a,$79
	ld   c,l
	ld   a,d
	rst  $38
	rst  $38
	ldi  [hl],a
	ld   a,c
	ld   e,c
	ld   a,c
	dec  de
	ld   a,d
	dec  de
	ld   a,d
	ld   [hl],b
	ld   a,d
	rst  $38
	rst  $38
	ld   l,$79
	sbc  l
	ld   [hl],c
	nop
	add  b
	and  c
	ld   [hl],$36
	ld   [hl],$36
	ld   bc,$9D00
	ld   [hl],c
	nop
	add  b
	and  c
	ld   b,b
	ld   b,b
	ld   b,b
	ld   b,b
	ld   bc,$9D00
	-
	ld   l,e
	jr   nz,.unk_78F4
	inc  l
	inc  l
	inc  l
	inc  l
	ld   bc,$A100
	dec  bc
	dec  bc
	dec  bc
	dec  bc
	ld   bc,$9D00
	sub  d
	nop
	add  b
	and  e
	ld   c,[hl]
	xor  b
	ld   bc,$4AA9
	ld   bc,$4A01
	ld   d,d
	ld   e,b
	and  e
	ld   d,[hl]
	ld   e,h
	sbc  l
	add  c
	nop
	add  b
	xor  c
	ld   [hl],$01
	ld   bc,$0136
	ld   b,$36
	ld   bc,$3606
	ld   bc,$A306
	ld   b,[hl]
	ld   c,d
	ld   b,h
	sbc  l
	pop  de
	nop
	add  b
	and  e
	ld   h,$00
	sbc  l
	and  c
	nop
	add  b
	and  e
	ld   b,b
	xor  b
	ld   bc,$3AA9
	ld   bc,$3A01
	ld   b,b
	ld   c,d
	and  e
	ld   b,h
	ld   c,[hl]
	sbc  l
	sub  c
	nop
	add  b
	xor  c
	ld   b,b
	ld   bc,$0601
	ld   bc,$061E
	ld   bc,$061E
	ld   bc,$A31E
	ldd  a,[hl]
	ld   b,b
	ld   a,$9D
	pop  de
	nop
	add  b
	and  e
	ld   c,$00
	sbc  l
	add  d
	nop
	add  b
	and  l
	ld   e,b
	ld   h,b
	ld   e,b
	sbc  l
	pop  de
	nop
	add  b
	xor  b
	ld   bc,$1AA3
	nop
	sbc  l
	sub  d
	nop
	add  b
	and  l
	ld   c,[hl]
	ld   e,b
	ld   c,[hl]
	sbc  l
	pop  de
	nop
	add  b
	xor  b
	ld   bc,$0CA3
	nop
	sbc  l
	di
	ld   l,e
	jr   nz,.unk_798D
	ld   h,b
	sbc  l
	-
	ld   l,e
	ld   hl,$66A9
	ld   l,b
	ld   h,[hl]
	ld   l,b
	ld   bc,$6866
	ld   h,[hl]
	ld   l,b
	ld   h,[hl]
	ld   e,b
	ld   bc,$5801
	ld   h,d
	ld   d,d
	ld   c,[hl]
	ld   bc,$A301
	ld   d,[hl]
	sbc  l
	di
	ld   l,e
	jr   nz,.unk_79AC
	ld   h,b
	ld   bc,$4E36
	ld   bc,$4E36
	ld   bc,$4E36
	ld   bc,$3236
	ld   bc,$3832
	ld   bc,$3638
	ld   bc,$A301
	ld   h,$00
	xor  c
	dec  d
	ld   bc,$1A0B
	ld   bc,$061A
	ld   bc,$060B
	ld   bc,$1515
	ld   bc,$1A0B
	ld   bc,$061A
	ld   bc,$060B
	ld   bc,$1515
	ld   bc,$1A0B
	ld   bc,$061A
	ld   bc,$060B
	ld   bc,$1A1A
	ld   bc,$1A15
	ld   bc,$1A15
	ld   bc,$1506
	ld   bc,$0001
	sbc  l
	di
	ld   l,e
	jr   nz,.unk_79ED
	inc  bc
	xor  d
	jr   nc,.unk_79FF
	ldd  [hl],a
	xor  c
	jr   nc,.unk_7A5B
	ldd  [hl],a
	xor  c
	jr   nc,.unk_7A5F
	ldd  [hl],a
	xor  c
	jr   nc,.unk_7A63
	ldd  [hl],a
	sbc  h
	xor  d
	jr   nc,.unk_7A10
	ldd  [hl],a
	xor  c
	jr   nc,.unk_7A6C
	ldd  [hl],a
	and  e
	ld   bc,$0024
	xor  c
	dec  d
	ld   bc,$060B
	ld   bc,$151A
	ld   bc,$060B
	ld   bc,$1515
	ld   bc,$060B
	ld   bc,$151A
	ld   bc,$060B
	ld   bc,$1501
	ld   bc,$060B
	ld   bc,$151A
	ld   bc,$060B
	ld   bc,$1515
	ld   bc,$060B
	ld   bc,$151A
	ld   bc,$150B
	ld   bc,$0001
	xor  h
	ld   a,d
	nop
	nop
	add  a,$7A
	ldh  [hUnk_FF7A],a
	ld   a,[wUnk_9D7A]
	add  c
	nop
	ret  nz
	xor  l
	ld   d,b
	ld   d,d
	ld   d,h
	ld   d,[hl]
	ld   e,b
	ld   e,d
	ld   e,h
	ld   e,[hl]
	ld   h,b
	sbc  l
	ld   [hl],b
	nop
	pop  bc
	and  c
	ld   d,b
	ld   bc,$3AA3
	and  h
	inc  a
	nop
	sbc  l
	add  c
	nop
	ret  nz
	xor  l
	ld   d,[hl]
	ld   e,b
	ld   e,d
	ld   e,h
	ld   e,[hl]
	ld   h,b
	ld   h,d
	ld   h,h
	ld   h,[hl]
	sbc  l
	add  b
	nop
	add  c
	and  c
	halt
	ld   bc,$48A3
	and  h
	ld   c,d
	nop
	sbc  l
	-
	ld   l,e
	jr   nz,.unk_7A92
	ld   h,b
	ld   h,d
	ld   h,h
	ld   h,[hl]
	ld   l,b
	ld   l,d
	ld   l,h
	ld   l,[hl]
	ld   [hl],b
	sbc  l
	-
	ld   l,e
	ld   hl,$58A1
	ld   bc,$5AA3
	and  h
	ld   e,h
	nop
	sbc  e
	add  hl,bc
	xor  l
	ld   b,$9C
	ld   bc,$0BA1
	ld   bc,$0BA8
	nop
	xor  h
	ld   a,d
	nop
	nop
	add  a,$7A
	ldh  [hUnk_FF7A],a
	ld   a,[wUnk_9D7A]
	ld   [hl],c
	nop
	add  b
	and  c
	ld   d,b
	ld   c,d
	ld   d,b
	sbc  l
	ld   [hl],b
	nop
	add  c
	and  a
	ld   d,h
	nop
	sbc  l
	ld   [hl],c
	nop
	add  b
	and  c
	ld   h,d
	ld   e,d
	ld   h,d
	sbc  l
	add  b
	nop
	add  c
	and  a
	ld   h,[hl]
	nop
	sbc  l
	di
	ld   l,e
	and  b
	and  c
	ld   e,d
	ld   e,d
	ld   e,d
	sbc  l
	di
	ld   l,e
	ld   hl,$5EA7
	nop
	and  c
	dec  bc
	dec  bc
	dec  bc
	sbc  e
	inc  b
	and  b
	ld   b,$06
	ld   b,$9C
	nop
	<corrupted stop>
	ld   [hl],a
	ld   a,e
	sbc  c
	ld   a,e
	xor  c
	ld   a,h
	or   d
	ld   a,h
	rst  $38
	rst  $38
	ld   c,l
	ld   a,e
	rra
	ld   a,e
	add  [hl]
	ld   a,e
	dec  l
	ld   a,h
	xor  [hl]
	ld   a,h
	rst  $38
	rst  $38
	ld   e,e
	ld   a,e
	ld   l,$7B
	sub  b
	ld   a,e
	xor  a,$7C
	rst  $38
	rst  $38
	ld   h,a
	ld   a,e
	dec  a
	ld   a,e
	sub  e
	ld   a,e
	ld   h,c
	ld   a,l
	rst  $38
	rst  $38
	ld   [hl],c
	ld   a,e
	sbc  a
	ld   [wUnk_4C9E],sp
	ld   l,h
	sbc  l
	ld   [hl],c
	nop
	ret  nz
	and  d
	ld   bc,$4E4A
	ld   c,d
	nop
	sbc  l
	add  c
	nop
	ret  nz
	and  d
	ld   bc,$1E1A
	ld   a,[de]
	nop
	and  h
	ld   bc,$A200
	ld   bc,$1A1A
	ld   a,[de]
	nop
	and  d
	ld   e,h
	ld   bc,$0158
	ld   d,d
	ld   d,b
	ld   c,[hl]
	ld   c,d
	ld   c,[hl]
	ld   c,d
	ld   bc,$014A
	ld   bc,$4A01
	ld   c,[hl]
	ld   c,[hl]
	ld   c,[hl]
	ld   c,d
	ld   d,d
	ld   c,d
	ld   bc,$9D4A
	ld   [hl],c
	nop
	jp   Unk_7A01
	ld   h,d
	ld   bc,$017A
	sbc  l
	ld   [hl],c
	nop
	ret  nz
	ld   c,d
	ld   c,d
	ld   e,h
	ld   e,h
	ld   e,b
	ld   e,b
	ld   d,b
	ld   d,b
	ld   c,[hl]
	ld   c,d
	ld   c,[hl]
	ld   c,d
	ld   bc,$0144
	ld   bc,$4001
	ld   c,[hl]
	ld   c,[hl]
	ld   c,[hl]
	ld   c,d
	ld   d,d
	ld   c,d
	ld   bc,$9D4A
	ld   [hl],c
	nop
	jp   Unk_0101
	ld   h,d
	ld   a,d
	ld   bc,$9D01
	ld   [hl],c
	nop
	ret  nz
	ld   c,d
	ld   b,[hl]
	ld   b,h
	ld   c,d
	ld   bc,$014A
	ld   bc,$0101
	ld   b,b
	ld   c,d
	ld   bc,$014A
	ld   bc,$0101
	inc  a
	ld   c,d
	ld   bc,$014A
	ld   bc,$4001
	ldd  a,[hl]
	ld   c,d
	ld   bc,$014A
	ld   bc,$0101
	ld   b,h
	ld   c,d
	ld   bc,$9D4A
	ld   [hl],c
	nop
	jp   Unk_7201
	ld   [hl],b
	ld   [hl],d
	sbc  l
	ld   [hl],c
	nop
	ret  nz
	ld   b,b
	ld   c,d
	ld   bc,$014A
	ld   bc,$0101
	inc  a
	ld   c,d
	ld   bc,$014A
	ld   bc,$4001
	and  l
	ld   bc,$A200
	inc  l
	ld   bc,$0128
	ldi  [hl],a
	jr   nz,.unk_7C53
	ld   a,[de]
	ld   e,$1A
	ld   bc,$011A
	ld   bc,$1A01
	ld   e,$1E
	ld   e,$1A
	ldi  [hl],a
	ld   a,[de]
	ld   bc,$011A
	ld   a,d
	ld   h,d
	ld   bc,$017A
	ld   a,[de]
	ld   a,[de]
	inc  l
	inc  l
	jr   z,.unk_7C7A
	jr   nz,.unk_7C74
	ld   e,$1A
	ld   e,$1A
	ld   bc,$0114
	ld   bc,$1001
	ld   e,$1E
	ld   e,$1A
	ldi  [hl],a
	ld   a,[de]
	ld   bc,$011A
	ld   bc,$7A62
	ld   bc,$1A01
	ld   d,$14
	ld   a,[de]
	ld   bc,$011A
	ld   bc,$0101
	<corrupted stop>
	ld   bc,$011A
	ld   bc,$0101
	inc  c
	ld   a,[de]
	ld   bc,$011A
	ld   bc,$1001
	ld   a,[bc]
	ld   a,[de]
	ld   bc,$011A
	ld   bc,$0101
	inc  d
	ld   a,[de]
	ld   bc,$011A
	ld   [hl],d
	ld   [hl],b
	ld   [hl],d
	<corrupted stop>
	ld   bc,$011A
	ld   bc,$0101
	inc  c
	ld   a,[de]
	ld   bc,$011A
	ld   bc,$1001
	and  l
	ld   bc,$9D00
	ld   [hl],c
	nop
	jp   Unk_9D00
	sub  c
	nop
	ret  nz
	sbc  e
	ld   [bc],a
	and  l
	ld   bc,$7AA2
	ld   h,d
	ld   bc,$017A
	ld   bc,$0101
	and  l
	ld   bc,$01A2
	ld   a,d
	ld   h,d
	ld   bc,$017A
	ld   bc,$9C01
	sbc  e
	inc  bc
	and  h
	ld   bc,$01A2
	ld   [hl],h
	ld   [hl],b
	ld   bc,$A49C
	ld   bc,$01A2
	ld   bc,$017A
	sbc  e
	inc  bc
	and  h
	ld   bc,$01A2
	ld   [hl],h
	ld   [hl],b
	ld   bc,$A29C
	ld   [hl],d
	ld   [hl],d
	ld   [hl],d
	ld   [hl],d
	and  h
	ld   bc,$9D00
	di
	ld   l,e
	jr   nz,.unk_7C8E
	ld   [bc],a
	and  e
	ldd  [hl],a
	and  d
	ld   bc,$3A38
	ld   b,b
	ld   b,h
	ld   bc,$24A3
	and  d
	ld   bc,$2C2A
	ldd  [hl],a
	ld   [hl],$01
	and  e
	jr   z,.unk_7CAB
	ld   bc,$302E
	ld   [hl],$3A
	ld   bc,$32A3
	and  d
	ld   bc,$3A38
	ld   b,b
	ld   b,h
	ld   bc,$A39C
	inc  h
	and  d
	ld   bc,$2C2A
	ld   bc,$0132
	and  e
	ldi  [hl],a
	and  d
	ld   bc,$2826
	ld   bc,$0132
	and  e
	ld   e,$A2
	ld   bc,$2C24
	ld   bc,$0132
	and  e
	ld   a,[de]
	and  d
	ld   bc,$2220
	ld   bc,$0132
	and  e
	inc  h
	and  d
	ld   bc,$2C2A
	ld   bc,$0132
	and  e
	ldi  [hl],a
	and  d
	ld   bc,$2826
	ld   bc,$0132
	and  e
	ld   e,$A2
	ld   bc,$2C24
	ld   bc,$0132
	jr   z,.unk_7D82
	jr   z,.unk_7D84
	ld   bc,$0101
	ld   bc,$9B00
	inc  b
	and  d
	dec  d
	ld   b,$1A
	ld   a,[de]
	ld   b,$06
	dec  d
	ld   b,$15
	ld   b,$1A
	ld   a,[de]
	ld   b,$1A
	ld   a,[de]
	ld   b,$9C
	sbc  e
	inc  bc
	dec  d
	ld   b,$06
	dec  d
	dec  d
	ld   b,$1A
	ld   b,$9C
	dec  d
	ld   b,$06
	dec  d
	dec  d
	ld   a,[de]
	ld   a,[de]
	ld   bc,$039B
	dec  d
	ld   b,$06
	dec  d
	dec  d
	ld   b,$1A
	ld   b,$9C
	ld   a,[de]
	dec  d
	dec  d
	dec  d
	ld   bc,$1A1A
	ld   bc,$A600
	ld   a,l
	nop
	nop
	cp   d
	ld   a,l
	adc  a,$7D
	rst  $18
	ld   a,l
	sbc  l
	or   d
	nop
	ret  nz
	and  b
	ld   b,$01
	ld   a,$A6
	ld   bc,$01AC
	ldi  a,[hl]
	xor  h
	ld   bc,$AC26
	ld   bc,$002E
	sbc  l
	jp   nz,wOAMBuffer
	and  b
	ld   a,[bc]
	ld   bc,$A644
	ld   bc,$01AC
	inc  l
	xor  h
	ld   bc,$AC28
	ld   bc,$0030
	sbc  l
	di
	ld   l,e
	jr   nz,.unk_7D73
	jr   z,.unk_7DD6
	ld   h,b
	and  [hl]
	ld   bc,$039B
	xor  h
	ld   bc,$9C1E
	nop
	and  b
	dec  d
	ld   bc,$A610
	ld   bc,$039B
	xor  h
	ld   bc,$9C10
	nop
	ld   l,h
	ld   a,[hl]
	cp   h
	ld   a,[hl]
	ld   [c],a
	ld   a,[hl]
	ld   [wUnk_AC7E],a
	ld   a,[hl]
	ld   [wUnk_BC7E],a
	ld   a,[hl]
	ld   [c],a
	ld   a,[hl]
	ld   [wUnk_AC7E],a
	ld   a,[hl]
	ld   [wUnk_BC7E],a
	ld   a,[hl]
	ld   [wUnk_EA7E],a
	ld   a,[hl]
	rst  $38
	rst  $38
	ld   [bc],a
	ld   a,[hl]
	ld   a,e
	ld   a,[hl]
	<corrupted stop>
	ldd  [hl],a
	ld   a,a
	ldd  a,[hl]
	ld   a,a
	ld   c,c
	ld   a,a
	ld   d,c
	ld   a,a
	<corrupted stop>
	ldd  [hl],a
	ld   a,a
	ldd  a,[hl]
	ld   a,a
	ld   c,c
	ld   a,a
	ld   d,c
	ld   a,a
	<corrupted stop>
	ldd  a,[hl]
	ld   a,a
	ld   d,c
	ld   a,a
	rst  $38
	rst  $38
	ldi  [hl],a
	ld   a,[hl]
	sbc  h
	ld   a,[hl]
	ld   e,[hl]
	ld   a,a
	ld   l,[hl]
	ld   a,a
	ld   [hl],d
	ld   a,a
	or   h
	ld   a,[hl]
	ld   [hl],d
	ld   a,a
	ld   e,[hl]
	ld   a,a
	ld   l,[hl]
	ld   a,a
	ld   [hl],d
	ld   a,a
	or   h
	ld   a,[hl]
	sbc  a
	ld   a,a
	ld   e,[hl]
	ld   a,a
	ld   [hl],d
	ld   a,a
	sbc  a
	ld   a,a
	rst  $38
	rst  $38
	ld   b,d
	ld   a,[hl]
	and  h
	ld   a,[hl]
	add  c
	ld   a,a
	adc  [hl]
	ld   a,a
	sub  d
	ld   a,a
	cp   b
	ld   a,[hl]
	sub  d
	ld   a,a
	add  c
	ld   a,a
	adc  [hl]
	ld   a,a
	sub  d
	ld   a,a
	cp   b
	ld   a,[hl]
	cp   b
	ld   a,a
	add  c
	ld   a,a
	sub  d
	ld   a,a
	cp   b
	ld   a,a
	rst  $38
	rst  $38
	ld   h,d
	ld   a,[hl]
	sbc  l
	jr   nz,.unk_7E6F
	add  e
	sbc  e
	dec  b
	and  d
	ld   [hl],b
	ld   l,[hl]
	ld   h,[hl]
	ld   h,d
	sbc  h
	xor  b
	ld   bc,$9D00
	dec  h
	nop
	add  b
	and  d
	ld   [hl],b
	ld   l,[hl]
	ld   h,[hl]
	ld   h,d
	sbc  l
	ld   b,l
	nop
	add  b
	and  d
	ld   [hl],b
	ld   l,[hl]
	ld   h,[hl]
	ld   h,d
	sbc  l
	add  [hl]
	nop
	add  b
	sbc  e
	inc  bc
	and  d
	ld   [hl],b
	ld   l,[hl]
	ld   h,[hl]
	ld   h,d
	sbc  h
	xor  b
	ld   bc,$9B00
	dec  b
	and  h
	ld   bc,$A89C
	ld   bc,$9B00
	dec  b
	and  h
	ld   bc,$A89C
	ld   bc,$9D00
	dec  hl
	nop
	add  b
	xor  c
	ld   bc,$0072
	xor  c
	ld   bc,$0001
	xor  c
	ld   bc,$0006
	sbc  l
	ld   h,l
	nop
	add  b
	and  d
	ld   h,[hl]
	ld   c,[hl]
	ld   e,b
	ld   c,[hl]
	ld   e,h
	ld   c,[hl]
	ld   d,[hl]
	ld   e,b
	ld   h,[hl]
	ld   c,[hl]
	ld   e,b
	ld   c,[hl]
	ld   e,h
	ld   c,[hl]
	ld   h,b
	ld   e,b
	ld   e,b
	ld   c,[hl]
	ld   e,h
	ld   c,[hl]
	ld   h,[hl]
	ld   c,[hl]
	ld   e,b
	ld   c,[hl]
	ld   e,b
	ld   b,[hl]
	ld   c,d
	ld   c,[hl]
	ld   c,d
	ld   b,b
	ld   c,d
	jr   c,.unk_7EE2
	sbc  l
	dec  hl
	nop
	add  b
	xor  c
	ld   h,h
	ld   l,b
	nop
	sbc  l
	ld   [hl],l
	nop
	add  b
	and  d
	ld   e,b
	ld   c,[hl]
	ld   c,b
	ld   b,b
	ld   [hl],$40
	ld   c,b
	ld   c,[hl]
	ld   d,[hl]
	ld   c,[hl]
	ld   b,h
	ld   a,$36
	ld   a,$44
	ld   c,[hl]
	ld   e,b
	ld   d,d
	ld   c,d
	ld   b,b
	ldd  a,[hl]
	ld   b,b
	ld   c,d
	ld   d,d
	ld   e,b
	ld   d,b
	ld   c,d
	ld   b,b
	ld   d,b
	ld   b,b
	ld   c,d
	ld   d,b
	nop
	sbc  l
	add  b
	nop
	add  c
	and  d
	ld   h,b
	ld   h,d
	ld   h,[hl]
	ld   l,d
	and  h
	ld   h,[hl]
	and  d
	ld   e,b
	ld   e,h
	ld   h,b
	ld   h,d
	and  h
	ld   h,b
	and  d
	ld   d,d
	ld   e,b
	and  e
	ld   e,b
	and  d
	ld   c,[hl]
	ld   e,b
	and  e
	ld   e,b
	and  h
	ld   c,d
	and  e
	ld   c,b
	ld   c,[hl]
	nop
	sbc  l
	dec  sp
	nop
	add  b
	xor  c
	ld   h,[hl]
	ld   l,d
	nop
	sbc  l
	add  b
	nop
	add  c
	and  l
	ld   h,b
	and  h
	ld   e,h
	and  e
	ld   e,b
	ld   d,[hl]
	and  l
	ld   e,b
	ld   c,d
	nop
	sbc  l
	dec  hl
	nop
	add  b
	xor  c
	ld   bc,$0074
	sbc  l
	add  b
	nop
	add  c
	and  l
	ld   h,b
	and  h
	ld   e,h
	ld   h,[hl]
	and  l
	ld   [hl],b
	ld   [hl],h
	nop
	sbc  l
	di
	ld   l,e
	ld   hl,$58A4
	ld   d,[hl]
	ld   d,d
	ld   c,[hl]
	ld   c,d
	ld   c,b
	ld   b,[hl]
	and  e
	ld   b,h
	ld   b,d
	nop
	xor  c
	ld   bc,$0001
	sbc  l
	di
	ld   l,e
	ld   hl,$039B
	and  h
	jr   z,.unk_7FBB
	sbc  h
	jr   z,.unk_7F21
	ld   b,b
	jr   z,.unk_7F81
	sbc  e
	inc  bc
	and  e
	dec  d
	ld   b,$1A
	ld   b,$9C
	dec  d
	ld   bc,$1515
	nop
	xor  c
	ld   b,$06
	nop
	sbc  e
	inc  bc
	and  e
	dec  d
	ld   b,$1A
	ld   b,$9C
	dec  d
	ld   bc,$1515
	nop
	and  h
	jr   z,.unk_7FE2
	jr   z,.unk_7FE4
	ld   c,b
	ld   c,d
	xor  d
	jr   c,.unk_7FDF
	ldd  [hl],a
	xor  e
	ld   bc,$2EAA
	sbc  l
	di
	ld   l,e
	jr   nz,.unk_7F5D
	inc  l
	jr   z,.unk_7F61
	ld   bc,$9B00
	inc  bc
	and  d
	dec  d
	ld   bc,$0606
	ld   a,[de]
	ld   b,$0B
	ld   bc,$AA9C
	dec  d
	ld   b,$0B
	xor  e
	ld   bc,$15AA
	dec  d
	ld   a,[de]
	xor  e
	ld   bc,Reset
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ld   bc,Reset
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
JumpTo:
	jp   Unk_65C0
JumpToInitMusic:
	jp   InitMusic
	jp   Unk_66A4
	nop
	nop
	nop
	nop
	nop
	ld   e,d
	nop  
