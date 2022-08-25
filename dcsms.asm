; Dragon Crystal Disassembly
; Disassembled with Emulicious 

; Variable Definitions
.include "defines\system_constants.i"
.include "defines\asciitable.i"
.include "defines\ram_map.i"
.include "defines\item_constants.i"
.include "defines\game_variables.i"
.include "defines\monster_constants.i"
.include "defines\game_message_constants.i"
.include "defines\mask_constants.i"
.include "defines\music_constants.i"

; End Definitions

.MEMORYMAP
SLOTSIZE $4001
SLOT 0 $0000
SLOTSIZE $3FFF
SLOT 1 $4001
SLOTSIZE $4000
SLOT 2 $8000
DEFAULTSLOT 2
.ENDME

.ROMBANKMAP
BANKSTOTAL 8
BANKSIZE $4001
BANKS 1
BANKSIZE $3FFF
BANKS 1
BANKSIZE $4000
BANKS 6
.ENDRO

.BANK 0 SLOT 0
.ORG $0000

Origin:
	jp Initialize

; Empty space
.ds 5, $FF

.org $0008
Interrupt8:
	di
	ld a, e
	out (VDPControl), a
	ld a, $40
	or d
	out (VDPControl), a
	ei
	ret

; Empty space
.ds 5, $FF

.org $0018
Interrupt18:
	di
	ld a, e
	out (VDPControl), a
	ld a, d
	out (VDPControl), a
	ei
	ret

; Empty space
.ds 7, $FF

.org $0028
Interrupt28:
	ld a, $E2
	jp FinishVDPControlInterrupt

; Empty space
.ds 3, $FF

.org $0030
Interrupt30:
	ld a, $A2
	jp FinishVDPControlInterrupt

; Empty space
.ds 3, $FF

; Interrupt $38 is VBLANK
.org $0038
VBlank:
	jp VBlankHandler

FinishVDPControlInterrupt:
	out (VDPControl), a
	ld a, $81
	out (VDPControl), a
	ret

; Data from 42 to 65 (36 bytes)
Data_42:
	.dw $8026 $81A2 $82FF $83FF
	.dw $84FF $85FF $86FB $8700
	.dw $8800 $8900 $8A00

; Empty space
.ds 14, $FF

; Pause handler- must be at $0066
.org $0066
PauseHandler:
	push af
	ld a, ($C019)			; If $C019 is 10, do nothing
	cp $0A
	jr nz, ++
	ld a, (Autoplay)		; If autoplay is on, do nothing
	or a
	jr nz, +
	ld a, (PlayerSpeed)		; Get player speed
	cpl						; Toggle between fast speed ($FF) and slow speed ($00)
	ld (PlayerSpeed), a		; Save player speed
+:
	pop af
	retn

++:
	pop af
	retn

Initialize:
	di
	ld sp, $DFF0
	im 1
	ld hl, $FFFC			; Initialize mapper
	ld (hl), $00
	inc hl					; $FFFD
	ld (hl), $00
	inc hl					; $FFFE
	ld (hl), $01
	inc hl					; $FFFF
	ld (hl), $02
	ld hl, $C001			; Zero out C001-C100
	ld de, $C002
	ld bc, $00FE
	ld (hl), $00
	ldir
WaitForLineB0:
	in a, ($7E)				; Get scan line currently being drawn
	cp $B0					; Is it $B0?
	jr nz, WaitForLineB0	; If not, go back and wait
	xor a					; Zero out a
	out (VDPControl), a		; Write $C000 out to the VDP to select CRAM
	ld a, $C0
	out (VDPControl), a
	xor a					; Zero out a again
	ld b, $20				; Load counter with $20
	ex (sp), hl				; Wait
	ex (sp), hl
-:
	out (VDPData), a		; Set the next palette color to black
	nop						; Wait
	djnz -					; Do this $20 times (32 times) for the whole palette
	
DoReset:					; If the game is reset, it jumps back to this point
	di
	ld sp, $DFF0			; Initialize stack pointer
	xor a					; Zero out a
	ld ($C005), a			; Set $C005 to zero
	ld ($C002), a			; Set $C002 to zero
	in a, (VDPControl)		; Clear VDP status flags by reading from port
	ld b, $16				; Read $16 from $0042 and output to VDPControl
	ld c, VDPControl
	ld hl, Data_42
	otir
	ld hl, $C100			; Zero out $C100-D000
	ld de, $C101
	ld bc, $0EFF
	ld (hl), $00
	ldir
	ld hl, $DD00			; Zero out $DD00-DFF0
	ld de, TempoTimeout
	ld bc, $02EF
	ld (hl), $00
	ldir
	rst $30					; Interrupt30- write $A2, $81 to VDPControl
	call InitializePaletteInRAM ; Initializes more memory, sets a flag in PaletteInRAMStatus
	call VDPOut_59D			; Some sort of display? Title screen, maybe?
	ld a, $FF
	ld (PlayerSpeed), a		; Set speed to fast ($FF)
	ld a, $00				; Zero out $C019 and TableIndex1...
	ld ($C019), a
	ld (TableIndex1), a
	ei						; Done with setup?
	in a, ($DC)				; Read controller 1 input
	cpl						; Invert so 1 means button pressed
	and %00111111			; Ignore bits used for Player 2 controller up and down input- not useful
	cp %00000101			; %00000101 Up and left pressed together? Cheat?
	jp nz, _LABEL_111_		; If not, go here
	ld a, $01				; If pressed, set $C0D6 to $01
	ld ($C0D6), a
	jp _LABEL_111_
	ret						; Unreachable

_LABEL_111_:
	call UpdateControllerState
	call _LABEL_4BD_
	ld hl, _LABEL_111_
	push hl
	ld hl, TableIndex1
	ld a, ($C019)
	xor (hl)
	and $7F
	ld a, (hl)
	jr z, _LABEL_12A_
	ld ($C019), a
_LABEL_12A_:
	ld hl, JumpTable1
CallJumpTable:
	ld e, a					; Load index passed in a into lower byte
	ld d, $00				; $00XX where XX is index
	add hl, de
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp (hl)

_LABEL_137_:
	ld a, $01
	ld (VBlankAction), a
_LABEL_13C_:
	ld a, (VBlankAction)
	or a
	jr nz, _LABEL_13C_
	ret

_LABEL_143_:
	ld a, (VBlankAction)
	or a
	jr nz, _LABEL_143_
	ld a, $02
	ld (VBlankAction), a
_LABEL_14E_:
	ld a, (VBlankAction)
	cp $02
	jr z, _LABEL_14E_
	ret

_LABEL_156_:
	ld a, (VBlankAction)
	or a
	jr nz, _LABEL_156_
	ld a, $04
	ld (VBlankAction), a
_LABEL_161_:
	ld a, (VBlankAction)
	cp $04
	jr z, _LABEL_161_
	ret

_LABEL_169_:
	ld a, $06
	ld (VBlankAction), a
_LABEL_16E_:
	ld a, (VBlankAction)
	or a
	jr nz, _LABEL_16E_
	ret

_LABEL_175_:
	ld hl, (TitleScreenCounterLow)
	dec hl
	ld (TitleScreenCounterLow), hl
	ld a, l
	or h
	ret

; Jump Table from 17F to 1AE (24 entries, indexed by TableIndex1)
JumpTable1:
	.dw JumpTable1_BD7    JumpTable1_BD7  JumpTable1_BEA  JumpTable1_C6D
	.dw SetUpGameAutoplay Origin          JumpTable1_F4C  JumpTable1_F4C
	.dw JumpTable1_1058   JumpTable1_1127 JumpTable1_11A0 DoGameOver
	.dw JumpTable1_1424   JumpTable1_1435 JumpTable1_152F JumpTable1_16F4
	.dw JumpTable1_192B   JumpTable1_1B20 JumpTable1_1CA8 JumpTable1_1CD0
	.dw JumpTable1_1D11   JumpTable1_1D4B JumpTable1_153B JumpTable1_1566

VBlankHandler:
	push af
	in a, (VDPControl)
	and $80
	jp z, _LABEL_2D1_
	ld a, ($FFFF)			; Save current mapper value
	push af					; Save registers
	push bc
	push de
	push hl
	ex af, af'
	exx
	push af
	push bc
	push de
	push hl
	push ix
	push iy
	ld a, (VBlankAction)
	ld hl, VBlankActionTable
	jp CallJumpTable

; Jump Table from 1D1 to 1E6 (11 entries, indexed by VBlankAction)
VBlankActionTable:
	.dw VBlankUpdateSound     VBlankActionTable_20E VBlankActionTable_22F VBlankActionTable_26B
	.dw VBlankActionTable_275 VBlankActionTable_29D VBlankActionTable_2AC VBlankUpdateSound
	.dw VBlankUpdateSound     VBlankUpdateSound     VBlankUpdateSound

; 1st entry of Jump Table from 1D1 (indexed by VBlankAction)
VBlankUpdateSound:
	ld hl, EndVBlank
	push hl
	ld a, $07
	ld ($FFFF), a
	ld a, ($C002)
	or a
	jp nz, SilencePSG
	jp UpdateAllSound

EndVBlank:
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ex af, af'
	exx
	pop hl
	pop de
	pop bc
	pop af
	ld ($FFFF), a
	pop af
	ei
	ret

; 2nd entry of Jump Table from 1D1 (indexed by VBlankAction)
VBlankActionTable_20E:
	call CheckForReset
	call _LABEL_2DD_
	call VDPOut_2E9
	ld b, $00
-:
	djnz -
	ld a, (PaletteInRAMStatus)
	and $01
	call nz, WritePalette
	xor a
	ld (PaletteInRAMStatus), a
	ld ($C01F), a
	ld (VBlankAction), a
	jr VBlankUpdateSound

; 3rd entry of Jump Table from 1D1 (indexed by VBlankAction)
VBlankActionTable_22F:
	call CheckForReset
	call _LABEL_2DD_
	call VDPOut_2E9
	call _LABEL_2802_
	ld a, (PaletteInRAMStatus)
	and $01
	call nz, WritePalette
	call _LABEL_30CC_
	call _LABEL_28B2_
	call _LABEL_30DF_
	call _LABEL_28FD_
	xor a
	ld (PaletteInRAMStatus), a
	ld ($C01F), a
	ld a, (PlayerSpeed)		; Get player speed
	or a					; Is player speed slow ($00)?
	jr nz, PlayerSpeedIsFast		; If not (speed is fast/$FF), go here
	ld hl, VBlankAction
	inc (hl)
	jp VBlankUpdateSound

PlayerSpeedIsFast:
	ld hl, VBlankAction
	ld (hl), $00
	jp VBlankUpdateSound

; 4th entry of Jump Table from 1D1 (indexed by VBlankAction)
VBlankActionTable_26B:
	call CheckForReset
	xor a
	ld (VBlankAction), a
	jp VBlankUpdateSound

; 5th entry of Jump Table from 1D1 (indexed by VBlankAction)
VBlankActionTable_275:
	ld a, $00
	out (VDPControl), a
	ld a, $88
	out (VDPControl), a
	call _LABEL_2DD_
	call VDPOut_2E9
	ld b, $00
-:
	djnz -
	ld a, (PaletteInRAMStatus)
	and $01
	call nz, WritePalette
	xor a
	ld (PaletteInRAMStatus), a
	ld ($C01F), a
	ld hl, VBlankAction
	inc (hl)
	jp VBlankUpdateSound

; 6th entry of Jump Table from 1D1 (indexed by VBlankAction)
VBlankActionTable_29D:
	ld a, $00
	out (VDPControl), a
	ld a, $88
	out (VDPControl), a
	xor a
	ld (VBlankAction), a
	jp VBlankUpdateSound

; 7th entry of Jump Table from 1D1 (indexed by VBlankAction)
VBlankActionTable_2AC:
	ld a, ($C0D2)
	out (VDPControl), a
	ld a, $89
	out (VDPControl), a
	call VDPOut_2E9
	ld b, $00
-:
	djnz -
	ld a, (PaletteInRAMStatus)
	and $01
	call nz, WritePalette
	xor a
	ld (PaletteInRAMStatus), a
	ld ($C01F), a
	ld (VBlankAction), a
	jp VBlankUpdateSound

_LABEL_2D1_:
	ld a, ($C0B7)
	out (VDPControl), a
	ld a, $88
	out (VDPControl), a
	pop af
	ei
	ret

_LABEL_2DD_:
	ld a, ($C014)
	or a
	ret z
	dec a
	jr z, _LABEL_2E7_
	rst $28	; Interrupt28
	ret

_LABEL_2E7_:
	rst $30	; Interrupt30
	ret

VDPOut_2E9:
	ld c, VDPData
	ld a, $00
	out (VDPControl), a
	ld a, $7F
	out (VDPControl), a
	ld hl, $C500
	call OUTI64
	ld a, $80
	out (VDPControl), a
	ld a, $7F
	out (VDPControl), a
	ld hl, $C540
	call OUTI128
	ret

CheckForReset:
	in a, ($DD)				; Read input from port $DD
	cpl						; Invert- now 1 is on
	and %00010000			; Check if RESET is on
	jr z, NoReset					; If not, jump down
	ld a, (CurrentlyResetting)		; If it is set, check CurrentlyResetting
	or a					; Is it zero?
	ret nz					; If already set, return
	ld a, $FF				; If it is zero, set it to $FF
	ld (CurrentlyResetting), a
	jp DoReset
NoReset:
	xor a					; Zero out a
	ld (CurrentlyResetting), a		; Set CurrentlyResetting flag to zero
	ret

UpdateControllerState:
	ld a, (CurrentControllerState) 	; Read previously stored controller state
	cpl								; Invert- now 1 is off, as if it was read just from the port
	ld d, a							; Save inverted input
	in a, ($DC)						; Read from controller port
	cpl								; Invert- now 1 is on
	and %00111111					; Mask off bits used for player 2 controller
	ld (CurrentControllerState), a 	; Store updated value in controller state
	and d							; Get button press continued since last state
	ld (LastControllerState), a		; Load into LastControllerState
	ld a, (Autoplay)				; If autoplay is on, return
	or a
	ret z
	dec a
	jr z, _LABEL_33C_
	jr _LABEL_384_

_LABEL_33C_:
	ld a, (LastControllerState)
	and %00110000					; Check for A or B button press
	jr z, _LABEL_35C_				; If none, start autoplay
	xor a							; Otherwise, zero out autoplay variables
	ld (Autoplay), a
	ld (AutoplayDirection), a
	ld (AutoplayCountdownLow), a
	ld (AutoplayCountdownHigh), a
	ld (AutoplayVar3), a
	call _LABEL_42C_
	ld a, $02
	ld (TableIndex1), a
	ret

_LABEL_35C_:
	ld hl, (AutoplayCountdownLow)
	ld a, l
	or h
	jr nz, _LABEL_37C_
	xor a
	ld (Autoplay), a
	ld (AutoplayDirection), a
	ld (AutoplayCountdownLow), a
	ld (AutoplayCountdownHigh), a
	ld (AutoplayVar3), a
	call _LABEL_42C_
	ld a, $00
	ld (TableIndex1), a
	ret

_LABEL_37C_:
	dec hl
	ld (AutoplayCountdownLow), hl
	ld a, h
	cp $02
	ret nc
_LABEL_384_:
	ld a, (AutoplayVar3)
	or a
	jr z, _LABEL_3BE_
	dec a
	ld (AutoplayVar3), a
_LABEL_38E_:
	ld a, (AutoplayDirection)
	ld hl, Data_3DE
	ld b, $04
Loop_396:
	rrca
	jr c, _LABEL_39F_
	inc hl
	inc hl
	djnz Loop_396
	jr _LABEL_3BE_

_LABEL_39F_:
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, ($C105)
	add hl, de
	ld a, (hl)
	and $7F
	jr z, _LABEL_3BE_
	cp $06
	jr c, _LABEL_3B3_
	cp $0C
	jr c, _LABEL_3BE_
_LABEL_3B3_:
	ld a, (AutoplayDirection)
	ld (CurrentControllerState), a
	xor a
	ld (LastControllerState), a
	ret

_LABEL_3BE_:
	ld d, $01
	call GetRandomNumber
	and $03
_LABEL_3C5_:
	or a
	jr z, _LABEL_3CD_
	dec a
	rlc d
	jr _LABEL_3C5_

_LABEL_3CD_:
	ld a, d
	ld (AutoplayDirection), a
	call GetRandomNumber
	and $1F
	add a, $10
	ld (AutoplayVar3), a
	jp _LABEL_38E_

; Data from 3DE to 3E5 (8 bytes)
Data_3DE:
	.dw $FFE0 $0020 $FFFF $0001

_LABEL_3E6_:
	ld ix, $C400
	ld b, $08
	jr ContinueFromSavedFunction

_LABEL_3EE_:
	ld ix, $C100
	ld b, $18
ContinueFromSavedFunction:
	push bc
	ld hl, _LABEL_403_
	push hl
	ld l, (ix+0)
	ld h, (ix+1)
	ld a, l
	or h
	ret z
	jp (hl)

_LABEL_403_:
	ld de, $0020
	add ix, de
	pop bc
	djnz ContinueFromSavedFunction
	ret

_LABEL_40C_:
	call LoadPaletteToRAMMirror
_LABEL_40F_:
	ld a, $01
	ld (TableIndex3), a
	ld hl, PaletteInRAM
	ld de, $C021
	ld bc, $001F
	ld (hl), $00
	ldir
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	ld a, $04
	ld ($C0A2), a
	ret

_LABEL_42C_:
	ld a, $02
	ld (TableIndex3), a
	ld hl, PaletteInRAM
	ld de, PaletteInRAM2
	call LDI32
	ld a, $04
	ld ($C0A2), a
	ret

; Data from 440 to 442 (3 bytes)
Data_440:
	.db $CD $50 $07

_LABEL_443_:
	ld a, $03
	ld (TableIndex3), a
	ld a, $3F
	ld (PaletteInRAM), a
	ld hl, PaletteInRAM
	ld de, $C021
	call LDI32
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	ld a, $04
	ld ($C0A2), a
	ret

_LABEL_461_:
	ld a, $04
	ld (TableIndex3), a
	ld hl, PaletteInRAM
	ld de, PaletteInRAM2
	call LDI32
	ld a, $04
	ld ($C0A2), a
	ret

_LABEL_475_:
	ld c, (hl)
	ld b, $00
	ex de, hl
	ld hl, PaletteInRAM
	add hl, bc
	ld ($C0A4), hl
	inc de
	ld a, (de)
	ld ($C0A3), a
	dec de
	ex de, hl
	call LoadPaletteToRAMMirror
	ld a, $05
	ld (TableIndex3), a
	ld a, ($C0A3)
	or a
	jr z, _LABEL_4DC_
	ld b, a
	ld hl, ($C0A4)
	xor a
-:
	ld (hl), a
	inc hl
	djnz -
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	ld a, $04
	ld ($C0A2), a
	ret

_LABEL_4A9_:
	ld a, $06
	ld (TableIndex3), a
	ld hl, PaletteInRAM
	ld de, PaletteInRAM2
	call LDI32
	ld a, $04
	ld ($C0A2), a
	ret

_LABEL_4BD_:
	ld hl, $C0A2
	dec (hl)
	ret nz
	ld a, $04
	ld ($C0A2), a
	ld a, (TableIndex3)
	or a
	ret z
	call CallJumpTable3
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	ld hl, $C0A1
	inc (hl)
	ld a, (hl)
	cp $04
	ret nz
_LABEL_4DC_:
	xor a
	ld ($C0A1), a
	ld (TableIndex3), a
	ret

CallJumpTable3:
	ld a, (TableIndex3)			; Call func in jumptable based on TableIndex3
	ld hl, JumpTable3
	jp CallJumpTable

; Jump Table from 4ED to 4FA (7 entries, indexed by TableIndex3)
JumpTable3:
	.dw Origin         JumpTable3_4FB JumpTable3_504 JumpTable3_539
	.dw JumpTable3_542 JumpTable3_580 JumpTable3_589

; 2nd entry of Jump Table from 4ED (indexed by TableIndex3)
JumpTable3_4FB:
	ld a, ($C0A1)
	ld d, a
	ld a, $03
	sub d
	jr _LABEL_507_

; 3rd entry of Jump Table from 4ED (indexed by TableIndex3)
JumpTable3_504:
	ld a, ($C0A1)
_LABEL_507_:
	ld c, a
	ld de, PaletteInRAM2
	ld hl, PaletteInRAM
	ld b, $20
_LABEL_510_:
	push bc
	ld a, (de)
	and $03
	sub c
	jr nc, _LABEL_518_
	xor a
_LABEL_518_:
	ld (hl), a
	rlc c
	rlc c
	ld a, (de)
	and $0C
	sub c
	jr nc, _LABEL_524_
	xor a
_LABEL_524_:
	or (hl)
	ld (hl), a
	rlc c
	rlc c
	ld a, (de)
	and $30
	sub c
	jr nc, _LABEL_531_
	xor a
_LABEL_531_:
	or (hl)
	ld (hl), a
	inc hl
	inc de
	pop bc
	djnz _LABEL_510_
	ret

; 4th entry of Jump Table from 4ED (indexed by TableIndex3)
; Title screen?
JumpTable3_539:
	ld a, ($C0A1)
	ld d, a
	ld a, $03
	sub d
	jr _LABEL_545_

; 5th entry of Jump Table from 4ED (indexed by TableIndex3)
JumpTable3_542:
	ld a, ($C0A1)
_LABEL_545_:
	ld c, a
	ld de, PaletteInRAM2
	ld hl, PaletteInRAM
	ld b, $20
Loop_54E:
	push bc
	ld a, (de)
	and $03
	add a, c
	cp $04
	jr c, _LABEL_559_
	ld a, $03
_LABEL_559_:
	ld (hl), a
	rlc c
	rlc c
	ld a, (de)
	and $0C
	add a, c
	cp $10
	jr c, _LABEL_568_
	ld a, $0C
_LABEL_568_:
	or (hl)
	ld (hl), a
	rlc c
	rlc c
	ld a, (de)
	and $30
	add a, c
	cp $40
	jr c, _LABEL_578_
	ld a, $30
_LABEL_578_:
	or (hl)
	ld (hl), a
	inc hl
	inc de
	pop bc
	djnz Loop_54E
	ret

; 6th entry of Jump Table from 4ED (indexed by TableIndex3)
JumpTable3_580:
	ld a, ($C0A1)
	ld d, a
	ld a, $03
	sub d
	jr _LABEL_58C_

; 7th entry of Jump Table from 4ED (indexed by TableIndex3)
JumpTable3_589:
	ld a, ($C0A1)
_LABEL_58C_:
	ld c, a
	ld de, ($C0A4)
	ld hl, $0040
	add hl, de
	ex de, hl
	ld a, ($C0A3)
	ld b, a
	jp _LABEL_510_

VDPOut_59D:
	ld de, $0000
	ld hl, $0000
	ld bc, $0010
	call VDPOut_Loop_632
	ld de, $2000
	ld hl, $0000
	ld bc, $0010
	call VDPOut_Loop_632
	ld de, $3800
	ld hl, $0000
	ld bc, $0380
	call VDPOut_Loop_632
	ld de, $3F00
	ld a, $D0
	ld bc, $0001
	call VDPOut_618
	ld hl, $C500
	ld (hl), $D0
	inc hl
	ld de, $C502
	ld (hl), $00
	call LDI129
	call LDI64
	ret

_LABEL_5DE_:
	ld hl, $C100
	ld de, $C101
	ld bc, $02FF
	ld (hl), $00
	ldir
	ld de, $3F00
	ld a, $D0
	ld bc, $0001
	call VDPOut_618
	ld hl, $C500
	ld (hl), $D0
	inc hl
	ld de, $C502
	ld (hl), $00
	call LDI129
	call LDI64
	ret

_LABEL_608_:
	rst $08	; Interrupt8
	inc b
Loop_60A:
	ld a, b
	ld b, c
	ld c, VDPData
_LABEL_60E_:
	outi
	jr nz, _LABEL_60E_
	ld b, a
	ld c, $00
	djnz Loop_60A
	ret

VDPOut_618:
	ex af, af'
	rst $08	; Interrupt8
	ex af, af'
	inc b
	push bc
	ld b, c
	jr _LABEL_623_

Loop_620:
	push bc
	ld b, $00
_LABEL_623_:
	out (VDPData), a
	nop
	djnz -4
	pop bc
	djnz Loop_620
	ret

; Unused?
_LABEL_62C_:
	out ($BE), a
	nop
	djnz -5
	ret

VDPOut_Loop_632:
	rst $08	; Interrupt8
	inc b
	ld d, c
	ld c, VDPData
	push bc							; Nested counters- rows and columns, maybe?
	ld b, d
	jr Inner_Loop_63E

Outer_Loop_63B:
	push bc
	ld b, $00
Inner_Loop_63E:
	ld a, l
	out (c), a
	ld a, h
	jr +

+:
	out (c), a
	djnz Inner_Loop_63E
	pop bc
	djnz Outer_Loop_63B
	ret

VDPOut_64C:
	rst $08	; Interrupt8
	push bc
	ld b, c
	ld c, VDPData
_LABEL_651_:
	outi
	outi
	jr nz, _LABEL_651_
	ex de, hl
	ld bc, $0040
	add hl, bc
	ex de, hl
	pop bc
	djnz VDPOut_64C
	ret

VDPOut_661:
	rst $08	; Interrupt8
	push bc
	ld b, c
	ld c, VDPData
Loop_666:
	outi
	nop
	jr +

+:
	outi
	nop
	jr nz, Loop_666
	ex de, hl
	ld bc, $0040
	add hl, bc
	ld a, h
	cp $3F
	jr c, _LABEL_67C_
	ld h, $38
_LABEL_67C_:
	ex de, hl
	pop bc
	djnz VDPOut_661
	ret

_LABEL_681_:
	ld a, c
	add a, e
	xor e
	bit 6, a
	jr z, VDPOut_661
	ld a, c
	add a, e
	and $3F
	jr z, VDPOut_661
	ex af, af'
	ld a, c
	add a, e
	and $3F
	neg
	add a, c
	ld c, a
Loop_697:
	push bc
	push de
	rst $08	; Interrupt8
	ld b, c
	ld c, VDPData
_LABEL_69D_:
	outi
	nop
	jr _LABEL_6A2_

_LABEL_6A2_:
	outi
	nop
	jr nz, _LABEL_69D_
	ld a, e
	and $C0
	ld e, a
	rst $08	; Interrupt8
	ex af, af'
	ld b, a
	ex af, af'
_LABEL_6AF_:
	outi
	nop
	jr _LABEL_6B4_

_LABEL_6B4_:
	outi
	nop
	jr nz, _LABEL_6AF_
	pop de
	ex de, hl
	ld bc, $0040
	add hl, bc
	ld a, h
	cp $3F
	jr c, _LABEL_6C6_
	ld h, $38
_LABEL_6C6_:
	ex de, hl
	pop bc
	djnz Loop_697
	ret

_LABEL_6CB_:
	push bc
	ex af, af'
	rst $08	; Interrupt8
_LABEL_6CE_:
	ld a, (hl)
	out ($BE), a
	ex af, af'
	jr _LABEL_6D4_

_LABEL_6D4_:
	out ($BE), a
	ex af, af'
	inc hl
	dec c
	jr nz, _LABEL_6CE_
	ex af, af'
	ex de, hl
	ld bc, $0040
	add hl, bc
	ex de, hl
	pop bc
	djnz -26
	ret

_LABEL_6E6_:
	push bc
	rst $18	; Interrupt18
	ld b, c
	ld c, $BE
_LABEL_6EB_:
	ini
	nop
	jr _LABEL_6F0_

_LABEL_6F0_:
	ini
	nop
	jr nz, _LABEL_6EB_
	ex de, hl
	ld bc, $0040
	add hl, bc
	ld a, h
	cp $3F
	jr c, _LABEL_701_
	ld h, $38
_LABEL_701_:
	ex de, hl
	pop bc
	djnz -31
	ret

_LABEL_706_:
	ld a, c
	add a, e
	xor e
	bit 6, a
	jr z, _LABEL_6E6_
	ld a, c
	add a, e
	and $3F
	jr z, _LABEL_6E6_
	ex af, af'
	ld a, c
	add a, e
	and $3F
	neg
	add a, c
	ld c, a
Loop_71C:
	push bc
	push de
	rst $18	; Interrupt18
	ld b, c
	ld c, $BE
_LABEL_722_:
	ini
	nop
	jr _LABEL_727_

_LABEL_727_:
	ini
	nop
	jr nz, _LABEL_722_
	ld a, e
	and $C0
	ld e, a
	rst $18	; Interrupt18
	ex af, af'
	ld b, a
	ex af, af'
_LABEL_734_:
	ini
	nop
	jr _LABEL_739_

_LABEL_739_:
	ini
	nop
	jr nz, _LABEL_734_
	pop de
	ex de, hl
	ld bc, $0040
	add hl, bc
	ld a, h
	cp $3F
	jr c, _LABEL_74B_
	ld h, $38
_LABEL_74B_:
	ex de, hl
	pop bc
	djnz Loop_71C
	ret

LoadPaletteToRAMMirror:
	ld de, PaletteInRAM2
	jr DoLoadPalette

LoadPaletteToRAMPrimary:
	ld a, (PaletteInRAMStatus)		; Set palette in RAM status to dirty
	or $01
	ld (PaletteInRAMStatus), a
	ld de, PaletteInRAM
DoLoadPalette:
	ld a, (hl)
	inc hl
	push hl
	ld l, a
	ld h, $00
	add hl, de
	ex de, hl
	pop hl
	ld a, (hl)
	ld c, a
	ld b, $00
	inc hl
	ldir
	ret

InitializePaletteInRAM:
	ld hl, PaletteInRAM		; Zero out PaletteInRAM-C040 (End palette in RAM?)
	ld de, $C021
	ld bc, $001F
	ld (hl), $00
	ldir
	ld hl, PaletteInRAMStatus
	set 0, (hl)				; Set palette status flag clean
	ret

WritePalette:
	xor a
	out (VDPControl), a
	ld a, $C0
	out (VDPControl), a
	ld hl, PaletteInRAM
	ld c, VDPData
	jp OUTI32

; Decompress to VDP
DecompressToVDP:
	ld a, (hl)
	inc hl
	exx
	ld e, a
	ld d, $00
	exx
	ld b, a
-:
	push bc
	push de
	exx
	pop hl
	push hl
	exx
	call DecompressToVDP_7AA
	pop de
	inc de
	pop bc
	djnz -
	ret

DecompressToVDP_7AA:
	ld a, (hl)
	inc hl
	or a
	ret z
	ld b, a
	and $80
	ld c, a
	ld a, b
	and $7F
	ld b, a
DecompressToVDP_7B6:
	rst $08	; Interrupt8
	ex (sp), hl
	ex (sp), hl
	jr DecompressToVDP_7BB

DecompressToVDP_7BB:
	ld a, (hl)
	out (VDPData), a
	xor a
	or c
	jr z, DecompressToVDP_7C3
	inc hl
DecompressToVDP_7C3:
	exx
	add hl, de
	push hl
	exx
	pop de
	djnz DecompressToVDP_7B6
	xor a
	or c
	jp nz, DecompressToVDP_7AA
	inc hl
	jp DecompressToVDP_7AA

; Decompress to RAM
DecompressToRAM:
	ld a, (hl)
	inc hl
	exx
	ld e, a
	ld d, $00
	exx
	ld b, a
-:
	push bc
	push de
	exx
	pop hl
	push hl
	exx
	call DecompressToRAM_7EA
	pop de
	inc de
	pop bc
	djnz -
	ret

DecompressToRAM_7EA:
	ld a, (hl)
	inc hl
	or a
	ret z
	ld b, a
	and $80
	ld c, a
	ld a, b
	and $7F
	ld b, a
DecompressToRAM_7F6:
	ld a, (hl)
	ld (de), a
	bit 7, c
	jr z, DecompressToRAM_7FD
	inc hl
DecompressToRAM_7FD:
	exx
	add hl, de
	push hl
	exx
	pop de
	djnz DecompressToRAM_7F6
	bit 7, c
	jp nz, DecompressToRAM_7EA
	inc hl
	jp DecompressToRAM_7EA

_LABEL_80D_:
	ld a, $01
	exx
	ld e, $FF
	jr _LABEL_817_

_LABEL_814_:
	exx
	ld e, $00
_LABEL_817_:
	exx
	ld ($C0CC), a
	rst $08	; Interrupt8
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl
_LABEL_820_:
	ld a, (hl)
	exx
	ld c, VDPData
	ld b, $04
	ld h, a
	ld a, ($C0CC)
_LABEL_82A_:
	rra
	ld d, h
	jr c, _LABEL_82F_
	ld d, e
_LABEL_82F_:
	out (c), d
	djnz _LABEL_82A_
	exx
	inc hl
	dec bc
	ld a, b
	or c
	jp nz, _LABEL_820_
	ret

; These two files contain large unrolled loops of OUTI, LDI, and LDD
; instructions to improve performance.
.include "utils\outi.asm"
.include "utils\ldi.asm"
.include "utils\ldd.asm"

; $B7B Get Random Number
GetRandomNumber:
	push hl
	ld hl, (RNGSeed)
	ld a, h
	rrca
	rrca
	xor h
	rrca
	xor l
	rrca
	rrca
	rrca
	rrca
	xor l
	rrca
	adc hl, hl
	jr nz, ReseedRNG
	ld hl, $733C
ReseedRNG:
	ld a, r
	xor l
	ld (RNGSeed), hl
	pop hl
	ret

_LABEL_B9A_:
	ld a, (TableIndex3)
	or a
	ret z
	pop hl
	jp _LABEL_137_

_LABEL_BA3_:
	call InitializePaletteInRAM
	ld a, $01
	ld ($C014), a
	call _LABEL_137_
	di
	jp VDPOut_59D

; Data from BB2 to BC7 (22 bytes) - Unused?
Data_BB2:
	.db $3E $0F $11 $00 $2B $21 $D8 $80
	.db $C3 $14 $08 $3E $0F $11 $00 $30
	.db $21 $86 $80 $C3 $14 $08

_LABEL_BC8_:
	xor a
	out (VDPControl), a
	ld a, $88
	out (VDPControl), a
	xor a
	out (VDPControl), a
	ld a, $89
	out (VDPControl), a
	ret

; 1st entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_BD7:
	call _LABEL_B9A_
	ld a, $26
	out (VDPControl), a
	ld a, $80
	out (VDPControl), a
	ld a, $02
	ld (TableIndex1), a
	jp _LABEL_137_

; 3rd entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_BEA:
	call _LABEL_B9A_
	ld a, $07
	ld ($FFFF), a
	call StopAllSound
	ld a, $02
	ld ($FFFF), a
	call _LABEL_BA3_
	call _LABEL_5DE_
	call _LABEL_BC8_
	ld a, $06
	ld ($FFFF), a
	ld hl, $8B6E
	ld de, $2000
	call DecompressToVDP
	ld hl, $99B4
	ld de, $0000
	call DecompressToVDP
	ld hl, $8934
	ld de, $3500
	call DecompressToVDP
	ld hl, $878D
	ld de, $1A00
	call DecompressToVDP
	ld hl, $80D6
	ld de, $CB00
	call DecompressToRAM
	ld hl, $CB00
	ld de, $3886
	ld bc, $0A36
	call VDPOut_64C
	ld hl, $81E6
	ld de, $3A98
	ld bc, $0A10
	call VDPOut_64C
	ld hl, $0D0C
	ld ($C100), hl
	ld hl, $8000
	call LoadPaletteToRAMPrimary
	ld a, $02
	ld ($C014), a
	ei
	ld hl, $0384
	ld (TitleScreenCounterLow), hl
	ld a, $03
	ld (TableIndex1), a
	jp _LABEL_137_

; 4th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_C6D:
	call _LABEL_137_
	ld a, (LastControllerState)
	and $30
	jr z, _LABEL_CF5_
	ld a, (CurrentControllerState)
	and $0F
	cp $0A
	jr z, SetUpGame
_LABEL_C80_:
	xor a
	ld ($C0D6), a
	call _LABEL_42C_
	ld a, $06
	ld (TableIndex1), a
	jp _LABEL_137_

SetUpGame:
	ld a, ($C0D6)				; If $C0D6 is zero, jump to _LABEL_C80_
	or a
	jr z, _LABEL_C80_
	xor a
	ld ($C0D6), a
	ld a, $01
	ld (Floor), a
	ld a, $01
	ld (CharacterLevel), a
	ld a, $30
	ld (Food), a
	ld hl, $03E7
	ld (CurrentHPLow), hl
	ld (MaxHPLow), hl
	ld hl, $FFFF
	ld (NextLevelLow), hl
	xor a
	ld ($C62A), a
	ld (ExperienceLow), a
	ld (ExperienceHigh), a
	ld ($C627), a
	ld (MoneyLow), a
	ld (MoneyMid), a
	ld (MoneyHigh), a
	ld a, $1E
	ld (BasePW), a
	ld (BaseAC), a
	ld a, DaggerSword
	ld (EquippedWeapon), a
	ld a, RobeArmor
	ld (EquippedArmor), a
	call _LABEL_101A_
	ld a, $07
	ld ($FFFF), a
	call StopAllSound
	call _LABEL_461_
	ld a, $0D
	ld (TableIndex1), a
	jp _LABEL_137_

_LABEL_CF5_:
	call _LABEL_3EE_
	call _LABEL_1D60_
	call _LABEL_175_
	jp nz, _LABEL_137_
	call _LABEL_42C_
	ld a, $04
	ld (TableIndex1), a
	jp _LABEL_137_

; Palette
_LABEL_D0C_:
	inc (ix+24)
	ld a, (ix+24)
	cp $08
	ret c
	ld (ix+24), $00
	ld (ix+2), $01
	ld (ix+15), $3F
	ld (ix+17), $80
	ld (ix+21), $08
	ld (ix+22), <Data_EE0
	ld (ix+23), >Data_EE0
	ld (ix+0), <_LABEL_D3A_
	ld (ix+1), >_LABEL_D3A_
	ret

_LABEL_D3A_:
	ld a, (ix+21)
	or a
	jr z, _LABEL_D45_
	dec a
	ld (ix+21), a
	ret

_LABEL_D45_:
	ld a, $02
	ld (ix+21), a
	ld l, (ix+22)
	ld h, (ix+23)
	ld a, (hl)
	ld (ix+3), a
	inc hl
	ld (ix+22), l
	ld (ix+23), h
	inc (ix+24)
	ld a, (ix+24)
	cp $02
	jr z, _LABEL_D75_
	cp $08
	ret c
	ld (ix+2), $00
	ld (ix+0), <_LABEL_D81_
	ld (ix+1), >_LABEL_D81_
	ret

_LABEL_D75_:
	ld a, $06
	ld ($FFFF), a
	ld hl, $800C
	call _LABEL_475_
	ret

_LABEL_D81_:
	ld a, $04
	ld ($FFFF), a
	ld hl, $800A
	ld de, $1C00
	ld bc, $0180
	call _LABEL_608_
	ld a, $06
	ld ($FFFF), a
	ld hl, $8466
	ld de, $1400
	call DecompressToVDP
	ld (ix+2), $01
	ld (ix+3), $BD
	ld (ix+15), $00
	ld (ix+17), $80
	ld (ix+28), $00
	ld (ix+29), $02
	ld (ix+0), <_LABEL_DC1_
	ld (ix+1), >_LABEL_DC1_
	ret

_LABEL_DC1_:
	ld l, (ix+26)
	ld h, (ix+15)
	ld e, (ix+28)
	ld d, (ix+29)
	add hl, de
	ld a, h
	cp $80
	jr nc, _LABEL_DE4_
	ld (ix+26), l
	ld (ix+15), h
	ld hl, $0040
	add hl, de
	ld (ix+28), l
	ld (ix+29), h
	ret

_LABEL_DE4_:
	ld (ix+26), $00
	ld (ix+15), $80
	ld (ix+0), <_LABEL_E01_
	ld (ix+1), >_LABEL_E01_
	ld (ix+21), $20
	ld (ix+0), <_LABEL_E01_
	ld (ix+1), >_LABEL_E01_
	ret

_LABEL_E01_:
	ld a, (ix+21)
	or a
	jr z, _LABEL_E0C_
	dec a
	ld (ix+21), a
	ret

_LABEL_E0C_:
	ld (ix+24), $00
	ld (ix+3), $C1
	ld (ix+21), $08
	ld (ix+22), <Data_EE8
	ld (ix+23), >Data_EE8
	ld (ix+0), <_LABEL_E29_
	ld (ix+1), >_LABEL_E29_
	ret

_LABEL_E29_:
	ld a, (ix+21)
	or a
	jr z, _LABEL_E34_
	dec a
	ld (ix+21), a
	ret

_LABEL_E34_:
	ld a, $03
	ld (ix+21), a
	ld l, (ix+22)
	ld h, (ix+23)
	ld a, (hl)
	ld (ix+3), a
	inc hl
	ld (ix+22), l
	ld (ix+23), h
	inc (ix+24)
	ld a, (ix+24)
	cp $0B
	ret c
	ld a, MusicTrack81
	ld (MusicQueue), a
	ld a, $40
	ld (ix+21), a
	ld (ix+0), <_LABEL_E66_
	ld (ix+1), >_LABEL_E66_
	ret

_LABEL_E66_:
	ld a, (ix+21)
	or a
	jr z, _LABEL_E71_
	dec a
	ld (ix+21), a
	ret

_LABEL_E71_:
	ld a, $06
	ld ($FFFF), a
	ld hl, $8016
	call _LABEL_475_
	ld a, $40
	ld (ix+21), a
	ld (ix+0), <_LABEL_E8A_
	ld (ix+1), >_LABEL_E8A_
	ret

_LABEL_E8A_:
	ld a, (ix+21)
	or a
	jr z, _LABEL_E95_
	dec a
	ld (ix+21), a
	ret

_LABEL_E95_:
	ld a, $06
	ld ($FFFF), a
	ld hl, $8020
	call _LABEL_475_
	ld (ix+0), <_LABEL_EA9_
	ld (ix+1), >_LABEL_EA9_
	ret

_LABEL_EA9_:
	ld a, (TableIndex3)
	or a
	ret nz
	ld a, $06
	ld ($FFFF), a
	ld hl, $8096
	ld de, $3D52
	ld bc, $0220
	call VDPOut_64C
	ld (ix+0), <_LABEL_EC8_
	ld (ix+1), >_LABEL_EC8_
	ret

_LABEL_EC8_:
	inc (ix+24)
	bit 3, (ix+24)
	ld hl, $0000
	jr z, _LABEL_ED7_
	ld hl, $0F29
_LABEL_ED7_:
	ld ($C03E), hl
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	ret

; Data from EE0 to EF2 (19 bytes)
Data_EE0:
	.db $B9 $BA $BB $BC $BB $BA $B9 $00

Data_EE8:
	.db $C1 $C0 $BF $BE $BF $C0 $C1 $C2
	.db $C1 $C2 $C1

; 5th entry of Jump Table from 17F (indexed by TableIndex1)
SetUpGameAutoplay:
	ld a, $01
	ld (Autoplay), a
	ld hl, $0210
	ld (AutoplayCountdownLow), hl
	ld a, $01
	ld (CharacterLevel), a
	ld a, $30
	ld (Food), a
	ld hl, $0064
	ld (CurrentHPLow), hl
	ld (MaxHPLow), hl
	ld hl, $FFFF
	ld (NextLevelLow), hl
	xor a
	ld ($C62A), a
	ld (ExperienceLow), a
	ld (ExperienceHigh), a
	ld ($C627), a
	ld (MoneyLow), a
	ld (MoneyMid), a
	ld (MoneyHigh), a
	ld a, $0A
	ld (BasePW), a
	ld (BaseAC), a
	ld a, $01
	ld (Floor), a
	ld a, DaggerSword
	ld (EquippedWeapon), a
	ld a, RobeArmor
	ld (EquippedArmor), a
	ld a, $08
	ld (TableIndex1), a
	jp _LABEL_137_

; 7th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_F4C:
	call _LABEL_B9A_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_BA3_
	call _LABEL_5DE_
	ld a, $FB
	out (VDPControl), a
	ld a, $86
	out (VDPControl), a
	ld hl, $C400
	ld de, $C401
	ld bc, $00FF
	ld (hl), $00
	ldir
	ld a, $01
	ld hl, $C935
	ld b, $10
-:
	ld (hl), a
	inc a
	inc hl
	djnz -
	ld hl, $C935
	ld de, $C945
	call LDI16
	ld hl, $C935
	ld de, $C955
	call LDI16
	ld hl, $C935
	ld de, $C965
	call LDI16
	ld hl, $C935
	call _LABEL_1000_
	ld hl, $C945
	call _LABEL_1000_
	ld hl, $C955
	call _LABEL_1000_
	ld hl, $C965
	call _LABEL_1000_
	ld a, $01
	ld (CharacterLevel), a
	ld a, $01
	ld (Floor), a
	ld a, $30
	ld (Food), a
	ld hl, $0064
	ld (CurrentHPLow), hl
	ld (MaxHPLow), hl
	ld hl, $0014
	ld (NextLevelLow), hl
	xor a
	ld ($C62A), a
	ld (ExperienceLow), a
	ld (ExperienceHigh), a
	ld ($C627), a
	ld (MoneyLow), a
	ld (MoneyMid), a
	ld (MoneyHigh), a
	ld (BasePW), a
	ld (BaseAC), a
	ld a, DaggerSword
	ld (EquippedWeapon), a
	ld a, RobeArmor
	ld (EquippedArmor), a
	call _LABEL_101A_
	call _LABEL_42C_
	ld a, $08
	ld (TableIndex1), a
	jp _LABEL_137_

_LABEL_1000_:
	ld e, l
	ld d, h
	ld b, $10
_LABEL_1004_:
	push bc
	push hl
	call GetRandomNumber
	and $0F
	ld c, a
	ld b, $00
	add hl, bc
	ld b, (hl)
	ld a, (de)
	ld (hl), a
	ld a, b
	ld (de), a
	inc de
	pop hl
	pop bc
	djnz _LABEL_1004_
	ret

_LABEL_101A_:
	ld hl, EquippedWeapon
	res 7, (hl)
	inc hl
	ld de, $C902
	ld (hl), $00
	call LDI6
	ld a, (EquippedWeapon)
	cp $0E                   ; GreatSword?
	jr nz, _LABEL_1034_
	ld a, $03
	ld ($C901), a
_LABEL_1034_:
	ld hl, EquippedArmor
	res 7, (hl)
	inc hl
	ld de, $C90A
	ld (hl), $00
	call LDI6
	ld hl, $C910
	ld de, $C911
	ld (hl), $00
	call LDI36
	jp EquipWeaponAndArmor

; Text "INIT"
.include "ui\init.asm"

; 9th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_1058:
	call _LABEL_B9A_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_BA3_
	call _LABEL_BC8_
	call _LABEL_5DE_
	ld de, $2B00
	ld hl, $80D8
	call _LABEL_80D_
	ld de, $3000
	ld hl, $8086
	call _LABEL_80D_
	ld hl, $8000
	ld de, $2A80
	call DecompressToVDP
	ld a, (Floor)
	dec a
	jr z, _LABEL_108F_
	call GetRandomNumber
	and $03
_LABEL_108F_:
	ld (FloorType), a
	call _LABEL_2A22_
	call _LABEL_2941_
	call _LABEL_2492_
	call _LABEL_263B_
	call _LABEL_1F8F_
	call SelectMonstersForFloor
	call _LABEL_20BA_
	ld hl, ($C105)
	ld de, $2D00
	add hl, de
	call _LABEL_2DFA_
	ld hl, _LABEL_311A_
	ld ($C100), hl
	ld hl, _LABEL_3CE6_
	ld ($C120), hl
	ld hl, PreventArmorRust
	ld de, ParalysisTicksLeft
	ld (hl), $00
	call LDI5
	ld hl, $8064
	call LoadPaletteToRAMMirror
	call _LABEL_27E3_
	call LoadMonsterPalette
	ld a, $04
	ld ($FFFF), a
	ld hl, $8000
	call LoadPaletteToRAMMirror
	ld a, (EquippedWeapon)
	dec a
	and $0C
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, SwordColors
	add hl, de
	ld de, $C077
	ldi
	call _LABEL_40F_
	ld a, $02
	ld ($C014), a
	ld a, (Floor)				; Select music for floor
	ld d, $84					; Start with song $84
	cp $0B						; If floor is 11 or greater, increment song
	jr c, PlayFloorMusic
	inc d
	cp $15						; If floor is 21 or greater, increment song
	jr c, PlayFloorMusic
	inc d
PlayFloorMusic:
	ld a, d
	ld (MusicQueue), a
	xor a
	ld (CurrentMessage), a
	ld ($CAC5), a
	ld a, $3C
	ld (PlayerIdleTimer), a
	ei
	ld a, $0A
	ld (TableIndex1), a
	jp _LABEL_143_

; Sword colors
.include "items\appearance\sword_color_palette.asm"

; 10th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_1127:
	call _LABEL_B9A_
	call _LABEL_BC8_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_BA3_
	ld de, $2B00
	ld hl, $80D8
	call _LABEL_80D_
	ld de, $3000
	ld hl, $8086
	call _LABEL_80D_
	ld de, $3000
	call _LABEL_2941_
	call _LABEL_2A22_
	ld hl, ($C105)
	ld de, $2D00
	add hl, de
	call _LABEL_2DFA_
	call _LABEL_2E69_
	call _LABEL_1F4F_
	ld hl, $8064
	call LoadPaletteToRAMMirror
	call _LABEL_27E3_
	call LoadMonsterPalette
	ld a, $04
	ld ($FFFF), a
	ld hl, $8000
	call LoadPaletteToRAMMirror
	ld a, (EquippedWeapon)					; Which color is the sword, 0, 1, 2, 3?
	dec a
	and $0C
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, SwordColors
	add hl, de
	ld a, (hl)
	ld ($C077), a
	call _LABEL_40F_
	ld a, $3C
	ld (PlayerIdleTimer), a
	ld a, $02
	ld ($C014), a
	ei
	ld a, $0A
	ld (TableIndex1), a
	jp _LABEL_143_

; 11th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_11A0:
	call _LABEL_3EE_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_2E6A_
	call _LABEL_1F4F_
	call _LABEL_1D60_
	ld a, ($C606)
	or a
	call nz, _LABEL_225C_
	ld a, ($C60E)
	or a
	call nz, _LABEL_2198_
	call _LABEL_2A6C_
	call _LABEL_2DAD_
	jp _LABEL_143_

; Unreachable?
_LABEL_11C8_:
	call _LABEL_42C_
	ld a, $0B
	ld (TableIndex1), a
	jp _LABEL_143_

; Just the "Game" from "Game Over"- is Game used elsewhere?
.include "ui\game_over_screen_1.asm"

; 12th entry of Jump Table from 17F (indexed by TableIndex1)
DoGameOver:
	call _LABEL_B9A_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_BA3_
	call _LABEL_BC8_
	call _LABEL_5DE_
	ld hl, $C400
	ld de, $C401
	ld bc, $00FF
	ld (hl), $00
	ldir
	ld de, $2B00
	ld hl, $80D8
	ld a, $09
	call _LABEL_814_
	ld de, $3000
	ld hl, $8086
	ld a, $09
	call _LABEL_814_
	ld a, $07
	ld ($FFFF), a
	ld hl, $ACC7
	ld de, $1800
	call DecompressToVDP
	ld a, $06
	ld ($FFFF), a
	ld hl, $99B4
	ld de, $0000
	call DecompressToVDP
	ld a, (FloorType)
	add a, a
	ld e, a
	ld d, $00
	ld hl, Data_142D
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld de, $38CC
	ld bc, $0A10
	call VDPOut_64C
	ld a, $07
	ld ($FFFF), a
	ld de, $3964
	rst $08	; Interrupt8
	ld a, (CharacterLevel)
	ld b, a
	ld hl, HUDCharacterClass-22
	ld de, $0016
-:
	add hl, de
	djnz -
	ld c, VDPData
	call OUTI22
	ld de, $3A24
	rst $08	; Interrupt8
	ld c, VDPData
	ld hl, HUDFL
	call OUTI8
	ld hl, (Floor)
	ld h, $00
	call _LABEL_2C98_
	ld e, $00
	ld hl, $C0B2
	ld a, (hl)
	call _LABEL_1940_
	dec hl
	ld a, (hl)
	add a, $80
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ld de, $3AE4
	rst $08	; Interrupt8
	ld c, VDPData
	ld hl, $AE3B
	call OUTI10
	ld hl, MoneyHigh
	ld e, $00
	ld b, $02
_LABEL_1298_:
	ld a, (hl)
	call _LABEL_1940_
	dec hl
	ld a, (hl)
	rrca
	rrca
	rrca
	rrca
	call _LABEL_1940_
	djnz _LABEL_1298_
	ld a, (hl)
	and $0F
	add a, $80
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ld de, $3B8C
	rst $08	; Interrupt8
	ld c, VDPData
	ld a, ($C63F)
	cp $FE
	jr c, _LABEL_12DD_
	jr z, _LABEL_12CA_
	ld hl, $AEA7
	ld b, $14
	ld a, $11
	jr _LABEL_12D1_

_LABEL_12CA_:
	ld hl, $AEBC
	ld b, $11
	ld a, $11
_LABEL_12D1_:
	outi
	nop
	jr _LABEL_12D6_

_LABEL_12D6_:
	out (c), a
	nop
	jr nz, _LABEL_12D1_
	jr _LABEL_131F_

_LABEL_12DD_:
	add a, a
	ld e, a
	ld d, $00
	ld hl, $AE5F
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld b, (hl)
	inc hl
	in a, (VDPData)
	nop
	jr _LABEL_12F0_

_LABEL_12F0_:
	in a, (VDPData)
	nop
	jr _LABEL_12F5_

_LABEL_12F5_:
	in a, (VDPData)
	nop
	jr _LABEL_12FA_

_LABEL_12FA_:
	in a, (VDPData)
	nop
	jr _LABEL_12FF_

_LABEL_12FF_:
	ld c, VDPData
	ld a, $11
_LABEL_1303_:
	outi
	nop
	jr _LABEL_1308_

_LABEL_1308_:
	out (c), a
	nop
	jr nz, _LABEL_1303_
	ld hl, $AEA1
	ld bc, $06BE
	ld a, $11
_LABEL_1315_:
	outi
	nop
	jr _LABEL_131A_

_LABEL_131A_:
	out (c), a
	nop
	jr nz, _LABEL_1315_
_LABEL_131F_:
	ld a, (ContinuesSpent)
	cp ContinueLimit
	jp nc, UnableToContinue
	ld d, a
	ld a, (Floor)
	and $FC
	rrca
	rrca
	inc a
	add a, d
	ld l, a
	ld h, $00
	call _LABEL_2C98_
	ld a, ($C0B3)
	ld d, a
	ld a, ($C0B2)
	add a, a
	add a, a
	add a, a
	add a, a
	ld e, a
	ld a, ($C0B1)
	or e
	ld e, a
	ld hl, (MoneyMid)
	ld a, l
	sub e
	daa
	ld l, a
	ld a, h
	sbc a, d
	daa
	ld h, a
	jr c, UnableToContinue
	ld (MoneyMid), hl
	ld de, Data_3C90
	rst $08	; Interrupt8
	ld c, VDPData
	ld hl, $AE45
	call OUTI16
	ld de, $3CAA
	rst $08	; Interrupt8
	ld c, VDPData
	ld hl, $AE55
	call OUTI6
	ld de, $3D2A
	rst $08	; Interrupt8
	ld c, VDPData
	ld hl, $AE5B
	call OUTI4
	ld hl, $4F98
	ld ($C100), hl
	ld a, $C4
	ld ($C103), a
	ld de, $1400
	rst $08	; Interrupt8
	ld a, (EquippedArmor)
	cp CuirassArmor                 ; $13 or less
	jr c, PlayerDeadWithLightArmor
	cp PlateArmor                   ; $16 or less
	jr c, PlayerDeadWithMediumArmor
	ld a, $02
	ld hl, $B5EE
	jr SelectGameOverGraphics

PlayerDeadWithMediumArmor:
	ld a, $04
	ld hl, $B24A
	jr SelectGameOverGraphics

PlayerDeadWithLightArmor:
	ld a, $04
	ld hl, $95CA
SelectGameOverGraphics:
	ld ($FFFF), a
	ld c, VDPData
	call OUTI128
	call OUTI128
	call OUTI128
	jr _LABEL_13BF_

UnableToContinue:
	ld hl, _LABEL_5010_
	ld ($C100), hl
_LABEL_13BF_:
	ld hl, _LABEL_5030_
	ld ($C120), hl
	ld a, $02
	ld ($FFFF), a
	ld hl, $8064
	call LoadPaletteToRAMMirror
	ld a, $07
	ld ($FFFF), a
	ld a, (FloorType)
	and $07
	rrca
	rrca
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, $ADF3
	add hl, de
	ld de, PaletteInRAM2
	call LDI32
	ld a, $04
	ld ($FFFF), a
	ld hl, $8000
	call LoadPaletteToRAMMirror
	ld a, (EquippedWeapon)
	dec a
	and $0C
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, SwordColors
	add hl, de
	ld de, $C08E
	ldi
	call _LABEL_40F_
	xor a
	ld ($C0D5), a
	ld a, $02
	ld ($C014), a
	ld a, MusicTrack83			; Play Game Over music
	ld (MusicQueue), a
	ei
	ld a, $0C
	ld (TableIndex1), a
	jp _LABEL_137_

; 13th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_1424:
	call _LABEL_3EE_
	call _LABEL_1D60_
	jp _LABEL_137_

; Data from 142D to 1434 (8 bytes)
; Pointers to graphics data
Data_142D:
	.dw $81E6 $8326 $83C6 $8286

; 14th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_1435:
	call _LABEL_B9A_
	ld a, $01
	ld ($C014), a
	call _LABEL_137_
	di
	call VDPOut_59D
	call _LABEL_5DE_
	call _LABEL_BC8_
	ld a, $02
	ld ($FFFF), a
	ld de, $2B00
	ld hl, $80D8
	ld a, $08
	call _LABEL_814_
	ld de, $3000
	ld hl, $8086
	ld a, $08
	call _LABEL_814_
	ld a, $06
	ld ($FFFF), a
	ld hl, $99B4
	ld de, $0000
	call DecompressToVDP
	ld hl, $A63A
	ld de, $1C00
	call DecompressToVDP
	ld de, $1200
	rst $08	; Interrupt8
	ld a, (EquippedArmor)
	cp CuirassArmor                 ; Cuirass or less
	jr c, _LABEL_149F_
	cp PlateArmor                   ; Plate armor or less
	jr c, _LABEL_1495_
	ld a, $02						; Base armor graphics?
	ld hl, $A02E
	ld de, $B5EE
	jr _LABEL_14A7_

_LABEL_1495_:
	ld a, $04						; Gray armor graphics?
	ld hl, $9C8A
	ld de, $B24A
	jr _LABEL_14A7_

_LABEL_149F_:
	ld a, $04						; Elaborate gray armor graphics?
	ld hl, $800A
	ld de, $95CA
_LABEL_14A7_:
	ld ($FFFF), a
	ld c, VDPData
	call OUTI128
	call OUTI128
	call OUTI128
	ex de, hl
	ld de, $1400
	rst $08	; Interrupt8
	call OUTI128
	call OUTI128
	call OUTI128
	ld a, $06
	ld ($FFFF), a
	ld a, (FloorType)
	add a, a
	ld e, a
	ld d, $00
	ld hl, Data_151F
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	push hl
	ex de, hl
	ld de, $3A98
	ld bc, $0A10
	call VDPOut_64C
	pop hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	call LoadPaletteToRAMMirror
	ld a, (EquippedWeapon)
	dec a
	and $0C
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, SwordColors
	add hl, de
	ld de, $C077
	ldi
	call _LABEL_443_
	ld hl, _LABEL_505C_
	ld ($C100), hl
	ld a, $02
	ld ($C014), a
	ei
	xor a
	ld ($C0B6), a
	ld hl, $003C
	ld (TitleScreenCounterLow), hl
	ld a, $0E
	ld (TableIndex1), a
	jp _LABEL_137_

; Data from 151F to 152E (16 bytes)
; Pointers to graphics data
Data_151F:
	.dw $81E6 $8026 $8286 $8042
	.dw $8326 $805E $83C6 $807A

; 15th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_152F:
	call _LABEL_3EE_
	call _LABEL_1D60_
	call _LABEL_137_
	jp _LABEL_137_

; 23rd entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_153B:
	ld a, $A7
	out (VDPControl), a
	ld a, $8A
	out (VDPControl), a
	ld a, $36
	out (VDPControl), a
	ld a, $80
	out (VDPControl), a
	ld hl, EndingText
	ld ($C0B8), hl
	xor a
	ld ($C0B7), a
	ld a, MusicTrack82
	ld (MusicQueue), a
	ld hl, $04A0
	ld (TitleScreenCounterLow), hl
	ld a, $17
	ld (TableIndex1), a
	ret

; 24th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_1566:
	ld a, ($C0B7)
	neg
	ld d, a
	and $07
	call z, _LABEL_15DF_
	ld hl, $C0B7
	dec (hl)
	call _LABEL_175_
	jp nz, _LABEL_156_
	ld a, $06
	out (VDPControl), a
	ld a, $80
	out (VDPControl), a
	xor a
	ld ($C0B7), a
	ld ($C0D3), a
	ld a, $30
	ld (Food), a
	ld hl, $03E7
	ld (CurrentHPLow), hl
	ld (MaxHPLow), hl
	xor a
	ld ($C62A), a
	ld (ExperienceLow), a
	ld (ExperienceHigh), a
	ld ($C627), a
	ld (MoneyLow), a
	ld (MoneyMid), a
	ld (MoneyHigh), a
	ld a, $1E
	ld (BasePW), a
	ld (BaseAC), a
	ld hl, $D300
	ld de, $D301
	ld (hl), $00
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI128
	call _LABEL_42C_
	ld a, $11
	ld (TableIndex1), a
	ret

_LABEL_15DF_:
	ld a, ($C0B7)
	neg
	and $F8
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, $3D40 ; Hits middle of an instruction in _LABEL_3D34_?
	add hl, de
	ex de, hl
	rst $08	; Interrupt8
	ld hl, ($C0B8)
	ld a, (hl)
	cp $FF
	jr z, _LABEL_1605_
	ld c, VDPData
	outi
	jr _LABEL_15FF_

_LABEL_15FF_:
	outi
	ld ($C0B8), hl
	ret

_LABEL_1605_:
	xor a
	out (VDPData), a
	jr _LABEL_160A_

_LABEL_160A_:
	jr _LABEL_160C_

_LABEL_160C_:
	out (VDPData), a
	ret

.include "ui\ending.asm"

; 16th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_16F4:
	call _LABEL_B9A_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_BA3_
	call _LABEL_BC8_
	ld de, $38C0
	ld hl, $0158
	ld bc, $0240
	call VDPOut_Loop_632
	xor a
	ld (CurrentMessage), a
	ld ($CAC5), a
	ld de, $2B00
	ld hl, $80D8
	call _LABEL_80D_
	ld de, $3000
	ld hl, $8086
	call _LABEL_80D_
	ld hl, $8000
	ld de, $2A80
	call DecompressToVDP
	ld de, $0B00
	ld hl, $80D8
	call _LABEL_80D_
	ld de, $1000
	ld hl, $8086
	call _LABEL_80D_
	ld de, $2020
	ld hl, $97AD
	call DecompressToVDP
	ld de, $0040
	ld hl, $9668
	call DecompressToVDP
	ld de, $38CA
	ld hl, $9A18
	ld bc, $022C
	call VDPOut_64C
	ld de, $39DC
	ld hl, $1954
	ld bc, $0A02
	call VDPOut_64C
	ld de, $39FC
	ld hl, $1968
	ld bc, $0A02
	call VDPOut_64C
	ld de, $39DE
	ld hl, $0155
	ld bc, $000F
	call VDPOut_Loop_632
	ld de, $3C1E
	ld hl, $0755
	ld bc, $000F
	call VDPOut_Loop_632
	ld de, $3CC4
	ld hl, $197C
	ld bc, $0502
	call VDPOut_64C
	ld de, $3CFA
	ld hl, $1986
	ld bc, $0502
	call VDPOut_64C
	ld de, $3CC6
	ld hl, $0155
	ld bc, $001A
	call VDPOut_Loop_632
	ld de, $3DC6
	ld hl, $0755
	ld bc, $001A
	call VDPOut_Loop_632
	ld de, $3D08
	rst $08	; Interrupt8
	ld c, VDPData
	ld hl, HUDFL
	call OUTI8
	ld hl, (Floor)
	ld h, $00
	call _LABEL_2C98_
	ld e, $00
	ld hl, $C0B2
	ld a, (hl)
	call _LABEL_1940_
	dec hl
	ld a, (hl)
	add a, $80
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ld de, $3D20
	rst $08	; Interrupt8
	ld a, (CharacterLevel)
	ld b, a
	ld hl, HUDCharacterClass-22
	ld de, $0016
-:
	add hl, de
	djnz -
	call OUTI22
	ld de, $3D48
	rst $08	; Interrupt8
	ld hl, HUDHP
	call OUTI6
	ld hl, (CurrentHPLow)
	call _LABEL_2C6D_
	ld e, $00
	ld hl, $C0B3
	ld a, (hl)
	call _LABEL_1940_
	dec hl
	ld a, (hl)
	call _LABEL_1940_
	dec hl
	ld a, (hl)
	and $0F
	add a, $80
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ld a, $7C
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ld hl, (MaxHPLow)
	call _LABEL_2C6D_
	ld e, $00
	ld hl, $C0B3
	ld a, (hl)
	call _LABEL_1940_
	dec hl
	ld a, (hl)
	call _LABEL_1940_
	dec hl
	ld a, (hl)
	and $0F
	add a, $80
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ld de, $3D60
	rst $08	; Interrupt8
	ld hl, HUDPW
	call OUTI6
	ld a, (WeaponPW)
	ld hl, (BasePW)
	add a, l
	ld l, a
	ld h, $00
	call _LABEL_2C98_
	ld e, $00
	ld a, ($C0B2)
	call _LABEL_1940_
	ld a, ($C0B1)
	add a, $80
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ld de, $3D6E
	rst $08	; Interrupt8
	ld hl, HUDAC
	call OUTI6
	ld a, (ArmorAC)
	ld hl, (BaseAC)
	add a, l
	ld l, a
	ld h, $00
	call _LABEL_2C98_
	ld e, $00
	ld a, ($C0B2)
	call _LABEL_1940_
	ld a, ($C0B1)
	add a, $80
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ld de, $3D8A
	rst $08	; Interrupt8
	ld hl, HUDGold
	call OUTI10
	ld hl, MoneyHigh
	ld e, $00
	ld b, $02
_LABEL_18B2_:
	ld a, (hl)
	call _LABEL_1940_
	dec hl
	ld a, (hl)
	rrca
	rrca
	rrca
	rrca
	call _LABEL_1940_
	djnz _LABEL_18B2_
	ld a, (hl)
	and $0F
	add a, $80
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ld de, $3DA6
	rst $08	; Interrupt8
	ld hl, HUDFood
	call OUTI10
	ld e, $00
	ld a, (Food)
	rrca
	rrca
	rrca
	rrca
	call _LABEL_1940_
	ld a, (Food)
	and $0F
	add a, $80
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ld hl, _LABEL_49A7_
	ld ($C400), hl
	ld hl, _LABEL_4C3E_
	ld ($C420), hl
	ld hl, _LABEL_4CC0_
	ld ($C440), hl
	ld hl, _LABEL_4D5D_
	ld ($C460), hl
	ld hl, $8064
	call LoadPaletteToRAMMirror
	ld hl, $9646
	call _LABEL_40C_
	xor a
	ld ($C00B), a
	ld a, $02
	ld ($C014), a
	ei
	ld hl, $0384
	ld (TitleScreenCounterLow), hl
	ld a, $10
	ld (TableIndex1), a
	jp _LABEL_137_

; 17th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_192B:
	call _LABEL_3E6_
	call _LABEL_1D9C_
	call _LABEL_2DAD_
	call _LABEL_137_
	ld a, (CurrentControllerState)
	and $80
	ret nz
	jp _LABEL_137_

_LABEL_1940_:
	and $0F
	ld d, a
	or e
	jr nz, _LABEL_1949_
	xor a
	jr _LABEL_194C_

_LABEL_1949_:
	ld a, d
	add a, $80
_LABEL_194C_:
	ld e, a
	out (VDPData), a
	ld a, $01
	out (VDPData), a
	ret

; Data from 1954 to 1B1F (460 bytes)
; Some kind of tile data- possibly the border
.dw $0154 $0157 $0157 $0157 $0157 $0157 $0157 $0157 $0157 $0756
.dw $0156 $0757 $0757 $0757 $0757 $0757 $0757 $0757 $0757 $0754
.dw $0154 $0157 $0157 $0157 $0756 $0156 $0757 $0757 $0757 $0754

.include "ui\hud.asm"

.include "player\character_classes.asm"

; 18th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_1B20:
	call _LABEL_B9A_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_BA3_
	call _LABEL_BC8_
	call _LABEL_5DE_
	ld de, $2B00
	ld hl, $80D8
	call _LABEL_80D_
	ld de, $3000
	ld hl, $8086
	call _LABEL_80D_
	ld hl, $8000
	ld de, $2A80
	call DecompressToVDP
	ld a, $02
	ld (Autoplay), a
	ld a, ($C0D3)
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, Data_1C90
	add hl, de
	ld a, (hl)
	ld (Floor), a
	inc hl
	ld a, (hl)
	ld (CharacterLevel), a
	inc hl
	ld a, (hl)
	ld (EquippedWeapon), a
	inc hl
	ld a, (hl)
	ld (EquippedArmor), a
	ld a, $02
	ld ($FFFF), a
	ld a, (Floor)
	dec a
	jr z, _LABEL_1B80_
	call GetRandomNumber
	and $03
_LABEL_1B80_:
	ld (FloorType), a
	call _LABEL_2A22_
	call _LABEL_2941_
	ld hl, $D700
	ld de, $D701
	ld (hl), $00
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI128
	ld a, $07
	ld ($FFFF), a
	ld a, ($C0D3)
	add a, a
	ld e, a
	ld d, $00
	ld hl, Data_1C84
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld de, $D300
	ld b, $0C
_LABEL_1BC2_:
	push bc
	call LDI16
	ex de, hl
	ld bc, $0010
	add hl, bc
	ex de, hl
	pop bc
	djnz _LABEL_1BC2_
	ld hl, $D300
	ld bc, $0004
_LABEL_1BD5_:
	set 7, (hl)
	inc hl
	djnz _LABEL_1BD5_
	dec c
	jr nz, _LABEL_1BD5_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_1F8F_
	call SelectMonstersForFloor
	call _LABEL_20BA_
	ld hl, $0000
	call _LABEL_2DFA_
	ld a, $07
	ld ($FFFF), a
	ld a, ($C0D3)
	add a, a
	ld e, a
	ld d, $00
	ld hl, Data_1C78
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld de, $3E00
	ld bc, $0440
	call VDPOut_661
	ld hl, $311A
	ld ($C100), hl
	ld hl, $3CE6
	ld ($C120), hl
	ld hl, PreventArmorRust
	ld de, ParalysisTicksLeft
	ld (hl), $00
	call LDI5
	ld a, $02
	ld ($FFFF), a
	ld hl, $8064
	call LoadPaletteToRAMMirror
	call _LABEL_27E3_
	call LoadMonsterPalette
	ld a, $04
	ld ($FFFF), a
	ld hl, $8000
	call LoadPaletteToRAMMirror
	ld a, (EquippedWeapon)
	dec a
	and $0C
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, SwordColors
	add hl, de
	ld de, $C077
	ldi
	call _LABEL_40F_
	ld a, $02
	ld ($C014), a
	xor a
	ld (CurrentMessage), a
	ld ($CAC5), a
	ld a, $3C
	ld (PlayerIdleTimer), a
	ei
	ld hl, $0078
	ld (TitleScreenCounterLow), hl
	ld a, $12
	ld (TableIndex1), a
	jp _LABEL_143_

; Data from 1C78 to 1C8F (24 bytes)
; Looks like words? Pointer table?
Data_1C78:
	.dw $B249 $B349 $B449 $B549
	.dw $B649 $B749

Data_1C84:
	.dw $B009 $B0C9 $B189 $B009
	.dw $B189 $B0C9

; Data from 1C90-1CA8 (24 bytes)
Data_1C90:
	.db $01 $01 $01 $10 $08 $04 $02 $12
	.db $0A $07 $03 $12 $12 $0A $08 $15
	.db $18 $0C $0C $1A $1D $10 $0C $1A

; 19th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_1CA8:
	call _LABEL_3EE_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_1F4F_
	call _LABEL_1D60_
	call _LABEL_175_
	jp nz, _LABEL_143_
	xor a
	ld (Autoplay), a
	ld ($C0D2), a
	ld a, $78
	ld ($C0D4), a
	ld a, $13
	ld (TableIndex1), a
	jp _LABEL_143_

; 20th entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_1CD0:
	ld a, ($C0D2)
	cp $20
	jp nc, _LABEL_1CF2_
	add a, $04
	ld ($C0D2), a
	ld hl, $C10F
	ld de, $0020
	ld b, $10
_LABEL_1CE5_:
	ld a, (hl)
	sub $04
	ld (hl), a
	add hl, de
	djnz _LABEL_1CE5_
	call _LABEL_1D60_
	jp _LABEL_169_

_LABEL_1CF2_:
	ld hl, $C0D4
	dec (hl)
	jp nz, _LABEL_169_
	call _LABEL_42C_
	ld a, ($C0D3)
	inc a
	ld ($C0D3), a
	cp $06
	ld a, $11
	jr nz, _LABEL_1D0B_
	ld a, $14
_LABEL_1D0B_:
	ld (TableIndex1), a
	jp _LABEL_137_

; 21st entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_1D11:
	call _LABEL_B9A_
	call _LABEL_BA3_
	call _LABEL_BC8_
	ld a, $06
	ld ($FFFF), a
	ld de, $0000
	ld hl, $A724
	call DecompressToVDP
	ld de, $3800
	ld hl, $BBA9
	call DecompressToVDP
	ld hl, $A712
	call _LABEL_40C_
	ld a, $02
	ld ($C014), a
	ei
	ld hl, $00B4
	ld (TitleScreenCounterLow), hl
	ld a, $15
	ld (TableIndex1), a
	jp _LABEL_137_

; 22nd entry of Jump Table from 17F (indexed by TableIndex1)
JumpTable1_1D4B:
	ld a, (LastControllerState)
	and $B0
	jr nz, _LABEL_1D55_
	jp _LABEL_137_

_LABEL_1D55_:
	call _LABEL_42C_
	ld a, $00
	ld (TableIndex1), a
	jp _LABEL_137_

_LABEL_1D60_:
	ld a, $03
	ld ($FFFF), a
	call _LABEL_1E34_
	xor a
	ld ($C5C0), a
	ld hl, $C5C2
_LABEL_1D6F_:
	ld a, (hl)
	cp $FF
	jr z, _LABEL_1D8F_
	push hl
	ld d, a
	xor a
	srl d
	rra
	srl d
	rra
	srl d
	rra
	ld e, a
	ld ix, $C100
	add ix, de
	call _LABEL_1DD4_
	pop hl
	inc hl
	inc hl
	jr _LABEL_1D6F_

_LABEL_1D8F_:
	ld a, ($C5C0)
	ld e, a
	ld d, $00
	ld hl, $C500
	add hl, de
	ld (hl), $D0
	ret

_LABEL_1D9C_:
	ld a, $03
	ld ($FFFF), a
	xor a
	ld ($C5C0), a
	ld ix, $C400
	ld de, $0020
	ld b, $08
_LABEL_1DAE_:
	push bc
	push de
	call _LABEL_1DC6_
	pop de
	add ix, de
	pop bc
	djnz _LABEL_1DAE_
	ld a, ($C5C0)
	ld e, a
	ld d, $00
	ld hl, $C500
	add hl, de
	ld (hl), $D0
	ret

_LABEL_1DC6_:
	ld a, (ix+2)
	or a
	ret z
	ld a, (ix+3)
	or a
	ret z
	call _LABEL_1EB1_
	ret c
_LABEL_1DD4_:
	ld a, (ix+3)
	ld e, a
	ld d, $00
	ld hl, Table_F12B-2
	add hl, de
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld c, (hl)
	ld b, $00
	inc hl
	ld a, ($C5C0)
	add a, c
	cp $41
	ret nc
	push hl
	ld a, ($C5C0)
	ld e, a
	ld d, $00
	ld hl, $C500
	add hl, de
	ex de, hl
	pop hl
	ld b, c
_LABEL_1DFC_:
	ld a, (hl)
	add a, (ix+15)
	cp $D0
	jr nz, _LABEL_1E05_
	inc a
_LABEL_1E05_:
	ld (de), a
	inc hl
	inc de
	djnz _LABEL_1DFC_
	ld a, ($C5C0)
	add a, c
	cp $40
	jr z, _LABEL_1E15_
	ld a, $D0
	ld (de), a
_LABEL_1E15_:
	push hl
	ld a, ($C5C0)
	ld e, a
	ld d, $00
	ld hl, $C540
	add hl, de
	add hl, de
	ex de, hl
	pop hl
	add a, c
	ld ($C5C0), a
	ld b, c
_LABEL_1E28_:
	ld a, (hl)
	add a, (ix+17)
	ld (de), a
	inc hl
	inc de
	ldi
	djnz _LABEL_1E28_
	ret

_LABEL_1E34_:
	ld a, ($C5C1)
	inc a
	and $01
	ld ($C5C1), a
	rra
	jr c, _LABEL_1E59_
	ld ix, $C100
	ld de, $0020
	ld bc, $1800
	ld hl, $C5C2
_LABEL_1E4D_:
	call _LABEL_1E9E_
	add ix, de
	inc c
	djnz _LABEL_1E4D_
	ld (hl), $FF
	jr _LABEL_1E70_

_LABEL_1E59_:
	ld ix, $C3E0
	ld de, $FFE0
	ld bc, $1817
	ld hl, $C5C2
_LABEL_1E66_:
	call _LABEL_1E9E_
	add ix, de
	dec c
	djnz _LABEL_1E66_
	ld (hl), $FF
_LABEL_1E70_:
	ld hl, $C5C2
_LABEL_1E73_:
	ld a, (hl)
	cp $FF
	ret z
	push hl
	inc hl
	ld e, l
	ld d, h
	ld c, (hl)
	inc hl
_LABEL_1E7D_:
	ld a, (hl)
	cp $FF
	jr z, _LABEL_1E8B_
	inc hl
	ld a, (hl)
	cp c
	call nc, _LABEL_1E90_
	inc hl
	jr _LABEL_1E7D_

_LABEL_1E8B_:
	pop hl
	inc hl
	inc hl
	jr _LABEL_1E73_

_LABEL_1E90_:
	ld a, (de)
	ldd
	ex af, af'
	ld a, (de)
	ldi
	dec hl
	ld (hl), a
	inc hl
	ex af, af'
	ld c, (hl)
	ld (hl), a
	ret

_LABEL_1E9E_:
	ld a, (ix+2)
	or a
	ret z
	ld a, (ix+3)
	or a
	ret z
	call _LABEL_1EB1_
	ret c
	ld (hl), c
	inc hl
	ld (hl), a
	inc hl
	ret

_LABEL_1EB1_:
	ld a, (ix+18)
	or (ix+16)
	jr nz, _LABEL_1EC9_
	ld a, (ix+17)
	cp $08
	jr c, _LABEL_1EC9_
	ld a, (ix+15)
	cp $E0
	jr nc, _LABEL_1EC9_
	or a
	ret

_LABEL_1EC9_:
	scf
	ret

_LABEL_1ECB_:
	ld a, ($CA06)
	add a, e
	jr c, _LABEL_1ED5_
	cp $E0
	jr c, _LABEL_1ED7_
_LABEL_1ED5_:
	add a, $20
_LABEL_1ED7_:
	and $F0
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, ($CA05)
	neg
	add a, d
	and $F0
	rrca
	rrca
	or l
	ld l, a
	ld de, $3800
	add hl, de
	ld a, h
	cp $38
	ret nc
	ld h, $3E
	ret

_LABEL_1EF6_:
	push ix
	pop hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	sub $08
	jr nz, _LABEL_1F03_
	ld a, $12
_LABEL_1F03_:
	ld b, a
	ld hl, $C13E
	ld de, $0020
	ld a, ($C11E)
_LABEL_1F0D_:
	or (hl)
	add hl, de
	djnz _LABEL_1F0D_
	jr nz, _LABEL_1F15_
	xor a
	ret

_LABEL_1F15_:
	scf
	ret

_LABEL_1F17_:
	push hl
	ld a, h
	ex af, af'
	ld a, l
	ld hl, $C107
	ld de, $001F
	ld b, $18
_LABEL_1F23_:
	cp (hl)
	inc hl
	jr nz, _LABEL_1F2C_
	ex af, af'
	cp (hl)
	jr z, _LABEL_1F32_
	ex af, af'
_LABEL_1F2C_:
	add hl, de
	djnz _LABEL_1F23_
	pop hl
	xor a
	ret

_LABEL_1F32_:
	ld a, l
	and $E0
	ld l, a
	ex de, hl
	pop hl
	scf
	ret

_LABEL_1F3A_:
	ld hl, $C100
	ld de, $001F
	ld b, $12
_LABEL_1F42_:
	ld a, (hl)
	inc hl
	or (hl)
	jr z, _LABEL_1F4C_
	add hl, de
	djnz _LABEL_1F42_
	scf
	ret

_LABEL_1F4C_:
	dec hl
	xor a
	ret

_LABEL_1F4F_:
	ld ix, $C100
	ld b, $18
_LABEL_1F55_:
	push bc
	ld a, (ix+0)
	or (ix+1)
	call nz, _LABEL_1F68_
	ld de, $0020
	add ix, de
	pop bc
	djnz _LABEL_1F55_
	ret

_LABEL_1F68_:
	ld de, ($CA03)
	ld l, (ix+10)
	ld h, (ix+11)
	xor a
	sbc hl, de
	ld (ix+16), h
	ld (ix+15), l
	ld de, ($CA01)
	ld l, (ix+13)
	ld h, (ix+14)
	xor a
	sbc hl, de
	ld (ix+18), h
	ld (ix+17), l
	ret

_LABEL_1F8F_:
	call _LABEL_207D_
	ld ($C105), hl
	ld de, $FFE0
	add hl, de
	call _LABEL_2091_
	jr nc, _LABEL_1FB4_
	ld de, $001F
	add hl, de
	call _LABEL_2091_
	jr nc, _LABEL_1FB4_
	ld de, $0002
	add hl, de
	call _LABEL_2091_
	jr nc, _LABEL_1FB4_
	ld de, $001F
	add hl, de
_LABEL_1FB4_:
	ld ($C125), hl
	ret

SelectMonstersForFloor:
	ld iy, $C140
	ld hl, (Floor)
	ld h, $00
	dec hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, MonsterEncounterTable
	add hl, de
	ld a, (Autoplay)
	cp $02
	jr nz, SetNumberOfMonsters
	ld b, AutoplayMonstersPerFloor
	jr GenerateMonsters

SetNumberOfMonsters:
	call GetRandomNumber
	and RangeMonstersPerFloor
	add a, MinimumMonstersPerFloor
	ld b, a
GenerateMonsters:
	push bc
	push hl
	call GetRandomNumber
	and MonsterTypesPerFloor
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	exx
	ld (iy+31), a
	add a, a
	ld l, a
	ld h, $00
	ld de, MonsterActionTable
	add hl, de
	ld a, (hl)
	ld (iy+0), a
	inc hl
	ld a, (hl)
	ld (iy+1), a
	call _LABEL_207D_
	ld (iy+5), l
	ld (iy+6), h
	exx
	ld de, $0020
	add iy, de
	pop hl
	pop bc
	djnz GenerateMonsters
	ret

; Jump Table from 2012 to 2053 (33 entries, indexed by unknown)
; Appears to be related to monster generation
MonsterActionTable:
	.dw OozeMonsterAction      SlimetoadMonsterAction ScorpionMonsterAction KragMonsterAction
	.dw BlueOozeMonsterAction  LochtoadMonsterAction  PhantomMonsterAction  OrbMonsterAction
	.dw RedOozeMonsterAction   BloodtoadMonsterAction WitchMonsterAction    MystMonsterAction
	.dw DemijawMonsterAction   KrakenMonsterAction    ScorpiusMonsterAction KingKragMonsterAction
	.dw RootMonsterAction      RedSnailMonsterAction  SpectreMonsterAction  BloodOrbMonsterAction
	.dw BloodRootMonsterAction BlueSnailMonsterAction MadWitchMonsterAction DeathMystMonsterAction
	.dw DeathRootMonsterAction KingSnailMonsterAction WraithMonsterAction   DeathOrbMonsterAction
	.dw BlobMonsterAction      KrakosMonsterAction    DragonMonsterAction   Kameleon1MonsterAction
	.dw Kameleon2MonsterAction

DoMonsterActionTable:
	ld a, $02
	ld ($FFFF), a
	ld hl, (Floor)
	dec hl
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, MonsterEncounterTable
	add hl, de
	call GetRandomNumber
	and $0F
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	ld l, a
	ld h, $00
	add hl, hl
	ld de, MonsterActionTable
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ret

; Map generation?
_LABEL_207D_:
	call GetRandomNumber
	ld l, a
	call GetRandomNumber
	and $03
	ld h, a
	ld de, $D300
	add hl, de
	call _LABEL_2091_
	jr c, _LABEL_207D_
	ret

_LABEL_2091_:
	ld a, (hl)
	and $7F
	cp $04
	jr z, _LABEL_209C_
	cp $0C
	jr c, _LABEL_20B8_
_LABEL_209C_:
	ld a, h
	ex af, af'
	ld a, l
	exx
	ld hl, $C105
	ld de, $0020
	ld b, $18
_LABEL_20A8_:
	cp (hl)
	jr nz, _LABEL_20B2_
	inc hl
	ex af, af'
	cp (hl)
	jr z, _LABEL_20B8_
	ex af, af'
	dec hl
_LABEL_20B2_:
	add hl, de
	djnz _LABEL_20A8_
	exx
	xor a
	ret

_LABEL_20B8_:
	scf
	ret

_LABEL_20BA_:
	ld hl, ($C105)
_LABEL_20BD_:
	dec hl
	ld a, (hl)
	and $7F
	cp $02
	jr z, _LABEL_20BD_
	cp $03
	jr z, _LABEL_20BD_
	cp $04
	jr z, _LABEL_20BD_
	cp $0C
	jr nc, _LABEL_20BD_
	inc hl
	push hl
	ld b, $00
_LABEL_20D5_:
	inc hl
	inc b
	ld a, (hl)
	and $7F
	cp $02
	jr z, _LABEL_20D5_
	cp $03
	jr z, _LABEL_20D5_
	cp $04
	jr z, _LABEL_20D5_
	cp $0C
	jr nc, _LABEL_20D5_
	pop hl
	ld de, $FFE0
_LABEL_20EE_:
	add hl, de
	ld a, (hl)
	and $7F
	cp $02
	jr z, _LABEL_20EE_
	cp $03
	jr z, _LABEL_20EE_
	cp $04
	jr z, _LABEL_20EE_
	cp $0C
	jr nc, _LABEL_20EE_
	push hl
	ex de, hl
	ld hl, $0400
	add hl, de
	ld c, b
_LABEL_2109_:
	ld a, (de)
	bit 7, a
	jr nz, _LABEL_2118_
	cp $05
	ld a, $0A
	jr z, _LABEL_211A_
	ld a, $05
	jr _LABEL_211A_

_LABEL_2118_:
	ld a, $04
_LABEL_211A_:
	ld (hl), a
	inc hl
	inc de
	djnz _LABEL_2109_
	pop hl
_LABEL_2120_:
	ld de, $0020
	add hl, de
	ld a, (hl)
	and $7F
	cp $02
	jr z, _LABEL_2137_
	cp $03
	jr z, _LABEL_2137_
	cp $04
	jr z, _LABEL_2137_
	cp $0C
	jr c, _LABEL_2178_
_LABEL_2137_:
	push hl
	ex de, hl
	ld hl, $0400
	add hl, de
	ld b, c
_LABEL_213E_:
	push bc
	ld a, (de)
	and $7F
	cp $0C
	jr c, _LABEL_2167_
	cp $10
	jr nc, _LABEL_214E_
	ld (de), a
	ld (hl), a
	jr _LABEL_2170_

_LABEL_214E_:
	ld (de), a
	exx
	sub $10
	add a, a
	ld l, a
	ld h, $00
	ld de, $C980
	add hl, de
	ld a, (hl)
	and $70
	rrca
	rrca
	rrca
	rrca
	add a, $10
	exx
	ld (hl), a
	jr _LABEL_2170_

_LABEL_2167_:
	cp $02
	jr nz, _LABEL_216D_
	ld a, $03
_LABEL_216D_:
	ld (de), a
	ld (hl), $09
_LABEL_2170_:
	inc hl
	inc de
	pop bc
	djnz _LABEL_213E_
	pop hl
	jr _LABEL_2120_

_LABEL_2178_:
	ld b, c
_LABEL_2179_:
	push bc
	push hl
	ld d, (hl)
	ld bc, $0020
	add hl, bc
	ld e, (hl)
	ld a, h
	cp $D7
	jr c, _LABEL_2187_
	ld e, d
_LABEL_2187_:
	ld c, $03
	call _LABEL_23ED_
	pop de
	ld hl, $0400
	add hl, de
	ld (hl), a
	ex de, hl
	inc hl
	pop bc
	djnz _LABEL_2179_
	ret

_LABEL_2198_:
	ld hl, ($CA07)
	ld ($C60F), hl
	ld hl, $CB00
	ld ($C611), hl
	ld bc, $0D10
	call _LABEL_26F3_
	ld hl, $CB00
	ld de, ($CA09)
	ld bc, $1A40
	call _LABEL_681_
	xor a
	ld ($C60E), a
	ld ($CAC5), a
	ret

_LABEL_21BF_:
	ld hl, $D300
	ld bc, $0400
_LABEL_21C5_:
	push bc
	ld b, c
_LABEL_21C7_:
	ld a, (hl)
	cp $03
	jr nz, _LABEL_21CE_
	ld (hl), $02
_LABEL_21CE_:
	set 7, (hl)
	inc hl
	djnz _LABEL_21C7_
	pop bc
	djnz _LABEL_21C5_
	ld hl, $C981
	ld de, $0002
	ld b, $36
_LABEL_21DE_:
	ld a, (hl)
	cp $03
	jr nz, _LABEL_21E5_
	ld (hl), $02
_LABEL_21E5_:
	add hl, de
	djnz _LABEL_21DE_
	ld hl, $D700
	ld de, $D701
	ld (hl), $00
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	jp LDI128

_LABEL_2208_:
	ld hl, $D300
	ld bc, $0400
_LABEL_220E_:
	push bc
	ld b, c
_LABEL_2210_:
	ld a, (hl)
	and $7F
	cp $02
	jr nz, _LABEL_2219_
	ld a, $03
_LABEL_2219_:
	ld (hl), a
	inc hl
	djnz _LABEL_2210_
	pop bc
	djnz _LABEL_220E_
	ld hl, $D300
	ld b, $20
_LABEL_2225_:
	push bc
	push hl
	ex de, hl
	ld hl, $0400
	add hl, de
	push hl
	ex de, hl
	ld de, $0020
	ld a, (hl)
	exx
	ld c, a
	ld d, a
	ld e, $00
	exx
	add hl, de
	pop de
	ld b, $20
_LABEL_223C_:
	push bc
	ld a, h
	cp $D7
	ld a, (hl)
	exx
	jr nc, _LABEL_2245_
	ld e, a
_LABEL_2245_:
	call _LABEL_23ED_
	ld c, d
	ld d, e
	exx
	ld (de), a
	ld bc, $0020
	ex de, hl
	add hl, bc
	ex de, hl
	add hl, bc
	pop bc
	djnz _LABEL_223C_
	pop hl
	inc hl
	pop bc
	djnz _LABEL_2225_
	ret

_LABEL_225C_:
	ld a, (BlindnessTicksLeft)
	or a
	jr z, _LABEL_22B0_
	ld hl, ($C105)
	ld de, $FF9E
	add hl, de
	ld bc, $0905
_LABEL_226C_:
	ld a, h
	cp $D3
	jr c, _LABEL_2287_
	cp $D7
	jr nc, _LABEL_2287_
	push bc
	push hl
	ld b, c
_LABEL_2278_:
	ld a, (hl)
	cp $03
	jr nz, _LABEL_227F_
	ld a, $02
_LABEL_227F_:
	set 7, a
	ld (hl), a
	inc hl
	djnz _LABEL_2278_
	pop hl
	pop bc
_LABEL_2287_:
	ld de, $0020
	add hl, de
	djnz _LABEL_226C_
	ld hl, ($C105)
	ld de, $039E
	add hl, de
	ld bc, $0905
_LABEL_2297_:
	ld a, h
	cp $D7
	jr c, _LABEL_22AA_
	cp $DB
	jr nc, _LABEL_22AA_
	push bc
	push hl
	ld b, c
_LABEL_22A3_:
	ld (hl), $00
	inc hl
	djnz _LABEL_22A3_
	pop hl
	pop bc
_LABEL_22AA_:
	ld de, $0020
	add hl, de
	djnz _LABEL_2297_
_LABEL_22B0_:
	ld hl, ($C105)
	ld de, $FFDF
	add hl, de
	ld b, $04
_LABEL_22B9_:
	push bc
	ld b, $03
_LABEL_22BC_:
	res 7, (hl)
	inc hl
	djnz _LABEL_22BC_
	ld bc, $001D
	add hl, bc
	pop bc
	djnz _LABEL_22B9_
	ld hl, ($C105)
	ld de, $FFDF
	add hl, de
	ld b, $03
_LABEL_22D1_:
	push bc
	push hl
	push hl
	ld de, $FFE0
	ld a, (hl)
	exx
	ld e, a
	exx
	add hl, de
	push hl
	ld a, h
	cp $D3
	ld a, (hl)
	exx
	jr nc, _LABEL_22E5_
	ld a, e
_LABEL_22E5_:
	ld d, a
	exx
	add hl, de
	ld a, h
	cp $D3
	ld a, (hl)
	exx
	jr nc, _LABEL_22F0_
	ld a, d
_LABEL_22F0_:
	ld c, a
	exx
	pop hl
	ld de, $0400
	add hl, de
	ex de, hl
	pop hl
	ld b, $06
_LABEL_22FB_:
	push bc
	ld a, d
	cp $D7
	jr c, _LABEL_2310_
	ld a, h
	cp $D7
	ld a, (hl)
	exx
	jr nc, _LABEL_2309_
	ld e, a
_LABEL_2309_:
	call _LABEL_23ED_
	ld c, d
	ld d, e
	exx
	ld (de), a
_LABEL_2310_:
	ld bc, $0020
	ex de, hl
	add hl, bc
	ld a, h
	ex de, hl
	add hl, bc
	pop bc
	ld a, d
	cp $DB
	jr nc, _LABEL_2320_
	djnz _LABEL_22FB_
_LABEL_2320_:
	pop hl
	inc hl
	pop bc
	djnz _LABEL_22D1_
	ld a, (BlindnessTicksLeft)
	or a
	jr nz, _LABEL_2369_
	ld hl, ($C105)
	ld de, $03BF
	add hl, de
	ld ($C60F), hl
	ld hl, $CB00
	ld ($C611), hl
	ld bc, $0603
	call _LABEL_26F3_
	ld a, ($C10F)
	sub $20
	jr nc, _LABEL_234A_
	sub $20
_LABEL_234A_:
	ld e, a
	ld a, ($C111)
	sub $10
	ld d, a
	call _LABEL_1ECB_
	ld ($C60C), hl
	ld de, ($C60C)
	ld hl, $CB00
	ld bc, $0C0C
	call _LABEL_681_
	xor a
	ld ($C606), a
	ret

_LABEL_2369_:
	ld hl, ($C105)
	ld de, $039E
	add hl, de
	ld ($C60F), hl
	ld hl, $CB00
	ld ($C611), hl
	ld bc, $0905
	call _LABEL_26F3_
	ld a, ($C10F)
	sub $30
	jr nc, _LABEL_2388_
	sub $20
_LABEL_2388_:
	ld d, a
	ld a, ($CA06)
	add a, d
	jr c, _LABEL_2393_
	cp $E0
	jr c, _LABEL_2395_
_LABEL_2393_:
	add a, $20
_LABEL_2395_:
	and $F0
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, ($C111)
	sub $20
	ld d, a
	ld a, ($CA05)
	neg
	add a, d
	and $F0
	rrca
	rrca
	or l
	ld l, a
	ld de, $3800
	add hl, de
	ld a, h
	cp $38
	jr nc, _LABEL_23BA_
	ld h, $3E
_LABEL_23BA_:
	ld ($C60C), hl
	ld hl, ($C105)
	ld de, $039E
	add hl, de
	ex de, hl
	ld hl, $DB00
	ld a, e
	and $E0
	ld e, a
	xor a
	sbc hl, de
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	cp $08
	jr c, _LABEL_23D9_
	ld a, $08
_LABEL_23D9_:
	inc a
	add a, a
	ld b, a
	ld c, $14
	ld de, ($C60C)
	ld hl, $CB00
	call _LABEL_681_
	xor a
	ld ($C606), a
	ret

_LABEL_23ED_:
	bit 7, d
	jr nz, _LABEL_2428_
	ld a, d
	cp $0C
	jr nc, _LABEL_240F_
	or a
	jr z, _LABEL_2428_
	cp $06
	jr nc, _LABEL_2428_
	add a, $07
	cp $08
	ret z
	cp $0C
	ld a, $09
	ret c
	ld a, $0A
	bit 7, e
	ret z
	ld a, $06
	ret

_LABEL_240F_:
	cp $10
	ret c
	push de
	sub $10
	add a, a
	ld e, a
	ld d, $00
	ld hl, $C980
	add hl, de
	ld a, (hl)
	and $70
	rrca
	rrca
	rrca
	rrca
	add a, $10
	pop de
	ret

_LABEL_2428_:
	ld a, c
	bit 7, a
	jr nz, _LABEL_2461_
	cp $0C
	jr nc, _LABEL_243A_
	or a
	jr z, _LABEL_2461_
	cp $05
	jr z, _LABEL_2447_
	jr nc, _LABEL_2461_
_LABEL_243A_:
	ld a, e
	cp $05
	ld a, $0A
	ret z
	ld a, $07
	bit 7, e
	ret z
	dec a
	ret

_LABEL_2447_:
	bit 7, d
	jr z, _LABEL_243A_
	xor a
	bit 7, e
	ret nz
	ld a, e
	or a
	jr z, _LABEL_245B_
	cp $10
	jr nc, _LABEL_245E_
	cp $06
	jr c, _LABEL_245E_
_LABEL_245B_:
	ld a, $03
	ret

_LABEL_245E_:
	ld a, $04
	ret

_LABEL_2461_:
	ld hl, Data_2480
	bit 7, d
	jr z, _LABEL_246B_
	ld hl, Data_2489
_LABEL_246B_:
	ld a, $08
	bit 7, e
	jr nz, _LABEL_2478_
	ld a, e
	cp $0C
	jr c, _LABEL_2478_
	ld a, $04
_LABEL_2478_:
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, (hl)
	ret

; Data from 2480 to 2491 (18 bytes)
Data_2480:
	.db $01 $05 $05 $05 $05 $05 $01 $01
	.db $02

Data_2489:
	.db $03 $04 $04 $04 $04 $04 $03 $03
	.db $00

_LABEL_2492_:
	ld hl, $D700
	ld de, $D701
	ld (hl), $00
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI129
	call LDI128
	ld a, $03
	ld ($FFFF), a
	call GetRandomNumber
	and $30
	ld e, a
	ld d, $00
	ld hl, JumpTable5
	add hl, de
	ld b, $03
_LABEL_24C5_:
	push bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	push de
	pop iy
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	push hl
	ld hl, _LABEL_24E4_
	push hl
	call GetRandomNumber
	and $0F
	ld b, a
	ld c, $00
	ld hl, $8000
	add hl, bc
	jp (iy)

_LABEL_24E4_:
	pop hl
	pop bc
	djnz _LABEL_24C5_
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	push de
	pop iy
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld hl, _LABEL_2505_
	push hl
	call GetRandomNumber
	and $1F
	ld b, a
	ld c, $00
	ld hl, $8000
	add hl, bc
	jp (iy)

_LABEL_2505_:
	ld hl, $D300
	ld de, $D301
	ld (hl), $00
	call LDI31
	ld hl, $D6E0
	ld de, $D6E1
	ld (hl), $00
	call LDI31
	ld hl, $D31F
	ld de, $001F
	ld b, $1F
_LABEL_2523_:
	ld (hl), $00
	inc hl
	ld (hl), $00
	add hl, de
	djnz _LABEL_2523_
	ld a, (Floor)
	cp LastFloor
	ld a, $01
	jr z, _LABEL_2535_
	xor a
_LABEL_2535_:
	ld ($C604), a
	ld a, $04
	ld ($C605), a
	ld hl, $D300
	ld bc, $0004
_LABEL_2543_:
	ld a, (hl)
	cp $01
	jr z, _LABEL_2559_
	cp $06
	jr z, _LABEL_257E_
	cp $07
	jr z, _LABEL_257E_
	set 7, (hl)
_LABEL_2552_:
	inc hl
	djnz _LABEL_2543_
	dec c
	jr nz, _LABEL_2543_
	ret

_LABEL_2559_:
	ld a, ($C604)
	or a
	jr nz, _LABEL_257A_
	ld a, ($C605)
	dec a
	ld ($C605), a
	jr z, _LABEL_2571_
	call GetRandomNumber
	and $07
	cp $03
	jr nc, _LABEL_257A_
_LABEL_2571_:
	ld a, $01
	ld ($C604), a
	ld (hl), $81
	jr _LABEL_2552_

_LABEL_257A_:
	ld (hl), $80
	jr _LABEL_2552_

_LABEL_257E_:
	push hl
	ld a, (Floor)
	sub $04
	jr c, _LABEL_2595_
	inc a
	ld d, a
	call GetRandomNumber
	and $3F
	sub d
	jr nc, _LABEL_2595_
	pop hl
	set 7, (hl)
	jr _LABEL_2552_

_LABEL_2595_:
	pop hl
	ld (hl), $85
	jr _LABEL_2552_

; 1st entry of Jump Table from 25FB (indexed by unknown)
JumpTable5_259A:
	ld b, $10
_LABEL_259C_:
	push bc
	call LDI16
	ex de, hl
	ld bc, $0010
	add hl, bc
	ex de, hl
	pop bc
	djnz _LABEL_259C_
	ret

; 2nd entry of Jump Table from 25FB (indexed by unknown)
JumpTable5_25AA:
	ex de, hl
	ld bc, $000F
	add hl, bc
	ex de, hl
	ld b, $10
_LABEL_25B2_:
	push bc
	ld b, $10
_LABEL_25B5_:
	ld a, (hl)
	ld (de), a
	inc hl
	dec de
	djnz _LABEL_25B5_
	ex de, hl
	ld bc, $0030
	add hl, bc
	ex de, hl
	pop bc
	djnz _LABEL_25B2_
	ret

; 3rd entry of Jump Table from 25FB (indexed by unknown)
JumpTable5_25C5:
	ex de, hl
	ld bc, $01E0
	add hl, bc
	ex de, hl
	ld b, $10
_LABEL_25CD_:
	push bc
	ld b, $10
_LABEL_25D0_:
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
	djnz _LABEL_25D0_
	ex de, hl
	ld bc, $FFD0
	add hl, bc
	ex de, hl
	pop bc
	djnz _LABEL_25CD_
	ret

; 4th entry of Jump Table from 25FB (indexed by unknown)
JumpTable5_25E0:
	ex de, hl
	ld bc, $01EF
	add hl, bc
	ex de, hl
	ld b, $10
_LABEL_25E8_:
	push bc
	ld b, $10
_LABEL_25EB_:
	ld a, (hl)
	ld (de), a
	inc hl
	dec de
	djnz _LABEL_25EB_
	ex de, hl
	ld bc, $FFF0
	add hl, bc
	ex de, hl
	pop bc
	djnz _LABEL_25E8_
	ret

; Jump Table from 25FB to 263A (16 entries, indexed by unknown)
; This is a table of permutations of the routines at 259A, 25AA, 25E0, and 25C5
; and the data $D300, $D310, $D510, and $D500. All possible combinations of
; routines and data are represented.
; Perhaps these are references to the four types of scenery?
; Flowers, horseheads, mountains, and mushrooms
JumpTable5:
	.dw JumpTable5_259A $D300
	.dw JumpTable5_25AA $D310
	.dw JumpTable5_25E0 $D510
	.dw JumpTable5_25C5 $D500
	.dw JumpTable5_259A $D310
	.dw JumpTable5_25C5 $D510
	.dw JumpTable5_25E0 $D500
	.dw JumpTable5_25AA $D300
	.dw JumpTable5_259A $D510
	.dw JumpTable5_25AA $D500
	.dw JumpTable5_25E0 $D300
	.dw JumpTable5_25C5 $D310
	.dw JumpTable5_259A $D500
	.dw JumpTable5_25C5 $D300
	.dw JumpTable5_25E0 $D310
	.dw JumpTable5_25AA $D510

_LABEL_263B_:
	call GetRandomNumber
	and $07
	inc a
	ld b, a
_LABEL_2642_:
	call _LABEL_26DD_
	ld (hl), $8C
	djnz _LABEL_2642_
	call GetRandomNumber
	and $03
	inc a
	ld b, a
_LABEL_2650_:
	call _LABEL_26DD_
	ld (hl), $8D
	djnz _LABEL_2650_
	call GetRandomNumber
	and $01
	inc a
	ld b, a
_LABEL_265E_:
	call _LABEL_26DD_
	ld (hl), $8E
	djnz _LABEL_265E_
	ld hl, $C980
	ld de, $C981
	ld (hl), $00
	call LDI112
	ld a, $02
	ld ($FFFF), a
	ld a, (Floor)
	dec a
	and $1E
	ld e, a
	ld d, $00
	ld hl, ItemOccurrencePointerTable
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	exx
	ld hl, $C980
	call GetRandomNumber
	and $07
	ld b, a
	ld a, (Floor)
	cp $0B
	jr c, _LABEL_269C_
	dec b
	cp $15
	jr c, _LABEL_269C_
	dec b
_LABEL_269C_:
	bit 7, b
	jr z, _LABEL_26A2_
	ld b, $00
_LABEL_26A2_:
	ld a, $03
	add a, b
	ld b, a
	ld c, $90
_LABEL_26A8_:
	exx
	call GetRandomNumber
	and $3F
	ld l, a
	ld h, $00
	add hl, de
	ld a, (hl)
	cp $20
	jr nc, _LABEL_26C1_
	call GetRandomNumber
	and $0F
	ld a, (hl)
	jr nz, _LABEL_26C1_
	set 7, a
_LABEL_26C1_:
	exx
	ld (hl), a
	inc hl
	ld (hl), $04
	inc hl
	push hl
	call _LABEL_26DD_
	ld (hl), c
	inc c
	pop hl
	djnz _LABEL_26A8_
	ld a, (Floor)
	cp LastFloor
	ret nz
	call _LABEL_26DD_
	ld a, $8F
	ld (hl), a
	ret

_LABEL_26DD_:
	call GetRandomNumber
	ld l, a
	call GetRandomNumber
	and $03
	ld h, a
	ld de, $D300
	add hl, de
	ld a, (hl)
	and $7F
	cp $04
	jr nz, _LABEL_26DD_
	ret

_LABEL_26F3_:
	ld a, $02
	ld ($FFFF), a
	ld l, c
	ld h, $00
	add hl, hl
	add hl, hl
	ld ($C615), hl
	dec hl
	dec hl
	dec hl
	dec hl
	ld ($C613), hl
_LABEL_2707_:
	push bc
	exx
	ld de, ($C611)
	exx
	ld hl, ($C60F)
	ld b, c
_LABEL_2712_:
	push bc
	ld a, (hl)
	and $7F
	exx
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, $C800
	add hl, bc
	ldi
	ldi
	ldi
	ldi
	push de
	ex de, hl
	ld bc, ($C613)
	add hl, bc
	ex de, hl
	ldi
	ldi
	ldi
	ldi
	pop de
	exx
	inc hl
	pop bc
	djnz _LABEL_2712_
	exx
	ld hl, ($C615)
	add hl, de
	ld ($C611), hl
	exx
	ld hl, ($C60F)
	ld de, $0020
	add hl, de
	ld ($C60F), hl
	pop bc
	djnz _LABEL_2707_
	ret

LoadMonsterPalette:
	ld a, (Floor)
	dec a
	and $FE
	add a, a
	add a, a
	ld l, a
	ld h, $00
	ld de, MonsterPalettes
	add hl, de
	ld de, MonsterPaletteInRAM
	jp LDI8

; Monster Palettes? from 276B to 27E2 (120 bytes)
.include "monsters\monster_color_palettes.asm"

_LABEL_27E3_:
	ld a, $02
	ld ($FFFF), a
	ld a, (FloorType)
	add a, a
	ld e, a
	ld d, $00
	ld hl, FloorTypePalettes
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp LoadPaletteToRAMMirror

; Data from 27FA to 2801 (8 bytes)
FloorTypePalettes:
	.dw $8715 $8A29 $8E66 $928A

_LABEL_2802_:
	ld de, $0040
	rst $08	; Interrupt8
	ld a, $04
	ld ($FFFF), a
	ld hl, Data_283A-2
	ld a, (EquippedArmor)
	and $0F
	cp $03
	jr c, _LABEL_2826_
	ld hl, Data_283A+38
	cp $06
	jr c, _LABEL_2826_
	ld hl, Data_283A+4E
	ld a, $02
	ld ($FFFF), a
_LABEL_2826_:
	ld de, ($C103)
	ld d, $00
	add hl, de
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld c, VDPData
	call OUTI256
	jp OUTI128

; Data from 283A to 28B1 (120 bytes)
; Pointers to player sprites data?
Data_283A:
	.dw $800A $818A $830A $848A
	.dw $860A $878A $890A $8A8A
	.dw $8C0A $8D8A $8F0A $904A
	.dw $918A $930A $944A $95CA
	.dw $970A $984A $99CA $9B0A
	.dw $9C8A $9E0A $9F8A $A10A
	.dw $A28A $A40A $A58A $A70A
	.dw $A88A $AA0A $AB8A $ACCA
	.dw $AE0A $AF8A $B0CA $B24A
	.dw $B38A $B4CA $B64A $B78A
	.dw $A02E $A1AE $A32E $A4AE
	.dw $A62E $A7AE $A92E $AAAE
	.dw $AC2E $ADAE $AF2E $B06E
	.dw $B1AE $B32E $B46E $B5EE
	.dw $B72E $B86E $B9EE $BB2E

_LABEL_28B2_:
	ld a, $07
	ld ($FFFF), a
	ld de, $0200
	rst $08	; Interrupt8
	ld a, (CharacterLevel)
	sub $04
	jr nc, _LABEL_28C7_
	ld hl, $92C7
	jr _LABEL_28F4_

_LABEL_28C7_:
	and $0C
	cp $0C
	jr nz, _LABEL_28CF_
	ld a, $08
_LABEL_28CF_:
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld a, ($C124)
	ld c, a
	ld a, ($C134)
	and $01
	add a, a
	ld b, $03
_LABEL_28E0_:
	rrc c
	jr c, _LABEL_28E8_
	add a, $04
	djnz _LABEL_28E0_
_LABEL_28E8_:
	ld l, a
	ld h, $00
	add hl, de
	ld de, Data_2911
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
_LABEL_28F4_:
	ld c, VDPData
	call OUTI80
	ld ($C0D0), hl
	ret

_LABEL_28FD_:
	ld a, $07
	ld ($FFFF), a
	ld de, $0250
	rst $08	; Interrupt8
	ld hl, ($C0D0)
	ld bc, $B0BE
_LABEL_290C_:
	outi
	jr nz, _LABEL_290C_
	ret

; Data from 2911 to 2940 (48 bytes)
Data_2911:
	.db $C7 $96 $C7 $97 $C7 $94 $C7 $95
	.db $C7 $98 $C7 $99 $C7 $9A $C7 $9B
	.db $C7 $9E $C7 $9F $C7 $9C $C7 $9D
	.db $C7 $A0 $C7 $A1 $C7 $A2 $C7 $A3
	.db $C7 $A6 $C7 $A7 $C7 $A4 $C7 $A5 
	.db $C7 $A8 $C7 $A9 $C7 $AA $C7 $AB

_LABEL_2941_:
	ld hl, (Floor)
	ld h, $00
	add hl, hl
	ld de, Data_2977-2
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
_LABEL_294F_:
	ld a, (hl)
	or a
	ret z
	cp $0E
	ld a, $05
	jr nz, _LABEL_295A_
	ld a, $02
_LABEL_295A_:
	ld ($FFFF), a
	ld a, (hl)
	push hl
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, Data_29EA-4
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	call DecompressToVDP
	pop hl
	inc hl
	jr _LABEL_294F_

; Data from 2977 to 2A21 (171 bytes)
; Palette data?
Data_2977:
	.dw Data_29B3 Data_29B3 Data_29B3 Data_29B3
	.dw Data_29B8 Data_29B8 Data_29B8 Data_29B8
	.dw Data_29BD Data_29BD Data_29C2 Data_29C2
	.dw Data_29C7 Data_29C7 Data_29CC Data_29CC
	.dw Data_29D1 Data_29D1 Data_29D1 Data_29D1
	.dw Data_29D6 Data_29D6 Data_29D6 Data_29D6
	.dw Data_29DB Data_29DB Data_29E0 Data_29E0
	.dw Data_29E5 Data_29E5

Data_29B3:
	.db $01 $02 $03 $04 $00

Data_29B8:
	.db $01 $02 $05 $06 $00

Data_29BD:
	.db $01 $02 $07 $08 $00

Data_29C2:
	.db $07 $08 $09 $0A $00

Data_29C7:
	.db $03 $04 $09 $0A $00

Data_29CC:
	.db $03 $04 $0B $0C $00

Data_29D1:
	.db $05 $06 $0B $0C $00

Data_29D6:
	.db $07 $08 $0B $0C $00 

Data_29DB:
	.db $05 $06 $0B $0C $00

Data_29E0:
	.db $01 $05 $06 $0A $00

Data_29E5:
	.db $01 $0A $0D $0E $00

Data_29EA:
	.db $80 $03 $00 $80 $00 $05 $08 $81 $80 $0F $B1 $86 $80 $19 $C7 $8D
	.db $80 $0F $EF $90 $C0 $18 $A0 $97 $40 $0F $BA $9B $C0 $1C $3B $A5
	.db $80 $03 $6B $A7 $00 $06 $B4 $A8 $80 $03 $AE $AC $80 $07 $1E $AF
	.db $C0 $0C $73 $B2 $00 $1D $AE $BC

_LABEL_2A22_:
	ld a, $02
	ld ($FFFF), a
	ld hl, $820A
	ld de, $2020
	call DecompressToVDP
	ld a, (FloorType)
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, Data_2A5C
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	push hl
	ex de, hl
	ld de, $2520
	call DecompressToVDP
	pop hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld de, $C800
	call LDI88
	ld hl, $86C5
	ld de, $C860
	jp LDI80

; Data from 2A5C to 2A6B (16 bytes)
Data_2A5C:
	.db $27 $87 $D1 $89 $3B $8A $0E $8E $78 $8E $32 $92 $9C $92 $EE $95

_LABEL_2A6C_:
	ld a, ($C0D5)
	or a
	jr nz, _LABEL_2A80_
	ld a, (CurrentMessage)
	or a
	jr nz, _LABEL_2A88_
	ld a, ($CAC5)
	or a
	jp nz, _LABEL_2B0B_
	ret

_LABEL_2A80_:
	xor a
	ld (CurrentMessage), a
	ld ($CAC5), a
	ret

_LABEL_2A88_:
	cp $FF
	jp z, _LABEL_2B1B_
	cp $FE
	jp z, _LABEL_2B23_
	ld a, ($CAC5)
	or a
	jr nz, _LABEL_2ABC_
	ld a, ($CA09)
	add a, $02
	and $3F
	ld c, a
	ld hl, ($CA09)
	ld a, l
	and $C0
	or c
	ld l, a
	ld de, $0540
	add hl, de
	ld a, h
	cp $3F
	jr c, _LABEL_2AB3_
	sub $07
_LABEL_2AB3_:
	ld h, a
	ld ($C7FA), hl
	ld a, $01
	ld ($CAC5), a
_LABEL_2ABC_:
	call _LABEL_2B2B_
	ld hl, $AA47
	ld de, $C700
	call DecompressToRAM
	ld a, (CurrentMessage)
	cp $01
	jp z, _LABEL_2B88_
	cp $02
	jp z, _LABEL_2BB8_
	cp $03
	jp z, _LABEL_2BEA_
	add a, a
	ld e, a
	ld d, $00
	ld hl, $AA7F
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld c, (hl)
	ld b, $00
	inc hl
	ld de, $C740
	ld a, $11
_LABEL_2AEF_:
	ldi
	ld a, $11
	ld (de), a
	inc de
	xor a
	or c
	jr nz, _LABEL_2AEF_
_LABEL_2AF9_:
	ld hl, $C700
	ld de, ($C7FA)
	ld bc, $033E
	call _LABEL_681_
	xor a
	ld (CurrentMessage), a
	ret

_LABEL_2B0B_:
	ld a, ($CA00)
	or a
	ret z
_LABEL_2B10_:
	call _LABEL_2198_
_LABEL_2B13_:
	xor a
	ld (CurrentMessage), a
	ld ($CAC5), a
	ret

_LABEL_2B1B_:
	ld a, ($CAC5)
	or a
	jr nz, _LABEL_2B10_
	jr _LABEL_2B13_

_LABEL_2B23_:
	call _LABEL_2B2B_
	xor a
	ld (CurrentMessage), a
	ret

_LABEL_2B2B_:
	ld a, $03
	ld ($FFFF), a
	ld hl, $AA63
	ld de, $C7BA
	call DecompressToRAM
	ld hl, (CurrentHPLow)
	call _LABEL_2C98_
	ld hl, $C7CC
	ld (hl), $60 ; H
	inc hl
	ld (hl), $11
	inc hl
	ld (hl), $68 ; P
	inc hl
	ld (hl), $11
	inc hl
	inc hl
	inc hl
	ex de, hl
	ld hl, $C0B3
	xor a
	ld b, $02
_LABEL_2B57_:
	or (hl)
	jr z, _LABEL_2B63_
	ld a, $80
	add a, (hl)
	ld (de), a
	inc de
	ld a, $11
	ld (de), a
	dec de
_LABEL_2B63_:
	inc de
	inc de
	dec hl
	djnz _LABEL_2B57_
	ld a, (hl)
	add a, $80
	ld (de), a
	inc de
	ld a, $11
	ld (de), a
	ld hl, ($CA09)
	ld a, l
	add a, $02
	and $3F
	ld d, a
	ld a, l
	and $C0
	or d
	ld l, a
	ex de, hl
	ld hl, $C7BA
	ld bc, $0310
	jp _LABEL_681_

_LABEL_2B88_:
	ld hl, ($CAC6)
	call _LABEL_2C6D_
	ld hl, ($AA81)
	ld c, (hl)
	ld b, $00
	inc hl
	ld de, $C740
_LABEL_2B98_:
	ldi
	ld a, $11
	ld (de), a
	inc de
	xor a
	or c
	jr nz, _LABEL_2B98_
	push hl
	call _LABEL_2CBC_
	pop hl
	ld c, (hl)
	ld b, $00
	inc hl
_LABEL_2BAB_:
	ldi
	ld a, $11
	ld (de), a
	inc de
	xor a
	or c
	jr nz, _LABEL_2BAB_
	jp _LABEL_2AF9_

_LABEL_2BB8_:
	ld hl, ($CAC6)
	call _LABEL_2C6D_
	ld hl, ($AA83)
	ld c, (hl)
	ld b, $00
	inc hl
	ld de, $C740
	ld a, $11
_LABEL_2BCA_:
	ldi
	ld a, $11
	ld (de), a
	inc de
	xor a
	or c
	jr nz, _LABEL_2BCA_
	push hl
	call _LABEL_2CBC_
	pop hl
	ld c, (hl)
	ld b, $00
	inc hl
_LABEL_2BDD_:
	ldi
	ld a, $11
	ld (de), a
	inc de
	xor a
	or c
	jr nz, _LABEL_2BDD_
	jp _LABEL_2AF9_

_LABEL_2BEA_:
	ld hl, ($CAC6)
	call _LABEL_2C6D_
	ld hl, ($AA85)
	ld c, (hl)
	ld b, $00
	inc hl
	ld de, $C740
_LABEL_2BFA_:
	ldi
	ld a, $11
	ld (de), a
	inc de
	xor a
	or c
	jr nz, _LABEL_2BFA_
	push hl
	push de
	ld a, ($CAC6)
	and $70
	rrca
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, Data_2C61
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, ($CAC6)
	sub $20
	jr c, _LABEL_2C32_
	ld c, a
	ld b, $00
	ld hl, $C935
	add hl, bc
	ld a, (hl)
	or a
	jr z, _LABEL_2C32_
	dec a
	ld hl, $0020
	add hl, de
	ex de, hl
	jr _LABEL_2C37_

_LABEL_2C32_:
	ld a, ($CAC6)
	and $0F
_LABEL_2C37_:
	add a, a
	ld l, a
	ld h, $00
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld c, (hl)
	ld b, $00
	inc hl
	pop de
_LABEL_2C45_:
	ldi
	ld a, $11
	ld (de), a
	inc de
	xor a
	or c
	jr nz, _LABEL_2C45_
	pop hl
	ld c, (hl)
	ld b, $00
	inc hl
_LABEL_2C54_:
	ldi
	ld a, $11
	ld (de), a
	inc de
	xor a
	or c
	jr nz, _LABEL_2C54_
	jp _LABEL_2AF9_

; Data from 2C61 to 2C6C (12 bytes)
Data_2C61:
	.db $00 $A0 $20 $A0 $40 $A0 $80 $A0 $C0 $A0 $00 $A1

_LABEL_2C6D_:
	ld b, $04
	ld de, $2710
	call _LABEL_2CB1_
	ld ($C0B5), a
	ld de, $03E8
	call _LABEL_2CB1_
	ld ($C0B4), a
	ld de, $0064
	call _LABEL_2CB1_
	ld ($C0B3), a
	ld de, $000A
	call _LABEL_2CB1_
	ld ($C0B2), a
	ld a, l
	ld ($C0B1), a
	ret

_LABEL_2C98_:
	ld b, $04
	ld de, $0064
	call _LABEL_2CB1_
	ld ($C0B3), a
	ld de, $000A
	call _LABEL_2CB1_
	ld ($C0B2), a
	ld a, l
	ld ($C0B1), a
	ret

_LABEL_2CB1_:
	xor a
_LABEL_2CB2_:
	or a
	sbc hl, de
	jr c, _LABEL_2CBA_
	inc a
	jr _LABEL_2CB2_

_LABEL_2CBA_:
	add hl, de
	ret

_LABEL_2CBC_:
	ld hl, $C0B5
	ld b, $04
	xor a
_LABEL_2CC2_:
	or (hl)
	jr z, _LABEL_2CCE_
	ld a, $80
	add a, (hl)
	ld (de), a
	inc de
	ld a, $11
	ld (de), a
	inc de
_LABEL_2CCE_:
	dec hl
	djnz _LABEL_2CC2_
	ld a, $80
	add a, (hl)
	ld (de), a
	inc de
	ld a, $11
	ld (de), a
	inc de
	ret

HandleTimers:
	call HandleFoodTimer
	call HandleHealTimer
	call HandlePoisonTimer
	call HandleBlindnessTimer
	call HandleDizzinessTimer
	ret

HandleFoodTimer:
	ld d, NormalFoodTicks
	ld a, ($C930)
	or a
	jr z, CheckFoodTimer
	ld d, FoodRingFoodTicks
	ld a, (EquippedRing)
	and IgnoreItemTypeMask
	cp (FoodRing & IgnoreItemTypeMask)
	jr z, CheckFoodTimer
	ld d, $04
	cp $07
	jr nz, CheckFoodTimer
	ld d, $02
CheckFoodTimer:
	ld a, d
	ld hl, FoodTimer
	cp (hl)
	jr c, Eat
	inc (hl)
	ret

Eat:
	ld (hl), $00
	ld a, (Food)
	sub $01
	daa
	jr c, Starve
	ld (Food), a
	ret

Starve:
	ld hl, (CurrentHPLow)
	dec hl
	ld (CurrentHPLow), hl
	ld a, l
	or a
	ret nz
	ld a, $FF
	ld ($C63F), a
	ret

HandleHealTimer:
	ld a, (PoisonTicksLeft)
	or a
	ret nz
	ld a, (Food)
	or a
	ret z
	ld a, ($C930)
	or a
	ld a, $08
	ld de, $0001
	jr z, _LABEL_2D50_
	ld a, (EquippedRing)
	cp CursedRing
	ret z
	cp HealRing
	ld a, $04
	jr nz, _LABEL_2D50_
	ld a, $02
_LABEL_2D50_:
	ld hl, HealTimer
	inc (hl)
	cp (hl)
	jr z, _LABEL_2D58_
	ret nc
_LABEL_2D58_:
	ld (hl), $00
	ld hl, (CurrentHPLow)
	ld de, (CharacterLevel)
	ld d, $00
	add hl, de
	ld (CurrentHPLow), hl
	ld de, (MaxHPLow)
	xor a
	sbc hl, de
	jr c, _LABEL_2D74_
	ld (CurrentHPLow), de
_LABEL_2D74_:
	ld a, ($CAC5)
	or a
	ret z
	ld a, $FE
	ld (CurrentMessage), a
	ret

HandlePoisonTimer:
	ld a, (PoisonTicksLeft)
	or a
	ret z
	dec a
	ld (PoisonTicksLeft), a
	ret

HandleBlindnessTimer:
	ld a, (BlindnessTicksLeft)
	or a
	ret z
	dec a
	ld (BlindnessTicksLeft), a
	ret nz
	ld hl, ($C105)
	ld a, (hl)
	cp $05
	ret z
	call _LABEL_20BA_
	ld a, $01
	ld ($C60E), a
	ret

HandleDizzinessTimer:
	ld a, (DizzinessTicksLeft)
	or a
	ret z
	dec a
	ld (DizzinessTicksLeft), a
	ret

_LABEL_2DAD_:
	ld b, $3F
	ld a, (PoisonTicksLeft)
	or a
	jr z, _LABEL_2DB7_
	ld b, $3A
_LABEL_2DB7_:
	ld a, (Food)
	or a
	jr nz, _LABEL_2DBF_
	ld b, $0F
_LABEL_2DBF_:
	ld hl, (MaxHPLow)
	srl h
	rr l
	srl h
	rr l
	ex de, hl
	ld hl, (CurrentHPLow)
	xor a
	sbc hl, de
	jr nc, _LABEL_2DE6_
	ld hl, $C0BE
	inc (hl)
	ld a, (hl)
	bit 4, a
	jr z, _LABEL_2DDD_
	cpl
_LABEL_2DDD_:
	and $0C
	ld b, a
	add a, a
	add a, a
	or b
	or $03
	ld b, a
_LABEL_2DE6_:
	ld a, (TableIndex3)
	or a
	ld de, $C06F
	jr nz, _LABEL_2DF7_
	ld de, $C02F
	ld hl, PaletteInRAMStatus
	set 0, (hl)
_LABEL_2DF7_:
	ex de, hl
	ld (hl), b
	ret

_LABEL_2DFA_:
	ld a, l
	and $1F
	sub $07
	jr nc, _LABEL_2E02_
	xor a
_LABEL_2E02_:
	cp $10
	jr c, _LABEL_2E08_
	ld a, $10
_LABEL_2E08_:
	ld e, a
	ld d, $00
	add a, a
	add a, a
	add a, a
	add a, a
	ld ($CA01), a
	ld a, $00
	rla
	ld ($CA02), a
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, h
	sub $05
	jr nc, _LABEL_2E21_
	xor a
_LABEL_2E21_:
	cp $14
	jr c, _LABEL_2E27_
	ld a, $14
_LABEL_2E27_:
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld ($CA03), hl
	add hl, hl
	add hl, de
	ld de, $D700
	add hl, de
	ld ($CA07), hl
	ld ($C60F), hl
	ld hl, $CB00
	ld ($C611), hl
	ld bc, $0C10
	call _LABEL_26F3_
	ld hl, $CB00
	ld de, $3800
	ld bc, $1840
	call VDPOut_661
	xor a
	ld ($CA05), a
	ld ($CA06), a
	ld hl, $3800
	ld ($CA09), hl
	ld a, $02
	ld ($CA0B), a
	ret
	ret									; Unreachable ret

_LABEL_2E69_:
	ret

_LABEL_2E6A_:
	ld a, ($CA00)
	or a
	ret z
	ld a, ($CAC5)
	or a
	jr z, _LABEL_2E7F_
	call _LABEL_2198_
	xor a
	ld (CurrentMessage), a
	ld ($CAC5), a
_LABEL_2E7F_:
	ld a, ($CA00)
	rrca
	call c, _LABEL_2EE1_
	rrca
	call c, _LABEL_2F22_
	rrca
	call c, _LABEL_2F68_
	rrca
	call c, _LABEL_2FA3_
	ld hl, ($CA01)
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld e, h
	ld d, $00
	ld hl, ($CA03)
	ld a, l
	and $F0
	ld l, a
	add hl, hl
	add hl, de
	ld de, $D700
	add hl, de
	ld ($CA07), hl
	ld a, ($CA05)
	neg
	and $F0
	rrca
	rrca
	ld e, a
	ld d, $00
	ld a, ($CA06)
	and $F0
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	ld de, $3800
	add hl, de
	ld ($CA09), hl
	ld a, ($CA00)
	or a
	ret z
	rrca
	call c, _LABEL_2FDC_
	rrca
	call c, _LABEL_2FF7_
	rrca
	call c, _LABEL_3020_
	rrca
	call c, _LABEL_3078_
	ret

_LABEL_2EE1_:
	push af
	ld hl, ($CA03)
	ld de, ($CA0B)
	ld d, $00
	xor a
	sbc hl, de
	jr nc, _LABEL_2EFA_
	ld a, ($CA03)
	or a
	jr z, _LABEL_2F1B_
	ld e, a
	ld hl, $0000
_LABEL_2EFA_:
	ld ($CA03), hl
	ld a, ($CA06)
	ld b, a
	sub e
	cp $E0
	jr c, _LABEL_2F08_
	sub $20
_LABEL_2F08_:
	ld ($CA06), a
	ld d, a
	and $0F
	jr z, _LABEL_2F1B_
	ld a, b
	and $0F
	jr z, _LABEL_2F20_
	ld a, b
	xor d
	and $10
	jr nz, _LABEL_2F20_
_LABEL_2F1B_:
	ld hl, $CA00
	res 0, (hl)
_LABEL_2F20_:
	pop af
	ret

_LABEL_2F22_:
	push af
	ld hl, ($CA03)
	ld de, ($CA0B)
	ld d, $00
	add hl, de
	ld a, h
	cp $01
	jr c, _LABEL_2F40_
	ld a, l
	sub $40
	jr c, _LABEL_2F40_
	neg
	add a, e
	jr z, _LABEL_2F61_
	ld e, a
	ld hl, $0140
_LABEL_2F40_:
	ld ($CA03), hl
	ld a, ($CA06)
	ld b, a
	add a, e
	cp $E0
	jr c, _LABEL_2F4E_
	add a, $20
_LABEL_2F4E_:
	ld ($CA06), a
	ld d, a
	and $0F
	jr z, _LABEL_2F61_
	ld a, b
	and $0F
	jr z, _LABEL_2F66_
	ld a, b
	xor d
	and $10
	jr nz, _LABEL_2F66_
_LABEL_2F61_:
	ld hl, $CA00
	res 1, (hl)
_LABEL_2F66_:
	pop af
	ret

_LABEL_2F68_:
	push af
	ld hl, ($CA01)
	ld de, ($CA0B)
	ld d, $00
	xor a
	sbc hl, de
	jr nc, _LABEL_2F81_
	ld a, ($CA01)
	or a
	jr z, _LABEL_2F9C_
	ld e, a
	ld hl, $0000
_LABEL_2F81_:
	ld ($CA01), hl
	ld a, ($CA05)
	ld b, a
	add a, e
	ld ($CA05), a
	ld d, a
	and $07
	jr z, _LABEL_2F9C_
	ld a, b
	and $07
	jr z, _LABEL_2FA1_
	ld a, b
	xor d
	and $08
	jr nz, _LABEL_2FA1_
_LABEL_2F9C_:
	ld hl, $CA00
	res 2, (hl)
_LABEL_2FA1_:
	pop af
	ret

_LABEL_2FA3_:
	push af
	ld hl, ($CA01)
	ld de, ($CA0B)
	ld d, $00
	add hl, de
	ld a, h
	or a
	jr z, _LABEL_2FBA_
	ld a, e
	sub l
	jr z, _LABEL_2FD5_
	ld e, a
	ld hl, $0100
_LABEL_2FBA_:
	ld ($CA01), hl
	ld a, ($CA05)
	ld b, a
	sub e
	ld ($CA05), a
	ld d, a
	and $07
	jr z, _LABEL_2FD5_
	ld a, b
	and $07
	jr z, _LABEL_2FDA_
	ld a, b
	xor d
	and $08
	jr nz, _LABEL_2FDA_
_LABEL_2FD5_:
	ld hl, $CA00
	res 3, (hl)
_LABEL_2FDA_:
	pop af
	ret

_LABEL_2FDC_:
	push af
	ld hl, ($CA07)
	ld ($C60F), hl
	ld hl, $CA42
	ld ($C611), hl
	ld bc, $0110
	call _LABEL_26F3_
	ld hl, ($CA09)
	ld ($CAC2), hl
	pop af
	ret

_LABEL_2FF7_:
	push af
	ld hl, ($CA07)
	ld de, $0180
	add hl, de
	ld ($C60F), hl
	ld hl, $CA42
	ld ($C611), hl
	ld bc, $0110
	call _LABEL_26F3_
	ld hl, ($CA09)
	ld a, h
	add a, $06
	cp $3F
	jr c, _LABEL_301A_
	sub $07
_LABEL_301A_:
	ld h, a
	ld ($CAC2), hl
	pop af
	ret

_LABEL_3020_:
	ld a, ($CA05)
	and $08
	rrca
	rrca
	ex af, af'
	ld de, $CA0C
	exx
	ld hl, ($CA07)
	ld a, ($CA05)
	and $08
	jr nz, _LABEL_3037_
	inc hl
_LABEL_3037_:
	ld de, $0020
	ld b, $0C
_LABEL_303C_:
	ld a, (hl)
	exx
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, $C800
	add hl, bc
	ex af, af'
	ld c, a
	ld b, $00
	ex af, af'
	add hl, bc
	ldi
	ldi
	inc hl
	inc hl
	ldi
	ldi
	exx
	add hl, de
	djnz _LABEL_303C_
	ld a, ($CA05)
	cpl
	and $08
	rrca
	rrca
	add a, $02
	ld d, a
	ld hl, ($CA09)
	ld a, l
	add a, d
	and $3F
	ld d, a
	ld a, l
	and $C0
	or d
	ld l, a
	ld ($CA40), hl
	ret

_LABEL_3078_:
	ld a, ($CA05)
	neg
	and $08
	rrca
	rrca
	ex af, af'
	ld de, $CA0C
	exx
	ld hl, ($CA07)
	ld de, $0010
	add hl, de
	ld de, $0020
	ld b, $0C
_LABEL_3092_:
	ld a, (hl)
	exx
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, $C800
	add hl, bc
	ex af, af'
	ld c, a
	ld b, $00
	ex af, af'
	add hl, bc
	ldi
	ldi
	inc hl
	inc hl
	ldi
	ldi
	exx
	add hl, de
	djnz _LABEL_3092_
	ld a, ($CA05)
	cpl
	and $08
	rrca
	rrca
	ld d, a
	ld hl, ($CA09)
	ld a, l
	add a, d
	and $3F
	ld d, a
	ld a, l
	and $C0
	or d
	ld l, a
	ld ($CA40), hl
	ret

_LABEL_30CC_:
	ld a, ($CA06)
	out (VDPControl), a
	ld a, $89
	out (VDPControl), a
	ld a, ($CA05)
	out (VDPControl), a
	ld a, $88
	out (VDPControl), a
	ret

_LABEL_30DF_:
	ld a, ($CA00)
	and $03
	call nz, _LABEL_30F4_
	ld a, ($CA00)
	and $0C
	call nz, _LABEL_3102_
	xor a
	ld ($CA00), a
	ret

_LABEL_30F4_:
	ld hl, $CA42
	ld de, ($CAC2)
	ld bc, $0240
	call _LABEL_681_
	ret

_LABEL_3102_:
	ld hl, $CA0C
	ld de, ($CA40)
	ld bc, $1A02
	jp _LABEL_681_

_LABEL_310F_:
	push ix
	pop hl
	ld e, l
	ld d, h
	inc de
	ld (hl), $00
	jp LDI31

_LABEL_311A_:
	call _LABEL_481B_
	ld a, (ix+5)
	ld (ix+7), a
	ld a, (ix+6)
	ld (ix+8), a
	ld (ix+2), $01
	ld (ix+3), $01
	ld (ix+4), $02
	ld (ix+19), $02
	ld (ix+0), <_LABEL_3142_
	ld (ix+1), >_LABEL_3142_
	ret

_LABEL_3142_:
	xor a
	ld ($C601), a
	ld hl, (CurrentHPLow)
	ld a, l
	or h
	jp z, _LABEL_31CB_
	call _LABEL_1EF6_
	jp c, _LABEL_322D_
	ld a, (TableIndex3)
	or a
	ret nz
	ld a, (ParalysisTicksLeft)
	or a
	jp nz, HandleParalysisTimer
	ld a, ($C932)
	or a
	jp nz, _LABEL_374A_
	ld a, (CurrentItem)
	or a
	jp nz, _LABEL_3796_
	ld a, (LastControllerState)
	bit 5, a
	jp nz, _LABEL_33F8_
	bit 4, a
	jp nz, _LABEL_31BD_
	ld a, (CurrentControllerState)
	and $0F
	jp z, _LABEL_321C_
	ld a, PlayerIdleTimeout
	ld (PlayerIdleTimer), a
	ld a, (DizzinessTicksLeft)
	or a
	jr nz, _LABEL_31AA_
	ld a, (CurrentControllerState)
	and (ix+4)
	jr nz, _LABEL_3199_
	ld a, (CurrentControllerState)
_LABEL_3199_:
	rrca
	jp c, _LABEL_32C4_
	rrca
	jp c, _LABEL_3309_
	rrca
	jp c, _LABEL_334E_
	rrca
	jp c, _LABEL_3393_
	ret

_LABEL_31AA_:
	call GetRandomNumber
	and $03
	jp z, _LABEL_32C4_
	dec a
	jp z, _LABEL_3309_
	dec a
	jp z, _LABEL_334E_
	jp _LABEL_3393_

_LABEL_31BD_:
	ld a, SoundEffect9B
	ld (SFXQueue), a
	call _LABEL_42C_
	ld a, $0F
	ld (TableIndex1), a
	ret

_LABEL_31CB_:
	ld a, SoundB1				; Seems to fadeout/silence music
	ld (MusicQueue), a
	ld a, PlayerDeadMessage
	ld (CurrentMessage), a
	ld (ix+30), $01
	ld (ix+24), $3C
	ld (ix+0), <_LABEL_31E6_
	ld (ix+1), >_LABEL_31E6_
	ret

_LABEL_31E6_:
	ld a, $01
	ld ($C0D5), a
	dec (ix+24)
	ret nz
	xor a
	ld (CurrentMessage), a
	ld ($CAC5), a
	call _LABEL_42C_
	ld a, $0B
	ld (TableIndex1), a			; Game over?
	ret

HandleParalysisTimer:
	ld hl, ParalysisTicksLeft
	dec (hl)
	jp nz, _LABEL_33D8_
	ld a, PlayerAwakenedMessage
	ld (CurrentMessage), a
	ret

_LABEL_320C_:
	ld hl, (CurrentHPLow)
	ld a, l
	or h
	jp z, _LABEL_31CB_
	call _LABEL_1EF6_
	jr c, _LABEL_321C_
	jp _LABEL_33D8_

_LABEL_321C_:
	ld a, ($CAC5)
	or a
	jr nz, _LABEL_322D_
	ld hl, PlayerIdleTimer
	dec (hl)
	jr nz, _LABEL_322D_
	ld a, PlayerIdleMessage
	ld (CurrentMessage), a
_LABEL_322D_:
	call _LABEL_481B_
	ld a, (ix+5)
	ld (ix+7), a
	ld a, (ix+6)
	ld (ix+8), a
	call _LABEL_4888_
	ret

; Data from 3240 to 3243 (4 bytes)
Data_3240:
	.db $06 $01 $0B $10

_LABEL_3244_:
	ld e, (ix+5)
	ld d, (ix+6)
	add hl, de
	ld a, (hl)
	res 7, a
	or a
	jr z, _LABEL_325E_
	cp $06
	jr c, _LABEL_3259_
	cp $0C
	jr c, _LABEL_325E_
_LABEL_3259_:
	xor a
	ld (SecretPathTries), a
	ret

_LABEL_325E_:
	scf
	ret

_LABEL_3260_:
	ld a, h
	ex af, af'
	ld a, l
	ld hl, $C145
	ld de, $001F
	ld b, $16
_LABEL_326B_:
	cp (hl)
	inc hl
	jr nz, _LABEL_3274_
	ex af, af'
	cp (hl)
	jr z, _LABEL_3279_
	ex af, af'
_LABEL_3274_:
	add hl, de
	djnz _LABEL_326B_
	xor a
	ret

_LABEL_3279_:
	ld a, l
	and $E0
	ld l, a
	scf
	ret

_LABEL_327F_:
	ld a, ($C930)
	or a
	ret z
	ld a, (EquippedRing)
	and IgnoreCurseMask
	cp ShiftRing
	ret nz
	call GetRandomNumber
	and $0F
	ret nz
	pop hl
	call _LABEL_4888_
	call _LABEL_1F8F_
	call _LABEL_481B_
	call _LABEL_20BA_
	ld hl, ($C105)
	ld de, $2D00
	add hl, de
	call _LABEL_2DFA_
	push ix
	call _LABEL_1F4F_
	pop ix
	call _LABEL_137_
	ld a, WarpMessage
	ld (CurrentMessage), a
	xor a
	ld ($CAC5), a
	ld a, SoundEffect98
	ld (SFXQueue), a
	jp _LABEL_3F1A_

_LABEL_32C4_:
	ld (ix+4), $01
	ld hl, $FFE0
	call _LABEL_3244_
	jp c, _LABEL_321C_
	call _LABEL_327F_
	call _LABEL_3260_
	ld de, Data_3A3A
	jp c, _LABEL_35CD_
	ld a, $FF
	ld (CurrentMessage), a
	ld (ix+30), $01
	ld l, (ix+5)
	ld h, (ix+6)
	ld de, $FFE0
	add hl, de
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+22), <Data_3845
	ld (ix+23), >Data_3845
	ld (ix+0), <_LABEL_3830_
	ld (ix+1), >_LABEL_3830_
	jp _LABEL_3830_

_LABEL_3309_:
	ld (ix+4), $02
	ld hl, $0020
	call _LABEL_3244_
	jp c, _LABEL_321C_
	call _LABEL_327F_
	call _LABEL_3260_
	ld de, Data_3A3E
	jp c, _LABEL_35CD_
	ld a, $FF
	ld (CurrentMessage), a
	ld (ix+30), $01
	ld l, (ix+5)
	ld h, (ix+6)
	ld de, $0020
	add hl, de
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+22), <Data_385C
	ld (ix+23), >Data_385C
	ld (ix+0), <_LABEL_3849_
	ld (ix+1), >_LABEL_3849_
	jp _LABEL_3849_

_LABEL_334E_:
	ld (ix+4), $04
	ld hl, $FFFF
	call _LABEL_3244_
	jp c, _LABEL_321C_
	call _LABEL_327F_
	call _LABEL_3260_
	ld de, Data_3A42
	jp c, _LABEL_35CD_
	ld a, $FF
	ld (CurrentMessage), a
	ld (ix+30), $01
	ld l, (ix+5)
	ld h, (ix+6)
	ld de, $FFFF
	add hl, de
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+22), <Data_3875
	ld (ix+23), >Data_3875
	ld (ix+0), <_LABEL_3860_
	ld (ix+1), >_LABEL_3860_
	jp _LABEL_3860_

_LABEL_3393_:
	ld (ix+4), $08
	ld hl, $0001
	call _LABEL_3244_
	jp c, _LABEL_321C_
	call _LABEL_327F_
	call _LABEL_3260_
	ld de, Data_3A46
	jp c, _LABEL_35CD_
	ld a, $FF
	ld (CurrentMessage), a
	ld (ix+30), $01
	ld l, (ix+5)
	ld h, (ix+6)
	ld de, $0001
	add hl, de
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+22), <Data_388C
	ld (ix+23), >Data_388C
	ld (ix+0), <_LABEL_3879_
	ld (ix+1), >_LABEL_3879_
	jp _LABEL_3879_

_LABEL_33D8_:
	ld a, $08
	ld ($C601), a
	ld l, (ix+5)
	ld h, (ix+6)
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), <_LABEL_38F5_
	ld (ix+1), >_LABEL_38F5_
	jp _LABEL_38F5_

_LABEL_33F8_:
	ld l, (ix+5)
	ld h, (ix+6)
	ld a, (hl)
	cp $0C
	jr nc, _LABEL_3461_
	ld a, (ix+4)
	ld hl, Data_3459
_LABEL_3409_:
	rrca
	jr c, _LABEL_3410_
	inc hl
	inc hl
	jr _LABEL_3409_

_LABEL_3410_:
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld l, (ix+5)
	ld h, (ix+6)
	add hl, de
	ld a, (hl)
	cp $06
	jr z, DoSecretPath
	cp $07
	jp nz, _LABEL_33D8_
DoSecretPath:
	ld a, ($C930)
	or a
	jr z, SearchForSecretPath
	ld a, (EquippedRing)
	cp SightRing
	jr z, RevealSecretPath
SearchForSecretPath:
	call GetRandomNumber
	and SecretPathTriesNeeded
	ld d, a
	ld a, (SecretPathTries)
	cp d
	jr c, SecretPathSearchFailed
RevealSecretPath:
	ld (hl), $05
	ld a, $01
	ld ($C606), a
	ld a, SecretPathFoundMessage
	ld (CurrentMessage), a
	ld a, SoundEffect93
	ld (SFXQueue), a
	ret

SecretPathSearchFailed:
	ld a, (SecretPathTries)
	inc a
	ld (SecretPathTries), a
	jp _LABEL_33D8_

; Data from 3459 to 3460 (8 bytes)
Data_3459:
	.dw $FFE0 $0020 $FFFF $0001

_LABEL_3461_:
	cp $10
	jr nc, _LABEL_3476_
	sub $0C
	jr z, _LABEL_34CF_
	dec a
	jp z, _LABEL_3544_
	dec a
	jp z, _LABEL_3548_
	dec a
	jp z, _LABEL_357C_
	ret

_LABEL_3476_:
	sub $10
	add a, a
	ld e, a
	ld d, $00
	ld hl, $C980
	add hl, de
	ex de, hl
	ld a, (de)
	and $70
	rrca
	ld c, a
	ld b, $00
	ld hl, $C907
	add hl, bc
	ld a, (hl)
	or a
	jr nz, _LABEL_34C7_
	ld a, (de)
	and $7F
	ld ($CAC6), a
	ld a, ItemFoundMessage1
	ld (CurrentMessage), a
	xor a
	ld b, $08
_LABEL_349E_:
	or (hl)
	jr nz, _LABEL_34A4_
	dec hl
	djnz _LABEL_349E_
_LABEL_34A4_:
	inc hl
	ld a, (de)
	ld (hl), a
	inc de
	ld l, (ix+5)
	ld h, (ix+6)
	ld a, (de)
	ld (hl), a
	ld bc, $0400
	add hl, bc
	ld (hl), a
	ex de, hl
	xor a
	ld (hl), a
	dec hl
	ld (hl), a
	ld a, $01
	ld ($C606), a
	ld a, SoundEffect93
	ld (SFXQueue), a
	jp _LABEL_33D8_

_LABEL_34C7_:
	ld a, HandsFullMessage
	ld (CurrentMessage), a
	jp _LABEL_33D8_

_LABEL_34CF_:
	ld (hl), $04
	call GetRandomNumber
	and $03
	inc a
	ld b, a
	ld a, (Floor)
	ld d, a
	xor a
_LABEL_34DD_:
	add a, d
	djnz _LABEL_34DD_
	ld d, a
	call GetRandomNumber
	and $03
	inc a
	ld b, a
	ld a, (CharacterLevel)
	ld e, a
	xor a
_LABEL_34ED_:
	add a, e
	djnz _LABEL_34ED_
	add a, d
	ld l, a
	ld h, $00
	call _LABEL_2C98_
	ld a, ($C0B3)
	ld h, a
	ld a, ($C0B2)
	add a, a
	add a, a
	add a, a
	add a, a
	ld l, a
	ld a, ($C0B1)
	or l
	ld l, a
	ld a, (MoneyLow)
	add a, l
	daa
	ld (MoneyLow), a
	ld a, (MoneyMid)
	adc a, h
	daa
	ld (MoneyMid), a
	ld a, (MoneyHigh)
	adc a, $00
	daa
	ld (MoneyHigh), a
	cp $10
	jr c, _LABEL_3532_
	ld a, $99
	ld (MoneyLow), a
	ld (MoneyMid), a
	ld a, $09
	ld (MoneyHigh), a
_LABEL_3532_:
	ld a, $01
	ld ($C606), a
	ld a, GoldFoundMessage
	ld (CurrentMessage), a
	ld a, SoundEffect93
	ld (SFXQueue), a
	jp _LABEL_33D8_

_LABEL_3544_:
	ld d, $10
	jr _LABEL_354A_

_LABEL_3548_:
	ld d, $30
_LABEL_354A_:
	ld (hl), $04
	call GetRandomNumber
	and $0F
	cp $09
	jr nc, _LABEL_354A_
	add a, d
	ld d, a
	call GetRandomNumber
	and $10
	add a, d
	ld d, a
	ld a, (Food)
	add a, d
	daa
	jr nc, _LABEL_3567_
	ld a, $99
_LABEL_3567_:
	ld (Food), a
	ld a, $01
	ld ($C606), a
	ld a, FoodFoundMessage
	ld (CurrentMessage), a
	ld a, SoundEffect93
	ld (SFXQueue), a
	jp _LABEL_33D8_

_LABEL_357C_:
	ld (hl), $04
	xor a
	ld (CurrentMessage), a
	ld ($CAC5), a
	ld a, $01
	ld ($C606), a
	ld ($C60E), a
	ld a, $3F
	ld (FlashColor), a
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld (ix+24), $3C
	ld (ix+0), <_LABEL_35B2_
	ld (ix+1), >_LABEL_35B2_
	ld a, $07
	ld ($FFFF), a
	call StopAllSound
	ld a, SoundEffect95
	ld (SFXQueue), a
	ret

_LABEL_35B2_:
	call _LABEL_3F2B_
	ret nc
	call _LABEL_461_
	ld (ix+0), <_LABEL_35C2_
	ld (ix+1), >_LABEL_35C2_
	ret

_LABEL_35C2_:
	ld a, (TableIndex3)
	or a
	ret nz
	ld a, $0D
	ld (TableIndex1), a
	ret

_LABEL_35CD_:
	ld (CurrentMonster), hl
	ld (ix+22), e
	ld (ix+23), d
	ld de, $001C
	add hl, de
	res 1, (hl)
	ld a, (EquippedWeapon)
	and IgnoreCurseMask
	cp $0E                 ; Great Sword?
	jr nz, _LABEL_35FD_
	ld de, $0003
	add hl, de
	ld a, (hl)
	or a
	jp z, _LABEL_372E_
	cp $04
	jp z, _LABEL_372E_
	cp $08
	jp z, _LABEL_372E_
	cp $1C
	jp z, _LABEL_372E_
_LABEL_35FD_:
	call GetRandomNumber
	and $7F
	ld b, a
	ld hl, (CurrentMonster)
	ld de, $001F
	add hl, de
	ld e, (hl)
	ld d, $00
	ld hl, MonsterEvasionTable
	add hl, de
	ld a, (WeaponHit)
	sub (hl)
	add a, $64
	cp b
	jp c, _LABEL_3712_
	ld hl, BasePW
	ld a, (WeaponPW)
	add a, (hl)
	call _LABEL_4848_
	ld e, a
	ld d, $00
	ld hl, (CurrentMonster)
	ld bc, $001F
	add hl, bc
	ld a, (EquippedWeapon)
	and $7F
	sub $09
	jp c, DoAttack
	jr z, DoMagiMasherSword
	dec a
	jr z, DoBushidoBladeSword
	dec a
	jr z, DoGhostKillerSword
	dec a
	jr z, DoDragonslayerSword
	dec a
	jr z, _LABEL_369F_
	dec a
	jr z, _LABEL_36C2_
	ld c, e
	ld b, d
	srl b
	rr c
	ld a, c
	or b
	jr nz, _LABEL_3657_
	ld bc, $0001
_LABEL_3657_:
	ld hl, (CurrentHPLow)
	xor a
	sbc hl, bc
	ld (CurrentHPLow), hl
	jr nc, DoAttack
	ld hl, $0000
	ld (CurrentHPLow), hl
	ld a, $FE
	ld ($C63F), a
	jr DoAttack

DoMagiMasherSword:
	ld a, (hl)
	cp Witch
	jr z, DoubleDamage
	cp MadWitch
	jr z, DoubleDamage
	jr DoAttack

DoBushidoBladeSword:
	ld a, (hl)
	cp Myst
	jr z, DoubleDamage
	cp DeathMyst
	jr z, DoubleDamage
	jr DoAttack

DoGhostKillerSword:
	ld a, (hl)
	cp Phantom
	jr z, DoubleDamage
	cp Spectre
	jr z, DoubleDamage
	cp Wraith
	jr z, DoubleDamage
	jr DoAttack

DoDragonslayerSword:
	ld a, (hl)
	cp Dragon
	jr nz, DoAttack
	ex de, hl
	add hl, hl
	add hl, hl
	ex de, hl
	jr DoAttack

_LABEL_369F_:
	ld c, e
	ld b, d
	srl b
	rr c
	ld a, c
	or b
	jr nz, _LABEL_36AC_
	ld bc, $0001
_LABEL_36AC_:
	ld hl, (CurrentHPLow)
	add hl, bc
	ld (CurrentHPLow), hl
	ld bc, (MaxHPLow)
	xor a
	sbc hl, bc
	jr c, DoAttack
	ld (CurrentHPLow), bc
	jr DoAttack

_LABEL_36C2_:
	jr DoAttack

DoubleDamage:
	ex de, hl
	add hl, hl
	ex de, hl
DoAttack:
	ld (DamageDealt), de
	ex de, hl
	call _LABEL_486E_
	ld a, e
	or d
	ld a, SoundEffect90
	jr nz, _LABEL_36D7_
	ld a, SoundEffect91
_LABEL_36D7_:
	ld (SFXQueue), a
	ld (ix+20), $00
	ld (ix+21), $00
	ld (ix+24), $08
	ld (ix+0), <_LABEL_3928_
	ld (ix+1), >_LABEL_3928_
	jp _LABEL_3928_

; Monster evasion table
.include "monsters\monster_evasion_table.asm"

_LABEL_3712_:
	ld (ix+20), $00
	ld (ix+21), $00
	ld (ix+24), $08
	ld (ix+0), <_LABEL_390A_
	ld (ix+1), >_LABEL_390A_
	ld a, SoundEffect92
	ld (SFXQueue), a
	jp _LABEL_390A_

_LABEL_372E_:
	ld (ix+20), $00
	ld (ix+21), $00
	ld (ix+24), $08
	ld (ix+0), <_LABEL_3919_
	ld (ix+1), >_LABEL_3919_
	ld a, SoundEffect92
	ld (SFXQueue), a
	jp _LABEL_3919_

_LABEL_374A_:
	ld a, $04
	ld ($FFFF), a
	ld a, ($C932)
	and $70
	rrca
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, $B90A
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	or a
	jr z, _LABEL_3768_
	cp $06
	jr nz, _LABEL_3779_
_LABEL_3768_:
	ld a, (ix+4)
	ld bc, $0080
	ld hl, $0000
_LABEL_3771_:
	rrca
	jr c, _LABEL_3777_
	add hl, bc
	jr _LABEL_3771_

_LABEL_3777_:
	add hl, de
	ex de, hl
_LABEL_3779_:
	ex de, hl
	ld de, $0300
	rst $08	; Interrupt8
	ld bc, $80BE
_LABEL_3781_:
	outi
	jr nz, _LABEL_3781_
	ld hl, _LABEL_3DA6_
	ld ($C3E0), hl
	ld (ix+0), <_LABEL_3AAC_
	ld (ix+1), >_LABEL_3AAC_
	jp _LABEL_3AAC_

_LABEL_3796_:
	ld a, (CurrentItem)
	bit 7, a
	jr z, _LABEL_37A5_
	and $70
	jp z, CursedSwordAction
	jp CursedArmorAction

_LABEL_37A5_:
	sub $20
	jr c, DoItemAction
	cp $20
	jr nc, DoItemAction
	and $70
	rrca
	rrca
	ld e, a
	ld a, (ix+4)
_LABEL_37B5_:
	rrca
	jr c, _LABEL_37BB_
	inc e
	jr _LABEL_37B5_

_LABEL_37BB_:
	ld d, $00
	ld hl, Data_37E0
	add hl, de
	ld a, (hl)
	ld (ix+3), a
DoItemAction:
	ld a, (CurrentItem)
	sub $20					; Weapons are $0X, armor is $1X, subtract $20 to ignore those offsets
	and IgnoreCurseMask		; Ignore curse bit?
	ld e, a
	ld d, $00
	ld hl, ItemActionOffsets
	add hl, de
	ld e, (hl)
	ld d, $00
	ld hl, ItemActionTable
	add hl, de
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	jp (hl)

; Data from 37E0 to 37EF (16 bytes)
Data_37E0:
	.db $09 $04 $0E $13 $0A $05 $0F $14 $06 $01 $0B $10 $06 $01 $0B $10 ; Possibly identifies unidentified items?

; Table mapping items to their offsets in the item action table
ItemActionOffsets:
	.include "items\behavior\item_action_offsets.asm"

_LABEL_3830_:
	ld a, (ix+15)
	cp $58
	jr z, _LABEL_3839_
	jr nc, _LABEL_383F_
_LABEL_3839_:
	ld a, (ix+4)
	ld ($CA00), a
_LABEL_383F_:
	call _LABEL_47B8_
	jp _LABEL_3890_

; Data from 3845 to 3848 (4 bytes)
Data_3845:
.db $03 $02 $07 $06

_LABEL_3849_:
	ld a, (ix+15)
	cp $68
	jr c, _LABEL_3856_
	ld a, (ix+4)
	ld ($CA00), a
_LABEL_3856_:
	call _LABEL_47B8_
	jp _LABEL_3890_

; Data from 385C to 385F (4 bytes)
Data_385C:
.db $03 $02 $02 $01

_LABEL_3860_:
	ld a, (ix+17)
	cp $78
	jr z, _LABEL_3869_
	jr nc, _LABEL_386F_
_LABEL_3869_:
	ld a, (ix+4)
	ld ($CA00), a
_LABEL_386F_:
	call _LABEL_47B8_
	jp _LABEL_3890_

; Data from 3875 to 3878 (4 bytes)
Data_3875:
.db $03 $02 $0C $0B

_LABEL_3879_:
	ld a, (ix+17)
	cp $88
	jr c, _LABEL_3886_
	ld a, (ix+4)
	ld ($CA00), a
_LABEL_3886_:
	call _LABEL_47B8_
	jp _LABEL_3890_

; Data from 388C to 388F (4 bytes)
Data_388C:
.db $03 $02 $11 $10

_LABEL_3890_:
	ld a, ($C601)
	inc a
	ld ($C601), a
	cp $08
	ret c
	ld l, (ix+7)
	ld h, (ix+8)
	ld (ix+5), l
	ld (ix+6), h
	ld a, (hl)
	cp $01
	jp z, _LABEL_3CD6_
	ld a, (BlindnessTicksLeft)
	or a
	jr nz, _LABEL_38D2_
	ld a, (hl)
	cp $02
	jr z, _LABEL_38CA_
	sub $10
	jr c, _LABEL_38D2_
	add a, a
	ld e, a
	ld d, $00
	ld hl, $C981
	add hl, de
	ld a, (hl)
	cp $02
	jr nz, _LABEL_38D2_
	ld (hl), $03
_LABEL_38CA_:
	call _LABEL_20BA_
	ld a, $01
	ld ($C60E), a
_LABEL_38D2_:
	ld a, $01
	ld ($C606), a
	ld (ix+30), $00
	ld a, (SluggishTicksLeft)
	or a
	jr nz, _LABEL_38EC_
	ld (ix+0), <_LABEL_3142_
	ld (ix+1), >_LABEL_3142_
	jp HandleTimers

_LABEL_38EC_:
	ld (ix+0), <_LABEL_320C_
	ld (ix+1), >_LABEL_320C_
	ret

_LABEL_38F5_:
	ld a, ($C601)
	inc a
	ld ($C601), a
	cp $10
	ret c
	ld (ix+0), <_LABEL_3142_
	ld (ix+1), >_LABEL_3142_
	jp HandleTimers

_LABEL_390A_:
	call _LABEL_478D_
	dec (ix+24)
	ret nz
	ld a, PlayerMissedMessage
	ld (CurrentMessage), a
	jp _LABEL_33D8_

_LABEL_3919_:
	call _LABEL_478D_
	dec (ix+24)
	ret nz
	ld a, SwordDoesNothingMessage
	ld (CurrentMessage), a
	jp _LABEL_33D8_

_LABEL_3928_:
	ld a, (ix+24)
	and $01
	ld hl, (CurrentMonster)
	ld de, $0002
	add hl, de
	ld (hl), a
	call _LABEL_478D_
	dec (ix+24)
	ret nz
_LABEL_393C_:
	ld a, MonsterDamagedMessage1_Mirror
	ld (CurrentMessage), a
	ld hl, (DamageDealt)
	ld ($CAC6), hl
	ld hl, (CurrentMonster)
	ld de, $001C
	add hl, de
	set 4, (hl)
	ld hl, (CurrentMonster)
	ld de, $0002
	add hl, de
	ld (hl), $01
	ld de, $0018
	add hl, de
	ld a, (hl)
	inc hl
	or (hl)
	jr nz, _LABEL_39B9_
_LABEL_3962_:
	ld a, VictoryMessage
	ld (CurrentMessage), a
	ld iy, (CurrentMonster)
	ld (iy+0), <_LABEL_310F_
	inc hl
	ld (iy+1), >_LABEL_310F_
	ld a, (iy+31)
	cp $1F
	jr c, _LABEL_39A0_
	ld e, (iy+15)
	ld d, (iy+17)
	call _LABEL_1ECB_
	ex de, hl
	ld l, (iy+5)
	ld h, (iy+6)
	ld bc, $0400
	add hl, bc
	ld a, (hl)
	add a, a
	add a, a
	add a, a
	ld c, a
	ld b, $00
	ld hl, $C800
	add hl, bc
	ld bc, $0204
	call _LABEL_681_
_LABEL_39A0_:
	ld e, (iy+31)
	ld d, $00
	ld hl, MonsterExperienceTable
	add hl, de
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, (ExperienceLow)
	add hl, de
	jr nc, _LABEL_39B6_
	ld hl, $FFFF
_LABEL_39B6_:
	ld (ExperienceLow), hl
_LABEL_39B9_:
	ld de, (NextLevelLow)
	ld hl, (ExperienceLow)
	or a
	sbc hl, de
	jp c, _LABEL_33D8_
	ld a, LevelUpMessage
	ld (CurrentMessage), a
	ld a, SoundEffectA9
	ld (SFXQueue), a
	ld a, (CharacterLevel)
	inc a
	cp MaximumCharacterLevel
	jr c, _LABEL_39DA_
	ld a, MaximumCharacterLevel
_LABEL_39DA_:
	ld (CharacterLevel), a
	add a, a
	ld e, a
	ld d, $00
	ld hl, ExperienceNeededTable			; Use high byte/low byte operator?
	add hl, de
	ld a, (hl)
	ld (NextLevelLow), a
	inc hl
	ld a, (hl)
	ld (NextLevelHigh), a
	ld a, (CharacterLevel)
	rrca
	rrca
	and $3F
	inc a
	ld d, a
	ld a, (BasePW)
	add a, d
	cp $3C
	jr c, _LABEL_3A01_
	ld a, $3B
_LABEL_3A01_:
	ld (BasePW), a
	ld a, (CharacterLevel)
	ld d, a
	ld a, (Floor)
	add a, d
	add a, a
	ld e, a
	ld d, $00
	ld hl, (MaxHPLow)
	add hl, de
	ld (MaxHPLow), hl
	ld bc, $03E7
	or a
	sbc hl, bc
	jr c, _LABEL_3A25_
	ld hl, $03E7
	ld (MaxHPLow), hl
_LABEL_3A25_:
	ld hl, (CurrentHPLow)
	add hl, de
	ld (CurrentHPLow), hl
	or a
	sbc hl, bc
	jr c, _LABEL_3A37_
	ld hl, $03E7
	ld (CurrentHPLow), hl
_LABEL_3A37_:
	jp _LABEL_3F1A_

; Data from 3A3A to 3A49 (16 bytes)
Data_3A3A:
	.db $04 $02 $08 $06
	
Data_3A3E:
	.db $04 $02 $03 $01

Data_3A42:
	.db $04 $02 $0D $0B

Data_3A46:
	.db $04 $02 $12 $10

; Data from 3A50 to 3AAB (98 bytes)
; Experience given by monsters! 3A50-3A8A
.include "monsters/monster_experience_table.asm"

; Experience table 3A8B-3AAB
.include "player/player_experience_needed_table.asm"

_LABEL_3AAC_:
	ld hl, ($C3E0)
	ld a, l
	or h
	ret nz
	ld a, ($C932)
	or a
	jp z, _LABEL_33D8_
	ld hl, (CurrentMonster)
	ld de, $001C
	add hl, de
	res 1, (hl)
	cp $40
	jr nc, DoJumpTable6
	ld a, ($C932)
	cp $0E
	jr nz, _LABEL_3AE9_
	ld hl, (CurrentMonster)
	ld de, $001F
	add hl, de
	ld a, (hl)
	cp $00
	jp z, _LABEL_3C74_
	cp $04
	jp z, _LABEL_3C74_
	cp $08
	jp z, _LABEL_3C74_
	cp $1C
	jp z, _LABEL_3C74_
_LABEL_3AE9_:
	call GetRandomNumber
	and $7F
	ld b, a
	ld hl, (CurrentMonster)
	ld de, $001F
	add hl, de
	ld e, (hl)
	ld d, $00
	ld hl, MonsterEvasionTable
	add hl, de
	ld a, $64
	sub (hl)
	cp b
	jp c, _LABEL_3C74_
	ld a, ($C932)
	cp $20
	jr c, _LABEL_3B0E_
	xor a
	jr _LABEL_3B16_

_LABEL_3B0E_:
	ld hl, Data_3C85
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
_LABEL_3B16_:
	ld hl, BasePW
	add a, (hl)
	call _LABEL_4848_
	ld l, a
	ld h, $00
	ld (DamageDealt), hl
	call _LABEL_486E_
	ld a, e
	or d
	ld a, SoundEffect90
	jr nz, _LABEL_3B2E_
	ld a, SoundEffect91
_LABEL_3B2E_:
	ld (SFXQueue), a
	xor a
	ld ($C932), a
	jp _LABEL_393C_

; Seems to be effects of thrown objects?
DoJumpTable6:
	set 4, (hl)
	sub $40
	ld e, a
	ld d, $00
	ld hl, JumpTable6ActionOffsets
	add hl, de
	ld a, (hl)
	add a, a
	ld e, a
	ld d, $00
	ld hl, JumpTable6
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	jp (hl)

; 1st entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3B51:
	ld hl, (CurrentMonster)
	ld de, $001A
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	add hl, hl
	ld bc, $03E7
	or a
	sbc hl, bc
	jr c, _LABEL_3B68_
	ld hl, $0000
_LABEL_3B68_:
	add hl, bc
	ex de, hl
	ld (hl), d
	dec hl
	ld (hl), e
	ld a, MonsterEnragedMessage
	ld (CurrentMessage), a
	xor a
	ld ($C932), a
	ld a, SoundEffectA9
	ld (SFXQueue), a
	jp _LABEL_3F1A_

; 2nd entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3B7E:
	ld hl, (CurrentMonster)
	ld de, $001A
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld c, e
	ld b, d
	srl b
	rr c
	srl b
	rr c
	ex de, hl
	xor a
	sbc hl, bc
	ex de, hl
	ld (hl), d
	dec hl
	ld (hl), e
	ld a, MonsterSlowMessage
	ld (CurrentMessage), a
	xor a
	ld ($C932), a
	ld a, SoundEffect90
	ld (SFXQueue), a
	jp _LABEL_3F1A_

; 3rd entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3BAB:
	ld hl, (CurrentMonster)
	ld de, $001C
	add hl, de
	set 0, (hl)
	ld a, MonsterConfusedMessage
	ld (CurrentMessage), a
	xor a
	ld ($C932), a
	ld a, SoundEffect90
	ld (SFXQueue), a
	jp _LABEL_3F1A_

; 4th entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3BC5:
	ld hl, (CurrentMonster)
	ld de, $001C
	add hl, de
	set 1, (hl)
	res 4, (hl)
	ld a, MonsterParalyzedMessage
	ld (CurrentMessage), a
	xor a
	ld ($C932), a
	ld a, SoundEffect90
	ld (SFXQueue), a
	jp _LABEL_3F1A_

; 5th entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3BE1:
	ld hl, (CurrentMonster)
	ld de, $001A
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	srl d
	rr e
	srl d
	rr e
	ld a, e
	or d
	jr nz, _LABEL_3BFA_
	ld de, $0001
_LABEL_3BFA_:
	ld (hl), d
	dec hl
	ld (hl), e
	ld a, MonsterSlowMessage
	ld (CurrentMessage), a
	xor a
	ld ($C932), a
	ld a, SoundEffect90
	ld (SFXQueue), a
	jp _LABEL_3F1A_

; 6th entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3C0E:
	ld a, NothingHappenedMessage
	ld (CurrentMessage), a
	xor a
	ld ($C932), a
	jp _LABEL_3F1A_

; 7th entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3C1A:
	xor a
	ld ($C932), a
	ld hl, $0001
	ld (DamageDealt), hl
	call _LABEL_486E_
	jp _LABEL_393C_

; 8th entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3C2A:
	call _LABEL_207D_
	ex de, hl
	ld hl, (CurrentMonster)
	ld bc, $0005
	add hl, bc
	ld (hl), e
	inc hl
	ld (hl), d
	ld a, MonsterBlownAwayMessage
	ld (CurrentMessage), a
	xor a
	ld ($C932), a
	jp _LABEL_3F1A_

; 9th entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3C44:
	ld hl, (CurrentMonster)
	ld de, $001F
	add hl, de
	ld a, (hl)
	cp $01
	jr z, _LABEL_3C5C_
	cp $05
	jr z, _LABEL_3C5C_
	cp $09
	jr z, _LABEL_3C5C_
	xor a
	jp _LABEL_3B16_

_LABEL_3C5C_:
	xor a
	ld ($C932), a
	ld hl, $03E7
	ld (DamageDealt), hl
	call _LABEL_486E_
	jp _LABEL_393C_

; 10th entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3C6C:
	xor a
	jp _LABEL_3B16_

; 11th entry of Jump Table from 3CC0 (indexed by unknown)
JumpTable6_3C70:
	xor a
	jp _LABEL_3C5C_

_LABEL_3C74_:
	ld a, SoundEffect92
	ld (SFXQueue), a
	ld a, PlayerMissedMessage
	ld (CurrentMessage), a
	xor a
	ld ($C932), a
	jp _LABEL_3F1A_

; Data from 3C85 to 3C8F (11 bytes)
Data_3C85:
	.db $00 $01 $02 $03 $05 $08 $0B $0E $12 $06 $06

; Data from 3C90 to 3C9F (16 bytes)
Data_3C90:
	.db $08 $08 $04 $08 $0C $00 $01 $02 $03 $04 $05 $06 $06 $0A $04 $0A 

; Data from 3CA0 to 3CBF (32 bytes)
; Same number of actions as monsters, but doesn't seem to match up
; with monster speed or behavior
; No- appears to be combat actions based on item?
JumpTable6ActionOffsets:
	.db $00 $00 $01 $00 $02 $02 $08 $03 $00 $00 $00 $09 $04 $00 $00 $00
	.db $00 $09 $00 $09 $00 $00 $04 $0A $09 $07 $00 $00 $00 $00 $00 $00

; Jump Table from 3CC0 to 3CD5 (11 entries, indexed by unknown)
JumpTable6:
	.dw JumpTable6_3B51 JumpTable6_3B7E JumpTable6_3BAB JumpTable6_3BC5
	.dw JumpTable6_3BE1 JumpTable6_3C0E JumpTable6_3C1A JumpTable6_3C2A
	.dw JumpTable6_3C44 JumpTable6_3C6C JumpTable6_3C70

_LABEL_3CD6_:
	ld hl, Floor
	inc (hl)
	ld a, (hl)
	call _LABEL_42C_
	ld a, $08
	ld (TableIndex1), a
	jp _LABEL_137_

_LABEL_3CE6_:
	call _LABEL_481B_
	ld a, (ix+5)
	ld (ix+7), a
	ld a, (ix+6)
	ld (ix+8), a
	ld (ix+2), $01
	ld (ix+3), $15
	ld (ix+4), $02
	ld (ix+19), $02
	ld (ix+22), <Data_3D16
	ld (ix+23), >Data_3D16
	ld (ix+0), <_LABEL_3D1A_
	ld (ix+1), >_LABEL_3D1A_
	ret

; Data from 3D16 to 3D19 (4 bytes)
Data_3D16:
.db $07 $02 $15 $15

_LABEL_3D1A_:
	call _LABEL_478D_
	ld a, ($C601)
	cp $01
	jr z, _LABEL_3D34_
	call _LABEL_481B_
	ld a, (ix+5)
	ld (ix+7), a
	ld a, (ix+6)
	ld (ix+8), a
	ret

_LABEL_3D34_:
	ld (ix+24), $08
	ld hl, ($C105)
	ld (ix+7), l
	ld (ix+8), h
	ld e, (ix+5)
	ld d, (ix+6)
	dec de
	or a
	sbc hl, de
	jr z, _LABEL_3D62_
	jr c, _LABEL_3D7E_
	ld a, l
	cp $02
	jr nz, _LABEL_3D70_
	ld (ix+4), $08
	ld (ix+0), <_LABEL_3D8A_
	ld (ix+1), >_LABEL_3D8A_
	jr _LABEL_3D8A_

_LABEL_3D62_:
	ld (ix+4), $04
	ld (ix+0), <_LABEL_3D8A_
	ld (ix+1), >_LABEL_3D8A_
	jr _LABEL_3D8A_

_LABEL_3D70_:
	ld (ix+4), $02
	ld (ix+0), <_LABEL_3D8A_
	ld (ix+1), >_LABEL_3D8A_
	jr _LABEL_3D8A_

_LABEL_3D7E_:
	ld (ix+4), $01
	ld (ix+0), <_LABEL_3D8A_
	ld (ix+1), >_LABEL_3D8A_
_LABEL_3D8A_:
	call _LABEL_47B8_
	dec (ix+24)
	ret nz
	ld l, (ix+7)
	ld h, (ix+8)
	ld (ix+5), l
	ld (ix+6), h
	ld (ix+0), <_LABEL_3D1A_
	ld (ix+1), >_LABEL_3D1A_
	ret

_LABEL_3DA6_:
	ld hl, ($C10A)
	ld (ix+10), l
	ld (ix+11), h
	ld hl, ($C10D)
	ld (ix+13), l
	ld (ix+14), h
	ld (ix+19), $04
	ld (ix+2), $01
	ld (ix+3), $1F
	ld (ix+24), $04
	ld a, ($C104)
	ld (ix+4), a
	ld (ix+0), <_LABEL_3DD7_
	ld (ix+1), >_LABEL_3DD7_
	ret

_LABEL_3DD7_:
	call _LABEL_47BB_
	dec (ix+24)
	ret nz
	ld a, (ix+10)
	and $F0
	ld l, a
	ld h, (ix+11)
	add hl, hl
	ex de, hl
	ld a, (ix+13)
	and $F0
	ld h, (ix+14)
	srl h
	rra
	srl h
	rra
	srl h
	rra
	srl h
	rra
	ld l, a
	add hl, de
	ld de, $D300
	add hl, de
	ld a, (hl)
	and $7F
	jr z, _LABEL_3E51_
	cp $0C
	jr nc, _LABEL_3E10_
	cp $06
	jr nc, _LABEL_3E51_
_LABEL_3E10_:
	ld iy, $C140
	ld de, $0020
	ld b, $14
_LABEL_3E19_:
	ld a, (iy+11)
	cp (ix+11)
	jr nz, _LABEL_3E39_
	ld a, (iy+10)
	cp (ix+10)
	jr nz, _LABEL_3E39_
	ld a, (iy+14)
	cp (ix+14)
	jr nz, _LABEL_3E39_
	ld a, (iy+13)
	cp (ix+13)
	jr z, _LABEL_3E42_
_LABEL_3E39_:
	add iy, de
	djnz _LABEL_3E19_
	ld (ix+24), $04
	ret

_LABEL_3E42_:
	push iy
	pop hl
	ld (CurrentMonster), hl
	ld (ix+0), <_LABEL_310F_
	ld (ix+1), >_LABEL_310F_
	ret

_LABEL_3E51_:
	ld a, SoundEffect92
	ld (SFXQueue), a
	ld a, PlayerMissedMessage
	ld (CurrentMessage), a
	xor a
	ld ($C932), a
	ld (ix+0), <_LABEL_310F_
	ld (ix+1), >_LABEL_310F_
	ret

; Jump Table from 3E68 to 3ED7 (56 entries, indexed by CurrentItem)
ItemActionTable:
	.dw BladeScrollAction     ShieldScrollAction    NorustScrollAction      BlessScrollAction
	.dw NothingHappenedAction MapScrollAction       ShiftScrollAction       MadScrollAction
	.dw FreezePotionAction    SummonScrollAction    MagiScrollAction        GasScrollAction
	.dw GhostScrollAction     DragonScrollAction    BlankScrollAction       FlameRodAction
	.dw FlashRodAction        ThunderRodAction      WindRodAction           BerserkRodAction
	.dw SilentRodAction       ReshapeRodAction      TravelRodAction         DrainRodAction
	.dw WitherRodAction       MinhealPotionAction   MidhealPotionAction     SlowPotionAction
	.dw SlowfixPotionAction   FogPotionAction       UnusedDizzinessItem     CurePotionAction
	.dw MaxhealPotionAction   WitherPotionAction    HealFoodRingEquipAction MagicRingEquipAction
	.dw SightRingEquipAction  ShieldRingEquipAction OgreRingEquipAction     ShiftRingEquipAction
	.dw CursedRingEquipAction HungerRingEquipAction ToyRingEquipAction      CursedSwordAction
	.dw CursedSwordAction     CursedArmorAction     PowerPotionAction       ReflexPotionAction
	.dw PotionScrollAction    SpiritRodAction       WaterPotionAction       DazePotionAction
	.dw UnusedNothingItem     UnusedNothingItem     UnusedNothingItem       UnusedNothingItem

_LABEL_3ED8_:
	ld a, $3F
	ld (FlashColor), a
	jr _LABEL_3EE5_

_LABEL_3EDF_:
	ld a, (PaletteInRAM)
	ld (FlashColor), a
_LABEL_3EE5_:
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld (ix+24), $1E
	ld hl, _LABEL_3EF5_
	jp SetVBlankContinuation

_LABEL_3EF5_:
	call _LABEL_3F2B_
	ret nc
	ld a, (NextMessage)
	ld (CurrentMessage), a
	ld hl, CurrentItem
	bit 7, (hl)
	jr z, _LABEL_3F0B_
	ld a, SoundEffectAA
	ld (SFXQueue), a
_LABEL_3F0B_:
	ld a, (hl)
	cp $23
	jr nz, _LABEL_3F15_
	ld a, SoundEffectAB
	ld (SFXQueue), a
_LABEL_3F15_:
	ld (hl), $00
	call _LABEL_4888_
_LABEL_3F1A_:
	ld (ix+24), $0F
	ld hl, _LABEL_3F24_
	jp SetVBlankContinuation

_LABEL_3F24_:
	dec (ix+24)
	ret nz
	jp _LABEL_33D8_

_LABEL_3F2B_:
	dec (ix+24)
	jr z, _LABEL_3F46_
	ld a, (FlashColor)
	bit 0, (ix+24)
	jr nz, _LABEL_3F3C_
	ld a, (SavedColor)
_LABEL_3F3C_:
	ld (PaletteInRAM), a
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	xor a
	ret

_LABEL_3F46_:
	ld a, (SavedColor)
	ld (PaletteInRAM), a
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	scf
	ret

; 1st entry of Jump Table from 3E68 (indexed by unknown)
BladeScrollAction:
	ld a, (WeaponPW)
	inc a
	cp WeaponPWCap					; Cap weapon power at 59
	jr c, SetWeaponPW
	ld a, WeaponPWCap-1
SetWeaponPW:
	ld (WeaponPW), a
	ld a, WeaponStrongerMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 2nd entry of Jump Table from 3E68 (indexed by unknown)
ShieldScrollAction:
	ld hl, ArmorAC
	inc (hl)
	ld a, ArmorStrongerMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 3rd entry of Jump Table from 3E68 (indexed by unknown)
NorustScrollAction:
	ld a, $01
	ld (PreventArmorRust), a
	ld a, NoRustMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 4th entry of Jump Table from 3E68 (indexed by unknown)
BlessScrollAction:
	ld a, ($C930)
	or a
	jr z, _LABEL_3F94_
	ld a, (EquippedRing)
	and IgnoreCurseMask
	cp CursedRing
	jr c, _LABEL_3F94_
	cp ToyRing
	jr nz, _LABEL_3FA1_
_LABEL_3F94_:
	ld a, (EquippedWeapon)
	ld d, a
	ld a, (EquippedArmor)
	or d
	ld d, a
	and $80
	jr z, NothingHappenedAction
_LABEL_3FA1_:
	ld hl, EquippedWeapon
	res 7, (hl)
	call EquipWeapon
	ld hl, EquippedArmor
	res 7, (hl)
	call EquipArmor
	ld a, ($C930)
	or a
	jr z, _LABEL_3FD2_
	ld a, (EquippedRing)
	and IgnoreCurseMask
	cp CursedRing
	jr c, _LABEL_3FD2_
	cp ToyRing
	jr z, _LABEL_3FD2_
	ld hl, $C929
	ld de, EquippedRing
	call LDI7
	xor a
	ld (de), a
	ld ($C930), a
_LABEL_3FD2_:
	ld a, CurseRemovedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 5th entry of Jump Table from 3E68 (indexed by unknown)
NothingHappenedAction:
	ld a, NothingHappenedMessage
	ld (NextMessage), a
	xor a
	ld (CurrentItem), a
	jp _LABEL_3EDF_

; 6th entry of Jump Table from 3E68 (indexed by unknown)
MapScrollAction:
	ld a, (BlindnessTicksLeft)
	or a
	jr nz, NothingHappenedAction
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld a, $3F
	ld (FlashColor), a
	ld (ix+24), $1E
	ld hl, CompleteMapScrollAction
	jp SetVBlankContinuation

.BANK 1 SLOT 1
.ORG $0000

CompleteMapScrollAction:
	call _LABEL_3F2B_
	ret nc
	ld a, FloorMapRevealedMessage
	ld (CurrentMessage), a
	call _LABEL_2208_
	ld a, $01
	ld ($C60E), a
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
	jp _LABEL_3F1A_

; 7th entry of Jump Table from 3E68 (indexed by unknown)
ShiftScrollAction:
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld a, $3F
	ld (FlashColor), a
	ld (ix+24), $1E
	ld hl, ContinueShiftScrollAction
	jp SetVBlankContinuation

ContinueShiftScrollAction:
	call _LABEL_3F2B_
	ret nc
	ld a, TeleportRandomRoomMessage
	ld (CurrentMessage), a
	ld (ix+24), $1E
	ld hl, CompleteShiftScrollAction
	jp SetVBlankContinuation

CompleteShiftScrollAction:
	dec (ix+24)
	ret nz
	call _LABEL_1F8F_
	call _LABEL_481B_
	call _LABEL_20BA_
	ld hl, ($C105)
	ld de, $2D00
	add hl, de
	call _LABEL_2DFA_
	push ix
	call _LABEL_1F4F_
	pop ix
	xor a
	ld (CurrentItem), a
	ld (CurrentMessage), a
	ld ($CAC5), a
	ld a, SoundEffect98
	ld (SFXQueue), a
	ld hl, _LABEL_3142_
	jp SetVBlankContinuation

; 8th entry of Jump Table from 3E68 (indexed by unknown)
MadScrollAction:
	ld iy, $C140
	ld de, $0020
	ld bc, $1600
_LABEL_4081_:
	ld a, (iy+0)
	or (iy+1)
	jr z, _LABEL_408E_
	set 0, (iy+28)
	inc c
_LABEL_408E_:
	add iy, de
	djnz _LABEL_4081_
	ld a, c
	or a
	jp z, NothingHappenedAction
	ld a, MonsterConfusedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 9th entry of Jump Table from 3E68 (indexed by unknown)
FreezePotionAction:
	call GetRandomNumber
	and RangeParalysisTicks
	inc a						 ; Min is one
	ld (ParalysisTicksLeft), a
	ld a, PlayerParalyzedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 10th entry of Jump Table from 3E68 (indexed by unknown)
SummonScrollAction:
	call _LABEL_1F3A_
	jp c, NothingHappenedAction
	ld (CurrentMonster), hl
	push hl
	pop iy
	ld a, (ix+4)
	ld hl, Data_4115
_LABEL_40C2_:
	rrca
	jr c, _LABEL_40C9_
	inc hl
	inc hl
	jr _LABEL_40C2_

_LABEL_40C9_:
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld l, (ix+5)
	ld h, (ix+6)
	add hl, de
	call _LABEL_2091_
	jp c, NothingHappenedAction
	ld (iy+5), l
	ld (iy+6), h
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld a, $3F
	ld (FlashColor), a
	ld (ix+24), $1E
	ld hl, CompleteSummonScrollAction
	jp SetVBlankContinuation

CompleteSummonScrollAction:
	call _LABEL_3F2B_
	ret nc
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
	call DoMonsterActionTable
	ld hl, (CurrentMonster)
	ld (hl), e
	inc hl
	ld (hl), d
	ld de, $001E
	add hl, de
	ld (hl), a
	ld a, EnemySummonedMessage
	ld (CurrentMessage), a
	jp _LABEL_3F1A_

; Data from 4115 to 411C (8 bytes)
Data_4115:
	.db $E0 $FF $20 $00 $FF $FF $01 $00

; 11th entry of Jump Table from 3E68 (indexed by unknown)
MagiScrollAction:
	ld a, (EquippedWeapon)
	cp MagiMasherSword
	jp z, NothingHappenedAction
	ld a, MagiMasherSword
	ld (EquippedWeapon), a
	ld hl, $0F00
	ld ($C04E), hl
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	call EquipWeapon
	ld a, SwordTransformedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 12th entry of Jump Table from 3E68 (indexed by unknown)
GasScrollAction:
	ld a, (EquippedWeapon)
	cp BushidoBladeSword
	jp z, NothingHappenedAction
	ld a, BushidoBladeSword
	ld (EquippedWeapon), a
	ld hl, $0F00
	ld ($C04E), hl
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	call EquipWeapon
	ld a, SwordTransformedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 13th entry of Jump Table from 3E68 (indexed by unknown)
GhostScrollAction:
	ld a, (EquippedWeapon)
	cp GhostKillerSword
	jp z, NothingHappenedAction
	ld a, GhostKillerSword
	ld (EquippedWeapon), a
	ld hl, $0F00
	ld ($C04E), hl
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	call EquipWeapon
	ld a, SwordTransformedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 14th entry of Jump Table from 3E68 (indexed by unknown)
DragonScrollAction:
	ld a, (EquippedWeapon)
	cp DragonslayerSword
	jp z, NothingHappenedAction
	ld a, DragonslayerSword
	ld (EquippedWeapon), a
	ld hl, $0F00
	ld ($C04E), hl
	ld hl, PaletteInRAMStatus
	set 0, (hl)
	call EquipWeapon
	ld a, SwordTransformedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 15th entry of Jump Table from 3E68 (indexed by unknown)
BlankScrollAction:
	ld a, BlankScrollNothingMessage
	ld (NextMessage), a
	jp _LABEL_3EDF_

; 16th entry of Jump Table from 3E68 (indexed by unknown)
FlameRodAction:
	ld a, (CharacterLevel)
	add a, a
	add a, a
	ld l, a
	ld h, $00
	ld (DamageDealt), hl
	ld a, $03
	ld (FlashColor), a
	ld a, SoundEffect96
	ld (SFXQueue), a

DoRodDamage:
	call _LABEL_489C_
	jr nc, _LABEL_41D8_
	ld a, NoEffectMessage
	ld (NextMessage), a
	ld a, SoundEffect00
	ld (SFXQueue), a
	jp _LABEL_3EE5_

_LABEL_41D8_:
	ld (CurrentMonster), iy
	set 4, (iy+28)
	res 1, (iy+28)
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld (ix+24), $1E
	ld hl, CompleteRodDamage
	jp SetVBlankContinuation

CompleteRodDamage:
	ld a, (ix+24)
	and $01
	ld hl, (CurrentMonster)
	ld de, $0002
	add hl, de
	ld (hl), a
	call _LABEL_3F2B_
	ret nc
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
	ld hl, (DamageDealt)
	ld a, ($C930)
	or a
	jr z, _LABEL_4220_
	ld a, (EquippedRing)
	cp MagicRing
	jr nz, _LABEL_4220_
	add hl, hl
	ld (DamageDealt), hl
_LABEL_4220_:
	call _LABEL_486E_
	jp _LABEL_393C_

; 17th entry of Jump Table from 3E68 (indexed by unknown)
FlashRodAction:
	ld a, (CharacterLevel)
	add a, a
	ld d, a
	add a, a
	add a, d
	ld l, a
	ld h, $00
	ld (DamageDealt), hl
	ld a, $3F
	ld (FlashColor), a
	ld a, SoundEffect97
	ld (SFXQueue), a
	jp DoRodDamage

; 18th entry of Jump Table from 3E68 (indexed by unknown)
ThunderRodAction:
	ld a, (CharacterLevel)
	add a, a
	add a, a
	add a, a
	ld l, a
	ld h, $00
	ld (DamageDealt), hl
	ld a, $0F
	ld (FlashColor), a
	ld a, SoundEffect95
	ld (SFXQueue), a
	jp DoRodDamage

; 19th entry of Jump Table from 3E68 (indexed by unknown)
WindRodAction:
	call _LABEL_489C_
	jr nc, _LABEL_4266_
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

_LABEL_4266_:
	ld (CurrentMonster), iy
	set 4, (iy+28)
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld a, $3F
	ld (FlashColor), a
	ld (ix+24), $1E
	ld hl, CompleteWindRodAction
	jp SetVBlankContinuation

CompleteWindRodAction:
	ld a, (ix+24)
	and $01
	ld hl, (CurrentMonster)
	ld de, $0002
	add hl, de
	ld (hl), a
	call _LABEL_3F2B_
	ret nc
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
	ld hl, (CurrentMonster)
	ld (hl), $0F
	inc hl
	ld (hl), $31
	ld a, MonsterBlownAwayMessage
	ld (CurrentMessage), a
	jp _LABEL_3F1A_

; 20th entry of Jump Table from 3E68 (indexed by unknown)
BerserkRodAction:
	call _LABEL_489C_
	jr nc, _LABEL_42B8_
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

_LABEL_42B8_:
	ld (CurrentMonster), iy
	set 4, (iy+28)
	res 1, (iy+28)
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld a, $3F
	ld (FlashColor), a
	ld a, SoundEffect96
	ld (SFXQueue), a
	ld (ix+24), $1E
	ld hl, CompleteBerserkRodAction
	jp SetVBlankContinuation

CompleteBerserkRodAction:
	ld a, (ix+24)
	and $01
	ld hl, (CurrentMonster)
	ld de, $0002
	add hl, de
	ld (hl), a
	call _LABEL_3F2B_
	ret nc
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
	ld hl, (CurrentHPLow)
	ld e, l
	ld d, h
	srl h
	rr l
	ld a, l
	or h
	jr nz, _LABEL_4306_
	ld hl, $0001
_LABEL_4306_:
	ld (CurrentHPLow), hl
	ex de, hl
	add hl, hl
	ld a, (EquippedRing)
	cp MagicRing
	jr nz, _LABEL_4313_
	add hl, hl
_LABEL_4313_:
	ld c, l
	ld b, h
	ld hl, (CurrentMonster)
	ld de, $001A
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	xor a
	sbc hl, bc
	ex de, hl
	jr nc, _LABEL_4329_
	ld de, $0000
_LABEL_4329_:
	ld (hl), d
	dec hl
	ld (hl), e
	ld a, e
	or d
	jp z, _LABEL_3962_
	ld a, PlayerBerserkMessage_Mirror
	ld (CurrentMessage), a
	jp _LABEL_3F1A_

; 21st entry of Jump Table from 3E68 (indexed by unknown)
SilentRodAction:
	call _LABEL_489C_
	jr nc, _LABEL_4346_
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

_LABEL_4346_:
	ld (CurrentMonster), iy
	set 4, (iy+28)
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld a, $3F
	ld (FlashColor), a
	ld (ix+24), $1E
	ld hl, CompleteSilentRodAction
	jp SetVBlankContinuation

CompleteSilentRodAction:
	ld a, (ix+24)
	and $01
	ld hl, (CurrentMonster)
	ld de, $0002
	add hl, de
	ld (hl), a
	call _LABEL_3F2B_
	ret nc
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
	ld hl, (CurrentMonster)
	ld de, $001C
	add hl, de
	set 3, (hl)
	ld a, MonsterNoMagicMessage
	ld (CurrentMessage), a
	jp _LABEL_3F1A_

; 22nd entry of Jump Table from 3E68 (indexed by unknown)
ReshapeRodAction:
	call _LABEL_489C_
	jr nc, _LABEL_4399_
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

_LABEL_4399_:
	ld (CurrentMonster), iy
	set 4, (iy+28)
	res 1, (iy+28)
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld a, $3F
	ld (FlashColor), a
	ld (ix+24), $1E
	ld hl, CompleteReshapeRodAction
	jp SetVBlankContinuation

CompleteReshapeRodAction:
	ld a, (ix+24)
	and $01
	ld hl, (CurrentMonster)
	ld de, $0002
	add hl, de
	ld (hl), a
	call _LABEL_3F2B_
	ret nc
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
_LABEL_43D2_:
	call DoMonsterActionTable
	ld hl, (CurrentMonster)
	ld bc, $001F
	add hl, bc
	cp (hl)
	jr z, _LABEL_43D2_
	ld (hl), a
	ld hl, (CurrentMonster)
	ld (hl), e
	inc hl
	ld (hl), d
	ld a, EnemyTransformedMessage
	ld (CurrentMessage), a
	jp _LABEL_3F1A_

; 23rd entry of Jump Table from 3E68 (indexed by unknown)
TravelRodAction:
	ld a, (Floor)
	cp LastFloor
	jr c, _LABEL_43FD_
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3EDF_

_LABEL_43FD_:
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld a, $3F
	ld (FlashColor), a
	ld (ix+24), $1E
	ld hl, ContinueTravelRodAction
	jp SetVBlankContinuation

ContinueTravelRodAction:
	call _LABEL_3F2B_
	ret nc
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
	ld a, TeleportNextFloorMessage
	ld (CurrentMessage), a
	ld (ix+24), $1E
	ld hl, CompleteTravelRodAction
	jp SetVBlankContinuation

CompleteTravelRodAction:
	dec (ix+24)
	ret nz
	ld hl, Floor
	inc (hl)
	xor a
	ld (CurrentMessage), a
	ld ($CAC5), a
	call _LABEL_42C_
	ld a, $08
	ld (TableIndex1), a
	jp _LABEL_143_

; 24th entry of Jump Table from 3E68 (indexed by unknown)
DrainRodAction:
	call _LABEL_489C_
	jr nc, _LABEL_4453_
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3EDF_

_LABEL_4453_:
	ld (CurrentMonster), iy
	res 1, (iy+28)
	ld e, (iy+26)
	ld d, (iy+27)
	ld hl, (CurrentHPLow)
	ld (iy+26), l
	ld (iy+27), h
	ld hl, (MaxHPLow)
	or a
	sbc hl, de
	ex de, hl
	jr nc, _LABEL_4474_
	add hl, de
_LABEL_4474_:
	ld (CurrentHPLow), hl
	ld a, HitPointSwapMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 25th entry of Jump Table from 3E68 (indexed by unknown)
WitherRodAction:
	ld a, (CharacterLevel)
	dec a
	jp z, NothingHappenedAction
	ld (CharacterLevel), a
	call _LABEL_496B_
	ld a, LevelDownMessage1
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 26th entry of Jump Table from 3E68 (indexed by unknown)
MinhealPotionAction:
	ld hl, (MaxHPLow)
	srl h
	rr l
	srl h
	rr l
DoPotionHealing:
	ld de, (CurrentHPLow)
	add hl, de
	ex de, hl
	ld hl, (MaxHPLow)
	xor a
	sbc hl, de
	ex de, hl
	jr nc, _LABEL_44B1_
	ld hl, (MaxHPLow)
_LABEL_44B1_:
	ld (CurrentHPLow), hl
	ld a, PlayerHealedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 27th entry of Jump Table from 3E68 (indexed by unknown)
MidhealPotionAction:
	ld hl, (MaxHPLow)
	srl h
	rr l
	jr DoPotionHealing

; 28th entry of Jump Table from 3E68 (indexed by unknown)
SlowPotionAction:
	ld a, (SluggishTicksLeft)
	or a
	jr z, _LABEL_44D3_
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3EDF_

_LABEL_44D3_:
	ld a, $01
	ld (SluggishTicksLeft), a
	ld a, PlayerSlowMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 29th entry of Jump Table from 3E68 (indexed by unknown)
SlowfixPotionAction:
	ld a, (SluggishTicksLeft)
	or a
	jr nz, _LABEL_44EE_
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3EDF_

_LABEL_44EE_:
	xor a
	ld (SluggishTicksLeft), a
	ld a, PlayerSlowHealedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 30th entry of Jump Table from 3E68 (indexed by unknown)
FogPotionAction:
	ld a, (BlindnessTicksLeft)
	or a
	jr z, _LABEL_4508_
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3EDF_

_LABEL_4508_:
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld a, $3F
	ld (FlashColor), a
	ld (ix+24), $1E
	ld hl, CompleteFogPotionAction
	jp SetVBlankContinuation

CompleteFogPotionAction:
	call _LABEL_3F2B_
	ret nc
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
	call _LABEL_21BF_
	ld a, $01
	ld ($C60E), a
	ld ($C606), a
	call GetRandomNumber
	and RangeBlindnessTicks
	add a, MinimumBlindnessTicks
	ld (BlindnessTicksLeft), a
	ld a, PlayerFogMessage
	ld (CurrentMessage), a
	jp _LABEL_3F1A_

; 31st entry of Jump Table from 3E68 (indexed by unknown)
UnusedDizzinessItem:
	ld a, (DizzinessTicksLeft)	; Causes 16-31 ticks of dizziness if player isn't already dizzy
	or a
	jr z, NotDizzyYet1
	ld a, NoEffectMessage			; Nothing happened
	ld (NextMessage), a
	jp _LABEL_3EDF_

NotDizzyYet1:
	call GetRandomNumber
	and RangeDizzinessTicks
	add a, MinimumDizzinessTicks
	ld (DizzinessTicksLeft), a
	ld a, PlayerLightheadedMessage	; Uses same message as monster-attack-induced dizziness
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 32nd entry of Jump Table from 3E68 (indexed by unknown)
CurePotionAction:
	ld a, (PoisonTicksLeft)
	ld d, a
	ld a, (BlindnessTicksLeft)
	ld e, a
	ld a, (DizzinessTicksLeft)
	or e						; Either blinded or dizzy
	or d						; Either poisoned or dizzy
	jr nz, CureStatusEffect		; If any of the three...
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3EDF_

CureStatusEffect:
	xor a
	ld (PoisonTicksLeft), a
	ld (BlindnessTicksLeft), a
	ld (DizzinessTicksLeft), a
	ld a, PlayerStatusHealedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 33rd entry of Jump Table from 3E68 (indexed by unknown)
MaxhealPotionAction:
	ld hl, (MaxHPLow)
	ld (CurrentHPLow), hl
	ld a, PlayerHealedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 34th entry of Jump Table from 3E68 (indexed by unknown)
WitherPotionAction:
	call GetRandomNumber
	and $01
	jr z, DecreaseAC				; If 0, decrease AC, if 1, decrease PW
	ld a, (BasePW)
	or a
	jp z, NothingHappenedAction
	dec a
	ld (BasePW), a
	ld a, PlayerStrengthDownMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

DecreaseAC:
	ld a, (BaseAC)
	or a
	jp z, NothingHappenedAction
	dec a
	ld (BasePW), a
	ld a, PlayerStrengthDownMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 35th entry of Jump Table from 3E68 (indexed by unknown)
HealFoodRingEquipAction:
	ld a, PlayerHealedMessage
	ld (NextMessage), a
_LABEL_45CE_:
	ld a, $3F
	ld (FlashColor), a
_LABEL_45D3_:
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld (ix+24), $1E
	ld hl, CompleteHealFoodRingEquipAction
	jp SetVBlankContinuation

CompleteHealFoodRingEquipAction:
	call _LABEL_3F2B_
	ret nc
	ld a, (NextMessage)
	ld (CurrentMessage), a
	ld a, (CurrentItem)
	and $0F
	cp $08
	jr z, _LABEL_45FF_
	cp $06
	jr c, _LABEL_45FF_
	ld a, SoundEffectAA
	ld (SFXQueue), a
_LABEL_45FF_:
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
	ld (ix+24), $1E
	ld hl, _LABEL_3142_
	jp SetVBlankContinuation

; 36th entry of Jump Table from 3E68 (indexed by unknown)
MagicRingEquipAction:
	ld a, PlayerMagicUpMessage
	ld (NextMessage), a
	jr _LABEL_45CE_

; 37th entry of Jump Table from 3E68 (indexed by unknown)
SightRingEquipAction:
	ld a, PlayerSightUpMessage
	ld (NextMessage), a
	jr _LABEL_45CE_

; 38th entry of Jump Table from 3E68 (indexed by unknown)
ShieldRingEquipAction:
	ld a, (BaseAC)
	add a, $04
	cp $32
	jr c, _LABEL_4629_
	ld a, $31
_LABEL_4629_:
	ld (BaseAC), a
	ld a, PlayerDefenseUpMessage1
	ld (NextMessage), a
	jr _LABEL_45CE_

; 39th entry of Jump Table from 3E68 (indexed by unknown)
OgreRingEquipAction:
	ld a, (BasePW)
	add a, $04
	cp $3C
	jr c, _LABEL_463E_
	ld a, $3B
_LABEL_463E_:
	ld (BasePW), a
	ld a, PlayerStrengthUpMessage1
	ld (NextMessage), a
	jp _LABEL_45CE_

; 40th entry of Jump Table from 3E68 (indexed by unknown)
ShiftRingEquipAction:
	ld a, TeleportRandomRoomMessage
	ld (NextMessage), a
	ld a, $00
	ld (FlashColor), a
	jp _LABEL_45D3_

; 41st entry of Jump Table from 3E68 (indexed by unknown)
CursedRingEquipAction:
	ld a, PlayerCursedMessage
	ld (NextMessage), a
	ld a, $00
	ld (FlashColor), a
	jp _LABEL_45D3_

; 42nd entry of Jump Table from 3E68 (indexed by unknown)
HungerRingEquipAction:
	ld a, PlayerCursedMessage
	ld (NextMessage), a
	ld a, $00
	ld (FlashColor), a
	jp _LABEL_45D3_

; 43rd entry of Jump Table from 3E68 (indexed by unknown)
ToyRingEquipAction:
	ld a, $3B
	ld (NextMessage), a
	ld a, (PaletteInRAM)
	ld (FlashColor), a
	jp _LABEL_45D3_

; 44th entry of Jump Table from 3E68 (indexed by unknown)
CursedSwordAction:
	ld a, $00
	ld (FlashColor), a
	ld a, SwordCursedMessage_Mirror
	ld (NextMessage), a
	jp _LABEL_3EE5_

; 46th entry of Jump Table from 3E68 (indexed by unknown)
CursedArmorAction:
	ld a, $00
	ld (FlashColor), a
	ld a, ArmorCursedMessage
	ld (NextMessage), a
	jp _LABEL_3EE5_

; 47th entry of Jump Table from 3E68 (indexed by unknown)
PowerPotionAction:
	ld a, (BasePW)
	inc a
	cp $3C
	jr c, _LABEL_46A2_
	ld a, $3B
_LABEL_46A2_:
	ld (BasePW), a
	ld a, PlayerStrengthUpMessage2
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 48th entry of Jump Table from 3E68 (indexed by unknown)
ReflexPotionAction:
	ld a, (BaseAC)
	inc a
	cp $32
	jr c, _LABEL_46B7_
	ld a, $31
_LABEL_46B7_:
	ld (BaseAC), a
	ld a, PlayerDefenseUpMessage2
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 49th entry of Jump Table from 3E68 (indexed by unknown)
PotionScrollAction:
	ld a, ($C920)
	or a
	jp z, NothingHappenedAction
	ld hl, $C920
	ld b, $08
ChangeNextPotion:
	ld a, (hl)
	or a
	jr z, NoMorePotions
	ld (hl), MidhealPotion
	inc hl
	djnz ChangeNextPotion
NoMorePotions:
	ld a, PotionTransformedMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 50th entry of Jump Table from 3E68 (indexed by unknown)
SpiritRodAction:
	call _LABEL_1F3A_
	jp c, NothingHappenedAction
	ld (CurrentMonster), hl
	push hl
	pop iy
	ld a, (ix+4)
	ld hl, Data_4744
_LABEL_46F1_:
	rrca
	jr c, _LABEL_46F8_
	inc hl
	inc hl
	jr _LABEL_46F1_

_LABEL_46F8_:
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld l, (ix+5)
	ld h, (ix+6)
	add hl, de
	call _LABEL_2091_
	jp c, NothingHappenedAction
	ld (iy+5), l
	ld (iy+6), h
	ld a, (PaletteInRAM)
	ld (SavedColor), a
	ld a, $3F
	ld (FlashColor), a
	ld (ix+24), $1E
	ld hl, CompleteSpiritRodAction
	jp SetVBlankContinuation

CompleteSpiritRodAction:
	call _LABEL_3F2B_
	ret nc
	xor a
	ld (CurrentItem), a
	call _LABEL_4888_
	call DoMonsterActionTable
	ld hl, (CurrentMonster)
	ld (hl), e
	inc hl
	ld (hl), d
	ld de, $001E
	add hl, de
	ld (hl), a
	ld a, MonsterSummonedMessage
	ld (CurrentMessage), a
	jp _LABEL_3F1A_

; Data from 4744 to 474B (8 bytes)
Data_4744:
	.db $E0 $FF $20 $00 $FF $FF $01 $00

; 51st entry of Jump Table from 3E68 (indexed by unknown)
WaterPotionAction:
	ld a, WaterPotionMessage
	ld (NextMessage), a
	xor a
	ld (CurrentItem), a
	jp _LABEL_3EDF_

; 52nd entry of Jump Table from 3E68 (indexed by unknown)
DazePotionAction:
	ld a, (DizzinessTicksLeft)
	or a
	jr z, NotDizzyYet2
	ld a, NoEffectMessage
	ld (NextMessage), a
	jp _LABEL_3EDF_

NotDizzyYet2:
	call GetRandomNumber
	and RangeDizzinessTicks
	add a, MinimumDizzinessTicks
	ld (DizzinessTicksLeft), a
	ld a, PlayerDizzinessMessage
	ld (NextMessage), a
	jp _LABEL_3ED8_

; 53rd entry of Jump Table from 3E68 (indexed by unknown)
UnusedNothingItem:
	ld a, (PaletteInRAM)
	ld (FlashColor), a
	ld a, NothingHappenedMessage
	ld (NextMessage), a
	jp _LABEL_3EE5_

SetVBlankContinuation:
	ld (ix+0), l
	ld (ix+1), h
	ret

_LABEL_478D_:
	ld a, (ix+21)
	or a
	jr z, _LABEL_4797_
	dec (ix+21)
	ret

_LABEL_4797_:
	ld l, (ix+22)
	ld h, (ix+23)
	ld a, (hl)
	ld (ix+21), a
	inc hl
	ld c, (hl)
	inc hl
	ld a, (ix+20)
	cp c
	jr c, _LABEL_47AB_
	xor a
_LABEL_47AB_:
	ld e, a
	ld d, $00
	add hl, de
	inc a
	ld (ix+20), a
	ld a, (hl)
	ld (ix+3), a
	ret

_LABEL_47B8_:
	call _LABEL_478D_
_LABEL_47BB_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_47CB_
	rrca
	jr c, _LABEL_47E0_
	rrca
	jr c, _LABEL_47F3_
	rrca
	jr c, _LABEL_4808_
	ret

_LABEL_47CB_:
	ld l, (ix+10)
	ld h, (ix+11)
	ld e, (ix+19)
	ld d, $00
	xor a
	sbc hl, de
	ld (ix+10), l
	ld (ix+11), h
	ret

_LABEL_47E0_:
	ld l, (ix+10)
	ld h, (ix+11)
	ld e, (ix+19)
	ld d, $00
	add hl, de
	ld (ix+10), l
	ld (ix+11), h
	ret

_LABEL_47F3_:
	ld l, (ix+13)
	ld h, (ix+14)
	ld e, (ix+19)
	ld d, $00
	xor a
	sbc hl, de
	ld (ix+13), l
	ld (ix+14), h
	ret

_LABEL_4808_:
	ld l, (ix+13)
	ld h, (ix+14)
	ld e, (ix+19)
	ld d, $00
	add hl, de
	ld (ix+13), l
	ld (ix+14), h
	ret

_LABEL_481B_:
	ld l, (ix+5)
	ld h, (ix+6)
	ld de, $2D00
	add hl, de
	ex de, hl
	ld h, d
	ld a, e
	and $E0
	srl h
	rra
	set 3, a
	ld (ix+10), a
	ld (ix+11), h
	ld a, e
	and $1F
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	set 3, l
	ld (ix+13), l
	ld (ix+14), h
	ret

_LABEL_4848_:
	ld d, a
	rrca
	rrca
	and $3F
	jr nz, _LABEL_4851_
	ld a, $01
_LABEL_4851_:
	ld e, a
	call GetRandomNumber
	ld b, a
	and $3F
	jr z, _LABEL_4863_
_LABEL_485A_:
	cp e
	jr z, _LABEL_4863_
	jr c, _LABEL_4863_
	srl a
	jr _LABEL_485A_

_LABEL_4863_:
	bit 7, b
	jr z, _LABEL_4869_
	neg
_LABEL_4869_:
	add a, d
	ret nz
	ld a, $01
	ret

_LABEL_486E_:
	ld c, l
	ld b, h
	ld hl, (CurrentMonster)
	ld de, $001A
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	xor a
	sbc hl, bc
	jr nc, _LABEL_4883_
	ld hl, $0000
_LABEL_4883_:
	ex de, hl
	ld (hl), d
	dec hl
	ld (hl), e
	ret

_LABEL_4888_:
	ld hl, Data_3240
	ld a, (ix+4)
	or a
	jr z, _LABEL_4897_
_LABEL_4891_:
	rrca
	jr c, _LABEL_4897_
	inc hl
	jr _LABEL_4891_

_LABEL_4897_:
	ld a, (hl)
	ld (ix+3), a
	ret

_LABEL_489C_:
	ld a, (ix+4)
	ld hl, Data_48E8
_LABEL_48A2_:
	rrca
	jr c, _LABEL_48A9_
	inc hl
	inc hl
	jr _LABEL_48A2_

_LABEL_48A9_:
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld l, (ix+5)
	ld h, (ix+6)
_LABEL_48B2_:
	push bc
	ld iy, $C140
	ld b, $16
_LABEL_48B9_:
	push bc
	ld a, (iy+5)
	cp l
	jr nz, _LABEL_48CA_
	ld a, (iy+6)
	cp h
	jr nz, _LABEL_48CA_
	pop bc
	pop bc
	xor a
	ret

_LABEL_48CA_:
	ld bc, $0020
	add iy, bc
	pop bc
	djnz _LABEL_48B9_
	add hl, de
	ld a, (hl)
	cp $0C
	jr nc, _LABEL_48E0_
	cp $06
	jr nc, _LABEL_48E5_
	cp $02
	jr c, _LABEL_48E5_
_LABEL_48E0_:
	pop bc
	djnz _LABEL_48B2_
	scf
	ret

_LABEL_48E5_:
	pop bc
	scf
	ret

; Data from 48E8 to 48EF (8 bytes)
Data_48E8:
	.db $E0 $FF $20 $00 $FF $FF $01 $00

EquipWeaponAndArmor:
	call EquipWeapon
	call EquipArmor
	ret

EquipWeapon:
	ld a, (EquippedWeapon)	; Get weapon to be equipped
	and $0F					; Mask off type of item type to get just the weapon number
	add a, a				; Double number to get statistic table offset
	ld e, a					; Put table offset into de
	ld d, $00
	ld hl, WeaponStatistics	; Put statistics table address into hl
	add hl, de				; Add offset
	ld de, WeaponHit		; Destination is weapon hit
	ldi						; Load weapon hit value
	ldi						; Increment and load PW value
	ld a, (EquippedWeapon)	; If weapon is cursed, no PW value?
	bit 7, a
	ret z
	xor a
	ld (WeaponPW), a
	ret

EquipArmor:
	ld a, (EquippedArmor)	; Get armor to be equipped
	and $0F					; Mask off type of item type to get just the armor number
	add a, a				; Double number to get statistic table offset
	ld e, a					; Put table offset into de
	ld d, $00
	ld hl, ArmorStatistics	; Put statistics table address into hl
	add hl, de				; Add offset
	ld de, ArmorEvd			; Destination is armor evade
	ldi						; Load evasion value
	ldi						; Increment and load AC value
	ld a, (EquippedArmor)	; If armor is cursed, no AC value?
	bit 7, a
	ret z
	xor a
	ld (ArmorAC), a
	ret

; Hit, then PW
WeaponStatistics:
	.include "items\behavior\weapon_statistics.asm"

; Evd, then AC
ArmorStatistics:
	.include "items\behavior\armor_statistics.asm"

_LABEL_496B_:
	ld a, (CharacterLevel)
	ld d, a
	ld a, (Floor)
	add a, d
	inc a
	ld e, a
	ld d, $00
	ld hl, (MaxHPLow)
	xor a
	sbc hl, de
	ld (MaxHPLow), hl
	ex de, hl
	ld hl, (CurrentHPLow)
	xor a
	sbc hl, de
	jr c, _LABEL_498D_
	ld (CurrentHPLow), de
_LABEL_498D_:
	ld a, (CharacterLevel)
	add a, a
	ld e, a
	ld d, $00
	ld hl, ExperienceNeededTable+1
	add hl, de
	ld de, NextLevelHigh
	ldd
	ldd
	ld de, ExperienceHigh
	ldd
	ldd
	ret

_LABEL_49A7_:
	ld (ix+24), $00
	ld (ix+0), <_LABEL_49B4_
	ld (ix+1), >_LABEL_49B4_
	ret

_LABEL_49B4_:
	ld a, (LastControllerState)
	bit 4, a
	jr nz, _LABEL_49D0_
	bit 5, a
	ret z
	ld a, SoundEffect9B
	ld (SFXQueue), a
	ld (ix+24), $01
	ld (ix+0), <_LABEL_49E0_
	ld (ix+1), >_LABEL_49E0_
	ret

_LABEL_49D0_:
	ld a, SoundEffect9B
	ld (SFXQueue), a
	call _LABEL_42C_
	ld a, $09
	ld (TableIndex1), a
	jp _LABEL_137_

_LABEL_49E0_:
	ld a, (LastControllerState)
	and $30
	ret z
	bit 4, a
	jr z, _LABEL_49FC_
	ld a, SoundEffect9B
	ld (SFXQueue), a
	ld (ix+24), $00
	ld (ix+0), <_LABEL_49B4_
	ld (ix+1), >_LABEL_49B4_
	ret

_LABEL_49FC_:
	ld a, (TableIndex8)
	add a, a
	add a, a
	add a, a
	ld e, a
	ld a, ($C458)
	add a, e
	ld e, a
	ld d, $00
	ld hl, EquippedWeapon
	add hl, de
	ld a, (hl)
	or a
	jr z, _LABEL_4A30_
	ld a, (TableIndex8)
	cp $05
	jr nc, _LABEL_4A36_
	cp $02
	jp c, _LABEL_4AAD_
_LABEL_4A1E_:
	ld a, SoundEffect9B
	ld (SFXQueue), a
	ld (ix+24), $02
	ld (ix+0), <_LABEL_4ABC_
	ld (ix+1), >_LABEL_4ABC_
	ret

_LABEL_4A30_:
	ld a, SoundEffectA8
	ld (SFXQueue), a
	ret

_LABEL_4A36_:
	ld a, ($C930)
	or a
	jr z, _LABEL_4A1E_
	ld a, ($C458)
	or a
	jr nz, _LABEL_4A1E_
	ld a, (EquippedRing)
	and IgnoreCurseMask
	cp CursedRing
	jr c, _LABEL_4A6F_
	cp ToyRing
	jr z, _LABEL_4A6F_
_LABEL_4A4F_:
	ld a, (TableIndex8)
	cp $02
	jr c, _LABEL_4A58_
	ld a, $02
_LABEL_4A58_:
	add a, CursedSwordEquippedMessage	; First of cursed messages, followed by armor and ring
	ld (CurrentMessage), a
	ld a, SoundEffectA8
	ld (SFXQueue), a
	ld (ix+24), $00
	call _LABEL_42C_
	ld a, $09
	ld (TableIndex1), a
	ret

_LABEL_4A6F_:
	ld a, (EquippedRing)
	cp ShieldRing
	call z, DequipShieldRing
	cp OgreRing
	call z, DequipOgreRing
	call _LABEL_4F51_
	ld a, SoundEffect9B
	ld (SFXQueue), a
	xor a
	ld ($C930), a
	ld (ix+24), $00
	ld (ix+0), <_LABEL_49B4_
	ld (ix+1), >_LABEL_49B4_
	jp CallJumpTable8

DequipShieldRing:
	ld hl, BaseAC
	dec (hl)
	dec (hl)
	dec (hl)
	dec (hl)
	ret p
	ld (hl), $00
	ret

DequipOgreRing:
	ld hl, BasePW
	dec (hl)
	dec (hl)
	dec (hl)
	dec (hl)
	ret p
	ld (hl), $00
	ret

_LABEL_4AAD_:
	ld a, SoundEffectA8
	ld (SFXQueue), a
	ld a, ($C458)
	or a
	jp nz, _LABEL_4A1E_
	jp _LABEL_4A30_

_LABEL_4ABC_:
	ld a, (LastControllerState)
	and $30
	ret z
	bit 4, a
	jr z, _LABEL_4AD8_
	ld a, SoundEffect9B
	ld (SFXQueue), a
	ld (ix+24), $01
	ld (ix+0), <_LABEL_49E0_
	ld (ix+1), >_LABEL_49E0_
	ret

_LABEL_4AD8_:
	ld a, (TableIndex8)
	add a, a
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, EquippedWeapon
	add hl, de
	ld a, ($C478)
	dec a
	jp z, _LABEL_4C0C_
	dec a
	jp z, _LABEL_4BB2_
	ld a, (TableIndex8)
	cp $05
	jr z, _LABEL_4B25_
	cp $02
	jr c, _LABEL_4B66_
	ld a, ($C458)
	ld e, a
	ld d, $00
	neg
	add a, $07
	ld c, a
	ld b, d
	add hl, de
	ld a, (hl)
	ld (CurrentItem), a
	ld e, l
	ld d, h
	inc hl
	ld a, c
	or a
	jr z, _LABEL_4B15_
	ldir
_LABEL_4B15_:
	xor a
	ld (de), a
	ld hl, (CurrentItem)
	ld h, $00
	ld de, $C915
	add hl, de
	ld (hl), $00
	jp _LABEL_49D0_

_LABEL_4B25_:
	ld a, ($C930)
	or a
	jr z, _LABEL_4B41_
	ld a, (EquippedRing)
	cp ToyRing
	jr z, _LABEL_4B41_
	cp CursedRing
	jp nc, _LABEL_4A4F_
	cp ShieldRing
	call z, DequipShieldRing
	cp OgreRing
	call z, DequipOgreRing
_LABEL_4B41_:
	ld a, $01
	ld ($C930), a
	ld de, EquippedRing
	ld hl, ($C458)
	ld h, $00
	add hl, de
	ld a, (hl)
	ex af, af'
	ld a, (de)
	ld (hl), a
	ex af, af'
	ld (de), a
	ld (CurrentItem), a
	and $0F
	ld e, a
	ld d, $00
	ld hl, $C965
	add hl, de
	ld (hl), $00
	jp _LABEL_49D0_

_LABEL_4B66_:
	bit 7, (hl)
	jp nz, _LABEL_4A4F_
	ex de, hl
	ld hl, ($C458)
	ld h, $00
	add hl, de
	ld a, (hl)
	ex af, af'
	ld a, (de)
	ld (hl), a
	ex af, af'
	ld (de), a
	ld a, (de)
	and $7F
	cp $10
	jr nc, _LABEL_4B8B_
	call EquipWeapon
	ld a, (EquippedWeapon)
	bit 7, a
	jr nz, _LABEL_4B95_
	jr _LABEL_4BA0_

_LABEL_4B8B_:
	call EquipArmor
	ld a, (EquippedArmor)
	bit 7, a
	jr z, _LABEL_4BA0_
_LABEL_4B95_:
	ld (CurrentItem), a
	call _LABEL_42C_
	ld a, $09
	ld (TableIndex1), a
_LABEL_4BA0_:
	call _LABEL_4F51_
	ld (ix+24), $00
	ld (ix+0), <_LABEL_49B4_
	ld (ix+1), >_LABEL_49B4_
	jp CallJumpTable8

_LABEL_4BB2_:
	ld de, ($C105)
	ld a, (de)
	cp $06
	jr nc, _LABEL_4C0B_
	cp $02
	jr c, _LABEL_4C0B_
	ld a, ($C458)
	ld e, a
	ld d, $00
	neg
	add a, $07
	ld c, a
	ld b, d
	add hl, de
	ld a, (hl)
	ld ($C933), a
	ld e, l
	ld d, h
	inc hl
	ld a, c
	or a
	jr z, _LABEL_4BD9_
	ldir
_LABEL_4BD9_:
	xor a
	ld (de), a
	ld hl, $C980
	ld b, $00
_LABEL_4BE0_:
	ld a, (hl)
	or a
	jr z, _LABEL_4BE9_
	inc hl
	inc hl
	inc b
	jr _LABEL_4BE0_

_LABEL_4BE9_:
	ld a, ($C933)
	ld (hl), a
	inc hl
	ld de, ($C105)
	ld a, (de)
	ld (hl), a
	ld a, $10
	add a, b
	ld (de), a
	ld hl, $0400
	add hl, de
	ld a, ($C933)
	and $70
	rrca
	rrca
	rrca
	rrca
	add a, $10
	ld (hl), a
	jp _LABEL_49D0_

_LABEL_4C0B_:
	ret

_LABEL_4C0C_:
	ld a, ($C458)
	ld e, a
	ld d, $00
	neg
	add a, $07
	ld c, a
	ld b, d
	add hl, de
	ld a, (hl)
	and $7F
	ld ($C932), a
	ld e, l
	ld d, h
	inc hl
	ld a, c
	or a
	jr z, _LABEL_4C28_
	ldir
_LABEL_4C28_:
	xor a
	ld (de), a
	ld a, ($C932)
	sub $20
	jp c, _LABEL_49D0_
	ld e, a
	ld d, $00
	ld hl, $C935
	add hl, de
	ld (hl), $00
	jp _LABEL_49D0_

_LABEL_4C3E_:
	ld (ix+2), $01
	ld (ix+3), $16
	ld (ix+15), $17
	ld (ix+0), <_LABEL_4C54_
	ld (ix+1), >_LABEL_4C54_
	jr _LABEL_4C9E_

_LABEL_4C54_:
	inc (ix+21)
	ld a, (ix+21)
	cp $18
	jr c, _LABEL_4C62_
	xor a
	ld (ix+21), a
_LABEL_4C62_:
	and $FC
	rrca
	rrca
	add a, $16
	ld (ix+3), a
	ld a, ($C418)
	or a
	ret nz
	ld a, (LastControllerState)
	and $0C
	ret z
	xor a
	ld ($C458), a
	ld ($C478), a
	ld a, (LastControllerState)
	bit 2, a
	jr z, _LABEL_4C92_
	ld a, (ix+24)
	dec a
	jp p, _LABEL_4C8D_
	ld a, $05
_LABEL_4C8D_:
	ld (ix+24), a
	jr _LABEL_4C9E_

_LABEL_4C92_:
	ld a, (ix+24)
	inc a
	cp $06
	jr c, _LABEL_4C9B_
	xor a
_LABEL_4C9B_:
	ld (ix+24), a
_LABEL_4C9E_:
	ld a, (ix+24)
	add a, a
	add a, a
	add a, a
	add a, a
	add a, a
	add a, $28
	ld (ix+17), a
CallJumpTable8:
	ld a, (TableIndex8)
	ld hl, JumpTable8
	jp CallJumpTable

; Jump Table from 4CB4 to 4CBF (6 entries, indexed by unknown)
JumpTable8:
	.dw JumpTable8_4E43 JumpTable8_4E54 JumpTable8_4E65 JumpTable8_4E79
	.dw JumpTable8_4E8D JumpTable8_4EA1

_LABEL_4CC0_:
	ld a, ($C418)
	cp $01
	ret nz
	ld (ix+0), <_LABEL_4CD0_
	ld (ix+1), >_LABEL_4CD0_
	jr _LABEL_4D2D_

_LABEL_4CD0_:
	ld a, ($C418)
	cp $01
	jr z, _LABEL_4CEB_
	or a
	jr nz, _LABEL_4CDF_
	call _LABEL_4D45_
	jr _LABEL_4CE2_

_LABEL_4CDF_:
	call _LABEL_4D2D_
_LABEL_4CE2_:
	ld (ix+0), <_LABEL_4CC0_
	ld (ix+1), >_LABEL_4CC0_
	ret

_LABEL_4CEB_:
	ld hl, _LABEL_4D00_
	push hl
	inc (ix+21)
	ld a, (ix+21)
	and $03
	ret nz
	bit 2, (ix+21)
	jr z, _LABEL_4D2D_
	jr _LABEL_4D45_

_LABEL_4D00_:
	ld a, (LastControllerState)
	and $03
	ret z
	xor a
	ld ($C478), a
	call _LABEL_4D45_
	ld a, (LastControllerState)
	rrca
	jr nc, _LABEL_4D21_
	ld a, (ix+24)
	sub $01
	jr nc, _LABEL_4D1C_
	ld a, $07
_LABEL_4D1C_:
	ld (ix+24), a
	jr _LABEL_4D2D_

_LABEL_4D21_:
	ld a, (ix+24)
	inc a
	cp $08
	jr c, _LABEL_4D2A_
	xor a
_LABEL_4D2A_:
	ld (ix+24), a
_LABEL_4D2D_:
	ld a, ($C458)
	ld l, $00
	rrca
	rr l
	rrca
	rr l
	and $3F
	ld h, a
	ld de, $3A1E
	add hl, de
	ex de, hl
	ld b, $0F
	jp _LABEL_4DF9_

_LABEL_4D45_:
	ld a, ($C458)
	ld l, $00
	rrca
	rr l
	rrca
	rr l
	and $3F
	ld h, a
	ld de, $3A1E
	add hl, de
	ex de, hl
	ld b, $0F
	jp _LABEL_4E0A_

_LABEL_4D5D_:
	ld a, ($C418)
	cp $02
	ret nz
	ld a, (TableIndex8)
	inc a
	call _LABEL_4E1B_
	ld (ix+0), <_LABEL_4D73_
	ld (ix+1), >_LABEL_4D73_
	ret

_LABEL_4D73_:
	ld a, ($C418)
	cp $02
	jr z, _LABEL_4D8A_
	xor a
	call _LABEL_4E1B_
	call _LABEL_4D45_
	ld (ix+0), <_LABEL_4D5D_
	ld (ix+1), >_LABEL_4D5D_
	ret

_LABEL_4D8A_:
	ld hl, _LABEL_4D9F_
	push hl
	inc (ix+21)
	ld a, (ix+21)
	and $03
	ret nz
	bit 2, (ix+21)
	jr z, _LABEL_4DCB_
	jr _LABEL_4DE2_

_LABEL_4D9F_:
	ld a, (LastControllerState)
	and $03
	ret z
	call _LABEL_4DE2_
	ld a, (LastControllerState)
	rrca
	jr nc, _LABEL_4DBC_
	ld a, (ix+24)
	sub $01
	jr nc, _LABEL_4DB7_
	ld a, $02
_LABEL_4DB7_:
	ld (ix+24), a
	jr _LABEL_4DC8_

_LABEL_4DBC_:
	ld a, (ix+24)
	inc a
	cp $03
	jr c, _LABEL_4DC5_
	xor a
_LABEL_4DC5_:
	ld (ix+24), a
_LABEL_4DC8_:
	jp _LABEL_4DCB_

_LABEL_4DCB_:
	ld a, ($C478)
	ld l, $00
	rrca
	rr l
	rrca
	rr l
	and $3F
	ld h, a
	ld de, $3A08
	add hl, de
	ex de, hl
	ld b, $05
	jr _LABEL_4DF9_

_LABEL_4DE2_:
	ld a, ($C478)
	ld l, $00
	rrca
	rr l
	rrca
	rr l
	and $3F
	ld h, a
	ld de, $3A08
	add hl, de
	ex de, hl
	ld b, $05
	jr _LABEL_4E0A_

_LABEL_4DF9_:
	rst $08	; Interrupt8
	ex (sp), hl
	ex (sp), hl
_LABEL_4DFC_:
	in a, (VDPData)
	nop
	ld a, $09
	jr _LABEL_4E03_

_LABEL_4E03_:
	out (VDPData), a
	nop
	nop
	djnz _LABEL_4DFC_
	ret

_LABEL_4E0A_:
	rst $08	; Interrupt8
	ex (sp), hl
	ex (sp), hl
_LABEL_4E0D_:
	in a, (VDPData)
	nop
	ld a, $01
	jr _LABEL_4E14_

_LABEL_4E14_:
	out (VDPData), a
	nop
	nop
	djnz _LABEL_4E0D_
	ret

_LABEL_4E1B_:
	add a, a
	ld e, a
	ld d, $00
	ld hl, Data_4E35
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, $39C6
	ex de, hl
	ld bc, $050E
	ld a, $03
	ld ($FFFF), a
	jp VDPOut_661

; Data from 4E35 to 4E42 (14 bytes)
Data_4E35:
	.dw $A975 $A9BB $A9BB $AA01
	.dw $AA01 $AA01 $A9BB

; 1st entry of Jump Table from 4CB4 (indexed by unknown)
JumpTable8_4E43:
	ld de, $3A1E
	rst $08	; Interrupt8
	ld a, $7B
	out (VDPData), a
	ld hl, EquippedWeapon
	ld de, $A000
	jp _LABEL_4EBD_

; 2nd entry of Jump Table from 4CB4 (indexed by unknown)
JumpTable8_4E54:
	ld de, $3A1E
	rst $08	; Interrupt8
	ld a, $7B
	out (VDPData), a
	ld hl, EquippedArmor
	ld de, $A020
	jp _LABEL_4EBD_

; 3rd entry of Jump Table from 4CB4 (indexed by unknown)
JumpTable8_4E65:
	ld de, $3A1E
	rst $08	; Interrupt8
	ld a, $58
	out (VDPData), a
	ld hl, $C910
	ld de, $A040
	ld bc, $C935
	jp _LABEL_4EFE_

; 4th entry of Jump Table from 4CB4 (indexed by unknown)
JumpTable8_4E79:
	ld de, $3A1E
	rst $08	; Interrupt8
	ld a, $58
	out (VDPData), a
	ld hl, $C918
	ld de, $A080
	ld bc, $C945
	jp _LABEL_4EFE_

; 5th entry of Jump Table from 4CB4 (indexed by unknown)
JumpTable8_4E8D:
	ld de, $3A1E
	rst $08	; Interrupt8
	ld a, $58
	out (VDPData), a
	ld hl, $C920
	ld de, $A0C0
	ld bc, $C955
	jp _LABEL_4EFE_

; 6th entry of Jump Table from 4CB4 (indexed by unknown)
JumpTable8_4EA1:
	ld de, $3A1E
	rst $08	; Interrupt8
	ld a, ($C930)
	or a
	ld a, $7B
	jr nz, _LABEL_4EAF_
	ld a, $58
_LABEL_4EAF_:
	out (VDPData), a
	ld hl, EquippedRing
	ld de, $A100
	ld bc, $C965
	jp _LABEL_4EFE_

_LABEL_4EBD_:
	ld a, $03
	ld ($FFFF), a
	ld c, VDPData
	exx
	ld de, $3A20
	ld b, $08
_LABEL_4ECA_:
	rst $08	; Interrupt8
	exx
	push hl
	push de
	ld a, (hl)
	or a
	jr nz, _LABEL_4ED7_
	ld hl, $A140
	jr _LABEL_4EE2_

_LABEL_4ED7_:
	and $0F
	add a, a
	ld l, a
	ld h, $00
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
_LABEL_4EE2_:
	inc hl
	ld bc, $0EBE
	ld a, $11
_LABEL_4EE8_:
	outi
	nop
	jr _LABEL_4EED_

_LABEL_4EED_:
	out (c), a
	nop
	jr nz, _LABEL_4EE8_
	pop de
	pop hl
	inc hl
	exx
	ld hl, $0040
	add hl, de
	ex de, hl
	djnz _LABEL_4ECA_
	ret

_LABEL_4EFE_:
	ld a, $03
	ld ($FFFF), a
	exx
	ld de, $3A20
	ld bc, $08BE
_LABEL_4F0A_:
	rst $08	; Interrupt8
	exx
	push hl
	push de
	push bc
	ld a, (hl)
	or a
	jr nz, _LABEL_4F18_
	ld hl, $A140
	jr _LABEL_4F34_

_LABEL_4F18_:
	and $0F
	ld l, a
	ld h, $00
	add hl, bc
	ex af, af'
	ld a, (hl)
	or a
	jr z, _LABEL_4F2A_
	dec a
	ex af, af'
	ld hl, $0020
	add hl, de
	ex de, hl
_LABEL_4F2A_:
	ex af, af'
	add a, a
	ld l, a
	ld h, $00
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
_LABEL_4F34_:
	inc hl
	ld bc, $0EBE
	ld a, $11
_LABEL_4F3A_:
	outi
	nop
	jr _LABEL_4F3F_

_LABEL_4F3F_:
	out (c), a
	nop
	jr nz, _LABEL_4F3A_
	pop bc
	pop de
	pop hl
	inc hl
	exx
	ld hl, $0040
	add hl, de
	ex de, hl
	djnz _LABEL_4F0A_
	ret

_LABEL_4F51_:
	ld de, $3D66
	rst $08	; Interrupt8
	ld a, (WeaponPW)
	ld hl, (BasePW)
	add a, l
	ld l, a
	ld h, $00
	call _LABEL_2C98_
	call _LABEL_4F76_
	ld de, $3D74
	rst $08	; Interrupt8
	ld a, (ArmorAC)
	ld hl, (BaseAC)
	add a, l
	ld l, a
	ld h, $00
	call _LABEL_2C98_
_LABEL_4F76_:
	ld a, ($C0B2)
	or a
	jr z, _LABEL_4F80_
	add a, $80
	jr _LABEL_4F82_

_LABEL_4F80_:
	ld a, $58
_LABEL_4F82_:
	out (VDPData), a
	jr _LABEL_4F86_

_LABEL_4F86_:
	ld a, $01
	out (VDPData), a
	ld a, ($C0B1)
	add a, $80
	out (VDPData), a
	jr _LABEL_4F93_

_LABEL_4F93_:
	ld a, $01
	out (VDPData), a
	ret

_LABEL_4F98_:
	ld (ix+2), $01
	ld (ix+15), $A0
	ld (ix+17), $90
	ld (ix+24), $00
	ld (ix+0), <_LABEL_4FB1_
	ld (ix+1), >_LABEL_4FB1_
	ret

_LABEL_4FB1_:
	ld a, (LastControllerState)
	and $03
	jr z, _LABEL_4FCD_
	rrca
	jr nc, _LABEL_4FC5_
	ld (ix+24), $00
	ld (ix+15), $A0
	jr _LABEL_4FCD_

_LABEL_4FC5_:
	ld (ix+24), $01
	ld (ix+15), $B0
_LABEL_4FCD_:
	ld a, (LastControllerState)
	and $B0
	ret z
	bit 0, (ix+24)
	jr z, _LABEL_4FE8_
	xor a
	ld (ContinuesSpent), a
	call _LABEL_42C_
	ld a, $00
	ld (TableIndex1), a
	jp _LABEL_137_

_LABEL_4FE8_:
	ld hl, ContinuesSpent
	inc (hl)
	ld hl, PreventArmorRust
	ld de, ParalysisTicksLeft
	ld (hl), $00
	call LDI5
	call _LABEL_101A_
	ld hl, (MaxHPLow)
	ld (CurrentHPLow), hl
	ld a, $30
	ld (Food), a
	call _LABEL_42C_
	ld a, $08
	ld (TableIndex1), a
	jp _LABEL_137_

_LABEL_5010_:
	ld (ix+0), <_LABEL_5019_
	ld (ix+1), >_LABEL_5019_
	ret

_LABEL_5019_:
	ld a, (LastControllerState)
	and $B0
	jr nz, _LABEL_5021_
	ret

_LABEL_5021_:
	xor a
	ld (ContinuesSpent), a
	call _LABEL_42C_
	ld a, $00
	ld (TableIndex1), a
	jp _LABEL_137_

_LABEL_5030_:
	ld d, $1C
	ld a, (EquippedArmor)
	cp CuirassArmor        ; $13 or less
	jr c, _LABEL_503F_
	inc d
	cp PlateArmor          ; $16 or less
	jr c, _LABEL_503F_
	inc d
_LABEL_503F_:
	ld (ix+3), d
	ld (ix+2), $01
	ld (ix+15), $34
	ld (ix+17), $48
	ld (ix+24), $00
	ld (ix+0), <_LABEL_505B_
	ld (ix+1), >_LABEL_505B_
	ret

_LABEL_505B_:
	ret

_LABEL_505C_:
	ld (ix+2), $01
	ld (ix+3), $C3
	ld (ix+26), $00
	ld (ix+15), $80
	ld (ix+17), $80
	ld (ix+24), $20
	ld (ix+0), <_LABEL_507D_
	ld (ix+1), >_LABEL_507D_
	ret

_LABEL_507D_:
	dec (ix+24)
	ret nz
	ld hl, PaletteInRAM
	ld ($C0A4), hl
	ld a, $08
	ld ($C0A3), a
	call _LABEL_4A9_
	ld (ix+24), $30
	ld (ix+0), <_LABEL_509C_
	ld (ix+1), >_LABEL_509C_
	ret

_LABEL_509C_:
	dec (ix+24)
	ret nz
	ld (ix+24), $10
	ld (ix+3), $C4
	ld (ix+0), <_LABEL_50B1_
	ld (ix+1), >_LABEL_50B1_
	ret

_LABEL_50B1_:
	dec (ix+24)
	ret nz
	ld (ix+28), $00
	ld (ix+29), $FA
	ld (ix+0), <_LABEL_50C6_
	ld (ix+1), >_LABEL_50C6_
	ret

_LABEL_50C6_:
	inc (ix+17)
	inc (ix+17)
	ld l, (ix+26)
	ld h, (ix+15)
	ld e, (ix+28)
	ld d, (ix+29)
	add hl, de
	ld a, h
	cp $A0
	jr nc, _LABEL_50EF_
	ld (ix+26), l
	ld (ix+15), h
	ld hl, $0074
	add hl, de
	ld (ix+28), l
	ld (ix+29), h
	ret

_LABEL_50EF_:
	ld hl, _LABEL_5176_
	ld ($C120), hl
	ld (ix+3), $00
	ld (ix+15), $A1
	ld (ix+17), $B8
	ld (ix+21), $20
	ld (ix+22), <Data_5116
	ld (ix+23), >Data_5116
	ld (ix+0), <_LABEL_511E_
	ld (ix+1), >_LABEL_511E_
	ret

; Data from 5116 to 511D (8 bytes)
Data_5116:
	.db $C5 $C6 $C7 $C8 $C7 $C6 $C5 $00

_LABEL_511E_:
	ld a, (ix+21)
	or a
	jr z, _LABEL_5129_
	dec a
	ld (ix+21), a
	ret

_LABEL_5129_:
	ld a, $02
	ld (ix+21), a
	ld l, (ix+22)
	ld h, (ix+23)
	ld a, (hl)
	ld (ix+3), a
	inc hl
	ld (ix+22), l
	ld (ix+23), h
	inc (ix+24)
	ld a, (ix+24)
	cp $02
	jr z, _LABEL_5159_
	cp $08
	ret c
	ld (ix+2), $00
	ld (ix+0), <_LABEL_5167_
	ld (ix+1), >_LABEL_5167_
	ret

_LABEL_5159_:
	ld hl, $C030
	ld ($C0A4), hl
	ld a, $08
	ld ($C0A3), a
	jp _LABEL_4A9_

_LABEL_5167_:
	ld a, $16
	ld (TableIndex1), a
	ld hl, _LABEL_310F_
	ld ($C100), hl
	ld ($C120), hl
	ret

_LABEL_5176_:
	ld (ix+2), $01
	ld (ix+3), $C4
	ld (ix+15), $A0
	ld (ix+17), $C0
	ld (ix+24), $08
	ld (ix+0), <_LABEL_5193_
	ld (ix+1), >_LABEL_5193_
	ret

_LABEL_5193_:
	dec (ix+24)
	ret nz
	ld (ix+3), $C3
	ld (ix+0), <_LABEL_51A4_
	ld (ix+1), >_LABEL_51A4_
	ret

_LABEL_51A4_:
	ret

_LABEL_51A5_:
	ld a, (EquippedArmor)
	cp MysticSuitArmor
	jr z, _LABEL_51B5_
	ld a, (ix+28)
	and $08
	jr nz, _LABEL_51B5_
	xor a
	ret

_LABEL_51B5_:
	scf
	ret

RustArmor:
	ld a, (EquippedArmor)
	cp $11					; Leathersuit won't rust
	jr z, ArmorDidntRust
	cp $12					; Lamellar won't rust
	jr z, ArmorDidntRust
	cp $19					; Mystic Suit won't rust
	jr z, ArmorDidntRust
	ld a, (EquippedRing)
	cp ShieldRing			; Shield ring prevents rusting
	jr z, ArmorDidntRust
	ld a, (ix+28)
	and $08
	jr nz, ArmorDidntRust
	ld a, (PreventArmorRust) ; No rust effect (set by Norust scroll) prevents rusting
	or a
	jr nz, ArmorDidntRust
	xor a
	ret

ArmorDidntRust:
	scf
	ret

_LABEL_51DE_:
	ld (ix+4), $00
	call _LABEL_5263_
	push hl
	call _LABEL_5280_
	pop hl
	or a
	sbc hl, bc
	jr z, _LABEL_5221_
	jr c, _LABEL_5209_
	ld hl, ($C10A)
	ld c, (ix+10)
	ld b, (ix+11)
	or a
	sbc hl, bc
	jr c, _LABEL_5204_
	ld (ix+4), $02
	ret

_LABEL_5204_:
	ld (ix+4), $01
	ret

_LABEL_5209_:
	ld hl, ($C10D)
	ld c, (ix+13)
	ld b, (ix+14)
	or a
	sbc hl, bc
	jr c, _LABEL_521C_
	ld (ix+4), $08
	ret

_LABEL_521C_:
	ld (ix+4), $04
	ret

_LABEL_5221_:
	ld hl, ($C10A)
	ld c, (ix+10)
	ld b, (ix+11)
	or a
	sbc hl, bc
	jr z, _LABEL_5243_
	jr c, _LABEL_523B_
	ld a, (ix+4)
	or $02
	ld (ix+4), a
	jr _LABEL_5243_

_LABEL_523B_:
	ld a, (ix+4)
	or $01
	ld (ix+4), a
_LABEL_5243_:
	ld hl, ($C10D)
	ld c, (ix+13)
	ld b, (ix+14)
	or a
	sbc hl, bc
	jr c, _LABEL_525A_
	ld a, (ix+4)
	or $08
	ld (ix+4), a
	ret

_LABEL_525A_:
	ld a, (ix+4)
	or $04
	ld (ix+4), a
	ret

_LABEL_5263_:
	ld hl, ($C10A)
	ld e, (ix+10)
	ld d, (ix+11)
	or a
	sbc hl, de
	jr c, _LABEL_5272_
	ret

_LABEL_5272_:
	ld l, (ix+10)
	ld h, (ix+11)
	ld de, ($C10A)
	or a
	sbc hl, de
	ret

_LABEL_5280_:
	ld hl, ($C10D)
	ld e, (ix+13)
	ld d, (ix+14)
	or a
	sbc hl, de
	jr c, _LABEL_5291_
	ld c, l
	ld b, h
	ret

_LABEL_5291_:
	ld l, (ix+13)
	ld h, (ix+14)
	ld de, ($C10D)
	or a
	sbc hl, de
	ld c, l
	ld b, h
	ret

_LABEL_52A1_:
	call GetRandomNumber
	cp $40
	jr c, _LABEL_52B2_
	cp $80
	jr c, _LABEL_52B7_
	cp $C0
	jr c, _LABEL_52BC_
	jr _LABEL_52C1_

_LABEL_52B2_:
	ld (ix+4), $01
	ret

_LABEL_52B7_:
	ld (ix+4), $02
	ret

_LABEL_52BC_:
	ld (ix+4), $04
	ret

_LABEL_52C1_:
	ld (ix+4), $08
	ret

_LABEL_52C6_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_52D4_
	rrca
	jr c, _LABEL_52DF_
	rrca
	jr c, _LABEL_52EA_
	jr _LABEL_52F5_

_LABEL_52D4_:
	ld a, ($C10A)
	ld b, (ix+10)
	cp b
	jr nc, _LABEL_5300_
	xor a
	ret

_LABEL_52DF_:
	ld a, ($C10A)
	ld b, (ix+10)
	cp b
	jr c, _LABEL_5300_
	xor a
	ret

_LABEL_52EA_:
	ld a, ($C10D)
	ld b, (ix+13)
	cp b
	jr nc, _LABEL_5300_
	xor a
	ret

_LABEL_52F5_:
	ld a, ($C10D)
	ld b, (ix+13)
	cp b
	jr c, _LABEL_5300_
	xor a
	ret

_LABEL_5300_:
	scf
	ret

_LABEL_5302_:
	ld a, (ArmorEvd)
	ld b, a
	ld a, $80
	sub b
	push af
	call GetRandomNumber
	and $7F
	ld b, a
	pop af
	cp b
	jr c, _LABEL_5360_
	ld a, (ix+31)
	ld l, a
	ld h, $00
	ld de, MonsterAttackTable
	add hl, de
	ld a, (ArmorAC)
	ld b, a
	ld a, (hl)
	sub b
	jr c, _LABEL_5334_
	cp $02
	jr c, _LABEL_5334_
	cp $CC
	call nc, _LABEL_536A_
	call _LABEL_4848_
	jr _LABEL_5336_

_LABEL_5334_:
	ld a, $01
_LABEL_5336_:
	push af
	ld c, a
	ld b, $00
	ld hl, (CurrentHPLow)
	or a
	sbc hl, bc
	call c, _LABEL_5356_
	call z, _LABEL_5356_
	ld (CurrentHPLow), hl
	pop af
	ld l, a
	ld h, $00
	ld ($CAC6), hl
	ld a, PlayerDamagedMessage1
	ld (CurrentMessage), a
	ret

_LABEL_5356_:
	ld a, (ix+31)
	ld ($C63F), a
	ld hl, $0000
	ret

_LABEL_5360_:
	ld a, PlayerDodgedMessage
	ld (CurrentMessage), a
	ld (ix+29), $01
	ret

_LABEL_536A_:
	ld a, $CC
	ret

.include "monsters\monster_attack_table.asm"

_LABEL_538E_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_539C_
	rrca
	jr c, _LABEL_53C0_
	rrca
	jr c, _LABEL_53E2_
	jr _LABEL_5401_

_LABEL_539C_:
	ld l, (ix+5)
	ld h, (ix+6)
_LABEL_53A2_:
	ld de, $0020
	or a
	sbc hl, de
	ld a, (hl)
	and $7F
	jr z, _LABEL_53B2_
	dec (ix+25)
	jr nz, _LABEL_53A2_
_LABEL_53B2_:
	ld e, (ix+5)
	ld d, (ix+6)
	or a
	sbc hl, de
	ld (ix+25), $01
	ret

_LABEL_53C0_:
	ld l, (ix+5)
	ld h, (ix+6)
_LABEL_53C6_:
	ld de, $0020
	add hl, de
	ld a, (hl)
	and $7F
	jr z, _LABEL_53D4_
	dec (ix+25)
	jr nz, _LABEL_53C6_
_LABEL_53D4_:
	ld e, (ix+5)
	ld d, (ix+6)
	or a
	sbc hl, de
	ld (ix+25), $01
	ret

_LABEL_53E2_:
	ld l, (ix+5)
	ld h, (ix+6)
_LABEL_53E8_:
	dec hl
	ld a, (hl)
	and $7F
	jr z, _LABEL_53F3_
	dec (ix+25)
	jr nz, _LABEL_53E8_
_LABEL_53F3_:
	ld e, (ix+5)
	ld d, (ix+6)
	or a
	sbc hl, de
	ld (ix+25), $01
	ret

_LABEL_5401_:
	ld l, (ix+5)
	ld h, (ix+6)
_LABEL_5407_:
	inc hl
	ld a, (hl)
	and $7F
	jr z, _LABEL_5412_
	dec (ix+25)
	jr nz, _LABEL_5407_
_LABEL_5412_:
	ld e, (ix+5)
	ld d, (ix+6)
	or a
	sbc hl, de
	ld (ix+25), $01
	ret

_LABEL_5420_:
	ld e, (ix+5)
	ld d, (ix+6)
	add hl, de
	ld a, (hl)
	bit 7, a
	jr nz, _LABEL_5443_
	ld (ix+2), $01
	cp $02
	jr c, _LABEL_5443_
	cp $06
	jr nc, _LABEL_543F_
_LABEL_5438_:
	call _LABEL_1F17_
	jr c, _LABEL_5443_
	xor a
	ret

_LABEL_543F_:
	cp $0C
	jr nc, _LABEL_5438_
_LABEL_5443_:
	scf
	ret

_LABEL_5445_:
	push hl
	ld e, (ix+5)
	ld d, (ix+6)
	add hl, de
	ld a, (hl)
	and $7F
	cp $05
	jr z, _LABEL_5457_
	pop hl
	xor a
	ret

_LABEL_5457_:
	pop hl
	scf
	ret

_LABEL_545A_:
	ld e, (ix+5)
	ld d, (ix+6)
	add hl, de
	ld a, (hl)
	cp $02
	jr c, _LABEL_5471_
	cp $06
	jr nc, _LABEL_5471_
	call _LABEL_1F17_
	jr c, _LABEL_5471_
	xor a
	ret

_LABEL_5471_:
	scf
	ret

_LABEL_5473_:
	ld de, ($C107)
	ld l, (ix+5)
	ld h, (ix+6)
	inc hl
	or a
	sbc hl, de
	jr nz, _LABEL_5489_
	ld (ix+4), $08
	jr _LABEL_54C6_

_LABEL_5489_:
	ld l, (ix+5)
	ld h, (ix+6)
	dec hl
	or a
	sbc hl, de
	jr nz, _LABEL_549B_
	ld (ix+4), $04
	jr _LABEL_54C6_

_LABEL_549B_:
	ld l, (ix+5)
	ld h, (ix+6)
	ld bc, $0020
	add hl, bc
	or a
	sbc hl, de
	jr nz, _LABEL_54B0_
	ld (ix+4), $02
	jr _LABEL_54C6_

_LABEL_54B0_:
	ld l, (ix+5)
	ld h, (ix+6)
	or a
	sbc hl, bc
	or a
	sbc hl, de
	jr nz, _LABEL_54C4_
	ld (ix+4), $01
	jr _LABEL_54C6_

_LABEL_54C4_:
	xor a
	ret

_LABEL_54C6_:
	scf
	ret

_LABEL_54C8_:
	call _LABEL_54DF_
	ret c
	ld (ix+4), a
	call _LABEL_1F3A_
	jr c, _LABEL_54DD_
	ex de, hl
	push ix
	pop hl
	call LDI32
	xor a
	ret

_LABEL_54DD_:
	scf
	ret

_LABEL_54DF_:
	ld hl, $FFE0
	call _LABEL_545A_
	jr c, _LABEL_54EA_
	ld a, $01
	ret

_LABEL_54EA_:
	ld hl, $0020
	call _LABEL_545A_
	jr c, _LABEL_54F5_
	ld a, $02
	ret

_LABEL_54F5_:
	ld hl, $FFFF
	call _LABEL_545A_
	jr c, _LABEL_5500_
	ld a, $04
	ret

_LABEL_5500_:
	ld hl, $0001
	call _LABEL_545A_
	jr c, _LABEL_550B_
	ld a, $08
	ret

_LABEL_550B_:
	scf
	ret

_LABEL_550D_:
	ld l, (ix+5)
	ld h, (ix+6)
	ld de, $2D00
	add hl, de
	ex de, hl
	ld h, d
	ld a, e
	and $E0
	srl h
	rra
	set 3, a
	ld (ix+10), a
	ld (ix+11), h
	ld a, e
	and $1F
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	set 3, l
	ld (ix+13), l
	ld (ix+14), h
	ret

_LABEL_553A_:
	ld a, (ix+21)
	or a
	jr z, _LABEL_5544_
	dec (ix+21)
	ret

_LABEL_5544_:
	ld l, (ix+22)
	ld h, (ix+23)
	ld a, (ix+20)
	cp (hl)
	jr c, _LABEL_5554_
	xor a
	ld (ix+20), a
_LABEL_5554_:
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	inc hl
	ld a, (hl)
	ld (ix+21), a
	inc hl
	ld a, (hl)
	ld (ix+3), a
	inc (ix+20)
	ret

_LABEL_5567_:
	xor a
	ld l, (ix+5)
	ld h, (ix+6)
	bit 7, (hl)
	jr nz, _LABEL_5577_
	ld (ix+2), $01
	ret

_LABEL_5577_:
	ld (ix+2), $00
	scf
	ret

_LABEL_557D_:
	ld a, ($C10A)
	ld b, (ix+10)
	cp b
	jr z, _LABEL_5591_
	ld a, ($C10D)
	ld b, (ix+13)
	cp b
	jr z, _LABEL_55A8_
	xor a
	ret

_LABEL_5591_:
	ld a, ($C10D)
	ld b, (ix+13)
	sub b
	jr nc, _LABEL_55A2_
	ld (ix+4), $04
	neg
	scf
	ret

_LABEL_55A2_:
	ld (ix+4), $08
	scf
	ret

_LABEL_55A8_:
	ld a, ($C10A)
	ld b, (ix+10)
	sub b
	jr nc, _LABEL_55B9_
	ld (ix+4), $01
	neg
	scf
	ret

_LABEL_55B9_:
	ld (ix+4), $02
	scf
	ret

_LABEL_55BF_:
	and $F0
	push af
	cp $50
	jr nc, _LABEL_5640_
	ld a, (ix+4)
	rrca
	jr c, _LABEL_55D4_
	rrca
	jr c, _LABEL_55F2_
	rrca
	jr c, _LABEL_560E_
	jr _LABEL_5627_

_LABEL_55D4_:
	pop af
	ld l, (ix+5)
	ld h, (ix+6)
_LABEL_55DB_:
	push af
	ld de, $0020
	or a
	sbc hl, de
	ld a, (hl)
	and $7F
	jr z, _LABEL_5640_
	cp $06
	jr z, _LABEL_5640_
	pop af
	sub $10
	jr nz, _LABEL_55DB_
	xor a
	ret

_LABEL_55F2_:
	pop af
	ld l, (ix+5)
	ld h, (ix+6)
_LABEL_55F9_:
	push af
	ld de, $0020
	add hl, de
	ld a, (hl)
	and $7F
	jr z, _LABEL_5640_
	cp $06
	jr z, _LABEL_5640_
	pop af
	sub $10
	jr nz, _LABEL_55F9_
	xor a
	ret

_LABEL_560E_:
	pop af
	ld l, (ix+5)
	ld h, (ix+6)
_LABEL_5615_:
	push af
	dec hl
	ld a, (hl)
	and $7F
	jr z, _LABEL_5640_
	cp $06
	jr z, _LABEL_5640_
	pop af
	sub $10
	jr nz, _LABEL_5615_
	xor a
	ret

_LABEL_5627_:
	pop af
	ld l, (ix+5)
	ld h, (ix+6)
_LABEL_562E_:
	push af
	inc hl
	ld a, (hl)
	and $7F
	jr z, _LABEL_5640_
	cp $06
	jr z, _LABEL_5640_
	pop af
	sub $10
	jr nz, _LABEL_562E_
	xor a
	ret

_LABEL_5640_:
	pop af
	scf
	ret

_LABEL_5643_:
	ld a, ($C102)
	cp $01
	jr z, _LABEL_5650_
	ld a, $01
	ld ($C102), a
	ret

_LABEL_5650_:
	xor a
	ld ($C102), a
	ret

_LABEL_5655_:
	ld a, $01
	ld ($C102), a
	ld (ix+30), $00
	ld (ix+24), $00
	ld (ix+21), $00
	ld (ix+20), $00
	ld (ix+29), $00
	ld a, (ix+7)
	ld (ix+5), a
	ld a, (ix+8)
	ld (ix+6), a
	ret

_LABEL_567B_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_5689_
	rrca
	jr c, _LABEL_5689_
	rrca
	jr c, _LABEL_568A_
	jr _LABEL_568B_

_LABEL_5689_:
	ret

_LABEL_568A_:
	ret

_LABEL_568B_:
	ret

_LABEL_568C_:
	ld hl, ($C107)
	ld a, (hl)
	cp $04
	jr z, _LABEL_569A_
	cp $03
	jr z, _LABEL_569A_
	xor a
	ret

_LABEL_569A_:
	scf
	ret

_LABEL_569C_:
	ld a, (ix+5)
	ld (ix+7), a
	ld a, (ix+6)
	ld (ix+8), a
	ret

_LABEL_56A9_:
	ld a, (ix+10)
	ld ($C3CA), a
	ld a, (ix+11)
	ld ($C3CB), a
	ld a, (ix+13)
	ld ($C3CD), a
	ld a, (ix+14)
	ld ($C3CE), a
	ld a, (ix+4)
	ld ($C3C4), a
	ret

; 1st entry of Jump Table from 2012 (indexed by unknown)
OozeMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $02
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+0), <OozeMonsterAction_56EF
	ld (ix+1), >OozeMonsterAction_56EF
	ld (ix+22), <OozeTypeMonsterData_7B25
	ld (ix+23), >OozeTypeMonsterData_7B25
	ret

OozeMonsterAction_56EF:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, OozeMonsterAction_570C
	cp $09
	jr z, OozeMonsterAction_570C
	jp _LABEL_481B_

OozeMonsterAction_570C:
	inc (ix+25)
	ld a, (ix+25)
	cp $02
	jr nz, OozeMonsterAction_572A
	ld (ix+25), $00
	call _LABEL_5473_
	jr nc, OozeMonsterAction_5740
	ld (ix+0), <OozeMonsterAction_5815
	ld (ix+1), >OozeMonsterAction_5815
	jp OozeMonsterAction_5815

OozeMonsterAction_572A:
	ld (ix+24), $08
	ld (ix+0), <OozeMonsterAction_5736
	ld (ix+1), >OozeMonsterAction_5736

OozeMonsterAction_5736:
	call _LABEL_553A_
	dec (ix+24)
	jp z, OozeMonsterAction_5801
	ret

OozeMonsterAction_5740:
	ld a, (ix+28)
	and $01
	jr nz, OozeMonsterAction_575D
	call _LABEL_568C_
	jr nc, OozeMonsterAction_575D
	call _LABEL_51DE_
OozeMonsterAction_574F:
	ld a, (ix+4)
	rrca
	jr c, OozeMonsterAction_5762
	rrca
	jr c, OozeMonsterAction_577A
	rrca
	jr c, OozeMonsterAction_5792
	jr OozeMonsterAction_57AC

OozeMonsterAction_575D:
	call _LABEL_52A1_
	jr OozeMonsterAction_574F

OozeMonsterAction_5762:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, OozeMonsterAction_5770
	ld (ix+4), $01
	jr OozeMonsterAction_57B9

OozeMonsterAction_5770:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr OozeMonsterAction_574F

OozeMonsterAction_577A:
	ld hl, $0020
	call _LABEL_5420_
	jr c, OozeMonsterAction_5788
	ld (ix+4), $02
	jr OozeMonsterAction_57B9

OozeMonsterAction_5788:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr OozeMonsterAction_574F

OozeMonsterAction_5792:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, OozeMonsterAction_57A0
	ld (ix+4), $04
	jr OozeMonsterAction_57B9

OozeMonsterAction_57A0:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr OozeMonsterAction_574F

OozeMonsterAction_57AC:
	ld hl, $0001
	call _LABEL_5420_
	jp c, OozeMonsterAction_572A
	ld (ix+4), $08
OozeMonsterAction_57B9:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), <OozeMonsterAction_57CB
	ld (ix+1), >OozeMonsterAction_57CB

OozeMonsterAction_57CB:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, OozeMonsterAction_5801
	ret

OozeMonsterAction_57D7:
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_
	ld (ix+0), <OozeMonsterAction_57E7
	ld (ix+1), >OozeMonsterAction_57E7

OozeMonsterAction_57E7:
	call _LABEL_553A_
	dec (ix+24)
	jr z, OozeMonsterAction_5801
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, OozeMonsterAction_57FE
	call _LABEL_5302_
OozeMonsterAction_57FE:
	jp _LABEL_5643_

OozeMonsterAction_5801:
	call _LABEL_5655_
	ld (ix+22), <OozeTypeMonsterData_7B25
	ld (ix+23), >OozeTypeMonsterData_7B25
	ld (ix+0), <OozeMonsterAction_56EF
	ld (ix+1), >OozeMonsterAction_56EF
	ret

OozeMonsterAction_5815:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, OozeMonsterAction_5801
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld (ix+24), $08
	ld (ix+22), <OozeTypeMonsterData_7B2E
	ld (ix+23), >OozeTypeMonsterData_7B2E
	ld (ix+0), <OozeMonsterAction_57D7
	ld (ix+1), >OozeMonsterAction_57D7
	jp OozeMonsterAction_57D7

; 5th entry of Jump Table from 2012 (indexed by unknown)
BlueOozeMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $06
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+0), <BlueOozeMonsterAction_5865
	ld (ix+1), >BlueOozeMonsterAction_5865
	ld (ix+22), <OozeTypeMonsterData_7B25
	ld (ix+23), >OozeTypeMonsterData_7B25
	ret

BlueOozeMonsterAction_5865:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, BlueOozeMonsterAction_5882
	cp $09
	jr z, BlueOozeMonsterAction_5882
	jp _LABEL_481B_

BlueOozeMonsterAction_5882:
	inc (ix+25)
	ld a, (ix+25)
	cp $02
	jr nz, BlueOozeMonsterAction_58A0
	ld (ix+25), $00
	call _LABEL_5473_
	jr nc, BlueOozeMonsterAction_58B6
	ld (ix+0), <BlueOozeMonsterAction_5959
	ld (ix+1), >BlueOozeMonsterAction_5959
	jp BlueOozeMonsterAction_5959

BlueOozeMonsterAction_58A0:
	ld (ix+24), $08
	ld (ix+0), <BlueOozeMonsterAction_58AC
	ld (ix+1), >BlueOozeMonsterAction_58AC

BlueOozeMonsterAction_58AC:
	call _LABEL_553A_
	dec (ix+24)
	jp z, BlueOozeMonsterAction_5945
	ret

BlueOozeMonsterAction_58B6:
	call _LABEL_52A1_
BlueOozeMonsterAction_58B9:
	ld a, (ix+4)
	rrca
	jr c, BlueOozeMonsterAction_58C7
	rrca
	jr c, BlueOozeMonsterAction_58D5
	rrca
	jr c, BlueOozeMonsterAction_58E3
	jr BlueOozeMonsterAction_58F1

BlueOozeMonsterAction_58C7:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, BlueOozeMonsterAction_58D5
	ld (ix+4), $01
	jr BlueOozeMonsterAction_58FD

BlueOozeMonsterAction_58D5:
	ld hl, $0020
	call _LABEL_5420_
	jr c, BlueOozeMonsterAction_58E3
	ld (ix+4), $02
	jr BlueOozeMonsterAction_58FD

BlueOozeMonsterAction_58E3:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, BlueOozeMonsterAction_58F1
	ld (ix+4), $04
	jr BlueOozeMonsterAction_58FD

BlueOozeMonsterAction_58F1:
	ld hl, $0001
	call _LABEL_5420_
	jr c, BlueOozeMonsterAction_58A0
	ld (ix+4), $08
BlueOozeMonsterAction_58FD:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), <BlueOozeMonsterAction_590F
	ld (ix+1), >BlueOozeMonsterAction_590F

BlueOozeMonsterAction_590F:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, BlueOozeMonsterAction_5945
	ret

BlueOozeMonsterAction_591B:
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_
	ld (ix+0), <BlueOozeMonsterAction_592B
	ld (ix+1), >BlueOozeMonsterAction_592B

BlueOozeMonsterAction_592B:
	call _LABEL_553A_
	dec (ix+24)
	jr z, BlueOozeMonsterAction_5945
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, BlueOozeMonsterAction_5942
	call _LABEL_5302_
BlueOozeMonsterAction_5942:
	jp _LABEL_5643_

BlueOozeMonsterAction_5945:
	call _LABEL_5655_
	ld (ix+22), <OozeTypeMonsterData_7B25
	ld (ix+23), >OozeTypeMonsterData_7B25
	ld (ix+0), <BlueOozeMonsterAction_5865
	ld (ix+1), >BlueOozeMonsterAction_5865
	ret

BlueOozeMonsterAction_5959:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, BlueOozeMonsterAction_5945
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	call GetRandomNumber
	cp $D8
	jr nc, BlueOozeMonsterAction_5989
	ld (ix+30), $01
	ld (ix+24), $08
	ld (ix+22), <OozeTypeMonsterData_7B2E
	ld (ix+23), >OozeTypeMonsterData_7B2E
	ld (ix+0), <BlueOozeMonsterAction_591B
	ld (ix+1), >BlueOozeMonsterAction_591B
	jp BlueOozeMonsterAction_591B

BlueOozeMonsterAction_5989:
	ld (ix+24), $08
	ld (ix+0), <BlueOozeMonsterAction_58A0
	ld (ix+1), >BlueOozeMonsterAction_58A0
	call _LABEL_54C8_
	jp c, BlueOozeMonsterAction_58A0
	ld a, SoundEffectA2
	ld (SFXQueue), a
	call _LABEL_567B_
	jp BlueOozeMonsterAction_58B9

; 9th entry of Jump Table from 2012 (indexed by unknown)
RedOozeMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $26
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+0), <RedOozeMonsterAction_59CD
	ld (ix+1), >RedOozeMonsterAction_59CD
	ld (ix+22), <OozeTypeMonsterData_7B25
	ld (ix+23), >OozeTypeMonsterData_7B25
	ret

RedOozeMonsterAction_59CD:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, RedOozeMonsterAction_59EA
	cp $09
	jr z, RedOozeMonsterAction_59EA
	jp _LABEL_481B_

RedOozeMonsterAction_59EA:
	inc (ix+25)
	ld a, (ix+25)
	cp $02
	jr nz, RedOozeMonsterAction_5A08
	ld (ix+25), $00
	call _LABEL_5473_
	jr nc, RedOozeMonsterAction_5A1E
	ld (ix+0), <RedOozeMonsterAction_5AF3
	ld (ix+1), >RedOozeMonsterAction_5AF3
	jp RedOozeMonsterAction_5AF3

RedOozeMonsterAction_5A08:
	ld (ix+24), $08
	ld (ix+0), <RedOozeMonsterAction_5A14
	ld (ix+1), >RedOozeMonsterAction_5A14

RedOozeMonsterAction_5A14:
	call _LABEL_553A_
	dec (ix+24)
	jp z, RedOozeMonsterAction_5ADF
	ret

RedOozeMonsterAction_5A1E:
	ld a, (ix+28)
	and $01
	jr nz, RedOozeMonsterAction_5A3B
	call _LABEL_568C_
	jr nc, RedOozeMonsterAction_5A3B
	call _LABEL_51DE_
RedOozeMonsterAction_5A2D:
	ld a, (ix+4)
	rrca
	jr c, RedOozeMonsterAction_5A40
	rrca
	jr c, RedOozeMonsterAction_5A58
	rrca
	jr c, RedOozeMonsterAction_5A70
	jr RedOozeMonsterAction_5A8A

RedOozeMonsterAction_5A3B:
	call _LABEL_52A1_
	jr RedOozeMonsterAction_5A2D

RedOozeMonsterAction_5A40:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, RedOozeMonsterAction_5A4E
	ld (ix+4), $01
	jr RedOozeMonsterAction_5A97

RedOozeMonsterAction_5A4E:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr RedOozeMonsterAction_5A2D

RedOozeMonsterAction_5A58:
	ld hl, $0020
	call _LABEL_5420_
	jr c, RedOozeMonsterAction_5A66
	ld (ix+4), $02
	jr RedOozeMonsterAction_5A97

RedOozeMonsterAction_5A66:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr RedOozeMonsterAction_5A2D

RedOozeMonsterAction_5A70:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, RedOozeMonsterAction_5A7E
	ld (ix+4), $04
	jr RedOozeMonsterAction_5A97

RedOozeMonsterAction_5A7E:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr RedOozeMonsterAction_5A2D

RedOozeMonsterAction_5A8A:
	ld hl, $0001
	call _LABEL_5420_
	jp c, RedOozeMonsterAction_5A08
	ld (ix+4), $08
RedOozeMonsterAction_5A97:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), <RedOozeMonsterAction_5AA9
	ld (ix+1), >RedOozeMonsterAction_5AA9

RedOozeMonsterAction_5AA9:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, RedOozeMonsterAction_5ADF
	ret

RedOozeMonsterAction_5AB5:
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_
	ld (ix+0), <RedOozeMonsterAction_5AC5
	ld (ix+1), >RedOozeMonsterAction_5AC5

RedOozeMonsterAction_5AC5:
	call _LABEL_553A_
	dec (ix+24)
	jr z, RedOozeMonsterAction_5ADF
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, RedOozeMonsterAction_5ADC
	call _LABEL_5302_
RedOozeMonsterAction_5ADC:
	jp _LABEL_5643_

RedOozeMonsterAction_5ADF:
	call _LABEL_5655_
	ld (ix+22), <OozeTypeMonsterData_7B25
	ld (ix+23), >OozeTypeMonsterData_7B25
	ld (ix+0), <RedOozeMonsterAction_59CD
	ld (ix+1), >RedOozeMonsterAction_59CD
	ret

RedOozeMonsterAction_5AF3:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, RedOozeMonsterAction_5ADF
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	call GetRandomNumber
	cp $A0
	jr nc, RedOozeMonsterAction_5B23
	ld (ix+30), $01
	ld (ix+24), $08
	ld (ix+22), <OozeTypeMonsterData_7B2E
	ld (ix+23), >OozeTypeMonsterData_7B2E
	ld (ix+0), <RedOozeMonsterAction_5AB5
	ld (ix+1), >RedOozeMonsterAction_5AB5
	jp RedOozeMonsterAction_5AB5

RedOozeMonsterAction_5B23:
	ld (ix+24), $08
	ld (ix+0), <RedOozeMonsterAction_5A08
	ld (ix+1), >RedOozeMonsterAction_5A08
	call _LABEL_54C8_
	jp c, RedOozeMonsterAction_5A08
	ld a, SoundEffectA2
	ld (SFXQueue), a
	call _LABEL_567B_
	jp RedOozeMonsterAction_5A2D

; 29th entry of Jump Table from 2012 (indexed by unknown)
BlobMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $04
	ld (ix+26), $A0
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+0), <BlobMonsterAction_5B67
	ld (ix+1), >BlobMonsterAction_5B67
	ld (ix+22), <OozeTypeMonsterData_7B25
	ld (ix+23), >OozeTypeMonsterData_7B25
	ret

BlobMonsterAction_5B67:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, BlobMonsterAction_5B84
	cp $09
	jr z, BlobMonsterAction_5B84
	jp _LABEL_481B_

BlobMonsterAction_5B84:
	ld a, $02
	ld (ix+25), a

BlobMonsterAction_5B89:
	call _LABEL_5473_
	jr nc, BlobMonsterAction_5BB3
	ld (ix+0), <BlobMonsterAction_5C70
	ld (ix+1), >BlobMonsterAction_5C70
	jp BlobMonsterAction_5C70

BlobMonsterAction_5B99:
	ld (ix+25), $01
	ld (ix+24), $08
	ld (ix+0), <BlobMonsterAction_5BA9
	ld (ix+1), >BlobMonsterAction_5BA9

BlobMonsterAction_5BA9:
	call _LABEL_553A_
	dec (ix+24)
	jp z, BlobMonsterAction_5C42
	ret

BlobMonsterAction_5BB3:
	call _LABEL_52A1_
	ld a, (ix+4)
	rrca
	jr c, BlobMonsterAction_5BC4
	rrca
	jr c, BlobMonsterAction_5BD2
	rrca
	jr c, BlobMonsterAction_5BE0
	jr BlobMonsterAction_5BEE

BlobMonsterAction_5BC4:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, BlobMonsterAction_5BD2
	ld (ix+4), $01
	jr BlobMonsterAction_5BFA

BlobMonsterAction_5BD2:
	ld hl, $0020
	call _LABEL_5420_
	jr c, BlobMonsterAction_5BE0
	ld (ix+4), $02
	jr BlobMonsterAction_5BFA

BlobMonsterAction_5BE0:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, BlobMonsterAction_5BEE
	ld (ix+4), $04
	jr BlobMonsterAction_5BFA

BlobMonsterAction_5BEE:
	ld hl, $0001
	call _LABEL_5420_
	jr c, BlobMonsterAction_5B99
	ld (ix+4), $08
BlobMonsterAction_5BFA:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $04
	ld (ix+0), <BlobMonsterAction_5C0C
	ld (ix+1), >BlobMonsterAction_5C0C

BlobMonsterAction_5C0C:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, BlobMonsterAction_5C42
	ret

BlobMonsterAction_5C18:
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_
	ld (ix+0), <BlobMonsterAction_5C28
	ld (ix+1), >BlobMonsterAction_5C28

BlobMonsterAction_5C28:
	call _LABEL_553A_
	dec (ix+24)
	jr z, BlobMonsterAction_5C42
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, BlobMonsterAction_5C3F
	call _LABEL_5302_
BlobMonsterAction_5C3F:
	jp _LABEL_5643_

BlobMonsterAction_5C42:
	dec (ix+25)
	jr nz, BlobMonsterAction_5C5B
	call _LABEL_5655_
	ld (ix+22), <OozeTypeMonsterData_7B25
	ld (ix+23), >OozeTypeMonsterData_7B25
	ld (ix+0), <BlobMonsterAction_5B67
	ld (ix+1), >BlobMonsterAction_5B67
	ret

BlobMonsterAction_5C5B:
	ld a, (ix+7)
	ld (ix+5), a
	ld a, (ix+8)
	ld (ix+6), a
	ld (ix+0), <BlobMonsterAction_5B89
	ld (ix+1), >BlobMonsterAction_5B89
	ret

BlobMonsterAction_5C70:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, BlobMonsterAction_5C42
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld (ix+24), $08
	ld (ix+25), $01
	ld (ix+22), <OozeTypeMonsterData_7B2E
	ld (ix+23), >OozeTypeMonsterData_7B2E
	ld (ix+0), <BlobMonsterAction_5C18
	ld (ix+1), >BlobMonsterAction_5C18
	jp BlobMonsterAction_5C18

; 2nd entry of Jump Table from 2012 (indexed by unknown)
SlimetoadMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $06
	ld (ix+27), $00
	ld (ix+3), $23
	call _LABEL_569C_
	ld (ix+0), <ToadTypeMonsterAction_5CC8
	ld (ix+1), >ToadTypeMonsterAction_5CC8
	ld (ix+22), <ToadTypeMonsterData_7B37
	ld (ix+23), >ToadTypeMonsterData_7B37
	ret

ToadTypeMonsterAction_5CC8:
	call _LABEL_5567_
	ret c
	call _LABEL_1EB1_
	ret c
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, ToadTypeMonsterAction_5CE6
	cp $09
	jr z, ToadTypeMonsterAction_5CE6
	jp _LABEL_481B_

ToadTypeMonsterAction_5CE6:
	call _LABEL_5473_
	jr nc, ToadTypeMonsterAction_5D09
	ld (ix+0), <ToadTypeMonsterAction_5E3E
	ld (ix+1), >ToadTypeMonsterAction_5E3E
	jp ToadTypeMonsterAction_5E3E

ToadTypeMonsterAction_5CF6:
	ld (ix+24), $08
	ld (ix+0), <ToadTypeMonsterAction_5D02
	ld (ix+1), >ToadTypeMonsterAction_5D02

ToadTypeMonsterAction_5D02:
	dec (ix+24)
	jp z, ToadTypeMonsterAction_5E32
	ret

ToadTypeMonsterAction_5D09:
	ld a, (ix+28)
	and $01
	jr nz, ToadTypeMonsterAction_5D21
	call _LABEL_51DE_
ToadTypeMonsterAction_5D13:
	ld a, (ix+4)
	rrca
	jr c, ToadTypeMonsterAction_5D26
	rrca
	jr c, ToadTypeMonsterAction_5D46
	rrca
	jr c, ToadTypeMonsterAction_5D66
	jr ToadTypeMonsterAction_5D88

ToadTypeMonsterAction_5D21:
	call _LABEL_52A1_
	jr ToadTypeMonsterAction_5D13

ToadTypeMonsterAction_5D26:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, ToadTypeMonsterAction_5D3C
	ld (ix+4), $01
	ld (ix+22), <ToadTypeMonsterData_7B55
	ld (ix+23), >ToadTypeMonsterData_7B55
	jr ToadTypeMonsterAction_5D9D

ToadTypeMonsterAction_5D3C:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr ToadTypeMonsterAction_5D13

ToadTypeMonsterAction_5D46:
	ld hl, $0020
	call _LABEL_5420_
	jr c, ToadTypeMonsterAction_5D5C
	ld (ix+4), $02
	ld (ix+22), <ToadTypeMonsterData_7B4B
	ld (ix+23), >ToadTypeMonsterData_7B4B
	jr ToadTypeMonsterAction_5D9D

ToadTypeMonsterAction_5D5C:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr ToadTypeMonsterAction_5D13

ToadTypeMonsterAction_5D66:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, ToadTypeMonsterAction_5D7C
	ld (ix+4), $04
	ld (ix+22), <ToadTypeMonsterData_7B37
	ld (ix+23), >ToadTypeMonsterData_7B37
	jr ToadTypeMonsterAction_5D9D

ToadTypeMonsterAction_5D7C:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr ToadTypeMonsterAction_5D13

ToadTypeMonsterAction_5D88:
	ld hl, $0001
	call _LABEL_5420_
	jp c, ToadTypeMonsterAction_5CF6
	ld (ix+4), $08
	ld (ix+22), <ToadTypeMonsterData_7B41
	ld (ix+23), >ToadTypeMonsterData_7B41
ToadTypeMonsterAction_5D9D:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), <ToadTypeMonsterAction_5DAF
	ld (ix+1), >ToadTypeMonsterAction_5DAF

ToadTypeMonsterAction_5DAF:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, ToadTypeMonsterAction_5E32
	ret

ToadTypeMonsterAction_5DBB:
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_
	ld (ix+0), <ToadTypeMonsterAction_5DCB
	ld (ix+1), >ToadTypeMonsterAction_5DCB

ToadTypeMonsterAction_5DCB:
	call _LABEL_553A_
	dec (ix+24)
	jr z, ToadTypeMonsterAction_5DE5
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, ToadTypeMonsterAction_5DE2
	call _LABEL_5302_
ToadTypeMonsterAction_5DE2:
	jp _LABEL_5643_

ToadTypeMonsterAction_5DE5:
	ld a, (ix+29)
	or a
	jr nz, ToadTypeMonsterAction_5E32
	ld a, $01
	ld ($C102), a
	call _LABEL_51A5_
	jr c, ToadTypeMonsterAction_5E32
	ld a, (PoisonTicksLeft)
	or a
	jr nz, ToadTypeMonsterAction_5E32
	call GetRandomNumber
	cp $40
	jr nc, ToadTypeMonsterAction_5E32
	ld (ix+24), $10
	ld (ix+0), <ToadTypeMonsterAction_5E0E
	ld (ix+1), >ToadTypeMonsterAction_5E0E

ToadTypeMonsterAction_5E0E:
	dec (ix+24)
	ret nz
	call GetRandomNumber
	and RangePoisonTicks
	ld b, MinimumPoisonTicks
	add a, b
	ld (PoisonTicksLeft), a
	ld a, PlayerPoisonedMessage
	ld (CurrentMessage), a
	ld (ix+24), $10
	ld (ix+0), <ToadTypeMonsterAction_5E2E
	ld (ix+1), >ToadTypeMonsterAction_5E2E

ToadTypeMonsterAction_5E2E:
	dec (ix+24)
	ret nz
ToadTypeMonsterAction_5E32:
	call _LABEL_5655_
	ld (ix+0), <ToadTypeMonsterAction_5CC8
	ld (ix+1), >ToadTypeMonsterAction_5CC8
	ret

ToadTypeMonsterAction_5E3E:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, ToadTypeMonsterAction_5E32
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, ToadTypeMonsterAction_5E5B
	rrca
	jr c, ToadTypeMonsterAction_5E65
	rrca
	jr c, ToadTypeMonsterAction_5E6F
	jr ToadTypeMonsterAction_5E79

ToadTypeMonsterAction_5E5B:
	ld (ix+22), <ToadTypeMonsterData_7B5A
	ld (ix+23), >ToadTypeMonsterData_7B5A
	jr ToadTypeMonsterAction_5E81

ToadTypeMonsterAction_5E65:
	ld (ix+22), <ToadTypeMonsterData_7B50
	ld (ix+23), >ToadTypeMonsterData_7B50
	jr ToadTypeMonsterAction_5E81

ToadTypeMonsterAction_5E6F:
	ld (ix+22), <ToadTypeMonsterData_7B3C
	ld (ix+23), >ToadTypeMonsterData_7B3C
	jr ToadTypeMonsterAction_5E81

ToadTypeMonsterAction_5E79:
	ld (ix+22), <ToadTypeMonsterData_7B46
	ld (ix+23), >ToadTypeMonsterData_7B46
ToadTypeMonsterAction_5E81:
	ld (ix+24), $0A
	ld (ix+0), <ToadTypeMonsterAction_5DBB
	ld (ix+1), >ToadTypeMonsterAction_5DBB
	jp ToadTypeMonsterAction_5DBB

; 6th entry of Jump Table from 2012 (indexed by unknown)
LochtoadMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $18
	ld (ix+27), $00
	ld (ix+3), $23
	call _LABEL_569C_
	ld (ix+0), <ToadTypeMonsterAction_5CC8
	ld (ix+1), >ToadTypeMonsterAction_5CC8
	ld (ix+22), <ToadTypeMonsterData_7B37
	ld (ix+23), >ToadTypeMonsterData_7B37
	ret

; 10th entry of Jump Table from 2012 (indexed by unknown)
BloodtoadMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $34
	ld (ix+27), $00
	ld (ix+3), $23
	call _LABEL_569C_
	ld (ix+0), <ToadTypeMonsterAction_5CC8
	ld (ix+1), >ToadTypeMonsterAction_5CC8
	ld (ix+22), <ToadTypeMonsterData_7B37
	ld (ix+23), >ToadTypeMonsterData_7B37
	ret

; 3rd entry of Jump Table from 2012 (indexed by unknown)
ScorpionMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $0A
	ld (ix+27), $00
	ld (ix+3), $2F
	call _LABEL_569C_
	ld (ix+0), <ScorpionTypeMonsterAction_5F09
	ld (ix+1), >ScorpionTypeMonsterAction_5F09
	ret

ScorpionTypeMonsterAction_5F09:
	call _LABEL_5567_
	ret c
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, ScorpionTypeMonsterAction_5F23
	cp $09
	jr z, ScorpionTypeMonsterAction_5F23
	jp _LABEL_481B_

ScorpionTypeMonsterAction_5F23:
	call _LABEL_5473_
	jr nc, ScorpionTypeMonsterAction_5F46
	ld (ix+0), <ScorpionTypeMonsterAction_6069
	ld (ix+1), >ScorpionTypeMonsterAction_6069
	jp ScorpionTypeMonsterAction_6069

ScorpionTypeMonsterAction_5F33:
	ld (ix+24), $08
	ld (ix+0), <ScorpionTypeMonsterAction_5F3F
	ld (ix+1), >ScorpionTypeMonsterAction_5F3F

ScorpionTypeMonsterAction_5F3F:
	dec (ix+24)
	jp z, ScorpionTypeMonsterAction_605D
	ret

ScorpionTypeMonsterAction_5F46:
	call _LABEL_1EB1_
	jr c, ScorpionTypeMonsterAction_5F67
	call _LABEL_557D_
	jr nc, ScorpionTypeMonsterAction_5F67
	call _LABEL_55BF_
	jr c, ScorpionTypeMonsterAction_5F67
	call GetRandomNumber
	cp $80
	jr nc, ScorpionTypeMonsterAction_5F67
	ld (ix+0), <ScorpionTypeMonsterAction_6069
	ld (ix+1), >ScorpionTypeMonsterAction_6069
	jp ScorpionTypeMonsterAction_6069

ScorpionTypeMonsterAction_5F67:
	ld a, (ix+28)
	and $01
	jr nz, ScorpionTypeMonsterAction_5F7F
	call _LABEL_51DE_
ScorpionTypeMonsterAction_5F71:
	ld a, (ix+4)
	rrca
	jr c, ScorpionTypeMonsterAction_5F84
	rrca
	jr c, ScorpionTypeMonsterAction_5FA4
	rrca
	jr c, ScorpionTypeMonsterAction_5FC4
	jr ScorpionTypeMonsterAction_5FE6

ScorpionTypeMonsterAction_5F7F:
	call _LABEL_52A1_
	jr ScorpionTypeMonsterAction_5F71

ScorpionTypeMonsterAction_5F84:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, ScorpionTypeMonsterAction_5F9A
	ld (ix+4), $01
	ld (ix+22), <ScorpionTypeMonsterData_7B64
	ld (ix+23), >ScorpionTypeMonsterData_7B64
	jr ScorpionTypeMonsterAction_5FFB

ScorpionTypeMonsterAction_5F9A:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr ScorpionTypeMonsterAction_5F71

ScorpionTypeMonsterAction_5FA4:
	ld hl, $0020
	call _LABEL_5420_
	jr c, ScorpionTypeMonsterAction_5FBA
	ld (ix+4), $02
	ld (ix+22), <ScorpionTypeMonsterData_7B64
	ld (ix+23), >ScorpionTypeMonsterData_7B64
	jr ScorpionTypeMonsterAction_5FFB

ScorpionTypeMonsterAction_5FBA:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr ScorpionTypeMonsterAction_5F71

ScorpionTypeMonsterAction_5FC4:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, ScorpionTypeMonsterAction_5FDA
	ld (ix+4), $04
	ld (ix+22), <ScorpionTypeMonsterData_7B5F
	ld (ix+23), >ScorpionTypeMonsterData_7B5F
	jr ScorpionTypeMonsterAction_5FFB

ScorpionTypeMonsterAction_5FDA:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr ScorpionTypeMonsterAction_5F71

ScorpionTypeMonsterAction_5FE6:
	ld hl, $0001
	call _LABEL_5420_
	jp c, ScorpionTypeMonsterAction_5F33
	ld (ix+4), $08
	ld (ix+22), <ScorpionTypeMonsterData_7B5F
	ld (ix+23), >ScorpionTypeMonsterData_7B5F
ScorpionTypeMonsterAction_5FFB:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), <ScorpionTypeMonsterAction_600D
	ld (ix+1), >ScorpionTypeMonsterAction_600D

ScorpionTypeMonsterAction_600D:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, ScorpionTypeMonsterAction_605D
	ret

ScorpionTypeMonsterAction_6019:
	call _LABEL_553A_
	dec (ix+24)
	jr z, ScorpionTypeMonsterAction_602A
	ld a, (ix+24)
	cp $08
	call z, ScorpionTypeMonsterAction_60BB
	ret

ScorpionTypeMonsterAction_602A:
	ld (ix+24), $10
	ld (ix+0), <ScorpionTypeMonsterAction_6036
	ld (ix+1), >ScorpionTypeMonsterAction_6036

ScorpionTypeMonsterAction_6036:
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), <ScorpionTypeMonsterAction_604B
	ld (ix+1), >ScorpionTypeMonsterAction_604B
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_

ScorpionTypeMonsterAction_604B:
	dec (ix+24)
	jr z, ScorpionTypeMonsterAction_605D
	ld a, (ix+24)
	cp $01
	jr nz, ScorpionTypeMonsterAction_605A
	call _LABEL_5302_
ScorpionTypeMonsterAction_605A:
	jp _LABEL_5643_

ScorpionTypeMonsterAction_605D:
	call _LABEL_5655_
	ld (ix+0), <ScorpionTypeMonsterAction_5F09
	ld (ix+1), >ScorpionTypeMonsterAction_5F09
	ret

ScorpionTypeMonsterAction_6069:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, ScorpionTypeMonsterAction_605D
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, ScorpionTypeMonsterAction_6086
	rrca
	jr c, ScorpionTypeMonsterAction_6090
	rrca
	jr c, ScorpionTypeMonsterAction_609A
	jr ScorpionTypeMonsterAction_60A4

ScorpionTypeMonsterAction_6086:
	ld (ix+22), <ScorpionTypeMonsterData_7B69
	ld (ix+23), >ScorpionTypeMonsterData_7B69
	jr ScorpionTypeMonsterAction_60AC

ScorpionTypeMonsterAction_6090:
	ld (ix+22), <ScorpionTypeMonsterData_7B72
	ld (ix+23), >ScorpionTypeMonsterData_7B72
	jr ScorpionTypeMonsterAction_60AC

ScorpionTypeMonsterAction_609A:
	ld (ix+22), <ScorpionTypeMonsterData_7B84
	ld (ix+23), >ScorpionTypeMonsterData_7B84
	jr ScorpionTypeMonsterAction_60AC

ScorpionTypeMonsterAction_60A4:
	ld (ix+22), <ScorpionTypeMonsterData_7B7B
	ld (ix+23), >ScorpionTypeMonsterData_7B7B
ScorpionTypeMonsterAction_60AC:
	ld (ix+24), $10
	ld (ix+0), <ScorpionTypeMonsterAction_6019
	ld (ix+1), >ScorpionTypeMonsterAction_6019
	jp ScorpionTypeMonsterAction_6019

ScorpionTypeMonsterAction_60BB:
	ld hl, _LABEL_7A1C_
	ld ($C3C0), hl
	jp _LABEL_56A9_

; 15th entry of Jump Table from 2012 (indexed by unknown)
ScorpiusMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $60
	ld (ix+27), $00
	ld (ix+3), $2F
	call _LABEL_569C_
	ld (ix+0), <ScorpionTypeMonsterAction_5F09
	ld (ix+1), >ScorpionTypeMonsterAction_5F09
	ret

; 4th entry of Jump Table from 2012 (indexed by unknown)
KragMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $04
	ld (ix+26), $09
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), <KragTypeMonsterData_7B92
	ld (ix+23), >KragTypeMonsterData_7B92
	ld (ix+0), <KragTypeMonsterAction_610E
	ld (ix+1), >KragTypeMonsterAction_610E
	ret

KragTypeMonsterAction_610E:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, KragTypeMonsterAction_612B
	cp $09
	jr z, KragTypeMonsterAction_612B
	jp _LABEL_481B_

KragTypeMonsterAction_612B:
	ld (ix+25), $02
KragTypeMonsterAction_612F:
	call _LABEL_1EB1_
	jr c, KragTypeMonsterAction_6177
	call _LABEL_5473_
	jr nc, KragTypeMonsterAction_6144
	ld (ix+0), <KragTypeMonsterAction_62C9
	ld (ix+1), >KragTypeMonsterAction_62C9
	jp KragTypeMonsterAction_62C9

KragTypeMonsterAction_6144:
	call _LABEL_557D_
	jr nc, KragTypeMonsterAction_6177
	call _LABEL_55BF_
	jr c, KragTypeMonsterAction_6177
	call GetRandomNumber
	cp $80
	jr nc, KragTypeMonsterAction_6160
	ld (ix+0), <KragTypeMonsterAction_62C9
	ld (ix+1), >KragTypeMonsterAction_62C9
	jp KragTypeMonsterAction_62C9

KragTypeMonsterAction_6160:
	ld (ix+24), $08
	ld (ix+0), <KragTypeMonsterAction_616D
	ld (ix+1), >KragTypeMonsterAction_616D
	ret

KragTypeMonsterAction_616D:
	call _LABEL_553A_
	dec (ix+24)
	jp z, KragTypeMonsterAction_62BD
	ret

KragTypeMonsterAction_6177:
	ld a, (ix+28)
	and $01
	jr nz, KragTypeMonsterAction_618F
	call _LABEL_51DE_
KragTypeMonsterAction_6181:
	ld a, (ix+4)
	rrca
	jr c, KragTypeMonsterAction_6194
	rrca
	jr c, KragTypeMonsterAction_61AC
	rrca
	jr c, KragTypeMonsterAction_61C4
	jr KragTypeMonsterAction_61DE

KragTypeMonsterAction_618F:
	call _LABEL_52A1_
	jr KragTypeMonsterAction_6181

KragTypeMonsterAction_6194:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, KragTypeMonsterAction_61A2
	ld (ix+4), $01
	jr KragTypeMonsterAction_61EB

KragTypeMonsterAction_61A2:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr KragTypeMonsterAction_6181

KragTypeMonsterAction_61AC:
	ld hl, $0020
	call _LABEL_5420_
	jr c, KragTypeMonsterAction_61BA
	ld (ix+4), $02
	jr KragTypeMonsterAction_61EB

KragTypeMonsterAction_61BA:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr KragTypeMonsterAction_6181

KragTypeMonsterAction_61C4:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, KragTypeMonsterAction_61D2
	ld (ix+4), $04
	jr KragTypeMonsterAction_61EB

KragTypeMonsterAction_61D2:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr KragTypeMonsterAction_6181

KragTypeMonsterAction_61DE:
	ld hl, $0001
	call _LABEL_5420_
	jp c, KragTypeMonsterAction_6160
	ld (ix+4), $08
KragTypeMonsterAction_61EB:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $04
	ld (ix+0), <KragTypeMonsterAction_61FD
	ld (ix+1), >KragTypeMonsterAction_61FD

KragTypeMonsterAction_61FD:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, KragTypeMonsterAction_6209
	ret

KragTypeMonsterAction_6209:
	ld a, (ix+7)
	ld (ix+5), a
	ld a, (ix+8)
	ld (ix+6), a
	dec (ix+25)
	jp z, KragTypeMonsterAction_62BD
	ld (ix+0), <KragTypeMonsterAction_612F
	ld (ix+1), >KragTypeMonsterAction_612F
	ret

KragTypeMonsterAction_6224:
	call _LABEL_553A_
	dec (ix+24)
	jr z, KragTypeMonsterAction_6235
	ld a, (ix+24)
	cp $08
	call z, KragTypeMonsterAction_62EA
	ret

KragTypeMonsterAction_6235:
	ld (ix+24), $10
	ld (ix+0), <KragTypeMonsterAction_6242
	ld (ix+1), >KragTypeMonsterAction_6242
	ret

KragTypeMonsterAction_6242:
	call _LABEL_553A_
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), <KragTypeMonsterAction_625A
	ld (ix+1), >KragTypeMonsterAction_625A
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_

KragTypeMonsterAction_625A:
	call _LABEL_553A_
	dec (ix+24)
	jr z, KragTypeMonsterAction_626F
	ld a, (ix+24)
	cp $01
	jr nz, KragTypeMonsterAction_626C
	call _LABEL_5302_
KragTypeMonsterAction_626C:
	jp _LABEL_5643_

KragTypeMonsterAction_626F:
	ld a, (ix+29)
	or a
	jr nz, KragTypeMonsterAction_62BD
	ld a, $01
	ld ($C102), a
	call _LABEL_51A5_
	jr c, KragTypeMonsterAction_62BD
	ld a, (DizzinessTicksLeft)
	or a
	jr nz, KragTypeMonsterAction_62BD
	call GetRandomNumber
	cp $18
	jp nc, KragTypeMonsterAction_62BD
	ld (ix+24), $10
	ld (ix+0), <KragTypeMonsterAction_6299
	ld (ix+1), >KragTypeMonsterAction_6299

KragTypeMonsterAction_6299:
	dec (ix+24)
	ret nz
	call GetRandomNumber
	and $07
	ld b, $08
	add a, b
	ld (DizzinessTicksLeft), a
	ld a, PlayerLightheadedMessage
	ld (CurrentMessage), a
	ld (ix+24), $10
	ld (ix+0), <KragTypeMonsterAction_62B9
	ld (ix+1), >KragTypeMonsterAction_62B9

KragTypeMonsterAction_62B9:
	dec (ix+24)
	ret nz
KragTypeMonsterAction_62BD:
	call _LABEL_5655_
	ld (ix+0), <KragTypeMonsterAction_610E
	ld (ix+1), >KragTypeMonsterAction_610E
	ret

KragTypeMonsterAction_62C9:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, KragTypeMonsterAction_62BD
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld (ix+24), $10
	ld (ix+0), <KragTypeMonsterAction_6224
	ld (ix+1), >KragTypeMonsterAction_6224
	jp KragTypeMonsterAction_6224

KragTypeMonsterAction_62EA:
	ld hl, _LABEL_7A46_
	ld ($C3C0), hl
	jp _LABEL_56A9_

; 16th entry of Jump Table from 2012 (indexed by unknown)
KingKragMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $04
	ld (ix+26), $32
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), <KragTypeMonsterData_7B92
	ld (ix+23), >KragTypeMonsterData_7B92
	ld (ix+0), <KragTypeMonsterAction_610E
	ld (ix+1), >KragTypeMonsterAction_610E
	ret

; 7th entry of Jump Table from 2012 (indexed by unknown)
PhantomMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+26), $1E
	ld (ix+27), $00
	ld (ix+3), $45
	call _LABEL_569C_
	ld (ix+0), <PhantomTypeMonsterAction_6339
	ld (ix+1), >PhantomTypeMonsterAction_6339
	ret

PhantomTypeMonsterAction_6339:
	call _LABEL_5567_
	ret c
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, PhantomTypeMonsterAction_6353
	cp $09
	jr z, PhantomTypeMonsterAction_6353
	jp _LABEL_481B_

PhantomTypeMonsterAction_6353:
	call _LABEL_1EB1_
	jp c, _LABEL_481B_
	call _LABEL_557D_
	jr nc, PhantomTypeMonsterAction_636E
	call _LABEL_55BF_
	jr c, PhantomTypeMonsterAction_636E
	ld (ix+0), <PhantomTypeMonsterAction_644E
	ld (ix+1), >PhantomTypeMonsterAction_644E
	jp PhantomTypeMonsterAction_644E

PhantomTypeMonsterAction_636E:
	call GetRandomNumber
	and $03
	jr nz, PhantomTypeMonsterAction_6377
	ld a, $04
PhantomTypeMonsterAction_6377:
	ld (ix+25), a
	call _LABEL_52A1_
	ld a, (ix+4)
	rrca
	jr c, PhantomTypeMonsterAction_638B
	rrca
	jr c, PhantomTypeMonsterAction_6399
	rrca
	jr c, PhantomTypeMonsterAction_63A7
	jr PhantomTypeMonsterAction_63B5

PhantomTypeMonsterAction_638B:
	ld (ix+4), $01
	call _LABEL_538E_
	call _LABEL_5420_
	jr c, PhantomTypeMonsterAction_6399
	jr PhantomTypeMonsterAction_63C0

PhantomTypeMonsterAction_6399:
	ld (ix+4), $02
	call _LABEL_538E_
	call _LABEL_5420_
	jr c, PhantomTypeMonsterAction_63A7
	jr PhantomTypeMonsterAction_63C0

PhantomTypeMonsterAction_63A7:
	ld (ix+4), $04
	call _LABEL_538E_
	call _LABEL_5420_
	jr c, PhantomTypeMonsterAction_63B5
	jr PhantomTypeMonsterAction_63C0

PhantomTypeMonsterAction_63B5:
	ld (ix+4), $08
	call _LABEL_538E_
	call _LABEL_5420_
	ret c
PhantomTypeMonsterAction_63C0:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+22), <PhantomTypeMonsterData_7B9B
	ld (ix+23), >PhantomTypeMonsterData_7B9B
	ld (ix+0), <PhantomTypeMonsterAction_63DA
	ld (ix+1), >PhantomTypeMonsterAction_63DA

PhantomTypeMonsterAction_63DA:
	call _LABEL_553A_
	dec (ix+24)
	jr z, PhantomTypeMonsterAction_643E
	ld a, (ix+24)
	cp $04
	call z, PhantomTypeMonsterAction_63EB
	ret

PhantomTypeMonsterAction_63EB:
	ld a, (ix+7)
	ld (ix+5), a
	ld a, (ix+8)
	ld (ix+6), a
	jp _LABEL_550D_

PhantomTypeMonsterAction_63FA:
	call _LABEL_553A_
	dec (ix+24)
	jr z, PhantomTypeMonsterAction_640B
	ld a, (ix+24)
	cp $06
	call z, PhantomTypeMonsterAction_64A0
	ret

PhantomTypeMonsterAction_640B:
	ld (ix+24), $10
	ld (ix+0), <PhantomTypeMonsterAction_6417
	ld (ix+1), >PhantomTypeMonsterAction_6417

PhantomTypeMonsterAction_6417:
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), <PhantomTypeMonsterAction_642C
	ld (ix+1), >PhantomTypeMonsterAction_642C
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_

PhantomTypeMonsterAction_642C:
	dec (ix+24)
	jr z, PhantomTypeMonsterAction_643E
	ld a, (ix+24)
	cp $01
	jr nz, PhantomTypeMonsterAction_643B
	call _LABEL_5302_
PhantomTypeMonsterAction_643B:
	jp _LABEL_5643_

PhantomTypeMonsterAction_643E:
	call _LABEL_5655_
	ld (ix+25), $00
	ld (ix+0), <PhantomTypeMonsterAction_6339
	ld (ix+1), >PhantomTypeMonsterAction_6339
	ret

PhantomTypeMonsterAction_644E:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, PhantomTypeMonsterAction_643E
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, PhantomTypeMonsterAction_646B
	rrca
	jr c, PhantomTypeMonsterAction_6475
	rrca
	jr c, PhantomTypeMonsterAction_647F
	jr PhantomTypeMonsterAction_6489

PhantomTypeMonsterAction_646B:
	ld (ix+22), <PhantomTypeMonsterData_7BC1
	ld (ix+23), >PhantomTypeMonsterData_7BC1
	jr PhantomTypeMonsterAction_6491

PhantomTypeMonsterAction_6475:
	ld (ix+22), <PhantomTypeMonsterData_7BAC
	ld (ix+23), >PhantomTypeMonsterData_7BAC
	jr PhantomTypeMonsterAction_6491

PhantomTypeMonsterAction_647F:
	ld (ix+22), <PhantomTypeMonsterData_7BB3
	ld (ix+23), >PhantomTypeMonsterData_7BB3
	jr PhantomTypeMonsterAction_6491

PhantomTypeMonsterAction_6489:
	ld (ix+22), <PhantomTypeMonsterData_7BBA
	ld (ix+23), >PhantomTypeMonsterData_7BBA
PhantomTypeMonsterAction_6491:
	ld (ix+24), $0C
	ld (ix+0), <PhantomTypeMonsterAction_63FA
	ld (ix+1), >PhantomTypeMonsterAction_63FA
	jp PhantomTypeMonsterAction_63FA

PhantomTypeMonsterAction_64A0:
	ld hl, _LABEL_7A5B_
	ld ($C3C0), hl
	jp _LABEL_56A9_

; 19th entry of Jump Table from 2012 (indexed by unknown)
SpectreMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+26), $50
	ld (ix+27), $00
	ld (ix+3), $45
	call _LABEL_569C_
	ld (ix+0), <PhantomTypeMonsterAction_6339
	ld (ix+1), >PhantomTypeMonsterAction_6339
	ret

; 27th entry of Jump Table from 2012 (indexed by unknown)
WraithMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+26), $B4
	ld (ix+27), $00
	ld (ix+3), $45
	call _LABEL_569C_
	ld (ix+0), <PhantomTypeMonsterAction_6339
	ld (ix+1), >PhantomTypeMonsterAction_6339
	ret

; 8th entry of Jump Table from 2012 (indexed by unknown)
OrbMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $28
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+0), <OrbTypeMonsterAction_650E
	ld (ix+1), >OrbTypeMonsterAction_650E
	ld (ix+22), <OrbTypeMonsterData_7BD2
	ld (ix+23), >OrbTypeMonsterData_7BD2
	ret

OrbTypeMonsterAction_650E:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, OrbTypeMonsterAction_652B
	cp $09
	jr z, OrbTypeMonsterAction_652B
	jp _LABEL_481B_

OrbTypeMonsterAction_652B:
	inc (ix+25)
	ld a, (ix+25)
	cp $02
	jr nz, OrbTypeMonsterAction_6549
	ld (ix+25), $00
	call _LABEL_5473_
	jr nc, OrbTypeMonsterAction_655F
	ld (ix+0), <OrbTypeMonsterAction_66D3
	ld (ix+1), >OrbTypeMonsterAction_66D3
	jp OrbTypeMonsterAction_66D3

OrbTypeMonsterAction_6549:
	ld (ix+24), $08
	ld (ix+0), <OrbTypeMonsterAction_6555
	ld (ix+1), >OrbTypeMonsterAction_6555

OrbTypeMonsterAction_6555:
	call _LABEL_553A_
	dec (ix+24)
	jp z, OrbTypeMonsterAction_66C7
	ret

OrbTypeMonsterAction_655F:
	ld a, (ix+28)
	and $01
	jr nz, OrbTypeMonsterAction_657C
	call _LABEL_568C_
	jr nc, OrbTypeMonsterAction_657C
	call _LABEL_51DE_
OrbTypeMonsterAction_656E:
	ld a, (ix+4)
	rrca
	jr c, OrbTypeMonsterAction_6581
	rrca
	jr c, OrbTypeMonsterAction_65A1
	rrca
	jr c, OrbTypeMonsterAction_65C1
	jr OrbTypeMonsterAction_65E3

OrbTypeMonsterAction_657C:
	call _LABEL_52A1_
	jr OrbTypeMonsterAction_656E

OrbTypeMonsterAction_6581:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, OrbTypeMonsterAction_6597
	ld (ix+4), $01
	ld (ix+22), <OrbTypeMonsterData_7BC8
	ld (ix+23), >OrbTypeMonsterData_7BC8
	jr OrbTypeMonsterAction_65F8

OrbTypeMonsterAction_6597:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr OrbTypeMonsterAction_656E

OrbTypeMonsterAction_65A1:
	ld hl, $0020
	call _LABEL_5420_
	jr c, OrbTypeMonsterAction_65B7
	ld (ix+4), $02
	ld (ix+22), <OrbTypeMonsterData_7BCD
	ld (ix+23), >OrbTypeMonsterData_7BCD
	jr OrbTypeMonsterAction_65F8

OrbTypeMonsterAction_65B7:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr OrbTypeMonsterAction_656E

OrbTypeMonsterAction_65C1:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, OrbTypeMonsterAction_65D7
	ld (ix+4), $04
	ld (ix+22), <OrbTypeMonsterData_7BD2
	ld (ix+23), >OrbTypeMonsterData_7BD2
	jr OrbTypeMonsterAction_65F8

OrbTypeMonsterAction_65D7:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr OrbTypeMonsterAction_656E

OrbTypeMonsterAction_65E3:
	ld hl, $0001
	call _LABEL_5420_
	jp c, OrbTypeMonsterAction_6549
	ld (ix+4), $08
	ld (ix+22), <OrbTypeMonsterData_7BD7
	ld (ix+23), >OrbTypeMonsterData_7BD7
OrbTypeMonsterAction_65F8:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+21), $00
	ld (ix+20), $00
	ld (ix+0), <OrbTypeMonsterAction_6612
	ld (ix+1), >OrbTypeMonsterAction_6612

OrbTypeMonsterAction_6612:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jp z, OrbTypeMonsterAction_66C7
	ret

OrbTypeMonsterAction_661F:
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_
	ld (ix+0), <OrbTypeMonsterAction_662F
	ld (ix+1), >OrbTypeMonsterAction_662F

OrbTypeMonsterAction_662F:
	call _LABEL_553A_
	dec (ix+24)
	jr z, OrbTypeMonsterAction_6649
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, OrbTypeMonsterAction_6646
	call _LABEL_5302_
OrbTypeMonsterAction_6646:
	jp _LABEL_5643_

OrbTypeMonsterAction_6649:
	ld a, (ix+29)
	or a
	jr nz, OrbTypeMonsterAction_66C7
	ld a, $01
	ld ($C102), a
	ld a, (ix+31)
	cp $13
	jr z, OrbTypeMonsterAction_6661
	cp $1B
	jr z, OrbTypeMonsterAction_668C
	jr OrbTypeMonsterAction_66C7

; Rust armor
OrbTypeMonsterAction_6661:
	call RustArmor
	jr c, OrbTypeMonsterAction_66C7
	ld a, (EquippedArmor)
	cp RobeArmor
	jr z, OrbTypeMonsterAction_66C7
	ld a, RobeArmor
	ld (EquippedArmor), a
	ld (ix+24), $10
	ld (ix+0), <OrbTypeMonsterAction_667E
	ld (ix+1), >OrbTypeMonsterAction_667E

OrbTypeMonsterAction_667E:
	dec (ix+24)
	ret nz
	call EquipArmor
	ld a, ArmorRustMessage
	ld (CurrentMessage), a
	jr OrbTypeMonsterAction_66C7

; Rust weapon
OrbTypeMonsterAction_668C:
	ld a, (ix+28)
	and $08
	jr nz, OrbTypeMonsterAction_66C7
	ld a, (EquippedWeapon)
	cp DaggerSword
	jr z, OrbTypeMonsterAction_66C7
	ld a, DaggerSword
	ld (EquippedWeapon), a
	ld (ix+24), $10
	ld (ix+0), <OrbTypeMonsterAction_66AB
	ld (ix+1), >OrbTypeMonsterAction_66AB

OrbTypeMonsterAction_66AB:
	dec (ix+24)
	ret nz
	call EquipWeapon
	ld a, WeaponRustMessage
	ld (CurrentMessage), a
	ld (ix+24), $10
	ld (ix+0), <OrbTypeMonsterAction_66C3
	ld (ix+1), >OrbTypeMonsterAction_66C3

OrbTypeMonsterAction_66C3:
	dec (ix+24)
	ret nz
OrbTypeMonsterAction_66C7:
	call _LABEL_5655_
	ld (ix+0), <OrbTypeMonsterAction_650E
	ld (ix+1), >OrbTypeMonsterAction_650E
	ret

OrbTypeMonsterAction_66D3:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, OrbTypeMonsterAction_66C7
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, OrbTypeMonsterAction_66F3
	rrca
	jr c, OrbTypeMonsterAction_66FD
	rrca
	jr c, OrbTypeMonsterAction_6707
	jr OrbTypeMonsterAction_6711

OrbTypeMonsterAction_66F3:
	ld (ix+22), <OrbTypeMonsterData_7BC8
	ld (ix+23), >OrbTypeMonsterData_7BC8
	jr OrbTypeMonsterAction_6719

OrbTypeMonsterAction_66FD:
	ld (ix+22), <OrbTypeMonsterData_7BCD
	ld (ix+23), >OrbTypeMonsterData_7BCD
	jr OrbTypeMonsterAction_6719

OrbTypeMonsterAction_6707:
	ld (ix+22), <OrbTypeMonsterData_7BD2
	ld (ix+23), >OrbTypeMonsterData_7BD2
	jr OrbTypeMonsterAction_6719

OrbTypeMonsterAction_6711:
	ld (ix+22), <OrbTypeMonsterData_7BD7
	ld (ix+23), >OrbTypeMonsterData_7BD7
OrbTypeMonsterAction_6719:
	ld (ix+24), $08
	ld (ix+21), $00
	ld (ix+20), $00
	ld (ix+0), <OrbTypeMonsterAction_661F
	ld (ix+1), >OrbTypeMonsterAction_661F
	jp OrbTypeMonsterAction_661F

; 20th entry of Jump Table from 2012 (indexed by unknown)
BloodOrbMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $50
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+0), <OrbTypeMonsterAction_650E
	ld (ix+1), >OrbTypeMonsterAction_650E
	ld (ix+22), <OrbTypeMonsterData_7BD2
	ld (ix+23), >OrbTypeMonsterData_7BD2
	ret

; 28th entry of Jump Table from 2012 (indexed by unknown)
DeathOrbMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $E6
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+0), <OrbTypeMonsterAction_650E
	ld (ix+1), >OrbTypeMonsterAction_650E
	ld (ix+22), <OrbTypeMonsterData_7BD2
	ld (ix+23), >OrbTypeMonsterData_7BD2
	ret

; 11th entry of Jump Table from 2012 (indexed by unknown)
WitchMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+26), $3C
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), <WitchTypeMonsterData_7C04
	ld (ix+23), >WitchTypeMonsterData_7C04
	ld (ix+0), <WitchTypeMonsterAction_67A1
	ld (ix+1), >WitchTypeMonsterAction_67A1
	ret

WitchTypeMonsterAction_67A1:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, WitchTypeMonsterAction_67BE
	cp $09
	jr z, WitchTypeMonsterAction_67BE
	jp _LABEL_481B_

WitchTypeMonsterAction_67BE:
	call _LABEL_1EB1_
	ret c
	call _LABEL_557D_
	jr nc, WitchTypeMonsterAction_67DF
	call _LABEL_55BF_
	jr c, WitchTypeMonsterAction_67DF
	ld (ix+21), $00
	ld (ix+20), $00
	ld (ix+0), <WitchTypeMonsterAction_6974
	ld (ix+1), >WitchTypeMonsterAction_6974
	jp WitchTypeMonsterAction_6974

WitchTypeMonsterAction_67DF:
	call GetRandomNumber
	and $03
	jr nz, WitchTypeMonsterAction_67E8
	ld a, $02
WitchTypeMonsterAction_67E8:
	ld (ix+25), a
	call _LABEL_52A1_
	ld a, (ix+4)
	rrca
	jr c, WitchTypeMonsterAction_67FC
	rrca
	jr c, WitchTypeMonsterAction_680A
	rrca
	jr c, WitchTypeMonsterAction_6818
	jr WitchTypeMonsterAction_6826

WitchTypeMonsterAction_67FC:
	ld (ix+4), $01
	call _LABEL_538E_
	call _LABEL_5420_
	jr c, WitchTypeMonsterAction_680A
	jr WitchTypeMonsterAction_6831

WitchTypeMonsterAction_680A:
	ld (ix+4), $02
	call _LABEL_538E_
	call _LABEL_5420_
	jr c, WitchTypeMonsterAction_6818
	jr WitchTypeMonsterAction_6831

WitchTypeMonsterAction_6818:
	ld (ix+4), $04
	call _LABEL_538E_
	call _LABEL_5420_
	jr c, WitchTypeMonsterAction_6826
	jr WitchTypeMonsterAction_6831

WitchTypeMonsterAction_6826:
	ld (ix+4), $08
	call _LABEL_538E_
	call _LABEL_5420_
	ret c
WitchTypeMonsterAction_6831:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+22), <WitchTypeMonsterData_7BDC
	ld (ix+23), >WitchTypeMonsterData_7BDC
	ld (ix+0), <WitchTypeMonsterAction_684B
	ld (ix+1), >WitchTypeMonsterAction_684B

WitchTypeMonsterAction_684B:
	call _LABEL_553A_
	dec (ix+24)
	jp z, WitchTypeMonsterAction_6931
	ld a, (ix+24)
	cp $04
	call z, WitchTypeMonsterAction_685D
	ret

WitchTypeMonsterAction_685D:
	ld (ix+4), $00
	ld (ix+22), <WitchTypeMonsterData_7C04
	ld (ix+23), >WitchTypeMonsterData_7C04
	ld a, (ix+7)
	ld (ix+5), a
	ld a, (ix+8)
	ld (ix+6), a
	jp _LABEL_550D_

WitchTypeMonsterAction_6878:
	call _LABEL_553A_
	dec (ix+24)
	jr z, WitchTypeMonsterAction_6889
	ld a, (ix+24)
	cp $08
	call z, WitchTypeMonsterAction_69C6
	ret

WitchTypeMonsterAction_6889:
	ld (ix+24), $10
	ld (ix+0), <WitchTypeMonsterAction_6895
	ld (ix+1), >WitchTypeMonsterAction_6895

WitchTypeMonsterAction_6895:
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), <WitchTypeMonsterAction_68AA
	ld (ix+1), >WitchTypeMonsterAction_68AA
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_

WitchTypeMonsterAction_68AA:
	dec (ix+24)
	jr z, WitchTypeMonsterAction_68BC
	ld a, (ix+24)
	cp $01
	jr nz, WitchTypeMonsterAction_68B9
	call _LABEL_5302_
WitchTypeMonsterAction_68B9:
	jp _LABEL_5643_

WitchTypeMonsterAction_68BC:
	ld a, (ix+29)
	or a
	jr nz, WitchTypeMonsterAction_6931
	ld a, $01
	ld ($C102), a
	call _LABEL_51A5_
	jr c, WitchTypeMonsterAction_6931
	ld a, (DizzinessTicksLeft)
	or a
	jr nz, WitchTypeMonsterAction_6931
	ld a, (BlindnessTicksLeft)
	or a
	jr nz, WitchTypeMonsterAction_6931
	call GetRandomNumber
	cp $40
	jp nc, WitchTypeMonsterAction_6931
	ld (ix+24), $10
	ld (ix+0), <WitchTypeMonsterAction_68EC
	ld (ix+1), >WitchTypeMonsterAction_68EC

WitchTypeMonsterAction_68EC:
	dec (ix+24)
	ret nz
	call GetRandomNumber
	and $07
	ld b, $08
	add a, b
	push af
	ld a, (ix+31)
	cp $0A
	jr z, WitchTypeMonsterAction_6918
	pop af
	call _LABEL_21BF_
	ld a, $01
	ld ($C60E), a
	ld ($C606), a
	ld a, $08
	ld (BlindnessTicksLeft), a
	ld a, PlayerFogMessage
	ld (CurrentMessage), a
	jr WitchTypeMonsterAction_6921

WitchTypeMonsterAction_6918:
	pop af
	ld (DizzinessTicksLeft), a
	ld a, PlayerLightheadedMessage
	ld (CurrentMessage), a
WitchTypeMonsterAction_6921:
	ld (ix+24), $10
	ld (ix+0), <WitchTypeMonsterAction_692D
	ld (ix+1), >WitchTypeMonsterAction_692D

WitchTypeMonsterAction_692D:
	dec (ix+24)
	ret nz
WitchTypeMonsterAction_6931:
	call _LABEL_5655_
	ld (ix+25), $00
	ld (ix+0), <WitchTypeMonsterAction_67A1
	ld (ix+1), >WitchTypeMonsterAction_67A1
	ld a, (ix+4)
	rrca
	jr c, WitchTypeMonsterAction_6950
	rrca
	jr c, WitchTypeMonsterAction_6959
	rrca
	jr c, WitchTypeMonsterAction_6962
	rrca
	jr c, WitchTypeMonsterAction_696B
	ret

WitchTypeMonsterAction_6950:
	ld (ix+22), <WitchTypeMonsterData_7BFF
	ld (ix+23), >WitchTypeMonsterData_7BFF
	ret

WitchTypeMonsterAction_6959:
	ld (ix+22), <WitchTypeMonsterData_7C04
	ld (ix+23), >WitchTypeMonsterData_7C04
	ret

WitchTypeMonsterAction_6962:
	ld (ix+22), <WitchTypeMonsterData_7C09
	ld (ix+23), >WitchTypeMonsterData_7C09
	ret

WitchTypeMonsterAction_696B:
	ld (ix+22), <WitchTypeMonsterData_7C0E
	ld (ix+23), >WitchTypeMonsterData_7C0E
	ret

WitchTypeMonsterAction_6974:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, WitchTypeMonsterAction_6931
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, WitchTypeMonsterAction_6991
	rrca
	jr c, WitchTypeMonsterAction_699B
	rrca
	jr c, WitchTypeMonsterAction_69A5
	jr WitchTypeMonsterAction_69AF

WitchTypeMonsterAction_6991:
	ld (ix+22), <WitchTypeMonsterData_7BF8
	ld (ix+23), >WitchTypeMonsterData_7BF8
	jr WitchTypeMonsterAction_69B7

WitchTypeMonsterAction_699B:
	ld (ix+22), <WitchTypeMonsterData_7BE3
	ld (ix+23), >WitchTypeMonsterData_7BE3
	jr WitchTypeMonsterAction_69B7

WitchTypeMonsterAction_69A5:
	ld (ix+22), <WitchTypeMonsterData_7BEA
	ld (ix+23), >WitchTypeMonsterData_7BEA
	jr WitchTypeMonsterAction_69B7

WitchTypeMonsterAction_69AF:
	ld (ix+22), <WitchTypeMonsterData_7BF1
	ld (ix+23), >WitchTypeMonsterData_7BF1
WitchTypeMonsterAction_69B7:
	ld (ix+24), $10
	ld (ix+0), <WitchTypeMonsterAction_6878
	ld (ix+1), >WitchTypeMonsterAction_6878
	jp WitchTypeMonsterAction_6878

WitchTypeMonsterAction_69C6:
	ld hl, _LABEL_7A70_
	ld ($C3C0), hl
	jp _LABEL_56A9_

; 23rd entry of Jump Table from 2012 (indexed by unknown)
MadWitchMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+26), $A0
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), <WitchTypeMonsterData_7C04
	ld (ix+23), >WitchTypeMonsterData_7C04
	ld (ix+0), <WitchTypeMonsterAction_67A1
	ld (ix+1), >WitchTypeMonsterAction_67A1
	ret

; 12th entry of Jump Table from 2012 (indexed by unknown)
MystMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $5A
	ld (ix+27), $00
	ld (ix+28), $02
	call _LABEL_569C_
	ld (ix+22), <MystTypeMonsterData_7C13
	ld (ix+23), >MystTypeMonsterData_7C13
	ld (ix+0), <MystTypeMonsterAction_6A1D
	ld (ix+1), >MystTypeMonsterAction_6A1D
	ret

MystTypeMonsterAction_6A1D:
	call _LABEL_5567_
	ret c
	ld (ix+3), $65
	ld a, (ix+28)
	and $02
	ret nz
	ld a, (ix+31)
	cp $0B
	jr nz, MystTypeMonsterAction_6A38
	ld a, (ix+28)
	and $10
	ret z
MystTypeMonsterAction_6A38:
	ld (ix+0), <MystTypeMonsterAction_6A40
	ld (ix+1), >MystTypeMonsterAction_6A40

MystTypeMonsterAction_6A40:
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, (ix+31)
	cp $0B
	jr nz, MystTypeMonsterAction_6A5A
	ld a, (ix+28)
	and $10
	jp z, _LABEL_481B_
MystTypeMonsterAction_6A5A:
	ld a, ($C601)
	cp $01
	jr z, MystTypeMonsterAction_6A68
	cp $09
	jr z, MystTypeMonsterAction_6A68
	jp _LABEL_481B_

MystTypeMonsterAction_6A68:
	call _LABEL_5473_
	jr nc, MystTypeMonsterAction_6A8E
	ld (ix+0), <MystTypeMonsterAction_6B76
	ld (ix+1), >MystTypeMonsterAction_6B76
	jp MystTypeMonsterAction_6B76

MystTypeMonsterAction_6A78:
	ld (ix+24), $08
	ld (ix+0), <MystTypeMonsterAction_6A84
	ld (ix+1), >MystTypeMonsterAction_6A84

MystTypeMonsterAction_6A84:
	call _LABEL_553A_
	dec (ix+24)
	jp z, MystTypeMonsterAction_6B6A
	ret

MystTypeMonsterAction_6A8E:
	ld a, (ix+28)
	and $01
	jr nz, MystTypeMonsterAction_6AA6
	call _LABEL_51DE_
MystTypeMonsterAction_6A98:
	ld a, (ix+4)
	rrca
	jr c, MystTypeMonsterAction_6AAB
	rrca
	jr c, MystTypeMonsterAction_6AC3
	rrca
	jr c, MystTypeMonsterAction_6ADB
	jr MystTypeMonsterAction_6AF5

MystTypeMonsterAction_6AA6:
	call _LABEL_52A1_
	jr MystTypeMonsterAction_6A98

MystTypeMonsterAction_6AAB:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, MystTypeMonsterAction_6AB9
	ld (ix+4), $01
	jr MystTypeMonsterAction_6B02

MystTypeMonsterAction_6AB9:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr MystTypeMonsterAction_6A98

MystTypeMonsterAction_6AC3:
	ld hl, $0020
	call _LABEL_5420_
	jr c, MystTypeMonsterAction_6AD1
	ld (ix+4), $02
	jr MystTypeMonsterAction_6B02

MystTypeMonsterAction_6AD1:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr MystTypeMonsterAction_6A98

MystTypeMonsterAction_6ADB:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, MystTypeMonsterAction_6AE9
	ld (ix+4), $04
	jr MystTypeMonsterAction_6B02

MystTypeMonsterAction_6AE9:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr MystTypeMonsterAction_6A98

MystTypeMonsterAction_6AF5:
	ld hl, $0001
	call _LABEL_5420_
	jp c, MystTypeMonsterAction_6A78
	ld (ix+4), $08
MystTypeMonsterAction_6B02:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), <MystTypeMonsterAction_6B14
	ld (ix+1), >MystTypeMonsterAction_6B14

MystTypeMonsterAction_6B14:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, MystTypeMonsterAction_6B6A
	ret

MystTypeMonsterAction_6B20:
	call _LABEL_553A_
	dec (ix+24)
	jr z, MystTypeMonsterAction_6B31
	ld a, (ix+24)
	cp $08
	call z, MystTypeMonsterAction_6B97
	ret

MystTypeMonsterAction_6B31:
	ld (ix+24), $10
	ld (ix+0), <MystTypeMonsterAction_6B3D
	ld (ix+1), >MystTypeMonsterAction_6B3D

MystTypeMonsterAction_6B3D:
	call _LABEL_553A_
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), <MystTypeMonsterAction_6B55
	ld (ix+1), >MystTypeMonsterAction_6B55
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_

MystTypeMonsterAction_6B55:
	call _LABEL_553A_
	dec (ix+24)
	jr z, MystTypeMonsterAction_6B6A
	ld a, (ix+24)
	cp $01
	jr nz, MystTypeMonsterAction_6B67
	call _LABEL_5302_
MystTypeMonsterAction_6B67:
	jp _LABEL_5643_

MystTypeMonsterAction_6B6A:
	call _LABEL_5655_
	ld (ix+0), <MystTypeMonsterAction_6A40
	ld (ix+1), >MystTypeMonsterAction_6A40
	ret

MystTypeMonsterAction_6B76:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, MystTypeMonsterAction_6B6A
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld (ix+24), $10
	ld (ix+0), <MystTypeMonsterAction_6B20
	ld (ix+1), >MystTypeMonsterAction_6B20
	jp MystTypeMonsterAction_6B20

MystTypeMonsterAction_6B97:
	ld hl, _LABEL_7A8D_
	ld ($C3C0), hl
	jp _LABEL_56A9_

; 24th entry of Jump Table from 2012 (indexed by unknown)
DeathMystMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $DC
	ld (ix+27), $00
	ld (ix+28), $02
	call _LABEL_569C_
	ld (ix+22), <MystTypeMonsterData_7C13
	ld (ix+23), >MystTypeMonsterData_7C13
	ld (ix+0), <MystTypeMonsterAction_6A1D
	ld (ix+1), >MystTypeMonsterAction_6A1D
	ret

; 13th entry of Jump Table from 2012 (indexed by unknown)
DemijawMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $04
	ld (ix+26), $14
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), <DemijawMonsterData_7C18
	ld (ix+23), >DemijawMonsterData_7C18
	ld (ix+0), <DemijawMonsterAction_6BF2
	ld (ix+1), >DemijawMonsterAction_6BF2
	ret

DemijawMonsterAction_6BF2:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, DemijawMonsterAction_6C0F
	cp $09
	jr z, DemijawMonsterAction_6C0F
	jp _LABEL_481B_

DemijawMonsterAction_6C0F:
	ld (ix+25), $02
DemijawMonsterAction_6C13:
	call _LABEL_5473_
	jr nc, DemijawMonsterAction_6C39
	ld (ix+0), <DemijawMonsterAction_6D26
	ld (ix+1), >DemijawMonsterAction_6D26
	jp DemijawMonsterAction_6D26

DemijawMonsterAction_6C23:
	ld (ix+24), $08
	ld (ix+0), <DemijawMonsterAction_6C2F
	ld (ix+1), >DemijawMonsterAction_6C2F

DemijawMonsterAction_6C2F:
	call _LABEL_553A_
	dec (ix+24)
	jp z, DemijawMonsterAction_6D16
	ret

DemijawMonsterAction_6C39:
	call GetRandomNumber
	cp $80
	jr c, DemijawMonsterAction_6C4C
	ld a, (ix+28)
	and $01
	jr nz, DemijawMonsterAction_6C4C
	call _LABEL_51DE_
	jr DemijawMonsterAction_6C4F

DemijawMonsterAction_6C4C:
	call _LABEL_52A1_
DemijawMonsterAction_6C4F:
	ld a, (ix+4)
	rrca
	jr c, DemijawMonsterAction_6C5D
	rrca
	jr c, DemijawMonsterAction_6C75
	rrca
	jr c, DemijawMonsterAction_6C8D
	jr DemijawMonsterAction_6CA7

DemijawMonsterAction_6C5D:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, DemijawMonsterAction_6C6B
	ld (ix+4), $01
	jr DemijawMonsterAction_6CB4

DemijawMonsterAction_6C6B:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr DemijawMonsterAction_6C4F

DemijawMonsterAction_6C75:
	ld hl, $0020
	call _LABEL_5420_
	jr c, DemijawMonsterAction_6C83
	ld (ix+4), $02
	jr DemijawMonsterAction_6CB4

DemijawMonsterAction_6C83:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr DemijawMonsterAction_6C4F

DemijawMonsterAction_6C8D:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, DemijawMonsterAction_6C9B
	ld (ix+4), $04
	jr DemijawMonsterAction_6CB4

DemijawMonsterAction_6C9B:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr DemijawMonsterAction_6C4F

DemijawMonsterAction_6CA7:
	ld hl, $0001
	call _LABEL_5420_
	jp c, DemijawMonsterAction_6C23
	ld (ix+4), $08
DemijawMonsterAction_6CB4:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $04
	ld (ix+0), <DemijawMonsterAction_6CC6
	ld (ix+1), >DemijawMonsterAction_6CC6

DemijawMonsterAction_6CC6:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, DemijawMonsterAction_6CD2
	ret

DemijawMonsterAction_6CD2:
	ld a, (ix+7)
	ld (ix+5), a
	ld a, (ix+8)
	ld (ix+6), a
	dec (ix+25)
	jr z, DemijawMonsterAction_6D16
	ld (ix+0), <DemijawMonsterAction_6C13
	ld (ix+1), >DemijawMonsterAction_6C13
	ret

DemijawMonsterAction_6CEC:
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_
	ld (ix+0), <DemijawMonsterAction_6CFC
	ld (ix+1), >DemijawMonsterAction_6CFC

DemijawMonsterAction_6CFC:
	call _LABEL_553A_
	dec (ix+24)
	jr z, DemijawMonsterAction_6D16
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, DemijawMonsterAction_6D13
	call _LABEL_5302_
DemijawMonsterAction_6D13:
	jp _LABEL_5643_

DemijawMonsterAction_6D16:
	call _LABEL_5655_
	ld (ix+25), $00
	ld (ix+0), <DemijawMonsterAction_6BF2
	ld (ix+1), >DemijawMonsterAction_6BF2
	ret

DemijawMonsterAction_6D26:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, DemijawMonsterAction_6D16
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld (ix+24), $10
	ld (ix+0), <DemijawMonsterAction_6CEC
	ld (ix+1), >DemijawMonsterAction_6CEC
	jp DemijawMonsterAction_6CEC

; 14th entry of Jump Table from 2012 (indexed by unknown)
KrakenMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $64
	ld (ix+27), $00
	ld (ix+3), $6C
	call _LABEL_569C_
	ld (ix+0), <KrakenTypeMonsterAction_6D6A
	ld (ix+1), >KrakenTypeMonsterAction_6D6A
	ret

KrakenTypeMonsterAction_6D6A:
	call _LABEL_5567_
	ret c
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, KrakenTypeMonsterAction_6D84
	cp $09
	jr z, KrakenTypeMonsterAction_6D84
	jp _LABEL_481B_

KrakenTypeMonsterAction_6D84:
	call _LABEL_5473_
	jr nc, KrakenTypeMonsterAction_6DA7
	ld (ix+0), <KrakenTypeMonsterAction_6EF6
	ld (ix+1), >KrakenTypeMonsterAction_6EF6
	jp KrakenTypeMonsterAction_6EF6

KrakenTypeMonsterAction_6D94:
	ld (ix+24), $08
	ld (ix+0), <KrakenTypeMonsterAction_6DA0
	ld (ix+1), >KrakenTypeMonsterAction_6DA0

KrakenTypeMonsterAction_6DA0:
	dec (ix+24)
	jp z, KrakenTypeMonsterAction_6EE6
	ret

KrakenTypeMonsterAction_6DA7:
	ld a, (ix+28)
	and $01
	jr nz, KrakenTypeMonsterAction_6DC4
	call _LABEL_568C_
	jr nc, KrakenTypeMonsterAction_6DC4
	call _LABEL_51DE_
KrakenTypeMonsterAction_6DB6:
	ld a, (ix+4)
	rrca
	jr c, KrakenTypeMonsterAction_6DC9
	rrca
	jr c, KrakenTypeMonsterAction_6DEA
	rrca
	jr c, KrakenTypeMonsterAction_6E0B
	jr KrakenTypeMonsterAction_6E2E

KrakenTypeMonsterAction_6DC4:
	call _LABEL_52A1_
	jr KrakenTypeMonsterAction_6DB6

KrakenTypeMonsterAction_6DC9:
	ld hl, $FFE0
	call _LABEL_5445_
	jr c, KrakenTypeMonsterAction_6DE0
	call _LABEL_5420_
	jr c, KrakenTypeMonsterAction_6DE0
	ld (ix+4), $01
	ld (ix+3), $6F
	jr KrakenTypeMonsterAction_6E45

KrakenTypeMonsterAction_6DE0:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr KrakenTypeMonsterAction_6DB6

KrakenTypeMonsterAction_6DEA:
	ld hl, $0020
	call _LABEL_5445_
	jr c, KrakenTypeMonsterAction_6E01
	call _LABEL_5420_
	jr c, KrakenTypeMonsterAction_6E01
	ld (ix+4), $02
	ld (ix+3), $6E
	jr KrakenTypeMonsterAction_6E45

KrakenTypeMonsterAction_6E01:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr KrakenTypeMonsterAction_6DB6

KrakenTypeMonsterAction_6E0B:
	ld hl, $FFFF
	call _LABEL_5445_
	jr c, KrakenTypeMonsterAction_6E22
	call _LABEL_5420_
	jr c, KrakenTypeMonsterAction_6E22
	ld (ix+4), $04
	ld (ix+3), $6C
	jr KrakenTypeMonsterAction_6E45

KrakenTypeMonsterAction_6E22:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr KrakenTypeMonsterAction_6DB6

KrakenTypeMonsterAction_6E2E:
	ld hl, $0001
	call _LABEL_5445_
	jp c, KrakenTypeMonsterAction_6D94
	call _LABEL_5420_
	jp c, KrakenTypeMonsterAction_6D94
	ld (ix+4), $08
	ld (ix+3), $6D
KrakenTypeMonsterAction_6E45:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), <KrakenTypeMonsterAction_6E57
	ld (ix+1), >KrakenTypeMonsterAction_6E57

KrakenTypeMonsterAction_6E57:
	call _LABEL_47BB_
	dec (ix+24)
	jp z, KrakenTypeMonsterAction_6EE6
	ret

KrakenTypeMonsterAction_6E61:
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_
	ld (ix+0), <KrakenTypeMonsterAction_6E71
	ld (ix+1), >KrakenTypeMonsterAction_6E71

KrakenTypeMonsterAction_6E71:
	call _LABEL_553A_
	dec (ix+24)
	jr z, KrakenTypeMonsterAction_6E8B
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, KrakenTypeMonsterAction_6E88
	call _LABEL_5302_
KrakenTypeMonsterAction_6E88:
	jp _LABEL_5643_

KrakenTypeMonsterAction_6E8B:
	ld a, (ix+29)
	or a
	jr nz, KrakenTypeMonsterAction_6EE6
	ld a, $01
	ld ($C102), a
	ld a, (ix+28)
	and $08
	jr nz, KrakenTypeMonsterAction_6EE6
	call GetRandomNumber
	cp $80
	jr nc, KrakenTypeMonsterAction_6EE6
	ld a, (Food)
	or a
	jr z, KrakenTypeMonsterAction_6EE6
	call GetRandomNumber
	and $07
	ld b, $08
	add a, b
	daa
	ld b, a
	ld a, (Food)
	sub b
	daa
	jr c, KrakenTypeMonsterAction_6EBD
	jr KrakenTypeMonsterAction_6EBE

KrakenTypeMonsterAction_6EBD:
	xor a
KrakenTypeMonsterAction_6EBE:
	ld (Food), a
	ld (ix+24), $10
	ld (ix+0), <KrakenTypeMonsterAction_6ECD
	ld (ix+1), >KrakenTypeMonsterAction_6ECD

KrakenTypeMonsterAction_6ECD:
	dec (ix+24)
	ret nz
	ld a, FoodStolenMessage
	ld (CurrentMessage), a
	ld (ix+24), $10
	ld (ix+0), <KrakenTypeMonsterAction_6EE2
	ld (ix+1), >KrakenTypeMonsterAction_6EE2

KrakenTypeMonsterAction_6EE2:
	dec (ix+24)
	ret nz
KrakenTypeMonsterAction_6EE6:
	call _LABEL_5655_
	ld (ix+25), $00
	ld (ix+0), <KrakenTypeMonsterAction_6D6A
	ld (ix+1), >KrakenTypeMonsterAction_6D6A
	ret

KrakenTypeMonsterAction_6EF6:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, KrakenTypeMonsterAction_6EE6
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, KrakenTypeMonsterAction_6F13
	rrca
	jr c, KrakenTypeMonsterAction_6F1D
	rrca
	jr c, KrakenTypeMonsterAction_6F27
	jr KrakenTypeMonsterAction_6F31

KrakenTypeMonsterAction_6F13:
	ld (ix+22), <KrakenTypeMonsterData_7C39
	ld (ix+23), >KrakenTypeMonsterData_7C39
	jr KrakenTypeMonsterAction_6F39

KrakenTypeMonsterAction_6F1D:
	ld (ix+22), <KrakenTypeMonsterData_7C46
	ld (ix+23), >KrakenTypeMonsterData_7C46
	jr KrakenTypeMonsterAction_6F39

KrakenTypeMonsterAction_6F27:
	ld (ix+22), <KrakenTypeMonsterData_7C1F
	ld (ix+23), >KrakenTypeMonsterData_7C1F
	jr KrakenTypeMonsterAction_6F39

KrakenTypeMonsterAction_6F31:
	ld (ix+22), <KrakenTypeMonsterData_7C2C
	ld (ix+23), >KrakenTypeMonsterData_7C2C
KrakenTypeMonsterAction_6F39:
	ld (ix+24), $12
	ld (ix+0), <KrakenTypeMonsterAction_6E61
	ld (ix+1), >KrakenTypeMonsterAction_6E61
	jp KrakenTypeMonsterAction_6E61

; 30th entry of Jump Table from 2012 (indexed by unknown)
KrakosMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $FA
	ld (ix+27), $00
	ld (ix+3), $6C
	call _LABEL_569C_
	ld (ix+0), <KrakenTypeMonsterAction_6D6A
	ld (ix+1), >KrakenTypeMonsterAction_6D6A
	ret

; 17th entry of Jump Table from 2012 (indexed by unknown)
RootMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+26), $5A
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), <RootTypeMonsterData_7C53
	ld (ix+23), >RootTypeMonsterData_7C53
	ld (ix+0), <RootTypeMonsterAction_6F8E
	ld (ix+1), >RootTypeMonsterAction_6F8E
	ret

RootTypeMonsterAction_6F8E:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, RootTypeMonsterAction_6FAB
	cp $09
	jr z, RootTypeMonsterAction_6FAB
	jp _LABEL_481B_

RootTypeMonsterAction_6FAB:
	call _LABEL_1EB1_
	ret c
	call _LABEL_557D_
	ret nc
	call _LABEL_55BF_
	ret c
	call GetRandomNumber
	cp $40
	ret c
	ld (ix+0), <RootTypeMonsterAction_70B4
	ld (ix+1), >RootTypeMonsterAction_70B4
	jp RootTypeMonsterAction_70B4

RootTypeMonsterAction_6FC8:
	call _LABEL_553A_
	dec (ix+24)
	jr z, RootTypeMonsterAction_6FD9
	ld a, (ix+24)
	cp $08
	call z, RootTypeMonsterAction_70D5
	ret

RootTypeMonsterAction_6FD9:
	ld (ix+24), $10
	ld (ix+0), <RootTypeMonsterAction_6FE5
	ld (ix+1), >RootTypeMonsterAction_6FE5

RootTypeMonsterAction_6FE5:
	call _LABEL_553A_
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), <RootTypeMonsterAction_6FFD
	ld (ix+1), >RootTypeMonsterAction_6FFD
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_

RootTypeMonsterAction_6FFD:
	call _LABEL_553A_

; 5th entry of Jump Table from 1C108 (indexed by PlaySoundSlot)
UnusedSoundEngineCallback:
	dec (ix+24)
	jr z, RootTypeMonsterAction_7012
	ld a, (ix+24)
	cp $01
	jr nz, RootTypeMonsterAction_700F
	call _LABEL_5302_
RootTypeMonsterAction_700F:
	jp _LABEL_5643_

RootTypeMonsterAction_7012:
	ld a, (ix+29)
	or a
	jp nz, RootTypeMonsterAction_709E
	ld a, (ix+31)
	cp $10
	jr z, RootTypeMonsterAction_709E
	cp $18
	jr z, RootTypeMonsterAction_702B
	call GetRandomNumber
	cp $80
	jr nc, RootTypeMonsterAction_709E
RootTypeMonsterAction_702B:
	ld a, $01
	ld ($C102), a
	ld a, (ix+28)
	and $08
	jr nz, RootTypeMonsterAction_709E
	ld hl, (MaxHPLow)
	ld a, h
	or l
	jr z, RootTypeMonsterAction_709E
	call GetRandomNumber
	and $07
	ld b, $08
	push af
	ld a, (ix+31)
	cp $18
	call z, RootTypeMonsterAction_7082
	pop af
	add a, b
	ld c, a
	ld b, $00
	ld hl, (MaxHPLow)
	or a
	sbc hl, bc
	call c, RootTypeMonsterAction_7077
	ld (MaxHPLow), hl
	ld bc, (CurrentHPLow)
	or a
	sbc hl, bc
	call c, RootTypeMonsterAction_707B
	ld (ix+24), $10
	ld (ix+0), <RootTypeMonsterAction_7085
	ld (ix+1), >RootTypeMonsterAction_7085
	jr RootTypeMonsterAction_7085

RootTypeMonsterAction_7077:
	ld hl, $0000
	ret

RootTypeMonsterAction_707B:
	ld hl, (MaxHPLow)
	ld (CurrentHPLow), hl
	ret

RootTypeMonsterAction_7082:
	ld b, $0C
	ret

RootTypeMonsterAction_7085:
	dec (ix+24)
	ret nz
	ld a, PlayerStrengthDownMessage
	ld (CurrentMessage), a
	ld (ix+24), $10
	ld (ix+0), <RootTypeMonsterAction_709A
	ld (ix+1), >RootTypeMonsterAction_709A

RootTypeMonsterAction_709A:
	dec (ix+24)
	ret nz
RootTypeMonsterAction_709E:
	ld a, $01
	ld ($C102), a
	ld (ix+30), $00
	ld (ix+24), $00
	ld (ix+0), <RootTypeMonsterAction_6F8E
	ld (ix+1), >RootTypeMonsterAction_6F8E
	ret

RootTypeMonsterAction_70B4:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, RootTypeMonsterAction_709E
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld (ix+24), $10
	ld (ix+0), <RootTypeMonsterAction_6FC8
	ld (ix+1), >RootTypeMonsterAction_6FC8
	jp RootTypeMonsterAction_6FC8

RootTypeMonsterAction_70D5:
	ld hl, _LABEL_7AA2_
	ld ($C3C0), hl
	jp _LABEL_56A9_

; 21st entry of Jump Table from 2012 (indexed by unknown)
BloodRootMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+26), $5F
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), <RootTypeMonsterData_7C53
	ld (ix+23), >RootTypeMonsterData_7C53
	ld (ix+0), <RootTypeMonsterAction_6F8E
	ld (ix+1), >RootTypeMonsterAction_6F8E
	ret

; 25th entry of Jump Table from 2012 (indexed by unknown)
DeathRootMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+26), $64
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), <RootTypeMonsterData_7C53
	ld (ix+23), >RootTypeMonsterData_7C53
	ld (ix+0), <RootTypeMonsterAction_6F8E
	ld (ix+1), >RootTypeMonsterAction_6F8E
	ret

; 31st entry of Jump Table from 2012 (indexed by unknown)
DragonMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $E0
	ld (ix+27), $01
	ld (ix+3), $88
	call _LABEL_569C_
	ld (ix+0), <DragonMonsterAction_7147
	ld (ix+1), >DragonMonsterAction_7147
	ret

DragonMonsterAction_7147:
	call _LABEL_5567_
	ret c
	ld a, ($C601)
	cp $01
	jr z, DragonMonsterAction_7159
	cp $09
	jr z, DragonMonsterAction_7159
	jp _LABEL_481B_

DragonMonsterAction_7159:
	call _LABEL_1EB1_
	ret c
	call _LABEL_5473_
	jr c, DragonMonsterAction_7173
	call _LABEL_557D_
	jr nc, DragonMonsterAction_7192
	call _LABEL_55BF_
	jr c, DragonMonsterAction_7192
	call GetRandomNumber
	cp $80
	jr nc, DragonMonsterAction_7192
DragonMonsterAction_7173:
	ld (ix+0), <DragonMonsterAction_7288
	ld (ix+1), >DragonMonsterAction_7288
	jp DragonMonsterAction_7288

DragonMonsterAction_717E:
	ld (ix+24), $08
	ld (ix+0), <DragonMonsterAction_718B
	ld (ix+1), >DragonMonsterAction_718B
	ret

DragonMonsterAction_718B:
	dec (ix+24)
	jp z, DragonMonsterAction_727C
	ret

DragonMonsterAction_7192:
	call _LABEL_51DE_
DragonMonsterAction_7195:
	ld a, (ix+4)
	rrca
	jr c, DragonMonsterAction_71A3
	rrca
	jr c, DragonMonsterAction_71C3
	rrca
	jr c, DragonMonsterAction_71E3
	jr DragonMonsterAction_7205

DragonMonsterAction_71A3:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, DragonMonsterAction_71B9
	ld (ix+4), $01
	ld (ix+22), <DragonTypeMonsterData_7C62
	ld (ix+23), >DragonTypeMonsterData_7C62
	jr DragonMonsterAction_721A

DragonMonsterAction_71B9:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr DragonMonsterAction_7195

DragonMonsterAction_71C3:
	ld hl, $0020
	call _LABEL_5420_
	jr c, DragonMonsterAction_71D9
	ld (ix+4), $02
	ld (ix+22), <DragonTypeMonsterData_7C67
	ld (ix+23), >DragonTypeMonsterData_7C67
	jr DragonMonsterAction_721A

DragonMonsterAction_71D9:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr DragonMonsterAction_7195

DragonMonsterAction_71E3:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, DragonMonsterAction_71F9
	ld (ix+4), $04
	ld (ix+22), <DragonTypeMonsterData_7C58
	ld (ix+23), >DragonTypeMonsterData_7C58
	jr DragonMonsterAction_721A

DragonMonsterAction_71F9:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr DragonMonsterAction_7195

DragonMonsterAction_7205:
	ld hl, $0001
	call _LABEL_5420_
	jp c, DragonMonsterAction_717E
	ld (ix+4), $08
	ld (ix+22), <DragonTypeMonsterData_7C5D
	ld (ix+23), >DragonTypeMonsterData_7C5D
DragonMonsterAction_721A:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), <DragonMonsterAction_722C
	ld (ix+1), >DragonMonsterAction_722C

DragonMonsterAction_722C:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, DragonMonsterAction_727C
	ret

DragonMonsterAction_7238:
	call _LABEL_553A_
	dec (ix+24)
	jr z, DragonMonsterAction_7249
	ld a, (ix+24)
	cp $08
	call z, DragonMonsterAction_72DA
	ret

DragonMonsterAction_7249:
	ld (ix+24), $10
	ld (ix+0), <DragonMonsterAction_7255
	ld (ix+1), >DragonMonsterAction_7255

DragonMonsterAction_7255:
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), <DragonMonsterAction_726A
	ld (ix+1), >DragonMonsterAction_726A
	ld a, SoundEffectA4
	ld (SFXQueue), a
	call _LABEL_567B_

DragonMonsterAction_726A:
	dec (ix+24)
	jr z, DragonMonsterAction_727C
	ld a, (ix+24)
	cp $01
	jr nz, DragonMonsterAction_7279
	call _LABEL_5302_
DragonMonsterAction_7279:
	jp _LABEL_5643_

DragonMonsterAction_727C:
	call _LABEL_5655_
	ld (ix+0), <DragonMonsterAction_7147
	ld (ix+1), >DragonMonsterAction_7147
	ret

DragonMonsterAction_7288:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, DragonMonsterAction_727C
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, DragonMonsterAction_72A5
	rrca
	jr c, DragonMonsterAction_72AF
	rrca
	jr c, DragonMonsterAction_72B9
	jr DragonMonsterAction_72C3

DragonMonsterAction_72A5:
	ld (ix+22), <DragonTypeMonsterData_7C76
	ld (ix+23), >DragonTypeMonsterData_7C76
	jr DragonMonsterAction_72CB

DragonMonsterAction_72AF:
	ld (ix+22), <DragonTypeMonsterData_7C7B
	ld (ix+23), >DragonTypeMonsterData_7C7B
	jr DragonMonsterAction_72CB

DragonMonsterAction_72B9:
	ld (ix+22), <DragonTypeMonsterData_7C6C
	ld (ix+23), >DragonTypeMonsterData_7C6C
	jr DragonMonsterAction_72CB

DragonMonsterAction_72C3:
	ld (ix+22), <DragonTypeMonsterData_7C71
	ld (ix+23), >DragonTypeMonsterData_7C71
DragonMonsterAction_72CB:
	ld (ix+24), $0A
	ld (ix+0), <DragonMonsterAction_7238
	ld (ix+1), >DragonMonsterAction_7238
	jp DragonMonsterAction_7238

DragonMonsterAction_72DA:
	ld hl, _LABEL_7ABF_
	ld ($C3C0), hl
	jp _LABEL_56A9_

; 18th entry of Jump Table from 2012 (indexed by unknown)
RedSnailMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $40
	ld (ix+27), $00
	ld (ix+3), $78
	call _LABEL_569C_
	ld (ix+0), <SnailTypeMonsterAction_7306
	ld (ix+1), >SnailTypeMonsterAction_7306
	ret

SnailTypeMonsterAction_7306:
	call _LABEL_5567_
	ret c
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, SnailTypeMonsterAction_7320
	cp $09
	jr z, SnailTypeMonsterAction_7320
	jp _LABEL_481B_

SnailTypeMonsterAction_7320:
	call _LABEL_1EB1_
	jr c, SnailTypeMonsterAction_7348
	call _LABEL_5473_
	jr nc, SnailTypeMonsterAction_7348
	ld (ix+0), <SnailTypeMonsterAction_74E5
	ld (ix+1), >SnailTypeMonsterAction_74E5
	jp SnailTypeMonsterAction_74E5

SnailTypeMonsterAction_7335:
	ld (ix+24), $08
	ld (ix+0), <SnailTypeMonsterAction_7341
	ld (ix+1), >SnailTypeMonsterAction_7341

SnailTypeMonsterAction_7341:
	dec (ix+24)
	jp z, SnailTypeMonsterAction_74D9
	ret

SnailTypeMonsterAction_7348:
	ld a, (ix+28)
	and $01
	jr nz, SnailTypeMonsterAction_7360
	call _LABEL_51DE_
SnailTypeMonsterAction_7352:
	ld a, (ix+4)
	rrca
	jr c, SnailTypeMonsterAction_7365
	rrca
	jr c, SnailTypeMonsterAction_7385
	rrca
	jr c, SnailTypeMonsterAction_73A5
	jr SnailTypeMonsterAction_73C7

SnailTypeMonsterAction_7360:
	call _LABEL_52A1_
	jr SnailTypeMonsterAction_7352

SnailTypeMonsterAction_7365:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, SnailTypeMonsterAction_737B
	ld (ix+4), $01
	ld (ix+22), <SnailTypeMonsterData_7C8A
	ld (ix+23), >SnailTypeMonsterData_7C8A
	jr SnailTypeMonsterAction_73DC

SnailTypeMonsterAction_737B:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr SnailTypeMonsterAction_7352

SnailTypeMonsterAction_7385:
	ld hl, $0020
	call _LABEL_5420_
	jr c, SnailTypeMonsterAction_739B
	ld (ix+4), $02
	ld (ix+22), <SnailTypeMonsterData_7C8F
	ld (ix+23), >SnailTypeMonsterData_7C8F
	jr SnailTypeMonsterAction_73DC

SnailTypeMonsterAction_739B:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr SnailTypeMonsterAction_7352

SnailTypeMonsterAction_73A5:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, SnailTypeMonsterAction_73BB
	ld (ix+4), $04
	ld (ix+22), <SnailTypeMonsterData_7C80
	ld (ix+23), >SnailTypeMonsterData_7C80
	jr SnailTypeMonsterAction_73DC

SnailTypeMonsterAction_73BB:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr SnailTypeMonsterAction_7352

SnailTypeMonsterAction_73C7:
	ld hl, $0001
	call _LABEL_5420_
	jp c, SnailTypeMonsterAction_7335
	ld (ix+4), $08
	ld (ix+22), <SnailTypeMonsterData_7C85
	ld (ix+23), >SnailTypeMonsterData_7C85
SnailTypeMonsterAction_73DC:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), <SnailTypeMonsterAction_73EE
	ld (ix+1), >SnailTypeMonsterAction_73EE

SnailTypeMonsterAction_73EE:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jp z, SnailTypeMonsterAction_74D9
	ret

SnailTypeMonsterAction_73FB:
	call _LABEL_553A_
	dec (ix+24)
	jr z, SnailTypeMonsterAction_740C
	ld a, (ix+24)
	cp $08
	call z, SnailTypeMonsterAction_7537
	ret

SnailTypeMonsterAction_740C:
	ld (ix+0), <SnailTypeMonsterAction_7414
	ld (ix+1), >SnailTypeMonsterAction_7414

SnailTypeMonsterAction_7414:
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+24), $10
	ld (ix+0), <SnailTypeMonsterAction_742D
	ld (ix+1), >SnailTypeMonsterAction_742D
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_

SnailTypeMonsterAction_742D:
	dec (ix+24)
	jr z, SnailTypeMonsterAction_743B
	ld a, (ix+24)
	cp $01
	ret nz
	jp _LABEL_5302_

SnailTypeMonsterAction_743B:
	ld a, (ix+29)
	or a
	jp nz, SnailTypeMonsterAction_74D9
	ld a, (ix+28)
	and $08
	jp nz, SnailTypeMonsterAction_74D9
	ld a, (ix+31)
	cp $19
	jr z, SnailTypeMonsterAction_7489
	ld a, (EquippedRing)
	cp OgreRing
	jp z, SnailTypeMonsterAction_74D9
	ld a, (ix+31)
	cp $15
	jr z, SnailTypeMonsterAction_7473
	call GetRandomNumber
	cp $40
	jr nc, SnailTypeMonsterAction_74D9
	ld a, (BasePW)
	or a
	jr z, SnailTypeMonsterAction_74D9
	dec a
	ld (BasePW), a
	jr SnailTypeMonsterAction_749E

SnailTypeMonsterAction_7473:
	call GetRandomNumber
	cp $80
	jr nc, SnailTypeMonsterAction_74D9
	ld a, (BasePW)
	or a
	jr z, SnailTypeMonsterAction_74D9
	dec a
	jr z, SnailTypeMonsterAction_7484
	dec a
SnailTypeMonsterAction_7484:
	ld (BasePW), a
	jr SnailTypeMonsterAction_749E

SnailTypeMonsterAction_7489:
	call GetRandomNumber
	cp $20
	jr nc, SnailTypeMonsterAction_74D9
	ld a, (CharacterLevel)
	cp $01
	jr z, SnailTypeMonsterAction_74D9
	dec a
	ld (CharacterLevel), a
	call _LABEL_496B_
SnailTypeMonsterAction_749E:
	ld a, SoundEffectA3
	ld (SFXQueue), a
	call _LABEL_567B_
	ld (ix+24), $10
	ld (ix+0), <SnailTypeMonsterAction_74B2
	ld (ix+1), >SnailTypeMonsterAction_74B2
SnailTypeMonsterAction_74B2:
	dec (ix+24)
	ret nz
	ld a, (ix+31)
	cp $19
	jr z, SnailTypeMonsterAction_74C4
	ld a, PlayerStrengthDownMessage2
	ld (CurrentMessage), a
	jr SnailTypeMonsterAction_74C9

SnailTypeMonsterAction_74C4:
	ld a, LevelDownMessage2
	ld (CurrentMessage), a
SnailTypeMonsterAction_74C9:
	ld (ix+24), $10
	ld (ix+0), <SnailTypeMonsterAction_74D5
	ld (ix+1), >SnailTypeMonsterAction_74D5
SnailTypeMonsterAction_74D5:
	dec (ix+24)
	ret nz
SnailTypeMonsterAction_74D9:
	call _LABEL_5655_
	ld (ix+0), <SnailTypeMonsterAction_7306
	ld (ix+1), >SnailTypeMonsterAction_7306
	ret

SnailTypeMonsterAction_74E5:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, SnailTypeMonsterAction_74D9
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, SnailTypeMonsterAction_7502
	rrca
	jr c, SnailTypeMonsterAction_750C
	rrca
	jr c, SnailTypeMonsterAction_7516
	jr SnailTypeMonsterAction_7520

SnailTypeMonsterAction_7502:
	ld (ix+22), <SnailTypeMonsterData_7C8A
	ld (ix+23), >SnailTypeMonsterData_7C8A
	jr SnailTypeMonsterAction_7528

SnailTypeMonsterAction_750C:
	ld (ix+22), <SnailTypeMonsterData_7C8F
	ld (ix+23), >SnailTypeMonsterData_7C8F
	jr SnailTypeMonsterAction_7528

SnailTypeMonsterAction_7516:
	ld (ix+22), <SnailTypeMonsterData_7C80
	ld (ix+23), >SnailTypeMonsterData_7C80
	jr SnailTypeMonsterAction_7528

SnailTypeMonsterAction_7520:
	ld (ix+22), <SnailTypeMonsterData_7C85
	ld (ix+23), >SnailTypeMonsterData_7C85
SnailTypeMonsterAction_7528:
	ld (ix+24), $10
	ld (ix+0), <SnailTypeMonsterAction_73FB
	ld (ix+1), >SnailTypeMonsterAction_73FB
	jp SnailTypeMonsterAction_73FB

SnailTypeMonsterAction_7537:
	ld hl, _LABEL_7AD3_
	ld ($C3C0), hl
	ld hl, ($C10A)
	ld ($C3CA), hl
	ld hl, ($C10D)
	ld ($C3CD), hl
	ld a, (ix+4)
	ld ($C3C4), a
	ret

; 22nd entry of Jump Table from 2012 (indexed by unknown)
BlueSnailMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $4E
	ld (ix+27), $00
	ld (ix+3), $78
	call _LABEL_569C_
	ld (ix+0), <SnailTypeMonsterAction_7306
	ld (ix+1), >SnailTypeMonsterAction_7306
	ret

; 26th entry of Jump Table from 2012 (indexed by unknown)
KingSnailMonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $78
	ld (ix+27), $00
	ld (ix+3), $78
	call _LABEL_569C_
	ld (ix+0), <SnailTypeMonsterAction_7306
	ld (ix+1), >SnailTypeMonsterAction_7306
	ret

; 32nd entry of Jump Table from 2012 (indexed by unknown)
Kameleon1MonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $B4
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), <Kameleon1MonsterData_7CBD
	ld (ix+23), >Kameleon1MonsterData_7CBD
	ld (ix+0), <Kameleon1MonsterAction_75BD
	ld (ix+1), >Kameleon1MonsterAction_75BD
	ret

Kameleon1MonsterAction_75BD:
	call _LABEL_1EB1_
	jp c, _LABEL_481B_
	call _LABEL_5567_
	ret c
	ld a, ($CAC5)
	or a
	ret nz
	ld a, ($C110)
	cp (ix+16)
	ret nz
	ld a, ($C112)
	cp (ix+18)
	ret nz
	ld e, (ix+15)
	ld d, (ix+17)
	call _LABEL_1ECB_
	ex de, hl
	ld hl, Data_7A0C
	ld bc, $0204
	call _LABEL_681_
	call _LABEL_5473_
	ret nc
	ld e, (iy+15)
	ld d, (iy+17)
	call _LABEL_1ECB_
	ex de, hl
	ld l, (iy+5)
	ld h, (iy+6)
	ld bc, $0400
	add hl, bc
	ld a, (hl)
	add a, a
	add a, a
	add a, a
	ld c, a
	ld b, $00
	ld hl, $C800
	add hl, bc
	ld bc, $0204
	call _LABEL_681_
	ld (ix+0), <Kameleon1MonsterAction_761E
	ld (ix+1), >Kameleon1MonsterAction_761E
	
Kameleon1MonsterAction_761E:
	call _LABEL_1EB1_
	jp c, _LABEL_481B_
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, Kameleon1MonsterAction_7641
	cp $09
	jr z, Kameleon1MonsterAction_7641
	jp _LABEL_481B_

Kameleon1MonsterAction_7641:
	call _LABEL_5473_
	jr nc, Kameleon1MonsterAction_7667
	ld (ix+0), <Kameleon1MonsterAction_7774
	ld (ix+1), >Kameleon1MonsterAction_7774
	jp Kameleon1MonsterAction_7774

Kameleon1MonsterAction_7651:
	ld (ix+24), $08
	ld (ix+0), <Kameleon1MonsterAction_765D
	ld (ix+1), >Kameleon1MonsterAction_765D

Kameleon1MonsterAction_765D:
	call _LABEL_553A_
	dec (ix+24)
	jp z, Kameleon1MonsterAction_7768
	ret

Kameleon1MonsterAction_7667:
	ld a, (ix+28)
	and $01
	jr nz, Kameleon1MonsterAction_7680
	call _LABEL_51DE_
Kameleon1MonsterAction_7671:
	ld a, (ix+4)
	rrca
	jr c, Kameleon1MonsterAction_7685
	rrca
	jr c, Kameleon1MonsterAction_76A5
	rrca
	jr c, Kameleon1MonsterAction_76C5
	jp Kameleon1MonsterAction_76E8

Kameleon1MonsterAction_7680:
	call _LABEL_52A1_
	jr Kameleon1MonsterAction_7671

Kameleon1MonsterAction_7685:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, Kameleon1MonsterAction_769B
	ld (ix+4), $01
	ld (ix+22), <Kameleon1MonsterData_7CC6
	ld (ix+23), >Kameleon1MonsterData_7CC6
	jr Kameleon1MonsterAction_76FD

Kameleon1MonsterAction_769B:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr Kameleon1MonsterAction_7671

Kameleon1MonsterAction_76A5:
	ld hl, $0020
	call _LABEL_5420_
	jr c, Kameleon1MonsterAction_76BB
	ld (ix+4), $02
	ld (ix+22), <Kameleon1MonsterData_7CCF
	ld (ix+23), >Kameleon1MonsterData_7CCF
	jr Kameleon1MonsterAction_76FD

Kameleon1MonsterAction_76BB:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr Kameleon1MonsterAction_7671

Kameleon1MonsterAction_76C5:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, Kameleon1MonsterAction_76DB
	ld (ix+4), $04
	ld (ix+22), <Kameleon1MonsterData_7CB4
	ld (ix+23), >Kameleon1MonsterData_7CB4
	jr Kameleon1MonsterAction_76FD

Kameleon1MonsterAction_76DB:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jp Kameleon1MonsterAction_7671

Kameleon1MonsterAction_76E8:
	ld hl, $0001
	call _LABEL_5420_
	jp c, Kameleon1MonsterAction_7651
	ld (ix+22), <Kameleon1MonsterData_7CBD
	ld (ix+23), >Kameleon1MonsterData_7CBD
	ld (ix+4), $08
Kameleon1MonsterAction_76FD:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+21), $00
	ld (ix+20), $00
	ld (ix+0), <Kameleon1MonsterAction_7717
	ld (ix+1), >Kameleon1MonsterAction_7717

Kameleon1MonsterAction_7717:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, Kameleon1MonsterAction_7768
	ret

Kameleon1MonsterAction_7723:
	call _LABEL_553A_
	dec (ix+24)
	jr z, Kameleon1MonsterAction_772F
	ld a, (ix+24)
	ret

Kameleon1MonsterAction_772F:
	ld (ix+24), $10
	ld (ix+0), <Kameleon1MonsterAction_773B
	ld (ix+1), >Kameleon1MonsterAction_773B

Kameleon1MonsterAction_773B:
	call _LABEL_553A_
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), <Kameleon1MonsterAction_7753
	ld (ix+1), >Kameleon1MonsterAction_7753
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_

Kameleon1MonsterAction_7753:
	call _LABEL_553A_
	dec (ix+24)
	jr z, Kameleon1MonsterAction_7768
	ld a, (ix+24)
	cp $01
	jr nz, Kameleon1MonsterAction_7765
	call _LABEL_5302_
Kameleon1MonsterAction_7765:
	jp _LABEL_5643_

Kameleon1MonsterAction_7768:
	call _LABEL_5655_
	ld (ix+0), <Kameleon1MonsterAction_761E
	ld (ix+1), >Kameleon1MonsterAction_761E
	ret

Kameleon1MonsterAction_7774:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, Kameleon1MonsterAction_7768
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld a, (ix+4)
	rrca
	jr c, Kameleon1MonsterAction_7790
	rrca
	jr c, Kameleon1MonsterAction_779A
	rrca
	jr c, Kameleon1MonsterAction_77A4
	jr Kameleon1MonsterAction_77AE

Kameleon1MonsterAction_7790:
	ld (ix+22), <Kameleon1MonsterData_7CC6
	ld (ix+23), >Kameleon1MonsterData_7CC6
	jr Kameleon1MonsterAction_77B6

Kameleon1MonsterAction_779A:
	ld (ix+22), <Kameleon1MonsterData_7CCF
	ld (ix+23), >Kameleon1MonsterData_7CCF
	jr Kameleon1MonsterAction_77B6

Kameleon1MonsterAction_77A4:
	ld (ix+22), <Kameleon1MonsterData_7CB4
	ld (ix+23), >Kameleon1MonsterData_7CB4
	jr Kameleon1MonsterAction_77B6

Kameleon1MonsterAction_77AE:
	ld (ix+22), <Kameleon1MonsterData_7CBD
	ld (ix+23), >Kameleon1MonsterData_7CBD
Kameleon1MonsterAction_77B6:
	ld (ix+30), $01
	ld (ix+24), $10
	ld (ix+21), $00
	ld (ix+20), $00
	ld (ix+0), <Kameleon1MonsterAction_7723
	ld (ix+1), >Kameleon1MonsterAction_7723
	jp Kameleon1MonsterAction_7723

; 33rd entry of Jump Table from 2012 (indexed by unknown)
Kameleon2MonsterAction:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $82
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), <Kameleon2MonsterData_7CE1
	ld (ix+23), >Kameleon2MonsterData_7CE1
	ld (ix+0), <Kameleon2MonsterAction_77F8
	ld (ix+1), >Kameleon2MonsterAction_77F8
	ret

Kameleon2MonsterAction_77F8:
	call _LABEL_1EB1_
	jp c, _LABEL_481B_
	call _LABEL_5567_
	ret c
	ld a, ($CAC5)
	or a
	ret nz
	ld a, ($C110)
	cp (ix+16)
	ret nz
	ld a, ($C112)
	cp (ix+18)
	ret nz
	ld e, (ix+15)
	ld d, (ix+17)
	call _LABEL_1ECB_
	ex de, hl
	ld hl, Data_7A14
	ld bc, $0204
	call _LABEL_681_
	call _LABEL_5473_
	ret nc
	ld e, (iy+15)
	ld d, (iy+17)
	call _LABEL_1ECB_
	ex de, hl
	ld l, (iy+5)
	ld h, (iy+6)
	ld bc, $0400
	add hl, bc
	ld a, (hl)
	add a, a
	add a, a
	add a, a
	ld c, a
	ld b, $00
	ld hl, $C800
	add hl, bc
	ld bc, $0204
	call _LABEL_681_
	ld (ix+0), <Kameleon2MonsterAction_7859
	ld (ix+1), >Kameleon2MonsterAction_7859

Kameleon2MonsterAction_7859:
	call _LABEL_1EB1_
	jp c, _LABEL_481B_
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, Kameleon2MonsterAction_787C
	cp $09
	jr z, Kameleon2MonsterAction_787C
	jp _LABEL_481B_

Kameleon2MonsterAction_787C:
	call _LABEL_5473_
	jr nc, Kameleon2MonsterAction_78A2
	ld (ix+0), <Kameleon2MonsterAction_79AF
	ld (ix+1), >Kameleon2MonsterAction_79AF
	jp Kameleon2MonsterAction_79AF

Kameleon2MonsterAction_788C:
	ld (ix+24), $08
	ld (ix+0), <Kameleon2MonsterAction_7898
	ld (ix+1), >Kameleon2MonsterAction_7898

Kameleon2MonsterAction_7898:
	call _LABEL_553A_
	dec (ix+24)
	jp z, Kameleon2MonsterAction_79A3
	ret

Kameleon2MonsterAction_78A2:
	ld a, (ix+28)
	and $01
	jr nz, Kameleon2MonsterAction_78BB
	call _LABEL_51DE_
Kameleon2MonsterAction_78AC:
	ld a, (ix+4)
	rrca
	jr c, Kameleon2MonsterAction_78C0
	rrca
	jr c, Kameleon2MonsterAction_78E0
	rrca
	jr c, Kameleon2MonsterAction_7900
	jp Kameleon2MonsterAction_7923

Kameleon2MonsterAction_78BB:
	call _LABEL_52A1_
	jr Kameleon2MonsterAction_78AC

Kameleon2MonsterAction_78C0:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, Kameleon2MonsterAction_78D6
	ld (ix+4), $01
	ld (ix+22), <Kameleon2MonsterData_7CEA
	ld (ix+23), >Kameleon2MonsterData_7CEA
	jr Kameleon2MonsterAction_7938

Kameleon2MonsterAction_78D6:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr Kameleon2MonsterAction_78AC

Kameleon2MonsterAction_78E0:
	ld hl, $0020
	call _LABEL_5420_
	jr c, Kameleon2MonsterAction_78F6
	ld (ix+4), $02
	ld (ix+22), <Kameleon2MonsterData_7CF3
	ld (ix+23), >Kameleon2MonsterData_7CF3
	jr Kameleon2MonsterAction_7938

Kameleon2MonsterAction_78F6:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr Kameleon2MonsterAction_78AC

Kameleon2MonsterAction_7900:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, Kameleon2MonsterAction_7916
	ld (ix+4), $04
	ld (ix+22), <Kameleon2MonsterData_7CD8
	ld (ix+23), >Kameleon2MonsterData_7CD8
	jr Kameleon2MonsterAction_7938

Kameleon2MonsterAction_7916:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jp Kameleon2MonsterAction_78AC

Kameleon2MonsterAction_7923:
	ld hl, $0001
	call _LABEL_5420_
	jp c, Kameleon2MonsterAction_788C
	ld (ix+22), <Kameleon2MonsterData_7CE1
	ld (ix+23), >Kameleon2MonsterData_7CE1
	ld (ix+4), $08
Kameleon2MonsterAction_7938:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+21), $00
	ld (ix+20), $00
	ld (ix+0), <Kameleon2MonsterAction_7952
	ld (ix+1), >Kameleon2MonsterAction_7952

Kameleon2MonsterAction_7952:
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, Kameleon2MonsterAction_79A3
	ret

Kameleon2MonsterAction_795E:
	call _LABEL_553A_
	dec (ix+24)
	jr z, Kameleon2MonsterAction_796A
	ld a, (ix+24)
	ret

Kameleon2MonsterAction_796A:
	ld (ix+24), $10
	ld (ix+0), <Kameleon2MonsterAction_7976
	ld (ix+1), >Kameleon2MonsterAction_7976

Kameleon2MonsterAction_7976:
	call _LABEL_553A_
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), <Kameleon2MonsterAction_798E
	ld (ix+1), >Kameleon2MonsterAction_798E
	ld a, SoundEffectA0
	ld (SFXQueue), a
	call _LABEL_567B_
Kameleon2MonsterAction_798E:
	call _LABEL_553A_
	dec (ix+24)
	jr z, Kameleon2MonsterAction_79A3
	ld a, (ix+24)
	cp $01
	jr nz, Kameleon2MonsterAction_79A0
	call _LABEL_5302_
Kameleon2MonsterAction_79A0:
	jp _LABEL_5643_

Kameleon2MonsterAction_79A3:
	call _LABEL_5655_
	ld (ix+0), <Kameleon2MonsterAction_7859
	ld (ix+1), >Kameleon2MonsterAction_7859
	ret

Kameleon2MonsterAction_79AF:
	ld hl, (CurrentHPLow)
	ld a, h
	or l
	jr z, Kameleon2MonsterAction_79A3
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld a, (ix+4)
	rrca
	jr c, Kameleon2MonsterAction_79CB
	rrca
	jr c, Kameleon2MonsterAction_79D5
	rrca
	jr c, Kameleon2MonsterAction_79DF
	jr Kameleon2MonsterAction_79E9

Kameleon2MonsterAction_79CB:
	ld (ix+22), <Kameleon2MonsterData_7CEA
	ld (ix+23), >Kameleon2MonsterData_7CEA
	jr Kameleon2MonsterAction_79F1

Kameleon2MonsterAction_79D5:
	ld (ix+22), <Kameleon2MonsterData_7CF3
	ld (ix+23), >Kameleon2MonsterData_7CF3
	jr Kameleon2MonsterAction_79F1

Kameleon2MonsterAction_79DF:
	ld (ix+22), <Kameleon2MonsterData_7CD8
	ld (ix+23), >Kameleon2MonsterData_7CD8
	jr Kameleon2MonsterAction_79F1

Kameleon2MonsterAction_79E9:
	ld (ix+22), <Kameleon2MonsterData_7CE1
	ld (ix+23), >Kameleon2MonsterData_7CE1
Kameleon2MonsterAction_79F1:
	ld (ix+30), $01
	ld (ix+24), $10
	ld (ix+21), $00
	ld (ix+20), $00
	ld (ix+0), <Kameleon2MonsterAction_795E
	ld (ix+1), >Kameleon2MonsterAction_795E
	jp Kameleon2MonsterAction_795E

; Data from 7A0C to 7A1B (16 bytes)
Data_7A0C:
	.db $01 $01 $02 $01 $03 $01 $04 $01

Data_7A14:
	.db $0D $01 $0E $01 $0F $01 $10 $01

_LABEL_7A1C_:
	ld (ix+2), $01
	ld (ix+3), $3B
	ld (ix+19), $04
	ld (ix+0), <_LABEL_7A34_
	ld (ix+1), >_LABEL_7A34_
	ret

_LABEL_7A31_:
	call _LABEL_553A_
_LABEL_7A34_:
	call _LABEL_47BB_
	call _LABEL_52C6_
	jr c, _LABEL_7A3D_
	ret

_LABEL_7A3D_:
	ld (ix+0), <_LABEL_310F_
	ld (ix+1), >_LABEL_310F_
	ret

_LABEL_7A46_:
	ld (ix+2), $01
	ld (ix+3), $41
	ld (ix+19), $04
	ld (ix+0), <_LABEL_7A34_
	ld (ix+1), >_LABEL_7A34_
	ret

_LABEL_7A5B_:
	ld (ix+2), $01
	ld (ix+3), $4D
	ld (ix+19), $04
	ld (ix+0), <_LABEL_7A34_
	ld (ix+1), >_LABEL_7A34_
	ret

_LABEL_7A70_:
	ld (ix+2), $01
	ld (ix+3), $63
	ld (ix+19), $04
	ld (ix+22), <Data_7C94
	ld (ix+23), >Data_7C94
	ld (ix+0), <_LABEL_7A31_
	ld (ix+1), >_LABEL_7A31_
	ret

_LABEL_7A8D_:
	ld (ix+2), $01
	ld (ix+3), $68
	ld (ix+19), $04
	ld (ix+0), <_LABEL_7A34_
	ld (ix+1), >_LABEL_7A34_
	ret

_LABEL_7AA2_:
	ld (ix+2), $01
	ld (ix+3), $75
	ld (ix+19), $04
	ld (ix+22), <Data_7C99
	ld (ix+23), >Data_7C99
	ld (ix+0), <_LABEL_7A31_
	ld (ix+1), >_LABEL_7A31_
	ret

_LABEL_7ABF_:
	ld (ix+2), $01
	ld (ix+19), $04
	call _LABEL_7AF3_
	ld (ix+0), <_LABEL_7A31_
	ld (ix+1), >_LABEL_7A31_
	ret

_LABEL_7AD3_:
	ld (ix+2), $01
	ld (ix+3), $80
	ld (ix+19), $04
	ld (ix+24), $10
	ld (ix+0), <_LABEL_7AEC_
	ld (ix+1), >_LABEL_7AEC_
	ret

_LABEL_7AEC_:
	dec (ix+24)
	jp z, _LABEL_7A3D_
	ret

_LABEL_7AF3_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_7B01_
	rrca
	jr c, _LABEL_7B0A_
	rrca
	jr c, _LABEL_7B13_
	jr _LABEL_7B1C_

_LABEL_7B01_:
	ld (ix+22), <Data_7CA0
	ld (ix+23), >Data_7CA0
	ret

_LABEL_7B0A_:
	ld (ix+22), <Data_7CA5
	ld (ix+23), >Data_7CA5
	ret

_LABEL_7B13_:
	ld (ix+22), <Data_7CAA
	ld (ix+23), >Data_7CAA
	ret

_LABEL_7B1C_:
	ld (ix+22), <Data_7CAF
	ld (ix+23), >Data_7CAF
	ret

; Data from 7B25 to 7D05 (480 bytes)
.include "data\dcsms_7b25.asm"

; Empty data at the end of the bank
.ds 746, $FF

; ROM header (16 bytes)
.include "rom_header.asm"

.BANK 2
.ORG $0000

; Data from 8000 to BF5F (16224 bytes)
.incbin "data\dcsms_8000.inc"

.include "monsters\monster_encounter_table.asm"

.include "items\behavior\item_occurrence_pointer_table.asm"
.include "items\behavior\item_occurrence_table.asm"

; Unknown data
.incbin "data\dcsms_a02e.inc"

; Empty data at the end of the bank
.ds 160, $FF

.BANK 3
.ORG $0000

; 32 16x16 blocks used to compose random maps
.include "map\map_block_table.asm"

; Pointer table for item and equipment names
.include "items\names\item_name_pointer_table.asm"

; Item and equipment names
.include "items\names\item_name_data_table.asm"

; Menu for item usage	
.include "ui\equip_throw_drop.asm"

; Pointer table for in-game messages
.include "text\game_messages_pointer_table.asm"

; In-game messages
.include "text\game_messages.asm"

; Unknown data structures and corresponding pointer table
.include "data\dcsms_f12b.asm"

; Unknown data
.incbin "data\dcsms_fb5d.inc"

; Empty data at the end of the bank
.ds 160, $FF

.BANK 4
.ORG $0000

; Data from 10000 to 13F5F (16224 bytes)
.incbin "data\dcsms_10000.inc"

; Empty data at the end of the bank
.ds 160, $FF

.BANK 5
.ORG $0000

; Data from 14000 to 17F5F (16224 bytes)
.incbin "data\dcsms_14000.inc"

; Empty data at the end of the bank
.ds 160, $FF

.BANK 6
.ORG $0000

; Data from 18000 to 1BD15 (15637 bytes)
.incbin "data\dcsms_18000.inc"

; Empty data at the end of the bank
.ds 746, $FF

.BANK 7
.ORG $0000

; Sound driver- pre-SMPS with 9-byte track header
.include "sound\sound_driver.asm"

; Sound data
.incbin "sound\sound_data.inc"

; Game over screen text
.include "ui\game_over_screen_2.asm"

; Pointer table for monster names
.include "monsters\monster_name_pointer_table.asm"

; Player death messages
.include "text\player_death_messages.asm"

; Monster names
.include "monsters\monster_names.asm"

; Data from 1F009 to 1F249 (576 bytes)
; This looks like blocks, possibly the windows that pop up for item actions?
.incbin "data\dcsms_1f009.inc"

; End credits
.include "ui\credits.asm"

; Empty data at the end of the bank
.ds 1975, $FF
