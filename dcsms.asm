; Dragon Crystal Disassembly
; Disassembled with Emulicious 

; Definitions

; Random Number Generation
.define RNGSeed	$C016

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

_LABEL_0_:
	jp _LABEL_81_

; Data from 3 to 7 (5 bytes)
.db $FF $FF $FF $FF $FF

_LABEL_8_:
	di
	ld a, e
	out ($BF), a
	ld a, $40
	or d
	out ($BF), a
	ei
	ret

; Data from 13 to 27 (21 bytes)
.db $FF $FF $FF $FF $FF $F3 $7B $D3 $BF $7A $D3 $BF $FB $C9 $FF $FF
.db $FF $FF $FF $FF $FF

_LABEL_28_:
	ld a, $E2
	jp _LABEL_3B_

; Data from 2D to 2F (3 bytes)
.db $FF $FF $FF

_LABEL_30_:
	ld a, $A2
	jp _LABEL_3B_

; Data from 35 to 37 (3 bytes)
.db $FF $FF $FF

_LABEL_38_:
	jp _LABEL_1AF_

_LABEL_3B_:
	out ($BF), a
	ld a, $81
	out ($BF), a
	ret

; Data from 42 to 65 (36 bytes)
.db $26 $80 $A2 $81 $FF $82 $FF $83 $FF $84 $FF $85 $FB $86 $00 $87
.db $00 $88 $00 $89 $00 $8A $FF $FF $FF $FF $FF $FF $FF $FF $FF $FF
.db $FF $FF $FF $FF

_LABEL_66_:
	push af
	ld a, ($C019)
	cp $0A
	jr nz, _LABEL_7E_
	ld a, ($C006)
	or a
	jr nz, _LABEL_7B_
	ld a, ($C0CF)
	cpl
	ld ($C0CF), a
_LABEL_7B_:
	pop af
	retn

_LABEL_7E_:
	pop af
	retn

_LABEL_81_:
	di
	ld sp, $DFF0
	im 1
	ld hl, $FFFC
	ld (hl), $00
	inc hl
	ld (hl), $00
	inc hl
	ld (hl), $01
	inc hl
	ld (hl), $02
	ld hl, $C001
	ld de, $C002
	ld bc, $00FE
	ld (hl), $00
	ldir
_LABEL_A2_:
	in a, ($7E)
	cp $B0
	jr nz, _LABEL_A2_
	xor a
	out ($BF), a
	ld a, $C0
	out ($BF), a
	xor a
	ld b, $20
	ex (sp), hl
	ex (sp), hl
_LABEL_B4_:
	out ($BE), a
	nop
	djnz _LABEL_B4_
_LABEL_B9_:
	di
	ld sp, $DFF0
	xor a
	ld ($C005), a
	ld ($C002), a
	in a, ($BF)
	ld b, $16
	ld c, $BF
	ld hl, $0042
	otir
	ld hl, $C100
	ld de, $C101
	ld bc, $0EFF
	ld (hl), $00
	ldir
	ld hl, $DD00
	ld de, $DD01
	ld bc, $02EF
	ld (hl), $00
	ldir
	rst $30	; _LABEL_30_
	call _LABEL_771_
	call _LABEL_59D_
	ld a, $FF
	ld ($C0CF), a
	ld a, $00
	ld ($C019), a
	ld ($C018), a
	ei
	in a, ($DC)
	cpl
	and $3F
	cp $05
	jp nz, _LABEL_111_
	ld a, $01
	ld ($C0D6), a
	jp _LABEL_111_

; Data from 110 to 110 (1 bytes)
.db $C9

_LABEL_111_:
	call _LABEL_321_
	call _LABEL_4BD_
	ld hl, $0111
	push hl
	ld hl, $C018
	ld a, ($C019)
	xor (hl)
	and $7F
	ld a, (hl)
	jr z, _LABEL_12A_
	ld ($C019), a
_LABEL_12A_:
	ld hl, $017F
_LABEL_12D_:
	ld e, a
	ld d, $00
	add hl, de
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp (hl)

_LABEL_137_:
	ld a, $01
	ld ($C011), a
_LABEL_13C_:
	ld a, ($C011)
	or a
	jr nz, _LABEL_13C_
	ret

_LABEL_143_:
	ld a, ($C011)
	or a
	jr nz, _LABEL_143_
	ld a, $02
	ld ($C011), a
_LABEL_14E_:
	ld a, ($C011)
	cp $02
	jr z, _LABEL_14E_
	ret

_LABEL_156_:
	ld a, ($C011)
	or a
	jr nz, _LABEL_156_
	ld a, $04
	ld ($C011), a
_LABEL_161_:
	ld a, ($C011)
	cp $04
	jr z, _LABEL_161_
	ret

_LABEL_169_:
	ld a, $06
	ld ($C011), a
_LABEL_16E_:
	ld a, ($C011)
	or a
	jr nz, _LABEL_16E_
	ret

_LABEL_175_:
	ld hl, ($C012)
	dec hl
	ld ($C012), hl
	ld a, l
	or h
	ret

; Jump Table from 17F to 1AE (24 entries, indexed by $C018)
.dw _LABEL_BD7_ _LABEL_BD7_ _LABEL_BEA_ _LABEL_C6D_ _LABEL_EF3_ $0000 _LABEL_F4C_ _LABEL_F4C_
.dw _LABEL_1058_ _LABEL_1127_ _LABEL_11A0_ _LABEL_11DB_ _LABEL_1424_ _LABEL_1435_ _LABEL_152F_ _LABEL_16F4_
.dw _LABEL_192B_ _LABEL_1B20_ _LABEL_1CA8_ _LABEL_1CD0_ _LABEL_1D11_ _LABEL_1D4B_ _LABEL_153B_ _LABEL_1566_

_LABEL_1AF_:
	push af
	in a, ($BF)
	and $80
	jp z, _LABEL_2D1_
	ld a, ($FFFF)
	push af
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
	ld a, ($C011)
	ld hl, $01D1
	jp _LABEL_12D_

; Jump Table from 1D1 to 1E6 (11 entries, indexed by $C011)
.dw _LABEL_1E7_ _LABEL_20E_ _LABEL_22F_ _LABEL_26B_ _LABEL_275_ _LABEL_29D_ _LABEL_2AC_ _LABEL_1E7_
.dw _LABEL_1E7_ _LABEL_1E7_ _LABEL_1E7_

; 1st entry of Jump Table from 1D1 (indexed by $C011)
_LABEL_1E7_:
	ld hl, $01FA
	push hl
	ld a, $07
	ld ($FFFF), a
	ld a, ($C002)
	or a
	jp nz, _LABEL_1C3C4_
	jp _LABEL_1C000_

_LABEL_1FA_:
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

; 2nd entry of Jump Table from 1D1 (indexed by $C011)
_LABEL_20E_:
	call _LABEL_308_
	call _LABEL_2DD_
	call _LABEL_2E9_
	ld b, $00
_LABEL_219_:
	djnz _LABEL_219_
	ld a, ($C01E)
	and $01
	call nz, _LABEL_784_
	xor a
	ld ($C01E), a
	ld ($C01F), a
	ld ($C011), a
	jr _LABEL_1E7_

; 3rd entry of Jump Table from 1D1 (indexed by $C011)
_LABEL_22F_:
	call _LABEL_308_
	call _LABEL_2DD_
	call _LABEL_2E9_
	call _LABEL_2802_
	ld a, ($C01E)
	and $01
	call nz, _LABEL_784_
	call _LABEL_30CC_
	call _LABEL_28B2_
	call _LABEL_30DF_
	call _LABEL_28FD_
	xor a
	ld ($C01E), a
	ld ($C01F), a
	ld a, ($C0CF)
	or a
	jr nz, _LABEL_263_
	ld hl, $C011
	inc (hl)
	jp _LABEL_1E7_

_LABEL_263_:
	ld hl, $C011
	ld (hl), $00
	jp _LABEL_1E7_

; 4th entry of Jump Table from 1D1 (indexed by $C011)
_LABEL_26B_:
	call _LABEL_308_
	xor a
	ld ($C011), a
	jp _LABEL_1E7_

; 5th entry of Jump Table from 1D1 (indexed by $C011)
_LABEL_275_:
	ld a, $00
	out ($BF), a
	ld a, $88
	out ($BF), a
	call _LABEL_2DD_
	call _LABEL_2E9_
	ld b, $00
_LABEL_285_:
	djnz _LABEL_285_
	ld a, ($C01E)
	and $01
	call nz, _LABEL_784_
	xor a
	ld ($C01E), a
	ld ($C01F), a
	ld hl, $C011
	inc (hl)
	jp _LABEL_1E7_

; 6th entry of Jump Table from 1D1 (indexed by $C011)
_LABEL_29D_:
	ld a, $00
	out ($BF), a
	ld a, $88
	out ($BF), a
	xor a
	ld ($C011), a
	jp _LABEL_1E7_

; 7th entry of Jump Table from 1D1 (indexed by $C011)
_LABEL_2AC_:
	ld a, ($C0D2)
	out ($BF), a
	ld a, $89
	out ($BF), a
	call _LABEL_2E9_
	ld b, $00
_LABEL_2BA_:
	djnz _LABEL_2BA_
	ld a, ($C01E)
	and $01
	call nz, _LABEL_784_
	xor a
	ld ($C01E), a
	ld ($C01F), a
	ld ($C011), a
	jp _LABEL_1E7_

_LABEL_2D1_:
	ld a, ($C0B7)
	out ($BF), a
	ld a, $88
	out ($BF), a
	pop af
	ei
	ret

_LABEL_2DD_:
	ld a, ($C014)
	or a
	ret z
	dec a
	jr z, _LABEL_2E7_
	rst $28	; _LABEL_28_
	ret

_LABEL_2E7_:
	rst $30	; _LABEL_30_
	ret

_LABEL_2E9_:
	ld c, $BE
	ld a, $00
	out ($BF), a
	ld a, $7F
	out ($BF), a
	ld hl, $C500
	call OUTI64
	ld a, $80
	out ($BF), a
	ld a, $7F
	out ($BF), a
	ld hl, $C540
	call OUTI128
	ret

_LABEL_308_:
	in a, ($DD)
	cpl
	and $10
	jr z, _LABEL_31C_
	ld a, ($C004)
	or a
	ret nz
	ld a, $FF
	ld ($C004), a
	jp _LABEL_B9_

_LABEL_31C_:
	xor a
	ld ($C004), a
	ret

_LABEL_321_:
	ld a, ($C00C)
	cpl
	ld d, a
	in a, ($DC)
	cpl
	and $3F
	ld ($C00C), a
	and d
	ld ($C00D), a
	ld a, ($C006)
	or a
	ret z
	dec a
	jr z, _LABEL_33C_
	jr _LABEL_384_

_LABEL_33C_:
	ld a, ($C00D)
	and $30
	jr z, _LABEL_35C_
	xor a
	ld ($C006), a
	ld ($C007), a
	ld ($C008), a
	ld ($C009), a
	ld ($C00A), a
	call _LABEL_42C_
	ld a, $02
	ld ($C018), a
	ret

_LABEL_35C_:
	ld hl, ($C008)
	ld a, l
	or h
	jr nz, _LABEL_37C_
	xor a
	ld ($C006), a
	ld ($C007), a
	ld ($C008), a
	ld ($C009), a
	ld ($C00A), a
	call _LABEL_42C_
	ld a, $00
	ld ($C018), a
	ret

_LABEL_37C_:
	dec hl
	ld ($C008), hl
	ld a, h
	cp $02
	ret nc
_LABEL_384_:
	ld a, ($C00A)
	or a
	jr z, _LABEL_3BE_
	dec a
	ld ($C00A), a
_LABEL_38E_:
	ld a, ($C007)
	ld hl, $03DE
	ld b, $04
_LABEL_396_:
	rrca
	jr c, _LABEL_39F_
	inc hl
	inc hl
	djnz _LABEL_396_
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
	ld a, ($C007)
	ld ($C00C), a
	xor a
	ld ($C00D), a
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
	ld ($C007), a
	call GetRandomNumber
	and $1F
	add a, $10
	ld ($C00A), a
	jp _LABEL_38E_

; Data from 3DE to 3E5 (8 bytes)
.db $E0 $FF $20 $00 $FF $FF $01 $00

_LABEL_3E6_:
	ld ix, $C400
	ld b, $08
	jr _LABEL_3F4_

_LABEL_3EE_:
	ld ix, $C100
	ld b, $18
_LABEL_3F4_:
	push bc
	ld hl, $0403
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
	djnz _LABEL_3F4_
	ret

_LABEL_40C_:
	call _LABEL_750_
_LABEL_40F_:
	ld a, $01
	ld ($C0A0), a
	ld hl, $C020
	ld de, $C021
	ld bc, $001F
	ld (hl), $00
	ldir
	ld hl, $C01E
	set 0, (hl)
	ld a, $04
	ld ($C0A2), a
	ret

_LABEL_42C_:
	ld a, $02
	ld ($C0A0), a
	ld hl, $C020
	ld de, $C060
	call LDI32
	ld a, $04
	ld ($C0A2), a
	ret

; Data from 440 to 442 (3 bytes)
.db $CD $50 $07

_LABEL_443_:
	ld a, $03
	ld ($C0A0), a
	ld a, $3F
	ld ($C020), a
	ld hl, $C020
	ld de, $C021
	call LDI32
	ld hl, $C01E
	set 0, (hl)
	ld a, $04
	ld ($C0A2), a
	ret

_LABEL_461_:
	ld a, $04
	ld ($C0A0), a
	ld hl, $C020
	ld de, $C060
	call LDI32
	ld a, $04
	ld ($C0A2), a
	ret

_LABEL_475_:
	ld c, (hl)
	ld b, $00
	ex de, hl
	ld hl, $C020
	add hl, bc
	ld ($C0A4), hl
	inc de
	ld a, (de)
	ld ($C0A3), a
	dec de
	ex de, hl
	call _LABEL_750_
	ld a, $05
	ld ($C0A0), a
	ld a, ($C0A3)
	or a
	jr z, _LABEL_4DC_
	ld b, a
	ld hl, ($C0A4)
	xor a
_LABEL_49A_:
	ld (hl), a
	inc hl
	djnz _LABEL_49A_
	ld hl, $C01E
	set 0, (hl)
	ld a, $04
	ld ($C0A2), a
	ret

_LABEL_4A9_:
	ld a, $06
	ld ($C0A0), a
	ld hl, $C020
	ld de, $C060
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
	ld a, ($C0A0)
	or a
	ret z
	call _LABEL_4E4_
	ld hl, $C01E
	set 0, (hl)
	ld hl, $C0A1
	inc (hl)
	ld a, (hl)
	cp $04
	ret nz
	xor a
	ld ($C0A1), a
	ld ($C0A0), a
	ret

_LABEL_4E4_:
	ld a, ($C0A0)
	ld hl, $04ED
	jp _LABEL_12D_

; Jump Table from 4ED to 4FA (7 entries, indexed by $C0A0)
.dw $0000 _LABEL_4FB_ _LABEL_504_ _LABEL_539_ _LABEL_542_ _LABEL_580_ _LABEL_589_

; 2nd entry of Jump Table from 4ED (indexed by $C0A0)
_LABEL_4FB_:
	ld a, ($C0A1)
	ld d, a
	ld a, $03
	sub d
	jr _LABEL_507_

; 3rd entry of Jump Table from 4ED (indexed by $C0A0)
_LABEL_504_:
	ld a, ($C0A1)
_LABEL_507_:
	ld c, a
	ld de, $C060
	ld hl, $C020
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

; 4th entry of Jump Table from 4ED (indexed by $C0A0)
_LABEL_539_:
	ld a, ($C0A1)
	ld d, a
	ld a, $03
	sub d
	jr _LABEL_545_

; 5th entry of Jump Table from 4ED (indexed by $C0A0)
_LABEL_542_:
	ld a, ($C0A1)
_LABEL_545_:
	ld c, a
	ld de, $C060
	ld hl, $C020
	ld b, $20
_LABEL_54E_:
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
	djnz _LABEL_54E_
	ret

; 6th entry of Jump Table from 4ED (indexed by $C0A0)
_LABEL_580_:
	ld a, ($C0A1)
	ld d, a
	ld a, $03
	sub d
	jr _LABEL_58C_

; 7th entry of Jump Table from 4ED (indexed by $C0A0)
_LABEL_589_:
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

_LABEL_59D_:
	ld de, $0000
	ld hl, $0000
	ld bc, $0010
	call _LABEL_632_
	ld de, $2000
	ld hl, $0000
	ld bc, $0010
	call _LABEL_632_
	ld de, $3800
	ld hl, $0000
	ld bc, $0380
	call _LABEL_632_
	ld de, $3F00
	ld a, $D0
	ld bc, $0001
	call _LABEL_618_
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
	call _LABEL_618_
	ld hl, $C500
	ld (hl), $D0
	inc hl
	ld de, $C502
	ld (hl), $00
	call LDI129
	call LDI64
	ret

_LABEL_608_:
	rst $08	; _LABEL_8_
	inc b
_LABEL_60A_:
	ld a, b
	ld b, c
	ld c, $BE
_LABEL_60E_:
	outi
	jr nz, _LABEL_60E_
	ld b, a
	ld c, $00
	djnz _LABEL_60A_
	ret

_LABEL_618_:
	ex af, af'
	rst $08	; _LABEL_8_
	ex af, af'
	inc b
	push bc
	ld b, c
	jr _LABEL_623_

_LABEL_620_:
	push bc
	ld b, $00
_LABEL_623_:
	out ($BE), a
	nop
	djnz -4
	pop bc
	djnz _LABEL_620_
	ret

; Data from 62C to 631 (6 bytes)
.db $D3 $BE $00 $10 $FB $C9

_LABEL_632_:
	rst $08	; _LABEL_8_
	inc b
	ld d, c
	ld c, $BE
	push bc
	ld b, d
	jr _LABEL_63E_

_LABEL_63B_:
	push bc
	ld b, $00
_LABEL_63E_:
	ld a, l
	out (c), a
	ld a, h
	jr _LABEL_644_

_LABEL_644_:
	out (c), a
	djnz _LABEL_63E_
	pop bc
	djnz _LABEL_63B_
	ret

_LABEL_64C_:
	rst $08	; _LABEL_8_
	push bc
	ld b, c
	ld c, $BE
_LABEL_651_:
	outi
	outi
	jr nz, _LABEL_651_
	ex de, hl
	ld bc, $0040
	add hl, bc
	ex de, hl
	pop bc
	djnz _LABEL_64C_
	ret

_LABEL_661_:
	rst $08	; _LABEL_8_
	push bc
	ld b, c
	ld c, $BE
_LABEL_666_:
	outi
	nop
	jr _LABEL_66B_

_LABEL_66B_:
	outi
	nop
	jr nz, _LABEL_666_
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
	djnz _LABEL_661_
	ret

_LABEL_681_:
	ld a, c
	add a, e
	xor e
	bit 6, a
	jr z, _LABEL_661_
	ld a, c
	add a, e
	and $3F
	jr z, _LABEL_661_
	ex af, af'
	ld a, c
	add a, e
	and $3F
	neg
	add a, c
	ld c, a
_LABEL_697_:
	push bc
	push de
	rst $08	; _LABEL_8_
	ld b, c
	ld c, $BE
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
	rst $08	; _LABEL_8_
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
	djnz _LABEL_697_
	ret

; Data from 6CB to 74F (133 bytes)
.db $C5 $08 $CF $7E $D3 $BE $08 $18 $00 $D3 $BE $08 $23 $0D $20 $F3
.db $08 $EB $01 $40 $00 $09 $EB $C1 $10 $E6 $C9 $C5 $DF $41 $0E $BE
.db $ED $A2 $00 $18 $00 $ED $A2 $00 $20 $F6 $EB $01 $40 $00 $09 $7C
.db $FE $3F $38 $02 $26 $38 $EB $C1 $10 $E1 $C9 $79 $83 $AB $CB $77
.db $28 $D9 $79 $83 $E6 $3F $28 $D3 $08 $79 $83 $E6 $3F $ED $44 $81
.db $4F $C5 $D5 $DF $41 $0E $BE $ED $A2 $00 $18 $00 $ED $A2 $00 $20
.db $F6 $7B $E6 $C0 $5F $DF $08 $47 $08 $ED $A2 $00 $18 $00 $ED $A2
.db $00 $20 $F6 $D1 $EB $01 $40 $00 $09 $7C $FE $3F $38 $02 $26 $38
.db $EB $C1 $10 $CD $C9

_LABEL_750_:
	ld de, $C060
	jr _LABEL_760_

_LABEL_755_:
	ld a, ($C01E)
	or $01
	ld ($C01E), a
	ld de, $C020
_LABEL_760_:
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

_LABEL_771_:
	ld hl, $C020
	ld de, $C021
	ld bc, $001F
	ld (hl), $00
	ldir
	ld hl, $C01E
	set 0, (hl)
	ret

_LABEL_784_:
	xor a
	out ($BF), a
	ld a, $C0
	out ($BF), a
	ld hl, $C020
	ld c, $BE
	jp OUTI32

_LABEL_793_:
	ld a, (hl)
	inc hl
	exx
	ld e, a
	ld d, $00
	exx
	ld b, a
_LABEL_79B_:
	push bc
	push de
	exx
	pop hl
	push hl
	exx
	call _LABEL_7AA_
	pop de
	inc de
	pop bc
	djnz _LABEL_79B_
	ret

_LABEL_7AA_:
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
_LABEL_7B6_:
	rst $08	; _LABEL_8_
	ex (sp), hl
	ex (sp), hl
	jr _LABEL_7BB_

_LABEL_7BB_:
	ld a, (hl)
	out ($BE), a
	xor a
	or c
	jr z, _LABEL_7C3_
	inc hl
_LABEL_7C3_:
	exx
	add hl, de
	push hl
	exx
	pop de
	djnz _LABEL_7B6_
	xor a
	or c
	jp nz, _LABEL_7AA_
	inc hl
	jp _LABEL_7AA_

_LABEL_7D3_:
	ld a, (hl)
	inc hl
	exx
	ld e, a
	ld d, $00
	exx
	ld b, a
_LABEL_7DB_:
	push bc
	push de
	exx
	pop hl
	push hl
	exx
	call _LABEL_7EA_
	pop de
	inc de
	pop bc
	djnz _LABEL_7DB_
	ret

_LABEL_7EA_:
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
_LABEL_7F6_:
	ld a, (hl)
	ld (de), a
	bit 7, c
	jr z, _LABEL_7FD_
	inc hl
_LABEL_7FD_:
	exx
	add hl, de
	push hl
	exx
	pop de
	djnz _LABEL_7F6_
	bit 7, c
	jp nz, _LABEL_7EA_
	inc hl
	jp _LABEL_7EA_

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
	rst $08	; _LABEL_8_
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl
_LABEL_820_:
	ld a, (hl)
	exx
	ld c, $BE
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

; Unrolled loop
OUTI256:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
OUTI128:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
OUTI80:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
OUTI64:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
OUTI32:
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
	outi
OUTI22:
	outi
	outi
	outi
	outi
	outi
	outi
OUTI16:
	outi
	outi
	outi
	outi
	outi
	outi
OUTI10:
	outi
	outi
OUTI8:
	outi
	outi
OUTI6:
	outi
	outi
OUTI4:
	outi
	outi
	outi
	outi
	ret

; Unrolled loop
LDI129:
	ldi
LDI128:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
LDI112:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
LDI88:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
LDI80:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
LDI64:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
LDI36:
	ldi
	ldi
	ldi
	ldi
LDI32:
	ldi
LDI31:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
LDI16:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
LDI8:
	ldi
	ldi
LDI6:
	ldi
LDI5:
	ldi
	ldi
	ldi
	ldi
	ldi
	ret

; Data from B3E to B7A (61 bytes)
.db $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8
.db $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8
.db $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8
.db $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $ED $A8 $C9

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
	jr nz, _LABEL_B92_
	ld hl, $733C
_LABEL_B92_:
	ld a, r
	xor l
	ld (RNGSeed), hl
	pop hl
	ret

_LABEL_B9A_:
	ld a, ($C0A0)
	or a
	ret z
	pop hl
	jp _LABEL_137_

_LABEL_BA3_:
	call _LABEL_771_
	ld a, $01
	ld ($C014), a
	call _LABEL_137_
	di
	jp _LABEL_59D_

; Data from BB2 to BC7 (22 bytes)
.db $3E $0F $11 $00 $2B $21 $D8 $80 $C3 $14 $08 $3E $0F $11 $00 $30
.db $21 $86 $80 $C3 $14 $08

_LABEL_BC8_:
	xor a
	out ($BF), a
	ld a, $88
	out ($BF), a
	xor a
	out ($BF), a
	ld a, $89
	out ($BF), a
	ret

; 1st entry of Jump Table from 17F (indexed by $C018)
_LABEL_BD7_:
	call _LABEL_B9A_
	ld a, $26
	out ($BF), a
	ld a, $80
	out ($BF), a
	ld a, $02
	ld ($C018), a
	jp _LABEL_137_

; 3rd entry of Jump Table from 17F (indexed by $C018)
_LABEL_BEA_:
	call _LABEL_B9A_
	ld a, $07
	ld ($FFFF), a
	call _LABEL_1C3B1_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_BA3_
	call _LABEL_5DE_
	call _LABEL_BC8_
	ld a, $06
	ld ($FFFF), a
	ld hl, $8B6E
	ld de, $2000
	call _LABEL_793_
	ld hl, $99B4
	ld de, $0000
	call _LABEL_793_
	ld hl, $8934
	ld de, $3500
	call _LABEL_793_
	ld hl, $878D
	ld de, $1A00
	call _LABEL_793_
	ld hl, $80D6
	ld de, $CB00
	call _LABEL_7D3_
	ld hl, $CB00
	ld de, $3886
	ld bc, $0A36
	call _LABEL_64C_
	ld hl, $81E6
	ld de, $3A98
	ld bc, $0A10
	call _LABEL_64C_
	ld hl, $0D0C
	ld ($C100), hl
	ld hl, $8000
	call _LABEL_755_
	ld a, $02
	ld ($C014), a
	ei
	ld hl, $0384
	ld ($C012), hl
	ld a, $03
	ld ($C018), a
	jp _LABEL_137_

; 4th entry of Jump Table from 17F (indexed by $C018)
_LABEL_C6D_:
	call _LABEL_137_
	ld a, ($C00D)
	and $30
	jr z, _LABEL_CF5_
	ld a, ($C00C)
	and $0F
	cp $0A
	jr z, _LABEL_C8F_
_LABEL_C80_:
	xor a
	ld ($C0D6), a
	call _LABEL_42C_
	ld a, $06
	ld ($C018), a
	jp _LABEL_137_

_LABEL_C8F_:
	ld a, ($C0D6)
	or a
	jr z, _LABEL_C80_
	xor a
	ld ($C0D6), a
	ld a, $01
	ld ($C01C), a
	ld a, $01
	ld ($C61F), a
	ld a, $30
	ld ($C620), a
	ld hl, $03E7
	ld ($C621), hl
	ld ($C623), hl
	ld hl, $FFFF
	ld ($C628), hl
	xor a
	ld ($C62A), a
	ld ($C625), a
	ld ($C626), a
	ld ($C627), a
	ld ($C62B), a
	ld ($C62C), a
	ld ($C62D), a
	ld a, $1E
	ld ($C62F), a
	ld ($C630), a
	ld a, $01
	ld ($C900), a
	ld a, $10
	ld ($C908), a
	call _LABEL_101A_
	ld a, $07
	ld ($FFFF), a
	call _LABEL_1C3B1_
	call _LABEL_461_
	ld a, $0D
	ld ($C018), a
	jp _LABEL_137_

_LABEL_CF5_:
	call _LABEL_3EE_
	call _LABEL_1D60_
	call _LABEL_175_
	jp nz, _LABEL_137_
	call _LABEL_42C_
	ld a, $04
	ld ($C018), a
	jp _LABEL_137_

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
	ld (ix+22), $E0
	ld (ix+23), $0E
	ld (ix+0), $3A
	ld (ix+1), $0D
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
	ld (ix+0), $81
	ld (ix+1), $0D
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
	call _LABEL_793_
	ld (ix+2), $01
	ld (ix+3), $BD
	ld (ix+15), $00
	ld (ix+17), $80
	ld (ix+28), $00
	ld (ix+29), $02
	ld (ix+0), $C1
	ld (ix+1), $0D
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
	ld (ix+0), $01
	ld (ix+1), $0E
	ld (ix+21), $20
	ld (ix+0), $01
	ld (ix+1), $0E
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
	ld (ix+22), $E8
	ld (ix+23), $0E
	ld (ix+0), $29
	ld (ix+1), $0E
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
	ld a, $81
	ld ($DD04), a
	ld a, $40
	ld (ix+21), a
	ld (ix+0), $66
	ld (ix+1), $0E
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
	ld (ix+0), $8A
	ld (ix+1), $0E
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
	ld (ix+0), $A9
	ld (ix+1), $0E
	ret

_LABEL_EA9_:
	ld a, ($C0A0)
	or a
	ret nz
	ld a, $06
	ld ($FFFF), a
	ld hl, $8096
	ld de, $3D52
	ld bc, $0220
	call _LABEL_64C_
	ld (ix+0), $C8
	ld (ix+1), $0E
	ret

_LABEL_EC8_:
	inc (ix+24)
	bit 3, (ix+24)
	ld hl, $0000
	jr z, _LABEL_ED7_
	ld hl, $0F29
_LABEL_ED7_:
	ld ($C03E), hl
	ld hl, $C01E
	set 0, (hl)
	ret

; Data from EE0 to EF2 (19 bytes)
.db $B9 $BA $BB $BC $BB $BA $B9 $00 $C1 $C0 $BF $BE $BF $C0 $C1 $C2
.db $C1 $C2 $C1

; 5th entry of Jump Table from 17F (indexed by $C018)
_LABEL_EF3_:
	ld a, $01
	ld ($C006), a
	ld hl, $0210
	ld ($C008), hl
	ld a, $01
	ld ($C61F), a
	ld a, $30
	ld ($C620), a
	ld hl, $0064
	ld ($C621), hl
	ld ($C623), hl
	ld hl, $FFFF
	ld ($C628), hl
	xor a
	ld ($C62A), a
	ld ($C625), a
	ld ($C626), a
	ld ($C627), a
	ld ($C62B), a
	ld ($C62C), a
	ld ($C62D), a
	ld a, $0A
	ld ($C62F), a
	ld ($C630), a
	ld a, $01
	ld ($C01C), a
	ld a, $01
	ld ($C900), a
	ld a, $10
	ld ($C908), a
	ld a, $08
	ld ($C018), a
	jp _LABEL_137_

; 7th entry of Jump Table from 17F (indexed by $C018)
_LABEL_F4C_:
	call _LABEL_B9A_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_BA3_
	call _LABEL_5DE_
	ld a, $FB
	out ($BF), a
	ld a, $86
	out ($BF), a
	ld hl, $C400
	ld de, $C401
	ld bc, $00FF
	ld (hl), $00
	ldir
	ld a, $01
	ld hl, $C935
	ld b, $10
_LABEL_F76_:
	ld (hl), a
	inc a
	inc hl
	djnz _LABEL_F76_
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
	ld ($C61F), a
	ld a, $01
	ld ($C01C), a
	ld a, $30
	ld ($C620), a
	ld hl, $0064
	ld ($C621), hl
	ld ($C623), hl
	ld hl, $0014
	ld ($C628), hl
	xor a
	ld ($C62A), a
	ld ($C625), a
	ld ($C626), a
	ld ($C627), a
	ld ($C62B), a
	ld ($C62C), a
	ld ($C62D), a
	ld ($C62F), a
	ld ($C630), a
	ld a, $01
	ld ($C900), a
	ld a, $10
	ld ($C908), a
	call _LABEL_101A_
	call _LABEL_42C_
	ld a, $08
	ld ($C018), a
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
	ld hl, $C900
	res 7, (hl)
	inc hl
	ld de, $C902
	ld (hl), $00
	call LDI6
	ld a, ($C900)
	cp $0E
	jr nz, _LABEL_1034_
	ld a, $03
	ld ($C901), a
_LABEL_1034_:
	ld hl, $C908
	res 7, (hl)
	inc hl
	ld de, $C90A
	ld (hl), $00
	call LDI6
	ld hl, $C910
	ld de, $C911
	ld (hl), $00
	call LDI36
	jp _LABEL_48F0_

; Data from 1050 to 1057 (8 bytes)
.db $61 $11 $66 $11 $61 $11 $6C $11

; 9th entry of Jump Table from 17F (indexed by $C018)
_LABEL_1058_:
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
	call _LABEL_793_
	ld a, ($C01C)
	dec a
	jr z, _LABEL_108F_
	call GetRandomNumber
	and $03
_LABEL_108F_:
	ld ($C01D), a
	call _LABEL_2A22_
	call _LABEL_2941_
	call _LABEL_2492_
	call _LABEL_263B_
	call _LABEL_1F8F_
	call _LABEL_1FB8_
	call _LABEL_20BA_
	ld hl, ($C105)
	ld de, $2D00
	add hl, de
	call _LABEL_2DFA_
	ld hl, $311A
	ld ($C100), hl
	ld hl, $3CE6
	ld ($C120), hl
	ld hl, $C631
	ld de, $C632
	ld (hl), $00
	call LDI5
	ld hl, $8064
	call _LABEL_750_
	call _LABEL_27E3_
	call _LABEL_2756_
	ld a, $04
	ld ($FFFF), a
	ld hl, $8000
	call _LABEL_750_
	ld a, ($C900)
	dec a
	and $0C
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, $1123
	add hl, de
	ld de, $C077
	ldi
	call _LABEL_40F_
	ld a, $02
	ld ($C014), a
	ld a, ($C01C)
	ld d, $84
	cp $0B
	jr c, _LABEL_110A_
	inc d
	cp $15
	jr c, _LABEL_110A_
	inc d
_LABEL_110A_:
	ld a, d
	ld ($DD04), a
	xor a
	ld ($CAC4), a
	ld ($CAC5), a
	ld a, $3C
	ld ($CAC8), a
	ei
	ld a, $0A
	ld ($C018), a
	jp _LABEL_143_

; Data from 1123 to 1126 (4 bytes)
.db $0C $03 $30 $33

; 10th entry of Jump Table from 17F (indexed by $C018)
_LABEL_1127_:
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
	call _LABEL_750_
	call _LABEL_27E3_
	call _LABEL_2756_
	ld a, $04
	ld ($FFFF), a
	ld hl, $8000
	call _LABEL_750_
	ld a, ($C900)
	dec a
	and $0C
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, $1123
	add hl, de
	ld a, (hl)
	ld ($C077), a
	call _LABEL_40F_
	ld a, $3C
	ld ($CAC8), a
	ld a, $02
	ld ($C014), a
	ei
	ld a, $0A
	ld ($C018), a
	jp _LABEL_143_

; 11th entry of Jump Table from 17F (indexed by $C018)
_LABEL_11A0_:
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

; Data from 11C8 to 11DA (19 bytes)
.db $CD $2C $04 $3E $0B $32 $18 $C0 $C3 $43 $01 $5F $11 $59 $11 $65
.db $11 $5D $11

; 12th entry of Jump Table from 17F (indexed by $C018)
_LABEL_11DB_:
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
	call _LABEL_793_
	ld a, $06
	ld ($FFFF), a
	ld hl, $99B4
	ld de, $0000
	call _LABEL_793_
	ld a, ($C01D)
	add a, a
	ld e, a
	ld d, $00
	ld hl, $142D
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld de, $38CC
	ld bc, $0A10
	call _LABEL_64C_
	ld a, $07
	ld ($FFFF), a
	ld de, $3964
	rst $08	; _LABEL_8_
	ld a, ($C61F)
	ld b, a
	ld hl, $19AA
	ld de, $0016
_LABEL_1256_:
	add hl, de
	djnz _LABEL_1256_
	ld c, $BE
	call OUTI22
	ld de, $3A24
	rst $08	; _LABEL_8_
	ld c, $BE
	ld hl, $1990
	call OUTI8
	ld hl, ($C01C)
	ld h, $00
	call _LABEL_2C98_
	ld e, $00
	ld hl, $C0B2
	ld a, (hl)
	call _LABEL_1940_
	dec hl
	ld a, (hl)
	add a, $80
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld de, $3AE4
	rst $08	; _LABEL_8_
	ld c, $BE
	ld hl, $AE3B
	call OUTI10
	ld hl, $C62D
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
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld de, $3B8C
	rst $08	; _LABEL_8_
	ld c, $BE
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
	in a, ($BE)
	nop
	jr _LABEL_12F0_

_LABEL_12F0_:
	in a, ($BE)
	nop
	jr _LABEL_12F5_

_LABEL_12F5_:
	in a, ($BE)
	nop
	jr _LABEL_12FA_

_LABEL_12FA_:
	in a, ($BE)
	nop
	jr _LABEL_12FF_

_LABEL_12FF_:
	ld c, $BE
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
	ld a, ($C63E)
	cp $03
	jp nc, _LABEL_13B9_
	ld d, a
	ld a, ($C01C)
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
	ld hl, ($C62C)
	ld a, l
	sub e
	daa
	ld l, a
	ld a, h
	sbc a, d
	daa
	ld h, a
	jr c, _LABEL_13B9_
	ld ($C62C), hl
	ld de, $3C90
	rst $08	; _LABEL_8_
	ld c, $BE
	ld hl, $AE45
	call OUTI16
	ld de, $3CAA
	rst $08	; _LABEL_8_
	ld c, $BE
	ld hl, $AE55
	call OUTI6
	ld de, $3D2A
	rst $08	; _LABEL_8_
	ld c, $BE
	ld hl, $AE5B
	call OUTI4
	ld hl, $4F98
	ld ($C100), hl
	ld a, $C4
	ld ($C103), a
	ld de, $1400
	rst $08	; _LABEL_8_
	ld a, ($C908)
	cp $13
	jr c, _LABEL_13A4_
	cp $16
	jr c, _LABEL_139D_
	ld a, $02
	ld hl, $B5EE
	jr _LABEL_13A9_

_LABEL_139D_:
	ld a, $04
	ld hl, $B24A
	jr _LABEL_13A9_

_LABEL_13A4_:
	ld a, $04
	ld hl, $95CA
_LABEL_13A9_:
	ld ($FFFF), a
	ld c, $BE
	call OUTI128
	call OUTI128
	call OUTI128
	jr _LABEL_13BF_

_LABEL_13B9_:
	ld hl, $5010
	ld ($C100), hl
_LABEL_13BF_:
	ld hl, $5030
	ld ($C120), hl
	ld a, $02
	ld ($FFFF), a
	ld hl, $8064
	call _LABEL_750_
	ld a, $07
	ld ($FFFF), a
	ld a, ($C01D)
	and $07
	rrca
	rrca
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, $ADF3
	add hl, de
	ld de, $C060
	call LDI32
	ld a, $04
	ld ($FFFF), a
	ld hl, $8000
	call _LABEL_750_
	ld a, ($C900)
	dec a
	and $0C
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, $1123
	add hl, de
	ld de, $C08E
	ldi
	call _LABEL_40F_
	xor a
	ld ($C0D5), a
	ld a, $02
	ld ($C014), a
	ld a, $83
	ld ($DD04), a
	ei
	ld a, $0C
	ld ($C018), a
	jp _LABEL_137_

; 13th entry of Jump Table from 17F (indexed by $C018)
_LABEL_1424_:
	call _LABEL_3EE_
	call _LABEL_1D60_
	jp _LABEL_137_

; Data from 142D to 1434 (8 bytes)
.db $E6 $81 $26 $83 $C6 $83 $86 $82

; 14th entry of Jump Table from 17F (indexed by $C018)
_LABEL_1435_:
	call _LABEL_B9A_
	ld a, $01
	ld ($C014), a
	call _LABEL_137_
	di
	call _LABEL_59D_
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
	call _LABEL_793_
	ld hl, $A63A
	ld de, $1C00
	call _LABEL_793_
	ld de, $1200
	rst $08	; _LABEL_8_
	ld a, ($C908)
	cp $13
	jr c, _LABEL_149F_
	cp $16
	jr c, _LABEL_1495_
	ld a, $02
	ld hl, $A02E
	ld de, $B5EE
	jr _LABEL_14A7_

_LABEL_1495_:
	ld a, $04
	ld hl, $9C8A
	ld de, $B24A
	jr _LABEL_14A7_

_LABEL_149F_:
	ld a, $04
	ld hl, $800A
	ld de, $95CA
_LABEL_14A7_:
	ld ($FFFF), a
	ld c, $BE
	call OUTI128
	call OUTI128
	call OUTI128
	ex de, hl
	ld de, $1400
	rst $08	; _LABEL_8_
	call OUTI128
	call OUTI128
	call OUTI128
	ld a, $06
	ld ($FFFF), a
	ld a, ($C01D)
	add a, a
	ld e, a
	ld d, $00
	ld hl, $151F
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	push hl
	ex de, hl
	ld de, $3A98
	ld bc, $0A10
	call _LABEL_64C_
	pop hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	call _LABEL_750_
	ld a, ($C900)
	dec a
	and $0C
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, $1123
	add hl, de
	ld de, $C077
	ldi
	call _LABEL_443_
	ld hl, $505C
	ld ($C100), hl
	ld a, $02
	ld ($C014), a
	ei
	xor a
	ld ($C0B6), a
	ld hl, $003C
	ld ($C012), hl
	ld a, $0E
	ld ($C018), a
	jp _LABEL_137_

; Data from 151F to 152E (16 bytes)
.db $E6 $81 $26 $80 $86 $82 $42 $80 $26 $83 $5E $80 $C6 $83 $7A $80

; 15th entry of Jump Table from 17F (indexed by $C018)
_LABEL_152F_:
	call _LABEL_3EE_
	call _LABEL_1D60_
	call _LABEL_137_
	jp _LABEL_137_

; 23rd entry of Jump Table from 17F (indexed by $C018)
_LABEL_153B_:
	ld a, $A7
	out ($BF), a
	ld a, $8A
	out ($BF), a
	ld a, $36
	out ($BF), a
	ld a, $80
	out ($BF), a
	ld hl, $160F
	ld ($C0B8), hl
	xor a
	ld ($C0B7), a
	ld a, $82
	ld ($DD04), a
	ld hl, $04A0
	ld ($C012), hl
	ld a, $17
	ld ($C018), a
	ret

; 24th entry of Jump Table from 17F (indexed by $C018)
_LABEL_1566_:
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
	out ($BF), a
	ld a, $80
	out ($BF), a
	xor a
	ld ($C0B7), a
	ld ($C0D3), a
	ld a, $30
	ld ($C620), a
	ld hl, $03E7
	ld ($C621), hl
	ld ($C623), hl
	xor a
	ld ($C62A), a
	ld ($C625), a
	ld ($C626), a
	ld ($C627), a
	ld ($C62B), a
	ld ($C62C), a
	ld ($C62D), a
	ld a, $1E
	ld ($C62F), a
	ld ($C630), a
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
	ld ($C018), a
	ret

_LABEL_15DF_:
	ld a, ($C0B7)
	neg
	and $F8
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, $3D40
	add hl, de
	ex de, hl
	rst $08	; _LABEL_8_
	ld hl, ($C0B8)
	ld a, (hl)
	cp $FF
	jr z, _LABEL_1605_
	ld c, $BE
	outi
	jr _LABEL_15FF_

_LABEL_15FF_:
	outi
	ld ($C0B8), hl
	ret

_LABEL_1605_:
	xor a
	out ($BE), a
	jr _LABEL_160A_

_LABEL_160A_:
	jr _LABEL_160C_

_LABEL_160C_:
	out ($BE), a
	ret

; Data from 160F to 16F3 (229 bytes)
.db $5B $11 $67 $11 $66 $11 $5F $11 $6A $11 $59 $11 $6C $11 $6D $11
.db $64 $11 $59 $11 $6C $11 $61 $11 $67 $11 $66 $11 $6B $11 $74 $11
.db $74 $11 $58 $11 $58 $11 $58 $11 $71 $11 $67 $11 $6D $11 $58 $11
.db $65 $11 $59 $11 $5C $11 $5D $11 $58 $11 $61 $11 $6C $11 $74 $11
.db $74 $11 $58 $11 $58 $11 $58 $11 $58 $11 $58 $11 $58 $11 $58 $11
.db $58 $11 $58 $11 $58 $11 $58 $11 $58 $11 $58 $11 $58 $11 $58 $11
.db $58 $11 $58 $11 $58 $11 $58 $11 $58 $11 $66 $11 $67 $11 $6F $11
.db $58 $11 $6A $11 $5D $11 $6C $11 $6D $11 $6A $11 $66 $11 $58 $11
.db $6C $11 $67 $11 $58 $11 $71 $11 $67 $11 $6D $11 $6A $11 $58 $11
.db $67 $11 $6F $11 $66 $11 $58 $11 $6F $11 $67 $11 $6A $11 $64 $11
.db $5C $11 $75 $11 $58 $11 $58 $11 $58 $11 $58 $11 $58 $11 $58 $11
.db $58 $11 $58 $11 $58 $11 $58 $11 $6C $11 $60 $11 $59 $11 $66 $11
.db $63 $11 $58 $11 $71 $11 $67 $11 $6D $11 $58 $11 $5E $11 $67 $11
.db $6A $11 $58 $11 $68 $11 $64 $11 $59 $11 $71 $11 $61 $11 $66 $11
.db $5F $11 $75 $11 $FF

; 16th entry of Jump Table from 17F (indexed by $C018)
_LABEL_16F4_:
	call _LABEL_B9A_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_BA3_
	call _LABEL_BC8_
	ld de, $38C0
	ld hl, $0158
	ld bc, $0240
	call _LABEL_632_
	xor a
	ld ($CAC4), a
	ld ($CAC5), a
	ld de, $2B00
	ld hl, $80D8
	call _LABEL_80D_
	ld de, $3000
	ld hl, $8086
	call _LABEL_80D_
	ld hl, $8000
	ld de, $2A80
	call _LABEL_793_
	ld de, $0B00
	ld hl, $80D8
	call _LABEL_80D_
	ld de, $1000
	ld hl, $8086
	call _LABEL_80D_
	ld de, $2020
	ld hl, $97AD
	call _LABEL_793_
	ld de, $0040
	ld hl, $9668
	call _LABEL_793_
	ld de, $38CA
	ld hl, $9A18
	ld bc, $022C
	call _LABEL_64C_
	ld de, $39DC
	ld hl, $1954
	ld bc, $0A02
	call _LABEL_64C_
	ld de, $39FC
	ld hl, $1968
	ld bc, $0A02
	call _LABEL_64C_
	ld de, $39DE
	ld hl, $0155
	ld bc, $000F
	call _LABEL_632_
	ld de, $3C1E
	ld hl, $0755
	ld bc, $000F
	call _LABEL_632_
	ld de, $3CC4
	ld hl, $197C
	ld bc, $0502
	call _LABEL_64C_
	ld de, $3CFA
	ld hl, $1986
	ld bc, $0502
	call _LABEL_64C_
	ld de, $3CC6
	ld hl, $0155
	ld bc, $001A
	call _LABEL_632_
	ld de, $3DC6
	ld hl, $0755
	ld bc, $001A
	call _LABEL_632_
	ld de, $3D08
	rst $08	; _LABEL_8_
	ld c, $BE
	ld hl, $1990
	call OUTI8
	ld hl, ($C01C)
	ld h, $00
	call _LABEL_2C98_
	ld e, $00
	ld hl, $C0B2
	ld a, (hl)
	call _LABEL_1940_
	dec hl
	ld a, (hl)
	add a, $80
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld de, $3D20
	rst $08	; _LABEL_8_
	ld a, ($C61F)
	ld b, a
	ld hl, $19AA
	ld de, $0016
_LABEL_17F5_:
	add hl, de
	djnz _LABEL_17F5_
	call OUTI22
	ld de, $3D48
	rst $08	; _LABEL_8_
	ld hl, $1998
	call OUTI6
	ld hl, ($C621)
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
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld a, $7C
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld hl, ($C623)
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
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld de, $3D60
	rst $08	; _LABEL_8_
	ld hl, $199E
	call OUTI6
	ld a, ($C618)
	ld hl, ($C62F)
	add a, l
	ld l, a
	ld h, $00
	call _LABEL_2C98_
	ld e, $00
	ld a, ($C0B2)
	call _LABEL_1940_
	ld a, ($C0B1)
	add a, $80
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld de, $3D6E
	rst $08	; _LABEL_8_
	ld hl, $19A4
	call OUTI6
	ld a, ($C61A)
	ld hl, ($C630)
	add a, l
	ld l, a
	ld h, $00
	call _LABEL_2C98_
	ld e, $00
	ld a, ($C0B2)
	call _LABEL_1940_
	ld a, ($C0B1)
	add a, $80
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld de, $3D8A
	rst $08	; _LABEL_8_
	ld hl, $19AA
	call OUTI10
	ld hl, $C62D
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
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld de, $3DA6
	rst $08	; _LABEL_8_
	ld hl, $19B6
	call OUTI10
	ld e, $00
	ld a, ($C620)
	rrca
	rrca
	rrca
	rrca
	call _LABEL_1940_
	ld a, ($C620)
	and $0F
	add a, $80
	out ($BE), a
	ld a, $01
	out ($BE), a
	ld hl, $49A7
	ld ($C400), hl
	ld hl, $4C3E
	ld ($C420), hl
	ld hl, $4CC0
	ld ($C440), hl
	ld hl, $4D5D
	ld ($C460), hl
	ld hl, $8064
	call _LABEL_750_
	ld hl, $9646
	call _LABEL_40C_
	xor a
	ld ($C00B), a
	ld a, $02
	ld ($C014), a
	ei
	ld hl, $0384
	ld ($C012), hl
	ld a, $10
	ld ($C018), a
	jp _LABEL_137_

; 17th entry of Jump Table from 17F (indexed by $C018)
_LABEL_192B_:
	call _LABEL_3E6_
	call _LABEL_1D9C_
	call _LABEL_2DAD_
	call _LABEL_137_
	ld a, ($C00C)
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
	out ($BE), a
	ld a, $01
	out ($BE), a
	ret

; Data from 1954 to 1B1F (460 bytes)
.db $54 $01 $57 $01 $57 $01 $57 $01 $57 $01 $57 $01 $57 $01 $57 $01
.db $57 $01 $56 $07 $56 $01 $57 $07 $57 $07 $57 $07 $57 $07 $57 $07
.db $57 $07 $57 $07 $57 $07 $54 $07 $54 $01 $57 $01 $57 $01 $57 $01
.db $56 $07 $56 $01 $57 $07 $57 $07 $57 $07 $54 $07 $5E $11 $64 $11
.db $58 $11 $58 $11 $60 $11 $68 $11 $58 $11 $68 $11 $6F $11 $58 $11
.db $59 $11 $5B $11 $58 $11 $5F $11 $67 $11 $64 $11 $5C $11 $58 $11
.db $58 $11 $5E $11 $67 $11 $67 $11 $5C $11 $58 $11 $59 $11 $68 $11
.db $68 $11 $6A $11 $5D $11 $66 $11 $6C $11 $61 $11 $5B $11 $5D $11
.db $58 $11 $6A $11 $59 $11 $66 $11 $5F $11 $5D $11 $6A $11 $58 $11
.db $58 $11 $58 $11 $58 $11 $58 $11 $6B $11 $67 $11 $64 $11 $5C $11
.db $61 $11 $5D $11 $6A $11 $58 $11 $58 $11 $58 $11 $58 $11 $6F $11
.db $59 $11 $6A $11 $6A $11 $61 $11 $67 $11 $6A $11 $58 $11 $58 $11
.db $58 $11 $58 $11 $5E $11 $61 $11 $5F $11 $60 $11 $6C $11 $5D $11
.db $6A $11 $58 $11 $58 $11 $58 $11 $58 $11 $6B $11 $6F $11 $67 $11
.db $6A $11 $5C $11 $6B $11 $65 $11 $59 $11 $66 $11 $58 $11 $58 $11
.db $6E $11 $5D $11 $6C $11 $5D $11 $6A $11 $59 $11 $66 $11 $58 $11
.db $58 $11 $58 $11 $58 $11 $63 $11 $66 $11 $61 $11 $5F $11 $60 $11
.db $6C $11 $58 $11 $58 $11 $58 $11 $58 $11 $58 $11 $5B $11 $60 $11
.db $59 $11 $65 $11 $68 $11 $61 $11 $67 $11 $66 $11 $58 $11 $58 $11
.db $58 $11 $60 $11 $5D $11 $6A $11 $67 $11 $58 $11 $58 $11 $58 $11
.db $58 $11 $58 $11 $58 $11 $58 $11 $65 $11 $59 $11 $6B $11 $6C $11
.db $5D $11 $6A $11 $58 $11 $58 $11 $58 $11 $58 $11 $58 $11 $68 $11
.db $59 $11 $6A $11 $59 $11 $5C $11 $61 $11 $66 $11 $58 $11 $58 $11
.db $58 $11 $58 $11 $6F $11 $59 $11 $6A $11 $64 $11 $67 $11 $6A $11
.db $5C $11 $58 $11 $58 $11 $58 $11 $58 $11 $5C $11 $6A $11 $59 $11
.db $5F $11 $67 $11 $66 $11 $64 $11 $67 $11 $6A $11 $5C $11 $58 $11
.db $59 $11 $6E $11 $59 $11 $6C $11 $59 $11 $6A $11 $58 $11 $58 $11
.db $58 $11 $58 $11 $58 $11 $65 $11 $59 $11 $6B $11 $6C $11 $5D $11
.db $6A $11 $64 $11 $67 $11 $6A $11 $5C $11 $58 $11

; 18th entry of Jump Table from 17F (indexed by $C018)
_LABEL_1B20_:
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
	call _LABEL_793_
	ld a, $02
	ld ($C006), a
	ld a, ($C0D3)
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, $1C90
	add hl, de
	ld a, (hl)
	ld ($C01C), a
	inc hl
	ld a, (hl)
	ld ($C61F), a
	inc hl
	ld a, (hl)
	ld ($C900), a
	inc hl
	ld a, (hl)
	ld ($C908), a
	ld a, $02
	ld ($FFFF), a
	ld a, ($C01C)
	dec a
	jr z, _LABEL_1B80_
	call GetRandomNumber
	and $03
_LABEL_1B80_:
	ld ($C01D), a
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
	ld hl, $1C84
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
	call _LABEL_1FB8_
	call _LABEL_20BA_
	ld hl, $0000
	call _LABEL_2DFA_
	ld a, $07
	ld ($FFFF), a
	ld a, ($C0D3)
	add a, a
	ld e, a
	ld d, $00
	ld hl, $1C78
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld de, $3E00
	ld bc, $0440
	call _LABEL_661_
	ld hl, $311A
	ld ($C100), hl
	ld hl, $3CE6
	ld ($C120), hl
	ld hl, $C631
	ld de, $C632
	ld (hl), $00
	call LDI5
	ld a, $02
	ld ($FFFF), a
	ld hl, $8064
	call _LABEL_750_
	call _LABEL_27E3_
	call _LABEL_2756_
	ld a, $04
	ld ($FFFF), a
	ld hl, $8000
	call _LABEL_750_
	ld a, ($C900)
	dec a
	and $0C
	rrca
	rrca
	ld e, a
	ld d, $00
	ld hl, $1123
	add hl, de
	ld de, $C077
	ldi
	call _LABEL_40F_
	ld a, $02
	ld ($C014), a
	xor a
	ld ($CAC4), a
	ld ($CAC5), a
	ld a, $3C
	ld ($CAC8), a
	ei
	ld hl, $0078
	ld ($C012), hl
	ld a, $12
	ld ($C018), a
	jp _LABEL_143_

; Data from 1C78 to 1CA7 (48 bytes)
.db $49 $B2 $49 $B3 $49 $B4 $49 $B5 $49 $B6 $49 $B7 $09 $B0 $C9 $B0
.db $89 $B1 $09 $B0 $89 $B1 $C9 $B0 $01 $01 $01 $10 $08 $04 $02 $12
.db $0A $07 $03 $12 $12 $0A $08 $15 $18 $0C $0C $1A $1D $10 $0C $1A

; 19th entry of Jump Table from 17F (indexed by $C018)
_LABEL_1CA8_:
	call _LABEL_3EE_
	ld a, $02
	ld ($FFFF), a
	call _LABEL_1F4F_
	call _LABEL_1D60_
	call _LABEL_175_
	jp nz, _LABEL_143_
	xor a
	ld ($C006), a
	ld ($C0D2), a
	ld a, $78
	ld ($C0D4), a
	ld a, $13
	ld ($C018), a
	jp _LABEL_143_

; 20th entry of Jump Table from 17F (indexed by $C018)
_LABEL_1CD0_:
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
	ld ($C018), a
	jp _LABEL_137_

; 21st entry of Jump Table from 17F (indexed by $C018)
_LABEL_1D11_:
	call _LABEL_B9A_
	call _LABEL_BA3_
	call _LABEL_BC8_
	ld a, $06
	ld ($FFFF), a
	ld de, $0000
	ld hl, $A724
	call _LABEL_793_
	ld de, $3800
	ld hl, $BBA9
	call _LABEL_793_
	ld hl, $A712
	call _LABEL_40C_
	ld a, $02
	ld ($C014), a
	ei
	ld hl, $00B4
	ld ($C012), hl
	ld a, $15
	ld ($C018), a
	jp _LABEL_137_

; 22nd entry of Jump Table from 17F (indexed by $C018)
_LABEL_1D4B_:
	ld a, ($C00D)
	and $B0
	jr nz, _LABEL_1D55_
	jp _LABEL_137_

_LABEL_1D55_:
	call _LABEL_42C_
	ld a, $00
	ld ($C018), a
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
	ld hl, $B129
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

_LABEL_1FB8_:
	ld iy, $C140
	ld hl, ($C01C)
	ld h, $00
	dec hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $9A70
	add hl, de
	ld a, ($C006)
	cp $02
	jr nz, _LABEL_1FD5_
	ld b, $02
	jr _LABEL_1FDD_

_LABEL_1FD5_:
	call GetRandomNumber
	and $07
	add a, $06
	ld b, a
_LABEL_1FDD_:
	push bc
	push hl
	call GetRandomNumber
	and $0F
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
	exx
	ld (iy+31), a
	add a, a
	ld l, a
	ld h, $00
	ld de, $2012
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
	djnz _LABEL_1FDD_
	ret

; Data from 2012 to 207C (107 bytes)
.db $C8 $56 $9D $5C $E6 $5E $E7 $60 $3E $58 $90 $5E $1A $63 $E7 $64
.db $A6 $59 $BB $5E $7E $67 $F2 $69 $CB $6B $47 $6D $C4 $60 $F3 $62
.db $6B $6F $E3 $72 $A9 $64 $30 $67 $DE $70 $50 $75 $CF $69 $A0 $6B
.db $01 $71 $73 $75 $C8 $64 $57 $67 $40 $5B $48 $6F $24 $71 $96 $75
.db $D1 $77 $3E $02 $32 $FF $FF $2A $1C $C0 $2B $26 $00 $29 $29 $29
.db $29 $11 $70 $9A $19 $CD $7B $0B $E6 $0F $5F $16 $00 $19 $7E $6F
.db $26 $00 $29 $11 $12 $20 $19 $5E $23 $56 $C9

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

; Data from 21BF to 225B (157 bytes)
.db $21 $00 $D3 $01 $00 $04 $C5 $41 $7E $FE $03 $20 $02 $36 $02 $CB
.db $FE $23 $10 $F4 $C1 $10 $EF $21 $81 $C9 $11 $02 $00 $06 $36 $7E
.db $FE $03 $20 $02 $36 $02 $19 $10 $F6 $21 $00 $D7 $11 $01 $D7 $36
.db $00 $CD $3D $0A $CD $3D $0A $CD $3D $0A $CD $3D $0A $CD $3D $0A
.db $CD $3D $0A $CD $3D $0A $C3 $3F $0A $21 $00 $D3 $01 $00 $04 $C5
.db $41 $7E $E6 $7F $FE $02 $20 $02 $3E $03 $77 $23 $10 $F3 $C1 $10
.db $EE $21 $00 $D3 $06 $20 $C5 $E5 $EB $21 $00 $04 $19 $E5 $EB $11
.db $20 $00 $7E $D9 $4F $57 $1E $00 $D9 $19 $D1 $06 $20 $C5 $7C $FE
.db $D7 $7E $D9 $30 $01 $5F $CD $ED $23 $4A $53 $D9 $12 $01 $20 $00
.db $EB $09 $EB $09 $C1 $10 $E6 $E1 $23 $C1 $10 $CA $C9

_LABEL_225C_:
	ld a, ($C635)
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
	ld a, ($C635)
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
	ld hl, $2480
	bit 7, d
	jr z, _LABEL_246B_
	ld hl, $2489
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
.db $01 $05 $05 $05 $05 $05 $01 $01 $02 $03 $04 $04 $04 $04 $04 $03
.db $03 $00

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
	ld hl, $25FB
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
	ld hl, $24E4
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
	ld hl, $2505
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
	ld a, ($C01C)
	cp $1E
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
	ld a, ($C01C)
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

_LABEL_259A_:
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

_LABEL_25AA_:
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

_LABEL_25C5_:
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

_LABEL_25E0_:
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

; Data from 25FB to 263A (64 bytes)
.db $9A $25 $00 $D3 $AA $25 $10 $D3 $E0 $25 $10 $D5 $C5 $25 $00 $D5
.db $9A $25 $10 $D3 $C5 $25 $10 $D5 $E0 $25 $00 $D5 $AA $25 $00 $D3
.db $9A $25 $10 $D5 $AA $25 $00 $D5 $E0 $25 $00 $D3 $C5 $25 $10 $D3
.db $9A $25 $00 $D5 $C5 $25 $00 $D3 $E0 $25 $10 $D3 $AA $25 $10 $D5

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
	ld a, ($C01C)
	dec a
	and $1E
	ld e, a
	ld d, $00
	ld hl, $9C50
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	exx
	ld hl, $C980
	call GetRandomNumber
	and $07
	ld b, a
	ld a, ($C01C)
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
	ld a, ($C01C)
	cp $1E
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

_LABEL_2756_:
	ld a, ($C01C)
	dec a
	and $FE
	add a, a
	add a, a
	ld l, a
	ld h, $00
	ld de, $276B
	add hl, de
	ld de, $C078
	jp LDI8

; Data from 276B to 27E2 (120 bytes)
.db $04 $08 $09 $1E $02 $03 $07 $0B $20 $34 $38 $3C $02 $03 $07 $0B
.db $20 $34 $38 $3C $15 $2A $2E $3F $02 $03 $03 $0B $15 $2A $2E $3F
.db $02 $03 $03 $0B $15 $2A $2E $3F $15 $2A $3E $3F $15 $2A $2E $3F
.db $15 $2A $3E $3F $20 $34 $38 $0C $01 $02 $03 $0B $20 $34 $38 $0C
.db $01 $02 $03 $0B $20 $34 $38 $0C $20 $34 $38 $3C $20 $34 $38 $0C
.db $20 $34 $38 $3C $15 $15 $2A $2A $07 $0B $0F $0F $15 $15 $2A $2A
.db $07 $0B $0F $0F $01 $02 $03 $0B $07 $0B $0F $0F $01 $02 $03 $0B
.db $07 $0B $0F $0F $04 $14 $19 $1A

_LABEL_27E3_:
	ld a, $02
	ld ($FFFF), a
	ld a, ($C01D)
	add a, a
	ld e, a
	ld d, $00
	ld hl, $27FA
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp _LABEL_750_

; Data from 27FA to 2801 (8 bytes)
.db $15 $87 $29 $8A $66 $8E $8A $92

_LABEL_2802_:
	ld de, $0040
	rst $08	; _LABEL_8_
	ld a, $04
	ld ($FFFF), a
	ld hl, $2838
	ld a, ($C908)
	and $0F
	cp $03
	jr c, _LABEL_2826_
	ld hl, $2860
	cp $06
	jr c, _LABEL_2826_
	ld hl, $2888
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
	ld c, $BE
	call OUTI256
	jp OUTI128

; Data from 283A to 28B1 (120 bytes)
.db $0A $80 $8A $81 $0A $83 $8A $84 $0A $86 $8A $87 $0A $89 $8A $8A
.db $0A $8C $8A $8D $0A $8F $4A $90 $8A $91 $0A $93 $4A $94 $CA $95
.db $0A $97 $4A $98 $CA $99 $0A $9B $8A $9C $0A $9E $8A $9F $0A $A1
.db $8A $A2 $0A $A4 $8A $A5 $0A $A7 $8A $A8 $0A $AA $8A $AB $CA $AC
.db $0A $AE $8A $AF $CA $B0 $4A $B2 $8A $B3 $CA $B4 $4A $B6 $8A $B7
.db $2E $A0 $AE $A1 $2E $A3 $AE $A4 $2E $A6 $AE $A7 $2E $A9 $AE $AA
.db $2E $AC $AE $AD $2E $AF $6E $B0 $AE $B1 $2E $B3 $6E $B4 $EE $B5
.db $2E $B7 $6E $B8 $EE $B9 $2E $BB

_LABEL_28B2_:
	ld a, $07
	ld ($FFFF), a
	ld de, $0200
	rst $08	; _LABEL_8_
	ld a, ($C61F)
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
	ld de, $2911
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
_LABEL_28F4_:
	ld c, $BE
	call OUTI80
	ld ($C0D0), hl
	ret

_LABEL_28FD_:
	ld a, $07
	ld ($FFFF), a
	ld de, $0250
	rst $08	; _LABEL_8_
	ld hl, ($C0D0)
	ld bc, $B0BE
_LABEL_290C_:
	outi
	jr nz, _LABEL_290C_
	ret

; Data from 2911 to 2940 (48 bytes)
.db $C7 $96 $C7 $97 $C7 $94 $C7 $95 $C7 $98 $C7 $99 $C7 $9A $C7 $9B
.db $C7 $9E $C7 $9F $C7 $9C $C7 $9D $C7 $A0 $C7 $A1 $C7 $A2 $C7 $A3
.db $C7 $A6 $C7 $A7 $C7 $A4 $C7 $A5 $C7 $A8 $C7 $A9 $C7 $AA $C7 $AB

_LABEL_2941_:
	ld hl, ($C01C)
	ld h, $00
	add hl, hl
	ld de, $2975
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
	ld hl, $29E6
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	call _LABEL_793_
	pop hl
	inc hl
	jr _LABEL_294F_

; Data from 2977 to 2A21 (171 bytes)
.db $B3 $29 $B3 $29 $B3 $29 $B3 $29 $B8 $29 $B8 $29 $B8 $29 $B8 $29
.db $BD $29 $BD $29 $C2 $29 $C2 $29 $C7 $29 $C7 $29 $CC $29 $CC $29
.db $D1 $29 $D1 $29 $D1 $29 $D1 $29 $D6 $29 $D6 $29 $D6 $29 $D6 $29
.db $DB $29 $DB $29 $E0 $29 $E0 $29 $E5 $29 $E5 $29 $01 $02 $03 $04
.db $00 $01 $02 $05 $06 $00 $01 $02 $07 $08 $00 $07 $08 $09 $0A $00
.db $03 $04 $09 $0A $00 $03 $04 $0B $0C $00 $05 $06 $0B $0C $00 $07
.db $08 $0B $0C $00 $05 $06 $0B $0C $00 $01 $05 $06 $0A $00 $01 $0A
.db $0D $0E $00 $80 $03 $00 $80 $00 $05 $08 $81 $80 $0F $B1 $86 $80
.db $19 $C7 $8D $80 $0F $EF $90 $C0 $18 $A0 $97 $40 $0F $BA $9B $C0
.db $1C $3B $A5 $80 $03 $6B $A7 $00 $06 $B4 $A8 $80 $03 $AE $AC $80
.db $07 $1E $AF $C0 $0C $73 $B2 $00 $1D $AE $BC

_LABEL_2A22_:
	ld a, $02
	ld ($FFFF), a
	ld hl, $820A
	ld de, $2020
	call _LABEL_793_
	ld a, ($C01D)
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, $2A5C
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	push hl
	ex de, hl
	ld de, $2520
	call _LABEL_793_
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
.db $27 $87 $D1 $89 $3B $8A $0E $8E $78 $8E $32 $92 $9C $92 $EE $95

_LABEL_2A6C_:
	ld a, ($C0D5)
	or a
	jr nz, _LABEL_2A80_
	ld a, ($CAC4)
	or a
	jr nz, _LABEL_2A88_
	ld a, ($CAC5)
	or a
	jp nz, _LABEL_2B0B_
	ret

_LABEL_2A80_:
	xor a
	ld ($CAC4), a
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
	call _LABEL_7D3_
	ld a, ($CAC4)
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
	ld ($CAC4), a
	ret

_LABEL_2B0B_:
	ld a, ($CA00)
	or a
	ret z
_LABEL_2B10_:
	call _LABEL_2198_
_LABEL_2B13_:
	xor a
	ld ($CAC4), a
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
	ld ($CAC4), a
	ret

_LABEL_2B2B_:
	ld a, $03
	ld ($FFFF), a
	ld hl, $AA63
	ld de, $C7BA
	call _LABEL_7D3_
	ld hl, ($C621)
	call _LABEL_2C98_
	ld hl, $C7CC
	ld (hl), $60
	inc hl
	ld (hl), $11
	inc hl
	ld (hl), $68
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
	ld hl, $2C61
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

_LABEL_2CDB_:
	call _LABEL_2CEB_
	call _LABEL_2D2D_
	call _LABEL_2D7F_
	call _LABEL_2D89_
	call _LABEL_2DA3_
	ret

_LABEL_2CEB_:
	ld d, $08
	ld a, ($C930)
	or a
	jr z, _LABEL_2D06_
	ld d, $10
	ld a, ($C928)
	and $0F
	cp $02
	jr z, _LABEL_2D06_
	ld d, $04
	cp $07
	jr nz, _LABEL_2D06_
	ld d, $02
_LABEL_2D06_:
	ld a, d
	ld hl, $C63C
	cp (hl)
	jr c, _LABEL_2D0F_
	inc (hl)
	ret

_LABEL_2D0F_:
	ld (hl), $00
	ld a, ($C620)
	sub $01
	daa
	jr c, _LABEL_2D1D_
	ld ($C620), a
	ret

_LABEL_2D1D_:
	ld hl, ($C621)
	dec hl
	ld ($C621), hl
	ld a, l
	or a
	ret nz
	ld a, $FF
	ld ($C63F), a
	ret

_LABEL_2D2D_:
	ld a, ($C634)
	or a
	ret nz
	ld a, ($C620)
	or a
	ret z
	ld a, ($C930)
	or a
	ld a, $08
	ld de, $0001
	jr z, _LABEL_2D50_
	ld a, ($C928)
	cp $56
	ret z
	cp $50
	ld a, $04
	jr nz, _LABEL_2D50_
	ld a, $02
_LABEL_2D50_:
	ld hl, $C63D
	inc (hl)
	cp (hl)
	jr z, _LABEL_2D58_
	ret nc
_LABEL_2D58_:
	ld (hl), $00
	ld hl, ($C621)
	ld de, ($C61F)
	ld d, $00
	add hl, de
	ld ($C621), hl
	ld de, ($C623)
	xor a
	sbc hl, de
	jr c, _LABEL_2D74_
	ld ($C621), de
_LABEL_2D74_:
	ld a, ($CAC5)
	or a
	ret z
	ld a, $FE
	ld ($CAC4), a
	ret

_LABEL_2D7F_:
	ld a, ($C634)
	or a
	ret z
	dec a
	ld ($C634), a
	ret

_LABEL_2D89_:
	ld a, ($C635)
	or a
	ret z
	dec a
	ld ($C635), a
	ret nz
	ld hl, ($C105)
	ld a, (hl)
	cp $05
	ret z
	call _LABEL_20BA_
	ld a, $01
	ld ($C60E), a
	ret

_LABEL_2DA3_:
	ld a, ($C636)
	or a
	ret z
	dec a
	ld ($C636), a
	ret

_LABEL_2DAD_:
	ld b, $3F
	ld a, ($C634)
	or a
	jr z, _LABEL_2DB7_
	ld b, $3A
_LABEL_2DB7_:
	ld a, ($C620)
	or a
	jr nz, _LABEL_2DBF_
	ld b, $0F
_LABEL_2DBF_:
	ld hl, ($C623)
	srl h
	rr l
	srl h
	rr l
	ex de, hl
	ld hl, ($C621)
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
	ld a, ($C0A0)
	or a
	ld de, $C06F
	jr nz, _LABEL_2DF7_
	ld de, $C02F
	ld hl, $C01E
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
	call _LABEL_661_
	xor a
	ld ($CA05), a
	ld ($CA06), a
	ld hl, $3800
	ld ($CA09), hl
	ld a, $02
	ld ($CA0B), a
	ret

; Data from 2E68 to 2E68 (1 bytes)
.db $C9

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
	ld ($CAC4), a
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
.incbin "dcsms_8000.inc"

_LABEL_2FF7_:
	push af
	ld hl, ($CA07)
	ld de, $0180
.incbin "dcsms_c000.inc"
	add hl, de
	ld ($C60F), hl
	ld hl, $CA42
	ld ($C611), hl
	ld bc, $0110
.incbin "dcsms_10000.inc"
	call _LABEL_26F3_
	ld hl, ($CA09)
	ld a, h
	add a, $06
	cp $3F
.incbin "dcsms_14000.inc"
	jr c, _LABEL_301A_
	sub $07
_LABEL_301A_:
	ld h, a
	ld ($CAC2), hl
.incbin "dcsms_18000.inc"
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
	out ($BF), a
	ld a, $89
	out ($BF), a
	ld a, ($CA05)
	out ($BF), a
	ld a, $88
	out ($BF), a
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
	ld (ix+0), $42
	ld (ix+1), $31
	ret

_LABEL_3142_:
	xor a
	ld ($C601), a
	ld hl, ($C621)
	ld a, l
	or h
	jp z, _LABEL_31CB_
	call _LABEL_1EF6_
	jp c, _LABEL_322D_
	ld a, ($C0A0)
	or a
	ret nz
	ld a, ($C632)
	or a
	jp nz, _LABEL_31FF_
	ld a, ($C932)
	or a
	jp nz, _LABEL_374A_
	ld a, ($C931)
	or a
	jp nz, _LABEL_3796_
	ld a, ($C00D)
	bit 5, a
	jp nz, _LABEL_33F8_
	bit 4, a
	jp nz, _LABEL_31BD_
	ld a, ($C00C)
	and $0F
	jp z, _LABEL_321C_
	ld a, $5A
	ld ($CAC8), a
	ld a, ($C636)
	or a
	jr nz, _LABEL_31AA_
	ld a, ($C00C)
	and (ix+4)
	jr nz, _LABEL_3199_
	ld a, ($C00C)
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
	ld a, $9B
	ld ($DD05), a
	call _LABEL_42C_
	ld a, $0F
	ld ($C018), a
	ret

_LABEL_31CB_:
	ld a, $B1
	ld ($DD04), a
	ld a, $3D
	ld ($CAC4), a
	ld (ix+30), $01
	ld (ix+24), $3C
	ld (ix+0), $E6
	ld (ix+1), $31
	ret

_LABEL_31E6_:
	ld a, $01
	ld ($C0D5), a
	dec (ix+24)
	ret nz
	xor a
	ld ($CAC4), a
	ld ($CAC5), a
	call _LABEL_42C_
	ld a, $0B
	ld ($C018), a
	ret

_LABEL_31FF_:
	ld hl, $C632
	dec (hl)
	jp nz, _LABEL_33D8_
	ld a, $1B
	ld ($CAC4), a
	ret

; Data from 320C to 321B (16 bytes)
.db $2A $21 $C6 $7D $B4 $CA $CB $31 $CD $F6 $1E $38 $03 $C3 $D8 $33

_LABEL_321C_:
	ld a, ($CAC5)
	or a
	jr nz, _LABEL_322D_
	ld hl, $CAC8
	dec (hl)
	jr nz, _LABEL_322D_
	ld a, $4B
	ld ($CAC4), a
_LABEL_322D_:
	call _LABEL_481B_
	ld a, (ix+5)
	ld (ix+7), a
	ld a, (ix+6)
	ld (ix+8), a
	call _LABEL_4888_
	ret

; Data from 3240 to 3243 (4 bytes)
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
	ld ($C637), a
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
	ld a, ($C928)
	and $7F
	cp $59
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
	ld a, $41
	ld ($CAC4), a
	xor a
	ld ($CAC5), a
	ld a, $98
	ld ($DD05), a
	jp _LABEL_3F1A_

_LABEL_32C4_:
	ld (ix+4), $01
	ld hl, $FFE0
	call _LABEL_3244_
	jp c, _LABEL_321C_
	call _LABEL_327F_
	call _LABEL_3260_
	ld de, $3A3A
	jp c, _LABEL_35CD_
	ld a, $FF
	ld ($CAC4), a
	ld (ix+30), $01
	ld l, (ix+5)
	ld h, (ix+6)
	ld de, $FFE0
	add hl, de
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+22), $45
	ld (ix+23), $38
	ld (ix+0), $30
	ld (ix+1), $38
	jp _LABEL_3830_

_LABEL_3309_:
	ld (ix+4), $02
	ld hl, $0020
	call _LABEL_3244_
	jp c, _LABEL_321C_
	call _LABEL_327F_
	call _LABEL_3260_
	ld de, $3A3E
	jp c, _LABEL_35CD_
	ld a, $FF
	ld ($CAC4), a
	ld (ix+30), $01
	ld l, (ix+5)
	ld h, (ix+6)
	ld de, $0020
	add hl, de
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+22), $5C
	ld (ix+23), $38
	ld (ix+0), $49
	ld (ix+1), $38
	jp _LABEL_3849_

_LABEL_334E_:
	ld (ix+4), $04
	ld hl, $FFFF
	call _LABEL_3244_
	jp c, _LABEL_321C_
	call _LABEL_327F_
	call _LABEL_3260_
	ld de, $3A42
	jp c, _LABEL_35CD_
	ld a, $FF
	ld ($CAC4), a
	ld (ix+30), $01
	ld l, (ix+5)
	ld h, (ix+6)
	ld de, $FFFF
	add hl, de
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+22), $75
	ld (ix+23), $38
	ld (ix+0), $60
	ld (ix+1), $38
	jp _LABEL_3860_

_LABEL_3393_:
	ld (ix+4), $08
	ld hl, $0001
	call _LABEL_3244_
	jp c, _LABEL_321C_
	call _LABEL_327F_
	call _LABEL_3260_
	ld de, $3A46
	jp c, _LABEL_35CD_
	ld a, $FF
	ld ($CAC4), a
	ld (ix+30), $01
	ld l, (ix+5)
	ld h, (ix+6)
	ld de, $0001
	add hl, de
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+22), $8C
	ld (ix+23), $38
	ld (ix+0), $79
	ld (ix+1), $38
	jp _LABEL_3879_

_LABEL_33D8_:
	ld a, $08
	ld ($C601), a
	ld l, (ix+5)
	ld h, (ix+6)
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), $F5
	ld (ix+1), $38
	jp _LABEL_38F5_

_LABEL_33F8_:
	ld l, (ix+5)
	ld h, (ix+6)
	ld a, (hl)
	cp $0C
	jr nc, _LABEL_3461_
	ld a, (ix+4)
	ld hl, $3459
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
	jr z, _LABEL_3424_
	cp $07
	jp nz, _LABEL_33D8_
_LABEL_3424_:
	ld a, ($C930)
	or a
	jr z, _LABEL_3431_
	ld a, ($C928)
	cp $53
	jr z, _LABEL_343D_
_LABEL_3431_:
	call GetRandomNumber
	and $07
	ld d, a
	ld a, ($C637)
	cp d
	jr c, _LABEL_344F_
_LABEL_343D_:
	ld (hl), $05
	ld a, $01
	ld ($C606), a
	ld a, $0E
	ld ($CAC4), a
	ld a, $93
	ld ($DD05), a
	ret

_LABEL_344F_:
	ld a, ($C637)
	inc a
	ld ($C637), a
	jp _LABEL_33D8_

; Data from 3459 to 3460 (8 bytes)
.db $E0 $FF $20 $00 $FF $FF $01 $00

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
	ld a, $03
	ld ($CAC4), a
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
	ld a, $93
	ld ($DD05), a
	jp _LABEL_33D8_

_LABEL_34C7_:
	ld a, $14
	ld ($CAC4), a
	jp _LABEL_33D8_

_LABEL_34CF_:
	ld (hl), $04
	call GetRandomNumber
	and $03
	inc a
	ld b, a
	ld a, ($C01C)
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
	ld a, ($C61F)
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
	ld a, ($C62B)
	add a, l
	daa
	ld ($C62B), a
	ld a, ($C62C)
	adc a, h
	daa
	ld ($C62C), a
	ld a, ($C62D)
	adc a, $00
	daa
	ld ($C62D), a
	cp $10
	jr c, _LABEL_3532_
	ld a, $99
	ld ($C62B), a
	ld ($C62C), a
	ld a, $09
	ld ($C62D), a
_LABEL_3532_:
	ld a, $01
	ld ($C606), a
	ld a, $0D
	ld ($CAC4), a
	ld a, $93
	ld ($DD05), a
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
	ld a, ($C620)
	add a, d
	daa
	jr nc, _LABEL_3567_
	ld a, $99
_LABEL_3567_:
	ld ($C620), a
	ld a, $01
	ld ($C606), a
	ld a, $0C
	ld ($CAC4), a
	ld a, $93
	ld ($DD05), a
	jp _LABEL_33D8_

_LABEL_357C_:
	ld (hl), $04
	xor a
	ld ($CAC4), a
	ld ($CAC5), a
	ld a, $01
	ld ($C606), a
	ld ($C60E), a
	ld a, $3F
	ld ($C0AB), a
	ld a, ($C020)
	ld ($C0A9), a
	ld (ix+24), $3C
	ld (ix+0), $B2
	ld (ix+1), $35
	ld a, $07
	ld ($FFFF), a
	call _LABEL_1C3B1_
	ld a, $95
	ld ($DD05), a
	ret

_LABEL_35B2_:
	call _LABEL_3F2B_
	ret nc
	call _LABEL_461_
	ld (ix+0), $C2
	ld (ix+1), $35
	ret

_LABEL_35C2_:
	ld a, ($C0A0)
	or a
	ret nz
	ld a, $0D
	ld ($C018), a
	ret

_LABEL_35CD_:
	ld ($C638), hl
	ld (ix+22), e
	ld (ix+23), d
	ld de, $001C
	add hl, de
	res 1, (hl)
	ld a, ($C900)
	and $7F
	cp $0E
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
	ld hl, ($C638)
	ld de, $001F
	add hl, de
	ld e, (hl)
	ld d, $00
	ld hl, $36F1
	add hl, de
	ld a, ($C617)
	sub (hl)
	add a, $64
	cp b
	jp c, _LABEL_3712_
	ld hl, $C62F
	ld a, ($C618)
	add a, (hl)
	call _LABEL_4848_
	ld e, a
	ld d, $00
	ld hl, ($C638)
	ld bc, $001F
	add hl, bc
	ld a, ($C900)
	and $7F
	sub $09
	jp c, _LABEL_36C7_
	jr z, _LABEL_366F_
	dec a
	jr z, _LABEL_367A_
	dec a
	jr z, _LABEL_3685_
	dec a
	jr z, _LABEL_3694_
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
	ld hl, ($C621)
	xor a
	sbc hl, bc
	ld ($C621), hl
	jr nc, _LABEL_36C7_
	ld hl, $0000
	ld ($C621), hl
	ld a, $FE
	ld ($C63F), a
	jr _LABEL_36C7_

_LABEL_366F_:
	ld a, (hl)
	cp $0A
	jr z, _LABEL_36C4_
	cp $16
	jr z, _LABEL_36C4_
	jr _LABEL_36C7_

_LABEL_367A_:
	ld a, (hl)
	cp $0B
	jr z, _LABEL_36C4_
	cp $17
	jr z, _LABEL_36C4_
	jr _LABEL_36C7_

_LABEL_3685_:
	ld a, (hl)
	cp $06
	jr z, _LABEL_36C4_
	cp $12
	jr z, _LABEL_36C4_
	cp $1A
	jr z, _LABEL_36C4_
	jr _LABEL_36C7_

_LABEL_3694_:
	ld a, (hl)
	cp $1E
	jr nz, _LABEL_36C7_
	ex de, hl
	add hl, hl
	add hl, hl
	ex de, hl
	jr _LABEL_36C7_

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
	ld hl, ($C621)
	add hl, bc
	ld ($C621), hl
	ld bc, ($C623)
	xor a
	sbc hl, bc
	jr c, _LABEL_36C7_
	ld ($C621), bc
	jr _LABEL_36C7_

_LABEL_36C2_:
	jr _LABEL_36C7_

_LABEL_36C4_:
	ex de, hl
	add hl, hl
	ex de, hl
_LABEL_36C7_:
	ld ($C63A), de
	ex de, hl
	call _LABEL_486E_
	ld a, e
	or d
	ld a, $90
	jr nz, _LABEL_36D7_
	ld a, $91
_LABEL_36D7_:
	ld ($DD05), a
	ld (ix+20), $00
	ld (ix+21), $00
	ld (ix+24), $08
	ld (ix+0), $28
	ld (ix+1), $39
	jp _LABEL_3928_

; Data from 36F1 to 3711 (33 bytes)
.db $00 $04 $08 $0A $00 $05 $0E $18 $00 $08 $04 $32 $00 $14 $0C $0A
.db $00 $0A $14 $0A $00 $18 $00 $1E $00 $0E $1E $14 $00 $0E $19 $0A
.db $0A

_LABEL_3712_:
	ld (ix+20), $00
	ld (ix+21), $00
	ld (ix+24), $08
	ld (ix+0), $0A
	ld (ix+1), $39
	ld a, $92
	ld ($DD05), a
	jp _LABEL_390A_

_LABEL_372E_:
	ld (ix+20), $00
	ld (ix+21), $00
	ld (ix+24), $08
	ld (ix+0), $19
	ld (ix+1), $39
	ld a, $92
	ld ($DD05), a
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
	rst $08	; _LABEL_8_
	ld bc, $80BE
_LABEL_3781_:
	outi
	jr nz, _LABEL_3781_
	ld hl, $3DA6
	ld ($C3E0), hl
	ld (ix+0), $AC
	ld (ix+1), $3A
	jp _LABEL_3AAC_

_LABEL_3796_:
	ld a, ($C931)
	bit 7, a
	jr z, _LABEL_37A5_
	and $70
	jp z, _LABEL_467E_
	jp _LABEL_468B_

_LABEL_37A5_:
	sub $20
	jr c, _LABEL_37C5_
	cp $20
	jr nc, _LABEL_37C5_
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
	ld hl, $37E0
	add hl, de
	ld a, (hl)
	ld (ix+3), a
_LABEL_37C5_:
	ld a, ($C931)
	sub $20
	and $7F
	ld e, a
	ld d, $00
	ld hl, $37F0
	add hl, de
	ld e, (hl)
.incbin "dcsms_1c88c.inc"
	ld d, $00
	ld hl, $3E68
	add hl, de
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	jp (hl)

; Data from 37E0 to 382F (80 bytes)
.db $09 $04 $0E $13 $0A $05 $0F $14 $06 $01 $0B $10 $06 $01 $0B $10
.db $00 $01 $02 $03 $05 $06 $07 $0A $0B $0C $0D $09 $0E $30 $FF $FF
.db $0F $10 $11 $16 $12 $13 $15 $14 $17 $31 $04 $18 $FF $FF $FF $FF
.db $19 $1A $1B $1C $1D $33 $1F $08 $2E $2F $20 $32 $21 $FF $FF $FF
.db $22 $23 $22 $24 $25 $26 $28 $29 $2A $27 $FF $FF $FF $FF $FF $FF

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
	ld a, ($C635)
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
	ld a, ($C633)
	or a
	jr nz, _LABEL_38EC_
	ld (ix+0), $42
	ld (ix+1), $31
	jp _LABEL_2CDB_

_LABEL_38EC_:
	ld (ix+0), $0C
	ld (ix+1), $32
	ret

_LABEL_38F5_:
	ld a, ($C601)
	inc a
	ld ($C601), a
	cp $10
	ret c
	ld (ix+0), $42
	ld (ix+1), $31
	jp _LABEL_2CDB_

_LABEL_390A_:
	call _LABEL_478D_
	dec (ix+24)
	ret nz
	ld a, $08
	ld ($CAC4), a
	jp _LABEL_33D8_

_LABEL_3919_:
	call _LABEL_478D_
	dec (ix+24)
	ret nz
	ld a, $3C
	ld ($CAC4), a
	jp _LABEL_33D8_

_LABEL_3928_:
	ld a, (ix+24)
	and $01
	ld hl, ($C638)
	ld de, $0002
	add hl, de
	ld (hl), a
	call _LABEL_478D_
	dec (ix+24)
	ret nz
_LABEL_393C_:
	ld a, $01
	ld ($CAC4), a
	ld hl, ($C63A)
	ld ($CAC6), hl
	ld hl, ($C638)
	ld de, $001C
	add hl, de
	set 4, (hl)
	ld hl, ($C638)
	ld de, $0002
	add hl, de
	ld (hl), $01
	ld de, $0018
	add hl, de
	ld a, (hl)
	inc hl
	or (hl)
	jr nz, _LABEL_39B9_
	ld a, $09
	ld ($CAC4), a
	ld iy, ($C638)
	ld (iy+0), $0F
	inc hl
	ld (iy+1), $31
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
	ld hl, $3A4A
	add hl, de
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, ($C625)
	add hl, de
	jr nc, _LABEL_39B6_
	ld hl, $FFFF
_LABEL_39B6_:
	ld ($C625), hl
_LABEL_39B9_:
	ld de, ($C628)
	ld hl, ($C625)
	or a
	sbc hl, de
	jp c, _LABEL_33D8_
	ld a, $0A
	ld ($CAC4), a
	ld a, $A9
	ld ($DD05), a
	ld a, ($C61F)
	inc a
	cp $10
	jr c, _LABEL_39DA_
	ld a, $10
_LABEL_39DA_:
	ld ($C61F), a
	add a, a
	ld e, a
	ld d, $00
	ld hl, $3A8C
	add hl, de
	ld a, (hl)
	ld ($C628), a
	inc hl
	ld a, (hl)
	ld ($C629), a
	ld a, ($C61F)
	rrca
	rrca
	and $3F
	inc a
	ld d, a
	ld a, ($C62F)
	add a, d
	cp $3C
	jr c, _LABEL_3A01_
	ld a, $3B
_LABEL_3A01_:
	ld ($C62F), a
	ld a, ($C61F)
	ld d, a
	ld a, ($C01C)
	add a, d
	add a, a
	ld e, a
	ld d, $00
	ld hl, ($C623)
	add hl, de
	ld ($C623), hl
	ld bc, $03E7
	or a
	sbc hl, bc
	jr c, _LABEL_3A25_
	ld hl, $03E7
	ld ($C623), hl
_LABEL_3A25_:
	ld hl, ($C621)
	add hl, de
	ld ($C621), hl
	or a
	sbc hl, bc
	jr c, _LABEL_3A37_
	ld hl, $03E7
	ld ($C621), hl
_LABEL_3A37_:
	jp _LABEL_3F1A_

; Data from 3A3A to 3AAB (114 bytes)
.db $04 $02 $08 $06 $04 $02 $03 $01 $04 $02 $0D $0B $04 $02 $12 $10
.db $01 $00 $02 $00 $06 $00 $0A $00 $03 $00 $06 $00 $01 $00 $08 $00
.db $05 $00 $0A $00 $19 $00 $30 $00 $0C $00 $20 $00 $14 $00 $16 $00
.db $2C $00 $3E $00 $48 $00 $34 $00 $4E $00 $6E $00 $3C $00 $96 $00
.db $8C $00 $2C $01 $6E $00 $60 $00 $1E $00 $82 $00 $FA $00 $78 $00
.db $78 $00 $00 $00 $14 $00 $46 $00 $82 $00 $C8 $00 $54 $01 $30 $02
.db $5C $03 $14 $05 $D0 $07 $B8 $0B $68 $10 $E0 $15 $E8 $1C $80 $25
.db $B0 $36

_LABEL_3AAC_:
	ld hl, ($C3E0)
	ld a, l
	or h
	ret nz
	ld a, ($C932)
	or a
	jp z, _LABEL_33D8_
	ld hl, ($C638)
	ld de, $001C
	add hl, de
	res 1, (hl)
	cp $40
	jr nc, _LABEL_3B38_
	ld a, ($C932)
	cp $0E
	jr nz, _LABEL_3AE9_
	ld hl, ($C638)
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
	ld hl, ($C638)
	ld de, $001F
	add hl, de
	ld e, (hl)
	ld d, $00
	ld hl, $36F1
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
	ld hl, $3C85
	ld e, a
	ld d, $00
	add hl, de
	ld a, (hl)
_LABEL_3B16_:
	ld hl, $C62F
	add a, (hl)
	call _LABEL_4848_
	ld l, a
	ld h, $00
	ld ($C63A), hl
	call _LABEL_486E_
	ld a, e
	or d
	ld a, $90
	jr nz, _LABEL_3B2E_
	ld a, $91
_LABEL_3B2E_:
	ld ($DD05), a
	xor a
	ld ($C932), a
	jp _LABEL_393C_

_LABEL_3B38_:
	set 4, (hl)
	sub $40
	ld e, a
	ld d, $00
	ld hl, $3CA0
	add hl, de
	ld a, (hl)
	add a, a
	ld e, a
	ld d, $00
	ld hl, $3CC0
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	jp (hl)

; Data from 3B51 to 3C73 (291 bytes)
.db $2A $38 $C6 $11 $1A $00 $19 $5E $23 $56 $EB $29 $01 $E7 $03 $B7
.db $ED $42 $38 $03 $21 $00 $00 $09 $EB $72 $2B $73 $3E $15 $32 $C4
.db $CA $AF $32 $32 $C9 $3E $A9 $32 $05 $DD $C3 $1A $3F $2A $38 $C6
.db $11 $1A $00 $19 $5E $23 $56 $4B $42 $CB $38 $CB $19 $CB $38 $CB
.db $19 $EB $AF $ED $42 $EB $72 $2B $73 $3E $18 $32 $C4 $CA $AF $32
.db $32 $C9 $3E $90 $32 $05 $DD $C3 $1A $3F $2A $38 $C6 $11 $1C $00
.db $19 $CB $C6 $3E $16 $32 $C4 $CA $AF $32 $32 $C9 $3E $90 $32 $05
.db $DD $C3 $1A $3F $2A $38 $C6 $11 $1C $00 $19 $CB $CE $CB $A6 $3E
.db $17 $32 $C4 $CA $AF $32 $32 $C9 $3E $90 $32 $05 $DD $C3 $1A $3F
.db $2A $38 $C6 $11 $1A $00 $19 $5E $23 $56 $CB $3A $CB $1B $CB $3A
.db $CB $1B $7B $B2 $20 $03 $11 $01 $00 $72 $2B $73 $3E $18 $32 $C4
.db $CA $AF $32 $32 $C9 $3E $90 $32 $05 $DD $C3 $1A $3F $3E $19 $32
.db $C4 $CA $AF $32 $32 $C9 $C3 $1A $3F $AF $32 $32 $C9 $21 $01 $00
.db $22 $3A $C6 $CD $6E $48 $C3 $3C $39 $CD $7D $20 $EB $2A $38 $C6
.db $01 $05 $00 $09 $73 $23 $72 $3E $1A $32 $C4 $CA $AF $32 $32 $C9
.db $C3 $1A $3F $2A $38 $C6 $11 $1F $00 $19 $7E $FE $01 $28 $0C $FE
.db $05 $28 $08 $FE $09 $28 $04 $AF $C3 $16 $3B $AF $32 $32 $C9 $21
.db $E7 $03 $22 $3A $C6 $CD $6E $48 $C3 $3C $39 $AF $C3 $16 $3B $AF
.db $C3 $5C $3C

_LABEL_3C74_:
	ld a, $92
	ld ($DD05), a
	ld a, $08
	ld ($CAC4), a
	xor a
	ld ($C932), a
	jp _LABEL_3F1A_

; Data from 3C85 to 3CD5 (81 bytes)
.db $00 $01 $02 $03 $05 $08 $0B $0E $12 $06 $06 $08 $08 $04 $08 $0C
.db $00 $01 $02 $03 $04 $05 $06 $06 $0A $04 $0A $00 $00 $01 $00 $02
.db $02 $08 $03 $00 $00 $00 $09 $04 $00 $00 $00 $00 $09 $00 $09 $00
.db $00 $04 $0A $09 $07 $00 $00 $00 $00 $00 $00 $51 $3B $7E $3B $AB
.db $3B $C5 $3B $E1 $3B $0E $3C $1A $3C $2A $3C $44 $3C $6C $3C $70
.db $3C

_LABEL_3CD6_:
	ld hl, $C01C
	inc (hl)
	ld a, (hl)
	call _LABEL_42C_
	ld a, $08
	ld ($C018), a
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
	ld (ix+22), $16
	ld (ix+23), $3D
	ld (ix+0), $1A
	ld (ix+1), $3D
	ret

; Data from 3D16 to 3D19 (4 bytes)
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
	ld (ix+0), $8A
	ld (ix+1), $3D
	jr _LABEL_3D8A_

_LABEL_3D62_:
	ld (ix+4), $04
	ld (ix+0), $8A
	ld (ix+1), $3D
	jr _LABEL_3D8A_

_LABEL_3D70_:
	ld (ix+4), $02
	ld (ix+0), $8A
	ld (ix+1), $3D
	jr _LABEL_3D8A_

_LABEL_3D7E_:
	ld (ix+4), $01
	ld (ix+0), $8A
	ld (ix+1), $3D
_LABEL_3D8A_:
	call _LABEL_47B8_
	dec (ix+24)
	ret nz
	ld l, (ix+7)
	ld h, (ix+8)
	ld (ix+5), l
	ld (ix+6), h
	ld (ix+0), $1A
	ld (ix+1), $3D
	ret

; Data from 3DA6 to 3ED7 (306 bytes)
.db $2A $0A $C1 $DD $75 $0A $DD $74 $0B $2A $0D $C1 $DD $75 $0D $DD
.db $74 $0E $DD $36 $13 $04 $DD $36 $02 $01 $DD $36 $03 $1F $DD $36
.db $18 $04 $3A $04 $C1 $DD $77 $04 $DD $36 $00 $D7 $DD $36 $01 $3D
.db $C9 $CD $BB $47 $DD $35 $18 $C0 $DD $7E $0A $E6 $F0 $6F $DD $66
.db $0B $29 $EB $DD $7E $0D $E6 $F0 $DD $66 $0E $CB $3C $1F $CB $3C
.db $1F $CB $3C $1F $CB $3C $1F $6F $19 $11 $00 $D3 $19 $7E $E6 $7F
.db $28 $49 $FE $0C $30 $04 $FE $06 $30 $41 $FD $21 $40 $C1 $11 $20
.db $00 $06 $14 $FD $7E $0B $DD $BE $0B $20 $18 $FD $7E $0A $DD $BE
.db $0A $20 $10 $FD $7E $0E $DD $BE $0E $20 $08 $FD $7E $0D $DD $BE
.db $0D $28 $09 $FD $19 $10 $DC $DD $36 $18 $04 $C9 $FD $E5 $E1 $22
.db $38 $C6 $DD $36 $00 $0F $DD $36 $01 $31 $C9 $3E $92 $32 $05 $DD
.db $3E $08 $32 $C4 $CA $AF $32 $32 $C9 $DD $36 $00 $0F $DD $36 $01
.db $31 $C9 $53 $3F $68 $3F $74 $3F $81 $3F $DA $3F $E6 $3F $1C $40
.db $77 $40 $9F $40 $B0 $40 $1D $41 $40 $41 $63 $41 $86 $41 $A9 $41
.db $B1 $41 $26 $42 $40 $42 $59 $42 $AB $42 $39 $43 $8C $43 $EE $43
.db $46 $44 $7F $44 $94 $44 $BC $44 $C5 $44 $E0 $44 $FA $44 $45 $45
.db $65 $45 $8E $45 $9C $45 $C9 $45 $10 $46 $17 $46 $1E $46 $33 $46
.db $49 $46 $56 $46 $63 $46 $70 $46 $7E $46 $7E $46 $8B $46 $98 $46
.db $AD $46 $C2 $46 $DF $46 $4C $47 $58 $47 $78 $47 $78 $47 $78 $47
.db $78 $47

_LABEL_3ED8_:
	ld a, $3F
	ld ($C0AB), a
.incbin "dcsms_409f.inc"
	jr _LABEL_3EE5_

_LABEL_3EDF_:
	ld a, ($C020)
	ld ($C0AB), a
_LABEL_3EE5_:
	ld a, ($C020)
	ld ($C0A9), a
	ld (ix+24), $1E
	ld hl, $3EF5
	jp _LABEL_4786_

_LABEL_3EF5_:
	call _LABEL_3F2B_
	ret nc
	ld a, ($C975)
	ld ($CAC4), a
	ld hl, $C931
	bit 7, (hl)
	jr z, _LABEL_3F0B_
	ld a, $AA
	ld ($DD05), a
_LABEL_3F0B_:
	ld a, (hl)
	cp $23
	jr nz, _LABEL_3F15_
	ld a, $AB
	ld ($DD05), a
_LABEL_3F15_:
	ld (hl), $00
	call _LABEL_4888_
_LABEL_3F1A_:
	ld (ix+24), $0F
	ld hl, $3F24
	jp _LABEL_4786_

_LABEL_3F24_:
	dec (ix+24)
	ret nz
	jp _LABEL_33D8_

_LABEL_3F2B_:
	dec (ix+24)
	jr z, _LABEL_3F46_
	ld a, ($C0AB)
	bit 0, (ix+24)
	jr nz, _LABEL_3F3C_
	ld a, ($C0A9)
_LABEL_3F3C_:
	ld ($C020), a
	ld hl, $C01E
	set 0, (hl)
	xor a
	ret

_LABEL_3F46_:
	ld a, ($C0A9)
	ld ($C020), a
	ld hl, $C01E
	set 0, (hl)
	scf
	ret

; Data from 3F53 to 3F80 (46 bytes)
.db $3A $18 $C6 $3C $FE $3C $38 $02 $3E $3B $32 $18 $C6 $3E $1C $32
.db $75 $C9 $C3 $D8 $3E $21 $1A $C6 $34 $3E $1D $32 $75 $C9 $C3 $D8
.db $3E $3E $01 $32 $31 $C6 $3E $1E $32 $75 $C9 $C3 $D8 $3E

_LABEL_3F81_:
	ld a, ($C930)
	or a
	jr z, _LABEL_3F94_
	ld a, ($C928)
	and $7F
	cp $56
	jr c, _LABEL_3F94_
	cp $58
	jr nz, _LABEL_3FA1_
_LABEL_3F94_:
	ld a, ($C900)
	ld d, a
	ld a, ($C908)
	or d
	ld d, a
	and $80
	jr z, _LABEL_3FDA_
_LABEL_3FA1_:
	ld hl, $C900
	res 7, (hl)
	call _LABEL_48F7_
	ld hl, $C908
	res 7, (hl)
	call _LABEL_4916_
	ld a, ($C930)
	or a
	jr z, _LABEL_3FD2_
	ld a, ($C928)
	and $7F
	cp $56
	jr c, _LABEL_3FD2_
	cp $58
	jr z, _LABEL_3FD2_
	ld hl, $C929
	ld de, $C928
	call _LABEL_B2F_
	xor a
	ld (de), a
	ld ($C930), a
_LABEL_3FD2_:
	ld a, $1F
	ld ($C975), a
	jp _LABEL_3ED8_

_LABEL_3FDA_:
	ld a, $19
	ld ($C975), a
	xor a
	ld ($C931), a
	jp _LABEL_3EDF_

; Data from 3FE6 to 3FFF (26 bytes)
.db $3A $35 $C6 $B7 $20 $EE $3A $20 $C0 $32 $A9 $C0 $3E $3F $32 $AB
.db $C0 $DD $36 $18 $1E $21 $01 $40 $C3 $86

.BANK 1 SLOT 1
.ORG $0000

; Data from 4000 to 4076 (119 bytes)
.db $47 $CD $2B $3F $D0 $3E $20 $32 $C4 $CA $CD $08 $22 $3E $01 $32
.db $0E $C6 $AF $32 $31 $C9 $CD $88 $48 $C3 $1A $3F $3A $20 $C0 $32
.db $A9 $C0 $3E $3F $32 $AB $C0 $DD $36 $18 $1E $21 $31 $40 $C3 $86
.db $47 $CD $2B $3F $D0 $3E $21 $32 $C4 $CA $DD $36 $18 $1E $21 $44
.db $40 $C3 $86 $47 $DD $35 $18 $C0 $CD $8F $1F $CD $1B $48 $CD $BA
.db $20 $2A $05 $C1 $11 $00 $2D $19 $CD $FA $2D $DD $E5 $CD $4F $1F
.db $DD $E1 $AF $32 $31 $C9 $32 $C4 $CA $32 $C5 $CA $3E $98 $32 $05
.db $DD $21 $42 $31 $C3 $86 $47

_LABEL_4077_:
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
	jp z, _LABEL_3FDA_
	ld a, $16
	ld ($C975), a
	jp _LABEL_3ED8_

; Data from 409F to 45CD (1327 bytes)

_LABEL_45CE_:
	ld a, $3F
	ld ($C0AB), a
	ld a, ($C020)
	ld ($C0A9), a
	ld (ix+24), $1E
	ld hl, $45E3
	jp _LABEL_4786_

_LABEL_45E3_:
	call _LABEL_3F2B_
	ret nc
	ld a, ($C975)
	ld ($CAC4), a
	ld a, ($C931)
	and $0F
	cp $08
	jr z, _LABEL_45FF_
	cp $06
	jr c, _LABEL_45FF_
	ld a, $AA
	ld ($DD05), a
_LABEL_45FF_:
	xor a
	ld ($C931), a
	call _LABEL_4888_
	ld (ix+24), $1E
	ld hl, $3142
	jp _LABEL_4786_

; Data from 4610 to 4616 (7 bytes)
.db $3E $36 $32 $75 $C9 $18 $B7

_LABEL_4617_:
	ld a, $37
	ld ($C975), a
	jr _LABEL_45CE_

_LABEL_461E_:
	ld a, ($C630)
	add a, $04
	cp $32
	jr c, _LABEL_4629_
	ld a, $31
_LABEL_4629_:
	ld ($C630), a
	ld a, $38
	ld ($C975), a
	jr _LABEL_45CE_

; Data from 4633 to 4655 (35 bytes)
.db $3A $2F $C6 $C6 $04 $FE $3C $38 $02 $3E $3B $32 $2F $C6 $3E $39
.db $32 $75 $C9 $C3 $CE $45 $3E $21 $32 $75 $C9 $3E $00 $32 $AB $C0
.db $C3 $D3 $45

_LABEL_4656_:
	ld a, $3A
	ld ($C975), a
	ld a, $00
	ld ($C0AB), a
	jp _LABEL_45D3_

; Data from 4663 to 467D (27 bytes)
.db $3E $3A $32 $75 $C9 $3E $00 $32 $AB $C0 $C3 $D3 $45 $3E $3B $32
.db $75 $C9 $3A $20 $C0 $32 $AB $C0 $C3 $D3 $45

_LABEL_467E_:
	ld a, $00
	ld ($C0AB), a
	ld a, $3F
	ld ($C975), a
	jp _LABEL_3EE5_

_LABEL_468B_:
	ld a, $00
	ld ($C0AB), a
	ld a, $40
	ld ($C975), a
	jp _LABEL_3EE5_

; Data from 4698 to 46DE (71 bytes)
.db $3A $2F $C6 $3C $FE $3C $38 $02 $3E $3B $32 $2F $C6 $3E $48 $32
.db $75 $C9 $C3 $D8 $3E $3A $30 $C6 $3C $FE $32 $38 $02 $3E $31 $32
.db $30 $C6 $3E $49 $32 $75 $C9 $C3 $D8 $3E $3A $20 $C9 $B7 $CA $DA
.db $3F $21 $20 $C9 $06 $08 $7E $B7 $28 $05 $36 $41 $23 $10 $F7 $3E
.db $4A $32 $75 $C9 $C3 $D8 $3E

_LABEL_46DF_:
	call _LABEL_1F3A_
	jp c, _LABEL_3FDA_
	ld ($C638), hl
	push hl
	pop iy
	ld a, (ix+4)
	ld hl, $4744
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
	jp c, _LABEL_3FDA_
	ld (iy+5), l
	ld (iy+6), h
	ld a, ($C020)
	ld ($C0A9), a
	ld a, $3F
	ld ($C0AB), a
	ld (ix+24), $1E
	ld hl, $4723
	jp _LABEL_4786_

; Data from 4723 to 4785 (99 bytes)
.db $CD $2B $3F $D0 $AF $32 $31 $C9 $CD $88 $48 $CD $54 $20 $2A $38
.db $C6 $73 $23 $72 $11 $1E $00 $19 $77 $3E $4F $32 $C4 $CA $C3 $1A
.db $3F $E0 $FF $20 $00 $FF $FF $01 $00 $3E $50 $32 $75 $C9 $AF $32
.db $31 $C9 $C3 $DF $3E $3A $36 $C6 $B7 $28 $08 $3E $22 $32 $75 $C9
.db $C3 $DF $3E $CD $7B $0B $E6 $0F $C6 $10 $32 $36 $C6 $3E $51 $32
.db $75 $C9 $C3 $D8 $3E $3A $20 $C0 $32 $AB $C0 $3E $19 $32 $75 $C9
.db $C3 $E5 $3E

_LABEL_4786_:
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
	ld hl, ($C638)
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
	ld hl, $3240
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

; Data from 489C to 48EF (84 bytes)
.db $DD $7E $04 $21 $E8 $48 $0F $38 $04 $23 $23 $18 $F9 $5E $23 $56
.db $DD $6E $05 $DD $66 $06 $C5 $FD $21 $40 $C1 $06 $16 $C5 $FD $7E
.db $05 $BD $20 $0A $FD $7E $06 $BC $20 $04 $C1 $C1 $AF $C9 $01 $20
.db $00 $FD $09 $C1 $10 $E7 $19 $7E $FE $0C $30 $08 $FE $06 $30 $09
.db $FE $02 $38 $05 $C1 $10 $CF $37 $C9 $C1 $37 $C9 $E0 $FF $20 $00
.db $FF $FF $01 $00

_LABEL_48F0_:
	call _LABEL_48F7_
	call _LABEL_4916_
	ret

_LABEL_48F7_:
	ld a, ($C900)
	and $0F
	add a, a
	ld e, a
	ld d, $00
	ld hl, $4935
	add hl, de
	ld de, $C617
	ldi
	ldi
	ld a, ($C900)
	bit 7, a
	ret z
	xor a
	ld ($C618), a
	ret

_LABEL_4916_:
	ld a, ($C908)
	and $0F
	add a, a
	ld e, a
	ld d, $00
	ld hl, $4955
	add hl, de
	ld de, $C619
	ldi
	ldi
	ld a, ($C908)
	bit 7, a
	ret z
	xor a
	ld ($C61A), a
	ret

; Data from 4935 to 49A6 (114 bytes)
.db $00 $00 $00 $02 $04 $04 $08 $08 $10 $0E $14 $13 $18 $19 $1E $20
.db $28 $28 $0A $0C $28 $0D $1E $0D $28 $17 $14 $0E $00 $12 $28 $1E
.db $00 $00 $08 $02 $0C $05 $10 $09 $14 $0F $18 $14 $1D $1C $23 $24
.db $28 $2C $28 $10 $32 $32 $3A $1F $C6 $57 $3A $1C $C0 $82 $3C $5F
.db $16 $00 $2A $23 $C6 $AF $ED $52 $22 $23 $C6 $EB $2A $21 $C6 $AF
.db $ED $52 $38 $04 $ED $53 $21 $C6 $3A $1F $C6 $87 $5F $16 $00 $21
.db $8D $3A $19 $11 $29 $C6 $ED $A8 $ED $A8 $11 $26 $C6 $ED $A8 $ED
.db $A8 $C9

_LABEL_49A7_:
	ld (ix+24), $00
	ld (ix+0), $B4
	ld (ix+1), $49
	ret

_LABEL_49B4_:
	ld a, ($C00D)
	bit 4, a
	jr nz, _LABEL_49D0_
	bit 5, a
	ret z
	ld a, $9B
	ld ($DD05), a
	ld (ix+24), $01
	ld (ix+0), $E0
	ld (ix+1), $49
	ret

_LABEL_49D0_:
	ld a, $9B
	ld ($DD05), a
	call _LABEL_42C_
	ld a, $09
	ld ($C018), a
	jp _LABEL_137_

_LABEL_49E0_:
	ld a, ($C00D)
	and $30
	ret z
	bit 4, a
	jr z, _LABEL_49FC_
	ld a, $9B
	ld ($DD05), a
	ld (ix+24), $00
	ld (ix+0), $B4
	ld (ix+1), $49
	ret

_LABEL_49FC_:
	ld a, ($C438)
	add a, a
	add a, a
	add a, a
	ld e, a
	ld a, ($C458)
	add a, e
	ld e, a
	ld d, $00
	ld hl, $C900
	add hl, de
	ld a, (hl)
	or a
	jr z, _LABEL_4A30_
	ld a, ($C438)
	cp $05
	jr nc, _LABEL_4A36_
	cp $02
	jp c, _LABEL_4AAD_
_LABEL_4A1E_:
	ld a, $9B
	ld ($DD05), a
	ld (ix+24), $02
	ld (ix+0), $BC
	ld (ix+1), $4A
	ret

_LABEL_4A30_:
	ld a, $A8
	ld ($DD05), a
	ret

_LABEL_4A36_:
	ld a, ($C930)
	or a
	jr z, _LABEL_4A1E_
	ld a, ($C458)
	or a
	jr nz, _LABEL_4A1E_
	ld a, ($C928)
	and $7F
	cp $56
	jr c, _LABEL_4A6F_
	cp $58
	jr z, _LABEL_4A6F_
	ld a, ($C438)
	cp $02
	jr c, _LABEL_4A58_
	ld a, $02
_LABEL_4A58_:
	add a, $4C
	ld ($CAC4), a
	ld a, $A8
	ld ($DD05), a
	ld (ix+24), $00
	call _LABEL_42C_
	ld a, $09
	ld ($C018), a
	ret

_LABEL_4A6F_:
	ld a, ($C928)
	cp $54
	call z, _LABEL_4A97_
	cp $55
	call z, _LABEL_4AA2_
	call _LABEL_4F51_
	ld a, $9B
	ld ($DD05), a
	xor a
	ld ($C930), a
	ld (ix+24), $00
	ld (ix+0), $B4
	ld (ix+1), $49
	jp _LABEL_4CAB_

_LABEL_4A97_:
	ld hl, $C630
	dec (hl)
	dec (hl)
	dec (hl)
	dec (hl)
	ret p
	ld (hl), $00
	ret

_LABEL_4AA2_:
	ld hl, $C62F
	dec (hl)
	dec (hl)
	dec (hl)
	dec (hl)
	ret p
	ld (hl), $00
	ret

_LABEL_4AAD_:
	ld a, $A8
	ld ($DD05), a
	ld a, ($C458)
	or a
	jp nz, _LABEL_4A1E_
	jp _LABEL_4A30_

_LABEL_4ABC_:
	ld a, ($C00D)
	and $30
	ret z
	bit 4, a
	jr z, _LABEL_4AD8_
	ld a, $9B
	ld ($DD05), a
	ld (ix+24), $01
	ld (ix+0), $E0
	ld (ix+1), $49
	ret

_LABEL_4AD8_:
	ld a, ($C438)
	add a, a
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, $C900
	add hl, de
	ld a, ($C478)
	dec a
	jp z, _LABEL_4C0C_
	dec a
	jp z, _LABEL_4BB2_
	ld a, ($C438)
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
	ld ($C931), a
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
	ld hl, ($C931)
	ld h, $00
	ld de, $C915
	add hl, de
	ld (hl), $00
	jp _LABEL_49D0_

_LABEL_4B25_:
	ld a, ($C930)
	or a
	jr z, _LABEL_4B41_
	ld a, ($C928)
	cp $58
	jr z, _LABEL_4B41_
	cp $56
	jp nc, _LABEL_4A4F_
	cp $54
	call z, _LABEL_4A97_
	cp $55
	call z, _LABEL_4AA2_
_LABEL_4B41_:
	ld a, $01
	ld ($C930), a
	ld de, $C928
	ld hl, ($C458)
	ld h, $00
	add hl, de
	ld a, (hl)
	ex af, af'
	ld a, (de)
	ld (hl), a
	ex af, af'
	ld (de), a
	ld ($C931), a
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
	call _LABEL_48F7_
	ld a, ($C900)
	bit 7, a
	jr nz, _LABEL_4B95_
	jr _LABEL_4BA0_

_LABEL_4B8B_:
	call _LABEL_4916_
	ld a, ($C908)
	bit 7, a
	jr z, _LABEL_4BA0_
_LABEL_4B95_:
	ld ($C931), a
	call _LABEL_42C_
	ld a, $09
	ld ($C018), a
_LABEL_4BA0_:
	call _LABEL_4F51_
	ld (ix+24), $00
	ld (ix+0), $B4
	ld (ix+1), $49
	jp _LABEL_4CAB_

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
	ld (ix+0), $54
	ld (ix+1), $4C
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
	ld a, ($C00D)
	and $0C
	ret z
	xor a
	ld ($C458), a
	ld ($C478), a
	ld a, ($C00D)
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
	ld a, ($C438)
	ld hl, $4CB4
	jp _LABEL_12D_

; Data from 4CB4 to 4CBF (12 bytes)
.db $43 $4E $54 $4E $65 $4E $79 $4E $8D $4E $A1 $4E

_LABEL_4CC0_:
	ld a, ($C418)
	cp $01
	ret nz
	ld (ix+0), $D0
	ld (ix+1), $4C
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
	ld (ix+0), $C0
	ld (ix+1), $4C
	ret

_LABEL_4CEB_:
	ld hl, $4D00
	push hl
	inc (ix+21)
	ld a, (ix+21)
	and $03
	ret nz
	bit 2, (ix+21)
	jr z, _LABEL_4D2D_
	jr _LABEL_4D45_

_LABEL_4D00_:
	ld a, ($C00D)
	and $03
	ret z
	xor a
	ld ($C478), a
	call _LABEL_4D45_
	ld a, ($C00D)
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
	ld a, ($C438)
	inc a
	call _LABEL_4E1B_
	ld (ix+0), $73
	ld (ix+1), $4D
	ret

_LABEL_4D73_:
	ld a, ($C418)
	cp $02
	jr z, _LABEL_4D8A_
	xor a
	call _LABEL_4E1B_
	call _LABEL_4D45_
	ld (ix+0), $5D
	ld (ix+1), $4D
	ret

_LABEL_4D8A_:
	ld hl, $4D9F
	push hl
	inc (ix+21)
	ld a, (ix+21)
	and $03
	ret nz
	bit 2, (ix+21)
	jr z, _LABEL_4DCB_
	jr _LABEL_4DE2_

_LABEL_4D9F_:
	ld a, ($C00D)
	and $03
	ret z
	call _LABEL_4DE2_
	ld a, ($C00D)
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
	rst $08	; _LABEL_8_
	ex (sp), hl
	ex (sp), hl
_LABEL_4DFC_:
	in a, ($BE)
	nop
	ld a, $09
	jr _LABEL_4E03_

_LABEL_4E03_:
	out ($BE), a
	nop
	nop
	djnz _LABEL_4DFC_
	ret

_LABEL_4E0A_:
	rst $08	; _LABEL_8_
	ex (sp), hl
	ex (sp), hl
_LABEL_4E0D_:
	in a, ($BE)
	nop
	ld a, $01
	jr _LABEL_4E14_

_LABEL_4E14_:
	out ($BE), a
	nop
	nop
	djnz _LABEL_4E0D_
	ret

_LABEL_4E1B_:
	add a, a
	ld e, a
	ld d, $00
	ld hl, $4E35
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, $39C6
	ex de, hl
	ld bc, $050E
	ld a, $03
	ld ($FFFF), a
	jp _LABEL_661_

; Data from 4E35 to 4E42 (14 bytes)
.db $75 $A9 $BB $A9 $BB $A9 $01 $AA $01 $AA $01 $AA $BB $A9

_LABEL_4E43_:
	ld de, $3A1E
	rst $08	; _LABEL_8_
	ld a, $7B
	out ($BE), a
	ld hl, $C900
	ld de, $A000
	jp _LABEL_4EBD_

_LABEL_4E54_:
	ld de, $3A1E
	rst $08	; _LABEL_8_
	ld a, $7B
	out ($BE), a
	ld hl, $C908
	ld de, $A020
	jp _LABEL_4EBD_

_LABEL_4E65_:
	ld de, $3A1E
	rst $08	; _LABEL_8_
	ld a, $58
	out ($BE), a
	ld hl, $C910
	ld de, $A040
	ld bc, $C935
	jp _LABEL_4EFE_

_LABEL_4E79_:
	ld de, $3A1E
	rst $08	; _LABEL_8_
	ld a, $58
	out ($BE), a
	ld hl, $C918
	ld de, $A080
	ld bc, $C945
	jp _LABEL_4EFE_

_LABEL_4E8D_:
	ld de, $3A1E
	rst $08	; _LABEL_8_
	ld a, $58
	out ($BE), a
	ld hl, $C920
	ld de, $A0C0
	ld bc, $C955
	jp _LABEL_4EFE_

_LABEL_4EA1_:
	ld de, $3A1E
	rst $08	; _LABEL_8_
	ld a, ($C930)
	or a
	ld a, $7B
	jr nz, _LABEL_4EAF_
	ld a, $58
_LABEL_4EAF_:
	out ($BE), a
	ld hl, $C928
	ld de, $A100
	ld bc, $C965
	jp _LABEL_4EFE_

_LABEL_4EBD_:
	ld a, $03
	ld ($FFFF), a
	ld c, $BE
	exx
	ld de, $3A20
	ld b, $08
_LABEL_4ECA_:
	rst $08	; _LABEL_8_
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
	rst $08	; _LABEL_8_
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
	rst $08	; _LABEL_8_
	ld a, ($C618)
	ld hl, ($C62F)
	add a, l
	ld l, a
	ld h, $00
	call _LABEL_2C98_
	call _LABEL_4F76_
	ld de, $3D74
	rst $08	; _LABEL_8_
	ld a, ($C61A)
	ld hl, ($C630)
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
	out ($BE), a
	jr _LABEL_4F86_

_LABEL_4F86_:
	ld a, $01
	out ($BE), a
	ld a, ($C0B1)
	add a, $80
	out ($BE), a
	jr _LABEL_4F93_

_LABEL_4F93_:
	ld a, $01
	out ($BE), a
	ret

; Data from 4F98 to 500F (120 bytes)
.db $DD $36 $02 $01 $DD $36 $0F $A0 $DD $36 $11 $90 $DD $36 $18 $00
.db $DD $36 $00 $B1 $DD $36 $01 $4F $C9 $3A $0D $C0 $E6 $03 $28 $15
.db $0F $30 $0A $DD $36 $18 $00 $DD $36 $0F $A0 $18 $08 $DD $36 $18
.db $01 $DD $36 $0F $B0 $3A $0D $C0 $E6 $B0 $C8 $DD $CB $18 $46 $28
.db $0F $AF $32 $3E $C6 $CD $2C $04 $3E $00 $32 $18 $C0 $C3 $37 $01
.db $21 $3E $C6 $34 $21 $31 $C6 $11 $32 $C6 $36 $00 $CD $33 $0B $CD
.db $1A $10 $2A $23 $C6 $22 $21 $C6 $3E $30 $32 $20 $C6 $CD $2C $04
.db $3E $08 $32 $18 $C0 $C3 $37 $01

_LABEL_5010_:
	ld (ix+0), $19
	ld (ix+1), $50
	ret

_LABEL_5019_:
	ld a, ($C00D)
	and $B0
	jr nz, _LABEL_5021_
	ret

_LABEL_5021_:
	xor a
	ld ($C63E), a
	call _LABEL_42C_
	ld a, $00
	ld ($C018), a
	jp _LABEL_137_

_LABEL_5030_:
	ld d, $1C
.incbin "dcsms_70b4.inc"
	ld a, ($C908)
	cp $13
	jr c, _LABEL_503F_
	inc d
	cp $16
	jr c, _LABEL_503F_
	inc d
_LABEL_503F_:
	ld (ix+3), d
	ld (ix+2), $01
	ld (ix+15), $34
	ld (ix+17), $48
	ld (ix+24), $00
	ld (ix+0), $5B
	ld (ix+1), $50
	ret

_LABEL_505B_:
	ret

; Data from 505C to 51A4 (329 bytes)
.db $DD $36 $02 $01 $DD $36 $03 $C3 $DD $36 $1A $00 $DD $36 $0F $80
.db $DD $36 $11 $80 $DD $36 $18 $20 $DD $36 $00 $7D $DD $36 $01 $50
.db $C9 $DD $35 $18 $C0 $21 $20 $C0 $22 $A4 $C0 $3E $08 $32 $A3 $C0
.db $CD $A9 $04 $DD $36 $18 $30 $DD $36 $00 $9C $DD $36 $01 $50 $C9
.db $DD $35 $18 $C0 $DD $36 $18 $10 $DD $36 $03 $C4 $DD $36 $00 $B1
.db $DD $36 $01 $50 $C9 $DD $35 $18 $C0 $DD $36 $1C $00 $DD $36 $1D
.db $FA $DD $36 $00 $C6 $DD $36 $01 $50 $C9 $DD $34 $11 $DD $34 $11
.db $DD $6E $1A $DD $66 $0F $DD $5E $1C $DD $56 $1D $19 $7C $FE $A0
.db $30 $11 $DD $75 $1A $DD $74 $0F $21 $74 $00 $19 $DD $75 $1C $DD
.db $74 $1D $C9 $21 $76 $51 $22 $20 $C1 $DD $36 $03 $00 $DD $36 $0F
.db $A1 $DD $36 $11 $B8 $DD $36 $15 $20 $DD $36 $16 $16 $DD $36 $17
.db $51 $DD $36 $00 $1E $DD $36 $01 $51 $C9 $C5 $C6 $C7 $C8 $C7 $C6
.db $C5 $00 $DD $7E $15 $B7 $28 $05 $3D $DD $77 $15 $C9 $3E $02 $DD
.db $77 $15 $DD $6E $16 $DD $66 $17 $7E $DD $77 $03 $23 $DD $75 $16
.db $DD $74 $17 $DD $34 $18 $DD $7E $18 $FE $02 $28 $10 $FE $08 $D8
.db $DD $36 $02 $00 $DD $36 $00 $67 $DD $36 $01 $51 $C9 $21 $30 $C0
.db $22 $A4 $C0 $3E $08 $32 $A3 $C0 $C3 $A9 $04 $3E $16 $32 $18 $C0
.db $21 $0F $31 $22 $00 $C1 $22 $20 $C1 $C9 $DD $36 $02 $01 $DD $36
.db $03 $C4 $DD $36 $0F $A0 $DD $36 $11 $C0 $DD $36 $18 $08 $DD $36
.db $00 $93 $DD $36 $01 $51 $C9 $DD $35 $18 $C0 $DD $36 $03 $C3 $DD
.db $36 $00 $A4 $DD $36 $01 $51 $C9 $C9

_LABEL_51A5_:
	ld a, ($C908)
	cp $19
	jr z, _LABEL_51B5_
	ld a, (ix+28)
	and $08
	jr nz, _LABEL_51B5_
	xor a
	ret

_LABEL_51B5_:
	scf
	ret

_LABEL_51B7_:
	ld a, ($C908)
	cp $11
	jr z, _LABEL_51DC_
	cp $12
	jr z, _LABEL_51DC_
	cp $19
	jr z, _LABEL_51DC_
	ld a, ($C928)
	cp $54
	jr z, _LABEL_51DC_
	ld a, (ix+28)
	and $08
	jr nz, _LABEL_51DC_
	ld a, ($C631)
	or a
	jr nz, _LABEL_51DC_
	xor a
	ret

_LABEL_51DC_:
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
	ld a, ($C619)
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
	ld de, $536D
	add hl, de
	ld a, ($C61A)
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
	ld hl, ($C621)
	or a
	sbc hl, bc
	call c, _LABEL_5356_
	call z, _LABEL_5356_
	ld ($C621), hl
	pop af
	ld l, a
	ld h, $00
	ld ($CAC6), hl
	ld a, $02
	ld ($CAC4), a
	ret

_LABEL_5356_:
	ld a, (ix+31)
	ld ($C63F), a
	ld hl, $0000
	ret

_LABEL_5360_:
	ld a, $0B
	ld ($CAC4), a
	ld (ix+29), $01
	ret

_LABEL_536A_:
	ld a, $CC
	ret

; Data from 536D to 541F (179 bytes)
.db $01 $02 $04 $06 $08 $0A $0E $14 $08 $12 $0E $35 $3C $1E $20 $1C
.db $32 $23 $34 $46 $3C $30 $3C $AF $50 $46 $8C $6E $10 $78 $B4 $64
.db $82 $DD $7E $04 $0F $38 $08 $0F $38 $29 $0F $38 $48 $18 $65 $DD
.db $6E $05 $DD $66 $06 $11 $20 $00 $B7 $ED $52 $7E $E6 $7F $28 $05
.db $DD $35 $19 $20 $F0 $DD $5E $05 $DD $56 $06 $B7 $ED $52 $DD $36
.db $19 $01 $C9 $DD $6E $05 $DD $66 $06 $11 $20 $00 $19 $7E $E6 $7F
.db $28 $05 $DD $35 $19 $20 $F2 $DD $5E $05 $DD $56 $06 $B7 $ED $52
.db $DD $36 $19 $01 $C9 $DD $6E $05 $DD $66 $06 $2B $7E $E6 $7F $28
.db $05 $DD $35 $19 $20 $F5 $DD $5E $05 $DD $56 $06 $B7 $ED $52 $DD
.db $36 $19 $01 $C9 $DD $6E $05 $DD $66 $06 $23 $7E $E6 $7F $28 $05
.db $DD $35 $19 $20 $F5 $DD $5E $05 $DD $56 $06 $B7 $ED $52 $DD $36
.db $19 $01 $C9

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

; Data from 5445 to 5459 (21 bytes)
.db $E5 $DD $5E $05 $DD $56 $06 $19 $7E $E6 $7F $FE $05 $28 $03 $E1
.db $AF $C9 $E1 $37 $C9

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

_LABEL_56C8_:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $02
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+0), $EF
	ld (ix+1), $56
	ld (ix+22), $25
	ld (ix+23), $7B
	ret

_LABEL_56EF_:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, _LABEL_570C_
	cp $09
	jr z, _LABEL_570C_
	jp _LABEL_481B_

_LABEL_570C_:
	inc (ix+25)
	ld a, (ix+25)
	cp $02
	jr nz, _LABEL_572A_
	ld (ix+25), $00
	call _LABEL_5473_
	jr nc, _LABEL_5740_
	ld (ix+0), $15
	ld (ix+1), $58
	jp _LABEL_5815_

_LABEL_572A_:
	ld (ix+24), $08
	ld (ix+0), $36
	ld (ix+1), $57
	call _LABEL_553A_
	dec (ix+24)
	jp z, _LABEL_5801_
	ret

_LABEL_5740_:
	ld a, (ix+28)
	and $01
	jr nz, _LABEL_575D_
	call _LABEL_568C_
	jr nc, _LABEL_575D_
	call _LABEL_51DE_
_LABEL_574F_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_5762_
	rrca
	jr c, _LABEL_577A_
	rrca
	jr c, _LABEL_5792_
	jr _LABEL_57AC_

_LABEL_575D_:
	call _LABEL_52A1_
	jr _LABEL_574F_

_LABEL_5762_:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, _LABEL_5770_
	ld (ix+4), $01
	jr _LABEL_57B9_

_LABEL_5770_:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr _LABEL_574F_

_LABEL_577A_:
	ld hl, $0020
	call _LABEL_5420_
	jr c, _LABEL_5788_
	ld (ix+4), $02
	jr _LABEL_57B9_

_LABEL_5788_:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr _LABEL_574F_

_LABEL_5792_:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, _LABEL_57A0_
	ld (ix+4), $04
	jr _LABEL_57B9_

_LABEL_57A0_:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr _LABEL_574F_

_LABEL_57AC_:
	ld hl, $0001
	call _LABEL_5420_
	jp c, _LABEL_572A_
	ld (ix+4), $08
_LABEL_57B9_:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), $CB
	ld (ix+1), $57
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_5801_
	ret

_LABEL_57D7_:
	ld a, $A0
	ld ($DD05), a
	call _LABEL_567B_
	ld (ix+0), $E7
	ld (ix+1), $57
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_5801_
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, _LABEL_57FE_
	call _LABEL_5302_
_LABEL_57FE_:
	jp _LABEL_5643_

_LABEL_5801_:
	call _LABEL_5655_
	ld (ix+22), $25
	ld (ix+23), $7B
	ld (ix+0), $EF
	ld (ix+1), $56
	ret

_LABEL_5815_:
	ld hl, ($C621)
	ld a, h
	or l
	jr z, _LABEL_5801_
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld (ix+24), $08
	ld (ix+22), $2E
	ld (ix+23), $7B
	ld (ix+0), $D7
	ld (ix+1), $57
	jp _LABEL_57D7_

_LABEL_583E_:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $06
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+0), $65
	ld (ix+1), $58
	ld (ix+22), $25
	ld (ix+23), $7B
	ret

_LABEL_5865_:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, _LABEL_5882_
	cp $09
	jr z, _LABEL_5882_
	jp _LABEL_481B_

_LABEL_5882_:
	inc (ix+25)
	ld a, (ix+25)
	cp $02
	jr nz, _LABEL_58A0_
	ld (ix+25), $00
	call _LABEL_5473_
	jr nc, _LABEL_58B6_
	ld (ix+0), $59
	ld (ix+1), $59
	jp _LABEL_5959_

_LABEL_58A0_:
	ld (ix+24), $08
	ld (ix+0), $AC
	ld (ix+1), $58
	call _LABEL_553A_
	dec (ix+24)
	jp z, _LABEL_5945_
	ret

_LABEL_58B6_:
	call _LABEL_52A1_
_LABEL_58B9_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_58C7_
	rrca
	jr c, _LABEL_58D5_
	rrca
	jr c, _LABEL_58E3_
	jr _LABEL_58F1_

_LABEL_58C7_:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, _LABEL_58D5_
	ld (ix+4), $01
	jr _LABEL_58FD_

_LABEL_58D5_:
	ld hl, $0020
	call _LABEL_5420_
	jr c, _LABEL_58E3_
	ld (ix+4), $02
	jr _LABEL_58FD_

_LABEL_58E3_:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, _LABEL_58F1_
	ld (ix+4), $04
	jr _LABEL_58FD_

_LABEL_58F1_:
	ld hl, $0001
	call _LABEL_5420_
	jr c, _LABEL_58A0_
	ld (ix+4), $08
_LABEL_58FD_:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), $0F
	ld (ix+1), $59
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_5945_
	ret

_LABEL_591B_:
	ld a, $A0
	ld ($DD05), a
	call _LABEL_567B_
	ld (ix+0), $2B
	ld (ix+1), $59
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_5945_
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, _LABEL_5942_
	call _LABEL_5302_
_LABEL_5942_:
	jp _LABEL_5643_

_LABEL_5945_:
	call _LABEL_5655_
	ld (ix+22), $25
	ld (ix+23), $7B
	ld (ix+0), $65
	ld (ix+1), $58
	ret

_LABEL_5959_:
	ld hl, ($C621)
	ld a, h
	or l
	jr z, _LABEL_5945_
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	call GetRandomNumber
	cp $D8
	jr nc, _LABEL_5989_
	ld (ix+30), $01
	ld (ix+24), $08
	ld (ix+22), $2E
	ld (ix+23), $7B
	ld (ix+0), $1B
	ld (ix+1), $59
	jp _LABEL_591B_

_LABEL_5989_:
	ld (ix+24), $08
	ld (ix+0), $A0
	ld (ix+1), $58
	call _LABEL_54C8_
	jp c, _LABEL_58A0_
	ld a, $A2
	ld ($DD05), a
	call _LABEL_567B_
	jp _LABEL_58B9_

; Data from 59A6 to 5C9C (759 bytes)
.db $DD $36 $02 $01 $CD $0D $55 $DD $36 $13 $02 $DD $36 $1A $26 $DD
.db $36 $1B $00 $CD $9C $56 $DD $36 $00 $CD $DD $36 $01 $59 $DD $36
.db $16 $25 $DD $36 $17 $7B $C9 $CD $67 $55 $D8 $CD $3A $55 $DD $7E
.db $1C $E6 $02 $C2 $1B $48 $3A $01 $C6 $FE $01 $28 $07 $FE $09 $28
.db $03 $C3 $1B $48 $DD $34 $19 $DD $7E $19 $FE $02 $20 $14 $DD $36
.db $19 $00 $CD $73 $54 $30 $21 $DD $36 $00 $F3 $DD $36 $01 $5A $C3
.db $F3 $5A $DD $36 $18 $08 $DD $36 $00 $14 $DD $36 $01 $5A $CD $3A
.db $55 $DD $35 $18 $CA $DF $5A $C9 $DD $7E $1C $E6 $01 $20 $16 $CD
.db $8C $56 $30 $11 $CD $DE $51 $DD $7E $04 $0F $38 $0D $0F $38 $22
.db $0F $38 $37 $18 $4F $CD $A1 $52 $18 $ED $21 $E0 $FF $CD $20 $54
.db $38 $06 $DD $36 $04 $01 $18 $49 $DD $7E $04 $E6 $FE $DD $77 $04
.db $18 $D5 $21 $20 $00 $CD $20 $54 $38 $06 $DD $36 $04 $02 $18 $31
.db $DD $7E $04 $E6 $FD $DD $77 $04 $18 $BD $21 $FF $FF $CD $20 $54
.db $38 $06 $DD $36 $04 $04 $18 $19 $DD $7E $04 $E6 $FB $F6 $03 $DD
.db $77 $04 $18 $A3 $21 $01 $00 $CD $20 $54 $DA $08 $5A $DD $36 $04
.db $08 $DD $75 $07 $DD $74 $08 $DD $36 $18 $08 $DD $36 $00 $A9 $DD
.db $36 $01 $5A $CD $BB $47 $CD $3A $55 $DD $35 $18 $28 $2B $C9 $3E
.db $A0 $32 $05 $DD $CD $7B $56 $DD $36 $00 $C5 $DD $36 $01 $5A $CD
.db $3A $55 $DD $35 $18 $28 $12 $DD $7E $1E $B7 $C8 $DD $7E $18 $FE
.db $01 $20 $03 $CD $02 $53 $C3 $43 $56 $CD $55 $56 $DD $36 $16 $25
.db $DD $36 $17 $7B $DD $36 $00 $CD $DD $36 $01 $59 $C9 $2A $21 $C6
.db $7C $B5 $28 $E5 $CD $3A $55 $CD $F6 $1E $D8 $CD $7B $0B $FE $A0
.db $30 $1B $DD $36 $1E $01 $DD $36 $18 $08 $DD $36 $16 $2E $DD $36
.db $17 $7B $DD $36 $00 $B5 $DD $36 $01 $5A $C3 $B5 $5A $DD $36 $18
.db $08 $DD $36 $00 $08 $DD $36 $01 $5A $CD $C8 $54 $DA $08 $5A $3E
.db $A2 $32 $05 $DD $CD $7B $56 $C3 $2D $5A $DD $36 $02 $01 $CD $0D
.db $55 $DD $36 $13 $04 $DD $36 $1A $A0 $DD $36 $1B $00 $CD $9C $56
.db $DD $36 $00 $67 $DD $36 $01 $5B $DD $36 $16 $25 $DD $36 $17 $7B
.db $C9 $CD $67 $55 $D8 $CD $3A $55 $DD $7E $1C $E6 $02 $C2 $1B $48
.db $3A $01 $C6 $FE $01 $28 $07 $FE $09 $28 $03 $C3 $1B $48 $3E $02
.db $DD $77 $19 $CD $73 $54 $30 $25 $DD $36 $00 $70 $DD $36 $01 $5C
.db $C3 $70 $5C $DD $36 $19 $01 $DD $36 $18 $08 $DD $36 $00 $A9 $DD
.db $36 $01 $5B $CD $3A $55 $DD $35 $18 $CA $42 $5C $C9 $CD $A1 $52
.db $DD $7E $04 $0F $38 $08 $0F $38 $13 $0F $38 $1E $18 $2A $21 $E0
.db $FF $CD $20 $54 $38 $06 $DD $36 $04 $01 $18 $28 $21 $20 $00 $CD
.db $20 $54 $38 $06 $DD $36 $04 $02 $18 $1A $21 $FF $FF $CD $20 $54
.db $38 $06 $DD $36 $04 $04 $18 $0C $21 $01 $00 $CD $20 $54 $38 $A3
.db $DD $36 $04 $08 $DD $75 $07 $DD $74 $08 $DD $36 $18 $04 $DD $36
.db $00 $0C $DD $36 $01 $5C $CD $BB $47 $CD $3A $55 $DD $35 $18 $28
.db $2B $C9 $3E $A0 $32 $05 $DD $CD $7B $56 $DD $36 $00 $28 $DD $36
.db $01 $5C $CD $3A $55 $DD $35 $18 $28 $12 $DD $7E $1E $B7 $C8 $DD
.db $7E $18 $FE $01 $20 $03 $CD $02 $53 $C3 $43 $56 $DD $35 $19 $20
.db $14 $CD $55 $56 $DD $36 $16 $25 $DD $36 $17 $7B $DD $36 $00 $67
.db $DD $36 $01 $5B $C9 $DD $7E $07 $DD $77 $05 $DD $7E $08 $DD $77
.db $06 $DD $36 $00 $89 $DD $36 $01 $5B $C9 $2A $21 $C6 $7C $B5 $28
.db $CB $CD $3A $55 $CD $F6 $1E $D8 $DD $36 $1E $01 $DD $36 $18 $08
.db $DD $36 $19 $01 $DD $36 $16 $2E $DD $36 $17 $7B $DD $36 $00 $18
.db $DD $36 $01 $5C $C3 $18 $5C

_LABEL_5C9D_:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $06
	ld (ix+27), $00
	ld (ix+3), $23
	call _LABEL_569C_
	ld (ix+0), $C8
	ld (ix+1), $5C
	ld (ix+22), $37
	ld (ix+23), $7B
	ret

_LABEL_5CC8_:
	call _LABEL_5567_
	ret c
	call _LABEL_1EB1_
	ret c
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, _LABEL_5CE6_
	cp $09
	jr z, _LABEL_5CE6_
	jp _LABEL_481B_

_LABEL_5CE6_:
	call _LABEL_5473_
	jr nc, _LABEL_5D09_
	ld (ix+0), $3E
	ld (ix+1), $5E
	jp _LABEL_5E3E_

_LABEL_5CF6_:
	ld (ix+24), $08
	ld (ix+0), $02
	ld (ix+1), $5D
	dec (ix+24)
	jp z, _LABEL_5E32_
	ret

_LABEL_5D09_:
	ld a, (ix+28)
	and $01
	jr nz, _LABEL_5D21_
	call _LABEL_51DE_
_LABEL_5D13_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_5D26_
	rrca
	jr c, _LABEL_5D46_
	rrca
	jr c, _LABEL_5D66_
	jr _LABEL_5D88_

_LABEL_5D21_:
	call _LABEL_52A1_
	jr _LABEL_5D13_

_LABEL_5D26_:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, _LABEL_5D3C_
	ld (ix+4), $01
	ld (ix+22), $55
	ld (ix+23), $7B
	jr _LABEL_5D9D_

_LABEL_5D3C_:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr _LABEL_5D13_

_LABEL_5D46_:
	ld hl, $0020
	call _LABEL_5420_
	jr c, _LABEL_5D5C_
	ld (ix+4), $02
	ld (ix+22), $4B
	ld (ix+23), $7B
	jr _LABEL_5D9D_

_LABEL_5D5C_:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr _LABEL_5D13_

_LABEL_5D66_:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, _LABEL_5D7C_
	ld (ix+4), $04
	ld (ix+22), $37
	ld (ix+23), $7B
	jr _LABEL_5D9D_

_LABEL_5D7C_:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr _LABEL_5D13_

_LABEL_5D88_:
	ld hl, $0001
	call _LABEL_5420_
	jp c, _LABEL_5CF6_
	ld (ix+4), $08
	ld (ix+22), $41
	ld (ix+23), $7B
_LABEL_5D9D_:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), $AF
	ld (ix+1), $5D
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_5E32_
	ret

_LABEL_5DBB_:
	ld a, $A0
	ld ($DD05), a
	call _LABEL_567B_
	ld (ix+0), $CB
	ld (ix+1), $5D
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_5DE5_
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, _LABEL_5DE2_
	call _LABEL_5302_
_LABEL_5DE2_:
	jp _LABEL_5643_

_LABEL_5DE5_:
	ld a, (ix+29)
	or a
	jr nz, _LABEL_5E32_
	ld a, $01
	ld ($C102), a
	call _LABEL_51A5_
	jr c, _LABEL_5E32_
	ld a, ($C634)
	or a
	jr nz, _LABEL_5E32_
	call GetRandomNumber
	cp $40
	jr nc, _LABEL_5E32_
	ld (ix+24), $10
	ld (ix+0), $0E
	ld (ix+1), $5E
	dec (ix+24)
	ret nz
	call GetRandomNumber
	and $0F
	ld b, $10
	add a, b
	ld ($C634), a
	ld a, $42
	ld ($CAC4), a
	ld (ix+24), $10
	ld (ix+0), $2E
	ld (ix+1), $5E
	dec (ix+24)
	ret nz
_LABEL_5E32_:
	call _LABEL_5655_
	ld (ix+0), $C8
	ld (ix+1), $5C
	ret

_LABEL_5E3E_:
	ld hl, ($C621)
	ld a, h
	or l
	jr z, _LABEL_5E32_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, _LABEL_5E5B_
	rrca
	jr c, _LABEL_5E65_
	rrca
	jr c, _LABEL_5E6F_
	jr _LABEL_5E79_

_LABEL_5E5B_:
	ld (ix+22), $5A
	ld (ix+23), $7B
	jr _LABEL_5E81_

_LABEL_5E65_:
	ld (ix+22), $50
	ld (ix+23), $7B
	jr _LABEL_5E81_

_LABEL_5E6F_:
	ld (ix+22), $3C
	ld (ix+23), $7B
	jr _LABEL_5E81_

_LABEL_5E79_:
	ld (ix+22), $46
	ld (ix+23), $7B
_LABEL_5E81_:
	ld (ix+24), $0A
	ld (ix+0), $BB
	ld (ix+1), $5D
	jp _LABEL_5DBB_

_LABEL_5E90_:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $18
	ld (ix+27), $00
	ld (ix+3), $23
	call _LABEL_569C_
	ld (ix+0), $C8
	ld (ix+1), $5C
	ld (ix+22), $37
	ld (ix+23), $7B
	ret

; Data from 5EBB to 5EE5 (43 bytes)
.db $DD $36 $02 $01 $CD $0D $55 $DD $36 $13 $02 $DD $36 $1A $34 $DD
.db $36 $1B $00 $DD $36 $03 $23 $CD $9C $56 $DD $36 $00 $C8 $DD $36
.db $01 $5C $DD $36 $16 $37 $DD $36 $17 $7B $C9

_LABEL_5EE6_:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $0A
	ld (ix+27), $00
	ld (ix+3), $2F
	call _LABEL_569C_
	ld (ix+0), $09
	ld (ix+1), $5F
	ret

_LABEL_5F09_:
	call _LABEL_5567_
	ret c
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, _LABEL_5F23_
	cp $09
	jr z, _LABEL_5F23_
	jp _LABEL_481B_

_LABEL_5F23_:
	call _LABEL_5473_
	jr nc, _LABEL_5F46_
	ld (ix+0), $69
	ld (ix+1), $60
	jp _LABEL_6069_

_LABEL_5F33_:
	ld (ix+24), $08
	ld (ix+0), $3F
	ld (ix+1), $5F
	dec (ix+24)
	jp z, _LABEL_605D_
	ret

_LABEL_5F46_:
	call _LABEL_1EB1_
	jr c, _LABEL_5F67_
	call _LABEL_557D_
	jr nc, _LABEL_5F67_
	call _LABEL_55BF_
	jr c, _LABEL_5F67_
	call GetRandomNumber
	cp $80
	jr nc, _LABEL_5F67_
	ld (ix+0), $69
	ld (ix+1), $60
	jp _LABEL_6069_

_LABEL_5F67_:
	ld a, (ix+28)
	and $01
	jr nz, _LABEL_5F7F_
	call _LABEL_51DE_
_LABEL_5F71_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_5F84_
	rrca
	jr c, _LABEL_5FA4_
	rrca
	jr c, _LABEL_5FC4_
	jr _LABEL_5FE6_

_LABEL_5F7F_:
	call _LABEL_52A1_
	jr _LABEL_5F71_

_LABEL_5F84_:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, _LABEL_5F9A_
	ld (ix+4), $01
	ld (ix+22), $64
	ld (ix+23), $7B
	jr _LABEL_5FFB_

_LABEL_5F9A_:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr _LABEL_5F71_

_LABEL_5FA4_:
	ld hl, $0020
	call _LABEL_5420_
	jr c, _LABEL_5FBA_
	ld (ix+4), $02
	ld (ix+22), $64
	ld (ix+23), $7B
	jr _LABEL_5FFB_

_LABEL_5FBA_:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr _LABEL_5F71_

_LABEL_5FC4_:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, _LABEL_5FDA_
	ld (ix+4), $04
	ld (ix+22), $5F
	ld (ix+23), $7B
	jr _LABEL_5FFB_

_LABEL_5FDA_:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr _LABEL_5F71_

_LABEL_5FE6_:
	ld hl, $0001
	call _LABEL_5420_
	jp c, _LABEL_5F33_
	ld (ix+4), $08
	ld (ix+22), $5F
	ld (ix+23), $7B
_LABEL_5FFB_:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+0), $0D
	ld (ix+1), $60
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_605D_
	ret

_LABEL_6019_:
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_602A_
	ld a, (ix+24)
	cp $08
	call z, _LABEL_60BB_
	ret

_LABEL_602A_:
	ld (ix+24), $10
	ld (ix+0), $36
	ld (ix+1), $60
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), $4B
	ld (ix+1), $60
	ld a, $A0
	ld ($DD05), a
	call _LABEL_567B_
	dec (ix+24)
	jr z, _LABEL_605D_
	ld a, (ix+24)
	cp $01
	jr nz, _LABEL_605A_
	call _LABEL_5302_
_LABEL_605A_:
	jp _LABEL_5643_

_LABEL_605D_:
	call _LABEL_5655_
	ld (ix+0), $09
	ld (ix+1), $5F
	ret

_LABEL_6069_:
	ld hl, ($C621)
	ld a, h
	or l
	jr z, _LABEL_605D_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, _LABEL_6086_
	rrca
	jr c, _LABEL_6090_
	rrca
	jr c, _LABEL_609A_
	jr _LABEL_60A4_

_LABEL_6086_:
	ld (ix+22), $69
	ld (ix+23), $7B
	jr _LABEL_60AC_

_LABEL_6090_:
	ld (ix+22), $72
	ld (ix+23), $7B
	jr _LABEL_60AC_

_LABEL_609A_:
	ld (ix+22), $84
	ld (ix+23), $7B
	jr _LABEL_60AC_

_LABEL_60A4_:
	ld (ix+22), $7B
	ld (ix+23), $7B
_LABEL_60AC_:
	ld (ix+24), $10
	ld (ix+0), $19
	ld (ix+1), $60
	jp _LABEL_6019_

_LABEL_60BB_:
	ld hl, $7A1C
	ld ($C3C0), hl
	jp _LABEL_56A9_

; Data from 60C4 to 60E6 (35 bytes)
.db $DD $36 $02 $01 $CD $0D $55 $DD $36 $13 $02 $DD $36 $1A $60 $DD
.db $36 $1B $00 $DD $36 $03 $2F $CD $9C $56 $DD $36 $00 $09 $DD $36
.db $01 $5F $C9

_LABEL_60E7_:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $04
	ld (ix+26), $09
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+22), $92
	ld (ix+23), $7B
	ld (ix+0), $0E
	ld (ix+1), $61
	ret

_LABEL_610E_:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, _LABEL_612B_
	cp $09
	jr z, _LABEL_612B_
	jp _LABEL_481B_

_LABEL_612B_:
	ld (ix+25), $02
	call _LABEL_1EB1_
	jr c, _LABEL_6177_
	call _LABEL_5473_
	jr nc, _LABEL_6144_
	ld (ix+0), $C9
	ld (ix+1), $62
	jp _LABEL_62C9_

_LABEL_6144_:
	call _LABEL_557D_
	jr nc, _LABEL_6177_
	call _LABEL_55BF_
	jr c, _LABEL_6177_
	call GetRandomNumber
	cp $80
	jr nc, _LABEL_6160_
	ld (ix+0), $C9
	ld (ix+1), $62
	jp _LABEL_62C9_

_LABEL_6160_:
	ld (ix+24), $08
	ld (ix+0), $6D
	ld (ix+1), $61
	ret

_LABEL_616D_:
	call _LABEL_553A_
	dec (ix+24)
	jp z, _LABEL_62BD_
	ret

_LABEL_6177_:
	ld a, (ix+28)
	and $01
	jr nz, _LABEL_618F_
	call _LABEL_51DE_
_LABEL_6181_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_6194_
	rrca
	jr c, _LABEL_61AC_
	rrca
	jr c, _LABEL_61C4_
	jr _LABEL_61DE_

_LABEL_618F_:
	call _LABEL_52A1_
	jr _LABEL_6181_

_LABEL_6194_:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, _LABEL_61A2_
	ld (ix+4), $01
	jr _LABEL_61EB_

_LABEL_61A2_:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr _LABEL_6181_

_LABEL_61AC_:
	ld hl, $0020
	call _LABEL_5420_
.incbin "dcsms_7a5b.inc"
	jr c, _LABEL_61BA_
	ld (ix+4), $02
	jr _LABEL_61EB_

_LABEL_61BA_:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr _LABEL_6181_

_LABEL_61C4_:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, _LABEL_61D2_
	ld (ix+4), $04
	jr _LABEL_61EB_

_LABEL_61D2_:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr _LABEL_6181_

_LABEL_61DE_:
	ld hl, $0001
	call _LABEL_5420_
	jp c, _LABEL_6160_
	ld (ix+4), $08
_LABEL_61EB_:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $04
	ld (ix+0), $FD
	ld (ix+1), $61
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_6209_
	ret

_LABEL_6209_:
	ld a, (ix+7)
	ld (ix+5), a
	ld a, (ix+8)
	ld (ix+6), a
	dec (ix+25)
	jp z, _LABEL_62BD_
	ld (ix+0), $2F
	ld (ix+1), $61
	ret

_LABEL_6224_:
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_6235_
	ld a, (ix+24)
	cp $08
	call z, _LABEL_62EA_
	ret

_LABEL_6235_:
	ld (ix+24), $10
	ld (ix+0), $42
	ld (ix+1), $62
	ret

_LABEL_6242_:
	call _LABEL_553A_
	ld a, ($C3C2)
	or a
	ret nz
	ld (ix+0), $5A
	ld (ix+1), $62
	ld a, $A0
	ld ($DD05), a
	call _LABEL_567B_
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_626F_
	ld a, (ix+24)
	cp $01
	jr nz, _LABEL_626C_
	call _LABEL_5302_
_LABEL_626C_:
	jp _LABEL_5643_

_LABEL_626F_:
	ld a, (ix+29)
	or a
	jr nz, _LABEL_62BD_
	ld a, $01
	ld ($C102), a
	call _LABEL_51A5_
	jr c, _LABEL_62BD_
	ld a, ($C636)
	or a
	jr nz, _LABEL_62BD_
	call GetRandomNumber
	cp $18
	jp nc, _LABEL_62BD_
	ld (ix+24), $10
	ld (ix+0), $99
	ld (ix+1), $62
	dec (ix+24)
	ret nz
	call GetRandomNumber
	and $07
	ld b, $08
	add a, b
	ld ($C636), a
	ld a, $33
	ld ($CAC4), a
	ld (ix+24), $10
	ld (ix+0), $B9
	ld (ix+1), $62
	dec (ix+24)
	ret nz
_LABEL_62BD_:
	call _LABEL_5655_
	ld (ix+0), $0E
	ld (ix+1), $61
	ret

_LABEL_62C9_:
	ld hl, ($C621)
	ld a, h
	or l
	jr z, _LABEL_62BD_
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld (ix+24), $10
	ld (ix+0), $24
	ld (ix+1), $62
	jp _LABEL_6224_

_LABEL_62EA_:
	ld hl, $7A46
	ld ($C3C0), hl
	jp _LABEL_56A9_

; Data from 62F3 to 64E6 (500 bytes)
.db $DD $36 $02 $01 $CD $0D $55 $DD $36 $13 $04 $DD $36 $1A $32 $DD
.db $36 $1B $00 $CD $9C $56 $DD $36 $16 $92 $DD $36 $17 $7B $DD $36
.db $00 $0E $DD $36 $01 $61 $C9 $DD $36 $02 $01 $CD $0D $55 $DD $36
.db $1A $1E $DD $36 $1B $00 $DD $36 $03 $45 $CD $9C $56 $DD $36 $00
.db $39 $DD $36 $01 $63 $C9 $CD $67 $55 $D8 $DD $7E $1C $E6 $02 $C2
.db $1B $48 $3A $01 $C6 $FE $01 $28 $07 $FE $09 $28 $03 $C3 $1B $48
.db $CD $B1 $1E $DA $1B $48 $CD $7D $55 $30 $10 $CD $BF $55 $38 $0B
.db $DD $36 $00 $4E $DD $36 $01 $64 $C3 $4E $64 $CD $7B $0B $E6 $03
.db $20 $02 $3E $04 $DD $77 $19 $CD $A1 $52 $DD $7E $04 $0F $38 $08
.db $0F $38 $13 $0F $38 $1E $18 $2A $DD $36 $04 $01 $CD $8E $53 $CD
.db $20 $54 $38 $02 $18 $27 $DD $36 $04 $02 $CD $8E $53 $CD $20 $54
.db $38 $02 $18 $19 $DD $36 $04 $04 $CD $8E $53 $CD $20 $54 $38 $02
.db $18 $0B $DD $36 $04 $08 $CD $8E $53 $CD $20 $54 $D8 $DD $75 $07
.db $DD $74 $08 $DD $36 $18 $08 $DD $36 $16 $9B $DD $36 $17 $7B $DD
.db $36 $00 $DA $DD $36 $01 $63 $CD $3A $55 $DD $35 $18 $28 $5C $DD
.db $7E $18 $FE $04 $CC $EB $63 $C9 $DD $7E $07 $DD $77 $05 $DD $7E
.db $08 $DD $77 $06 $C3 $0D $55 $CD $3A $55 $DD $35 $18 $28 $09 $DD
.db $7E $18 $FE $06 $CC $A0 $64 $C9 $DD $36 $18 $10 $DD $36 $00 $17
.db $DD $36 $01 $64 $3A $C2 $C3 $B7 $C0 $DD $36 $00 $2C $DD $36 $01
.db $64 $3E $A0 $32 $05 $DD $CD $7B $56 $DD $35 $18 $28 $0D $DD $7E
.db $18 $FE $01 $20 $03 $CD $02 $53 $C3 $43 $56 $CD $55 $56 $DD $36
.db $19 $00 $DD $36 $00 $39 $DD $36 $01 $63 $C9 $2A $21 $C6 $7C $B5
.db $28 $E9 $CD $F6 $1E $D8 $DD $36 $1E $01 $DD $7E $04 $0F $38 $08
.db $0F $38 $0F $0F $38 $16 $18 $1E $DD $36 $16 $C1 $DD $36 $17 $7B
.db $18 $1C $DD $36 $16 $AC $DD $36 $17 $7B $18 $12 $DD $36 $16 $B3
.db $DD $36 $17 $7B $18 $08 $DD $36 $16 $BA $DD $36 $17 $7B $DD $36
.db $18 $0C $DD $36 $00 $FA $DD $36 $01 $63 $C3 $FA $63 $21 $5B $7A
.db $22 $C0 $C3 $C3 $A9 $56 $DD $36 $02 $01 $CD $0D $55 $DD $36 $1A
.db $50 $DD $36 $1B $00 $DD $36 $03 $45 $CD $9C $56 $DD $36 $00 $39
.db $DD $36 $01 $63 $C9 $DD $36 $02 $01 $CD $0D $55 $DD $36 $1A $B4
.db $DD $36 $1B $00 $DD $36 $03 $45 $CD $9C $56 $DD $36 $00 $39 $DD
.db $36 $01 $63 $C9

_LABEL_64E7_:
	ld (ix+2), $01
	call _LABEL_550D_
	ld (ix+19), $02
	ld (ix+26), $28
	ld (ix+27), $00
	call _LABEL_569C_
	ld (ix+0), $0E
	ld (ix+1), $65
	ld (ix+22), $D2
	ld (ix+23), $7B
	ret

_LABEL_650E_:
	call _LABEL_5567_
	ret c
	call _LABEL_553A_
	ld a, (ix+28)
	and $02
	jp nz, _LABEL_481B_
	ld a, ($C601)
	cp $01
	jr z, _LABEL_652B_
	cp $09
	jr z, _LABEL_652B_
	jp _LABEL_481B_

_LABEL_652B_:
	inc (ix+25)
	ld a, (ix+25)
	cp $02
	jr nz, _LABEL_6549_
	ld (ix+25), $00
	call _LABEL_5473_
.incbin "dcsms_6730.inc"
	jr nc, _LABEL_655F_
	ld (ix+0), $D3
	ld (ix+1), $66
	jp _LABEL_66D3_

_LABEL_6549_:
	ld (ix+24), $08
	ld (ix+0), $55
	ld (ix+1), $65
	call _LABEL_553A_
	dec (ix+24)
	jp z, _LABEL_66C7_
	ret

_LABEL_655F_:
	ld a, (ix+28)
	and $01
	jr nz, _LABEL_657C_
	call _LABEL_568C_
	jr nc, _LABEL_657C_
	call _LABEL_51DE_
_LABEL_656E_:
	ld a, (ix+4)
	rrca
	jr c, _LABEL_6581_
	rrca
	jr c, _LABEL_65A1_
	rrca
	jr c, _LABEL_65C1_
	jr _LABEL_65E3_

_LABEL_657C_:
	call _LABEL_52A1_
	jr _LABEL_656E_

_LABEL_6581_:
	ld hl, $FFE0
	call _LABEL_5420_
	jr c, _LABEL_6597_
	ld (ix+4), $01
	ld (ix+22), $C8
	ld (ix+23), $7B
	jr _LABEL_65F8_

_LABEL_6597_:
	ld a, (ix+4)
	and $FE
	ld (ix+4), a
	jr _LABEL_656E_

_LABEL_65A1_:
	ld hl, $0020
	call _LABEL_5420_
	jr c, _LABEL_65B7_
	ld (ix+4), $02
	ld (ix+22), $CD
	ld (ix+23), $7B
	jr _LABEL_65F8_

_LABEL_65B7_:
	ld a, (ix+4)
	and $FD
	ld (ix+4), a
	jr _LABEL_656E_

_LABEL_65C1_:
	ld hl, $FFFF
	call _LABEL_5420_
	jr c, _LABEL_65D7_
	ld (ix+4), $04
	ld (ix+22), $D2
	ld (ix+23), $7B
	jr _LABEL_65F8_

_LABEL_65D7_:
	ld a, (ix+4)
	and $FB
	or $03
	ld (ix+4), a
	jr _LABEL_656E_

_LABEL_65E3_:
	ld hl, $0001
	call _LABEL_5420_
	jp c, _LABEL_6549_
	ld (ix+4), $08
	ld (ix+22), $D7
	ld (ix+23), $7B
_LABEL_65F8_:
	ld (ix+7), l
	ld (ix+8), h
	ld (ix+24), $08
	ld (ix+21), $00
	ld (ix+20), $00
	ld (ix+0), $12
	ld (ix+1), $66
	call _LABEL_47BB_
	call _LABEL_553A_
	dec (ix+24)
	jp z, _LABEL_66C7_
	ret

_LABEL_661F_:
	ld a, $A0
	ld ($DD05), a
	call _LABEL_567B_
	ld (ix+0), $2F
	ld (ix+1), $66
	call _LABEL_553A_
	dec (ix+24)
	jr z, _LABEL_6649_
	ld a, (ix+30)
	or a
	ret z
	ld a, (ix+24)
	cp $01
	jr nz, _LABEL_6646_
	call _LABEL_5302_
_LABEL_6646_:
	jp _LABEL_5643_

_LABEL_6649_:
	ld a, (ix+29)
	or a
	jr nz, _LABEL_66C7_
	ld a, $01
	ld ($C102), a
	ld a, (ix+31)
	cp $13
	jr z, _LABEL_6661_
	cp $1B
	jr z, _LABEL_668C_
	jr _LABEL_66C7_

_LABEL_6661_:
	call _LABEL_51B7_
	jr c, _LABEL_66C7_
	ld a, ($C908)
	cp $10
	jr z, _LABEL_66C7_
	ld a, $10
	ld ($C908), a
	ld (ix+24), $10
	ld (ix+0), $7E
	ld (ix+1), $66
	dec (ix+24)
	ret nz
	call _LABEL_4916_
	ld a, $43
	ld ($CAC4), a
	jr _LABEL_66C7_

_LABEL_668C_:
	ld a, (ix+28)
	and $08
	jr nz, _LABEL_66C7_
	ld a, ($C900)
	cp $01
	jr z, _LABEL_66C7_
	ld a, $01
	ld ($C900), a
	ld (ix+24), $10
	ld (ix+0), $AB
	ld (ix+1), $66
	dec (ix+24)
	ret nz
	call _LABEL_48F7_
	ld a, $44
	ld ($CAC4), a
	ld (ix+24), $10
	ld (ix+0), $C3
	ld (ix+1), $66
	dec (ix+24)
	ret nz
_LABEL_66C7_:
	call _LABEL_5655_
	ld (ix+0), $0E
	ld (ix+1), $65
	ret

_LABEL_66D3_:
	ld hl, ($C621)
	ld a, h
	or l
	jr z, _LABEL_66C7_
	call _LABEL_553A_
	call _LABEL_1EF6_
	ret c
	ld (ix+30), $01
	ld a, (ix+4)
	rrca
	jr c, _LABEL_66F3_
	rrca
	jr c, _LABEL_66FD_
	rrca
	jr c, _LABEL_6707_
	jr _LABEL_6711_

_LABEL_66F3_:
	ld (ix+22), $C8
	ld (ix+23), $7B
	jr _LABEL_6719_

_LABEL_66FD_:
	ld (ix+22), $CD
	ld (ix+23), $7B
	jr _LABEL_6719_

_LABEL_6707_:
	ld (ix+22), $D2
	ld (ix+23), $7B
	jr _LABEL_6719_

_LABEL_6711_:
	ld (ix+22), $D7
	ld (ix+23), $7B
_LABEL_6719_:
	ld (ix+24), $08
	ld (ix+21), $00
	ld (ix+20), $00
	ld (ix+0), $1F
	ld (ix+1), $66
	jp _LABEL_661F_

; Data from 6730 to 6FFF (2256 bytes)

; 5th entry of Jump Table from 1C108 (indexed by $DD03)
_LABEL_7000_:
	dec (ix+24)
	jr z, _LABEL_7012_
	ld a, (ix+24)
	cp $01
	jr nz, _LABEL_700F_
	call _LABEL_5302_
_LABEL_700F_:
	jp _LABEL_5643_

_LABEL_7012_:
	ld a, (ix+29)
	or a
	jp nz, _LABEL_709E_
	ld a, (ix+31)
	cp $10
	jr z, _LABEL_709E_
	cp $18
	jr z, _LABEL_702B_
	call GetRandomNumber
	cp $80
	jr nc, _LABEL_709E_
_LABEL_702B_:
	ld a, $01
	ld ($C102), a
	ld a, (ix+28)
	and $08
	jr nz, _LABEL_709E_
	ld hl, ($C623)
	ld a, h
	or l
	jr z, _LABEL_709E_
	call GetRandomNumber
	and $07
	ld b, $08
	push af
	ld a, (ix+31)
	cp $18
	call z, _LABEL_7082_
	pop af
	add a, b
	ld c, a
	ld b, $00
	ld hl, ($C623)
	or a
	sbc hl, bc
	call c, _LABEL_7077_
	ld ($C623), hl
	ld bc, ($C621)
	or a
	sbc hl, bc
	call c, _LABEL_707B_
	ld (ix+24), $10
	ld (ix+0), $85
	ld (ix+1), $70
	jr _LABEL_7085_

_LABEL_7077_:
	ld hl, $0000
	ret

_LABEL_707B_:
	ld hl, ($C623)
	ld ($C621), hl
	ret

_LABEL_7082_:
	ld b, $0C
	ret

_LABEL_7085_:
	dec (ix+24)
	ret nz
	ld a, $35
	ld ($CAC4), a
	ld (ix+24), $10
	ld (ix+0), $9A
	ld (ix+1), $70
	dec (ix+24)
	ret nz
_LABEL_709E_:
	ld a, $01
	ld ($C102), a
	ld (ix+30), $00
	ld (ix+24), $00
	ld (ix+0), $8E
	ld (ix+1), $6F
	ret

; Data from 70B4 to 7A1B (2408 bytes)

_LABEL_7A1C_:
	ld (ix+2), $01
	ld (ix+3), $3B
	ld (ix+19), $04
	ld (ix+0), $34
	ld (ix+1), $7A
	ret

; Data from 7A31 to 7A33 (3 bytes)
.db $CD $3A $55

_LABEL_7A34_:
	call _LABEL_47BB_
	call _LABEL_52C6_
	jr c, _LABEL_7A3D_
	ret

_LABEL_7A3D_:
	ld (ix+0), $0F
	ld (ix+1), $31
	ret

_LABEL_7A46_:
	ld (ix+2), $01
	ld (ix+3), $41
	ld (ix+19), $04
	ld (ix+0), $34
	ld (ix+1), $7A
	ret

; Data from 7A5B to 7FFF (1445 bytes)

.BANK 2
.ORG $0000

; Data from 8000 to BFFF (16384 bytes)

.BANK 3
.ORG $0000

; Data from C000 to FFFF (16384 bytes)

.BANK 4
.ORG $0000

; Data from 10000 to 13FFF (16384 bytes)

.BANK 5
.ORG $0000

; Data from 14000 to 17FFF (16384 bytes)

.BANK 6
.ORG $0000

; Data from 18000 to 1BFFF (16384 bytes)

.BANK 7
.ORG $0000

_LABEL_1C000_:
	ld hl, $DD08
	ld a, (hl)
	or a
	jr z, _LABEL_1C00C_
	ret p
	dec (hl)
	jp _LABEL_1C3C4_

_LABEL_1C00C_:
	call _LABEL_1C082_
	call _LABEL_1C069_
	call _LABEL_1C0B3_
	call _LABEL_1C0EA_
	call _LABEL_1C1E3_
	ld ix, $DD40
	bit 7, (ix+0)
	call nz, _LABEL_1C48F_
	ld ix, $DD70
	bit 7, (ix+0)
	call nz, _LABEL_1C48F_
	ld ix, $DDA0
	bit 7, (ix+0)
	call nz, _LABEL_1C48F_
	ld ix, $DDD0
	bit 7, (ix+0)
	call nz, _LABEL_1C617_
	ld ix, $DE00
	bit 7, (ix+0)
	call nz, _LABEL_1C48F_
	ld ix, $DE30
	bit 7, (ix+0)
	call nz, _LABEL_1C48F_
	ld ix, $DE60
	bit 7, (ix+0)
	call nz, _LABEL_1C48F_
	ret

_LABEL_1C069_:
	ld hl, $DD01
	ld a, (hl)
	or a
	ret z
	dec (hl)
	ret nz
	ld a, ($DD02)
	ld (hl), a
	ld hl, $DD4A
	ld de, $0030
	ld b, $04
_LABEL_1C07D_:
	inc (hl)
	add hl, de
	djnz _LABEL_1C07D_
	ret

_LABEL_1C082_:
	ld de, $DD04
	ld ix, $DD0F
	ld iy, $DD03
	call _LABEL_1C093_
	call _LABEL_1C093_
_LABEL_1C093_:
	ld a, (de)
	and $7F
	jr z, _LABEL_1C0AF_
_LABEL_1C098_:
	dec a
	ld hl, $8938
	ld c, a
	ld b, $00
	add hl, bc
	ld a, (hl)
	cp (ix+0)
	jr c, _LABEL_1C0AF_
	and $7F
	ld (ix+0), a
	ld a, (de)
	ld (iy+0), a
_LABEL_1C0AF_:
	xor a
	ld (de), a
	inc de
	ret

_LABEL_1C0B3_:
	ld a, ($DD09)
	or a
	ret z
	ld a, ($DD0A)
	dec a
	jr z, _LABEL_1C0C2_
	ld ($DD0A), a
	ret

_LABEL_1C0C2_:
	ld a, ($DD0B)
	ld ($DD0A), a
	ld a, ($DD09)
	dec a
	ld ($DD09), a
	jp z, _LABEL_1C3B1_
	ld hl, $DD48
	ld de, $0030
	ld b, $03
_LABEL_1C0DA_:
	call _LABEL_1C0E3_
	add hl, de
	djnz _LABEL_1C0DA_
	ld hl, $DD16
_LABEL_1C0E3_:
	ld a, (hl)
	inc a
	cp $0C
	ret nc
	ld (hl), a
	ret

_LABEL_1C0EA_:
	ld a, ($DD03)
	bit 7, a
	jp z, _LABEL_1C3B1_
	cp $90
	jr c, _LABEL_1C13A_
	cp $B0
	jr c, _LABEL_1C167_
	cp $B6
	jp nc, _LABEL_1C3B1_
	sub $B1
	ld hl, $8108
	call _LABEL_1C3E6_
	jp (hl)

; Jump Table from 1C108 to 1C111 (5 entries, indexed by $DD03)
.dw _LABEL_1C112_ _LABEL_1C3B1_ _LABEL_1C122_ _LABEL_1C243_ _LABEL_7000_

; 1st entry of Jump Table from 1C108 (indexed by $DD03)
_LABEL_1C112_:
	ld a, $0C
	ld ($DD09), a
	ld a, $12
	ld ($DD0A), a
	ld ($DD0B), a
	jp _LABEL_1C161_

; 3rd entry of Jump Table from 1C108 (indexed by $DD03)
_LABEL_1C122_:
	ld iy, $DE00
	ld de, $0030
	ld b, $03
	ld hl, $8139
_LABEL_1C12E_:
	ld (iy+3), l
	ld (iy+4), h
	add iy, de
	djnz _LABEL_1C12E_
	ret

; Data from 1C139 to 1C139 (1 bytes)
.db $F2

_LABEL_1C13A_:
	sub $81
	ret m
	ex af, af'
	call _LABEL_1C3B1_
	ex af, af'
	ld hl, $896D
	ld c, a
	ex af, af'
	call _LABEL_1C3F0_
	ld ($DD01), a
	ld ($DD02), a
	ex af, af'
	ld hl, $897C
	call _LABEL_1C3E6_
	ld b, (hl)
	inc hl
	ld de, $DD40
_LABEL_1C15C_:
	call _LABEL_1C1B5_
	djnz _LABEL_1C15C_
_LABEL_1C161_:
	ld a, $80
	ld ($DD03), a
	ret

_LABEL_1C167_:
	ld ($DD0D), a
	sub $90
	ld hl, $899A
	call _LABEL_1C3E6_
	ld b, (hl)
	inc hl
_LABEL_1C174_:
	inc hl
	ld a, (hl)
	dec hl
	cp $A0
	jr z, _LABEL_1C1A3_
	cp $C0
	jr z, _LABEL_1C188_
	ld de, $DE60
	ld iy, $DDD0
	jr _LABEL_1C1AA_

_LABEL_1C188_:
	ld iy, $DE60
	bit 6, (iy+0)
	jr nz, _LABEL_1C19A_
	set 2, (iy+0)
	ld a, $FF
	out ($7F), a
_LABEL_1C19A_:
	ld de, $DE30
	ld iy, $DDA0
	jr _LABEL_1C1AA_

_LABEL_1C1A3_:
	ld de, $DE00
	ld iy, $DD70
_LABEL_1C1AA_:
	call _LABEL_1C1B1_
	djnz _LABEL_1C174_
	jr _LABEL_1C161_

_LABEL_1C1B1_:
	set 2, (iy+0)
_LABEL_1C1B5_:
	ld c, $39
	push de
	pop ix
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ld a, c
	ld (de), a
	inc de
	xor a
	ld (ix+39), a
	ld (ix+40), a
	ld (ix+41), a
	inc a
	ld (de), a
	push hl
	ld hl, $0026
	add hl, de
	ex de, hl
	pop hl
	ret

_LABEL_1C1E3_:
	ld de, $DD07
	ld a, (de)
	cp $80
	jr z, _LABEL_1C24A_
	and $7F
	ret z
	ld ix, $DD0E
	ld iy, $DD0C
	call _LABEL_1C098_
	ld a, (iy+0)
	call _LABEL_1C24C_
	sub $90
	ld hl, $899A
	call _LABEL_1C3E6_
	inc hl
	inc hl
	ld a, (hl)
	dec hl
	cp $C0
	jr z, _LABEL_1C21F_
	ld de, $DE60
	ld iy, $DDD0
	ld a, (de)
	or a
	jp m, _LABEL_1C23F_
	ld a, $01
	jr _LABEL_1C239_

_LABEL_1C21F_:
	ld de, $DE30
	ld iy, $DDA0
	ld a, ($DE60)
	or a
	jp p, _LABEL_1C233_
	and $40
	ld a, $80
	jr z, _LABEL_1C23F_
_LABEL_1C233_:
	ld a, (de)
	or a
	jp m, _LABEL_1C23F_
	xor a
_LABEL_1C239_:
	ld ($DD0D), a
	jp _LABEL_1C1B1_

_LABEL_1C23F_:
	ld ($DD0D), a
	ret

; 4th entry of Jump Table from 1C108 (indexed by $DD03)
_LABEL_1C243_:
	xor a
	call _LABEL_1C24C_
	jp _LABEL_1C161_

_LABEL_1C24A_:
	xor a
	ld (de), a
_LABEL_1C24C_:
	ld ($DD0C), a
	ex af, af'
	ld a, ($DD0D)
	or a
	jp m, _LABEL_1C27C_
	push af
	ld hl, $DDA0
	ld a, (hl)
	or a
	jp z, _LABEL_1C26C_
	res 2, (hl)
	ld hl, $DDD0
	ld a, (hl)
	or a
	jp z, _LABEL_1C26C_
	res 2, (hl)
_LABEL_1C26C_:
	pop af
	ld hl, $DE30
	jr z, _LABEL_1C275_
	ld hl, $DE60
_LABEL_1C275_:
	ld (hl), a
	inc hl
	ld a, (hl)
	add a, $1F
	out ($7F), a
_LABEL_1C27C_:
	ex af, af'
	ret

_LABEL_1C27E_:
	bit 7, (ix+6)
	ret z
	bit 1, (ix+0)
	ret nz
	ld e, (ix+16)
	ld d, (ix+17)
	push ix
	pop hl
	ld b, $00
	ld c, $14
	add hl, bc
	ex de, hl
	ldi
	ldi
	ldi
	ld a, (hl)
	srl a
	ld (de), a
	xor a
	ld (ix+18), a
	ld (ix+19), a
	ret

_LABEL_1C2A9_:
	bit 7, (ix+7)
	ret z
	bit 1, (ix+0)
	ret nz
	bit 7, (ix+29)
	ret nz
	ld a, $FF
	ld (ix+31), a
	and $10
	or (ix+30)
	ld (ix+29), a
	ret

_LABEL_1C2C6_:
	ld l, (ix+11)
	ld h, (ix+12)
	ld a, (ix+6)
	or a
	ret z
	dec (ix+20)
	ret nz
	inc (ix+20)
	push hl
	ld l, (ix+18)
	ld h, (ix+19)
	dec (ix+21)
	jr nz, _LABEL_1C304_
	ld e, (ix+16)
	ld d, (ix+17)
	push de
	pop iy
	ld a, (iy+1)
	ld (ix+21), a
	ld a, (ix+22)
	ld c, a
	and $80
	rlca
	neg
	ld b, a
	add hl, bc
	ld (ix+18), l
	ld (ix+19), h
_LABEL_1C304_:
	pop bc
	add hl, bc
	dec (ix+23)
	ret nz
	ld a, (iy+3)
	ld (ix+23), a
	ld a, (ix+22)
	neg
	ld (ix+22), a
	ret

_LABEL_1C319_:
	res 1, (ix+0)
	res 4, (ix+0)
	ld e, (ix+3)
	ld d, (ix+4)
_LABEL_1C327_:
	ld a, (de)
	inc de
	cp $E0
	jp nc, _LABEL_1C6A3_
	bit 3, (ix+0)
	jp nz, _LABEL_1C393_
	cp $80
	jr c, _LABEL_1C35D_
	jr z, _LABEL_1C38E_
	ex af, af'
	ld a, (ix+29)
	and $7F
	ld (ix+29), a
	ex af, af'
	call _LABEL_1C3DE_
	ld (ix+11), l
	ld (ix+12), h
_LABEL_1C34E_:
	ld a, (de)
	inc de
	or a
	jp p, _LABEL_1C35D_
	ld a, (ix+13)
	ld (ix+10), a
	dec de
	jr _LABEL_1C366_

_LABEL_1C35D_:
	call _LABEL_1C3F5_
	ld (ix+10), a
	ld (ix+13), a
_LABEL_1C366_:
	ld (ix+3), e
	ld (ix+4), d
	bit 1, (ix+0)
	ret nz
	bit 6, (ix+0)
	jr nz, _LABEL_1C37B_
	res 5, (ix+0)
_LABEL_1C37B_:
	ld a, (ix+15)
	ld (ix+14), a
	xor a
	ld (ix+21), a
	bit 7, (ix+7)
	ret nz
	ld (ix+31), a
	ret

_LABEL_1C38E_:
	call _LABEL_1C5B3_
	jr _LABEL_1C34E_

_LABEL_1C393_:
	ld h, a
	ld a, (de)
	inc de
	ld l, a
	or h
	jr z, _LABEL_1C3A6_
	ld b, $00
	ld a, (ix+5)
	or a
	ld c, a
	jp p, _LABEL_1C3A5_
	dec b
_LABEL_1C3A5_:
	add hl, bc
_LABEL_1C3A6_:
	ld (ix+11), l
	ld (ix+12), h
	ld a, (de)
	inc de
	jp _LABEL_1C35D_

; 2nd entry of Jump Table from 1C108 (indexed by $DD03)
_LABEL_1C3B1_:
	push hl
	push bc
	push de
	ld hl, $DD03
	ld de, $DD04
	ld bc, $018C
	ld (hl), $00
	ldir
	pop de
	pop bc
	pop hl
_LABEL_1C3C4_:
	push hl
	push bc
	ld hl, $83D4
	ld b, $0A
	ld c, $7F
	otir
	pop bc
	pop hl
	jp _LABEL_1C161_

; Data from 1C3D4 to 1C3DD (10 bytes)
.db $80 $00 $A0 $00 $C0 $00 $9F $BF $DF $FF

_LABEL_1C3DE_:
	and $7F
	add a, (ix+5)
	ld hl, $83FF
_LABEL_1C3E6_:
	ld c, a
	ld b, $00
	add hl, bc
	add hl, bc
	ld c, (hl)
	inc hl
	ld h, (hl)
	ld l, c
	ret

_LABEL_1C3F0_:
	ld b, $00
	add hl, bc
	ld a, (hl)
	ret

_LABEL_1C3F5_:
	ld b, (ix+2)
	dec b
	ret z
	ld c, a
_LABEL_1C3FB_:
	add a, c
	djnz _LABEL_1C3FB_
	ret

; Data from 1C3FF to 1C48E (144 bytes)
.db $FF $03 $C7 $03 $90 $03 $5D $03 $2D $03 $FF $02 $D4 $02 $AB $02
.db $85 $02 $61 $02 $3F $02 $1E $02 $00 $02 $E3 $01 $C8 $01 $AF $01
.db $96 $01 $80 $01 $6A $01 $56 $01 $43 $01 $30 $01 $1F $01 $0F $01
.db $00 $01 $F2 $00 $E4 $00 $D7 $00 $CB $00 $C0 $00 $B5 $00 $AB $00
.db $A1 $00 $98 $00 $90 $00 $88 $00 $80 $00 $79 $00 $72 $00 $6C $00
.db $66 $00 $60 $00 $5B $00 $55 $00 $51 $00 $4C $00 $48 $00 $44 $00
.db $40 $00 $3C $00 $39 $00 $36 $00 $33 $00 $30 $00 $2D $00 $2B $00
.db $28 $00 $26 $00 $24 $00 $22 $00 $20 $00 $1E $00 $1C $00 $1B $00
.db $19 $00 $18 $00 $16 $00 $15 $00 $14 $00 $13 $00 $12 $00 $11 $00

_LABEL_1C48F_:
	dec (ix+10)
	jr nz, _LABEL_1C4A9_
	call _LABEL_1C319_
	bit 4, (ix+0)
	ret nz
	bit 2, (ix+0)
	ret nz
	call _LABEL_1C27E_
	call _LABEL_1C2A9_
	jr _LABEL_1C4C6_

_LABEL_1C4A9_:
	bit 2, (ix+0)
	ret nz
	ld a, (ix+14)
	or a
	jr z, _LABEL_1C4BA_
	dec (ix+14)
	call z, _LABEL_1C5B3_
_LABEL_1C4BA_:
	ld a, (ix+6)
	or a
	jr z, _LABEL_1C4F5_
	bit 5, (ix+0)
	jr nz, _LABEL_1C4F5_
_LABEL_1C4C6_:
	bit 6, (ix+0)
	jr nz, _LABEL_1C4F5_
	call _LABEL_1C2C6_
	ld d, $00
	ld a, (ix+37)
	or a
	jp p, _LABEL_1C4D9_
	dec d
_LABEL_1C4D9_:
	ld e, a
	add hl, de
	ld a, (ix+1)
	cp $E0
	jr nz, _LABEL_1C4E4_
	ld a, $C0
_LABEL_1C4E4_:
	ld c, a
	ld a, l
	and $0F
	or c
	out ($7F), a
	ld a, l
	and $F0
	or h
	rrca
	rrca
	rrca
	rrca
	out ($7F), a
_LABEL_1C4F5_:
	call _LABEL_1C513_
	bit 2, (ix+0)
	ret nz
	bit 4, (ix+0)
	ret nz
	add a, (ix+8)
	bit 4, a
	jr z, _LABEL_1C50B_
	ld a, $0F
_LABEL_1C50B_:
	or (ix+1)
	add a, $10
	out ($7F), a
	ret

_LABEL_1C513_:
	ld a, (ix+7)
	or a
	ret z
	jp p, _LABEL_1C5CA_
	bit 4, (ix+29)
	jr z, _LABEL_1C53B_
	ld d, (ix+32)
	ld a, (ix+31)
	sub d
	jr nc, _LABEL_1C52B_
	xor a
_LABEL_1C52B_:
	or a
	ld (ix+31), a
	jr nz, _LABEL_1C5A9_
	ld a, (ix+29)
	xor $30
	ld (ix+29), a
	jr _LABEL_1C5A9_

_LABEL_1C53B_:
	bit 5, (ix+29)
	jr z, _LABEL_1C56B_
	ld a, (ix+31)
	ld d, (ix+33)
	ld e, (ix+34)
	add a, d
	jr c, _LABEL_1C550_
	cp e
	jr c, _LABEL_1C551_
_LABEL_1C550_:
	ld a, e
_LABEL_1C551_:
	cp e
	ld (ix+31), a
	jr nz, _LABEL_1C5A9_
	ld a, (ix+29)
	bit 3, (ix+29)
	jr z, _LABEL_1C564_
	xor $30
	jr _LABEL_1C566_

_LABEL_1C564_:
	xor $60
_LABEL_1C566_:
	ld (ix+29), a
	jr _LABEL_1C5A9_

_LABEL_1C56B_:
	bit 6, (ix+29)
	jr z, _LABEL_1C58D_
	ld a, (ix+31)
	ld d, (ix+35)
	add a, d
	jr nc, _LABEL_1C57C_
	ld a, $FF
_LABEL_1C57C_:
	cp $FF
	ld (ix+31), a
	jr nz, _LABEL_1C5A9_
	ld a, (ix+29)
	and $8F
	ld (ix+29), a
	jr _LABEL_1C5A9_

_LABEL_1C58D_:
	ld a, (ix+31)
	ld d, (ix+36)
	add a, d
	jr nc, _LABEL_1C5A6_
	ld a, (ix+29)
	and $0F
	ld (ix+29), a
	ld a, $FF
	ld (ix+31), a
	jp _LABEL_1C606_

_LABEL_1C5A6_:
	ld (ix+31), a
_LABEL_1C5A9_:
	ld a, (ix+31)
	rrca
	rrca
	rrca
	rrca
	and $0F
	ret

_LABEL_1C5B3_:
	bit 1, (ix+0)
	ret nz
	bit 7, (ix+7)
	jp z, _LABEL_1C606_
	ld a, (ix+29)
	and $0F
	or $80
	ld (ix+29), a
	ret

_LABEL_1C5CA_:
	dec a
	ld hl, $888C
	call _LABEL_1C3E6_
	jr _LABEL_1C5D6_

_LABEL_1C5D3_:
	ld (ix+31), a
_LABEL_1C5D6_:
	push hl
	ld c, (ix+31)
	call _LABEL_1C3F0_
	pop hl
	bit 7, a
	jr z, _LABEL_1C602_
	cp $82
	jr z, _LABEL_1C5F2_
	cp $81
	jr z, _LABEL_1C5FC_
	cp $80
	jr z, _LABEL_1C5F9_
	inc de
	ld a, (de)
	jr _LABEL_1C5D3_

_LABEL_1C5F2_:
	set 4, (ix+0)
	pop hl
	jr _LABEL_1C606_

_LABEL_1C5F9_:
	xor a
	jr _LABEL_1C5D3_

_LABEL_1C5FC_:
	set 4, (ix+0)
	pop hl
	ret

_LABEL_1C602_:
	inc (ix+31)
	ret

_LABEL_1C606_:
	set 4, (ix+0)
	bit 2, (ix+0)
	ret nz
	ld a, $1F
	add a, (ix+1)
	out ($7F), a
	ret

_LABEL_1C617_:
	dec (ix+10)
	jp nz, _LABEL_1C4F5_
	res 4, (ix+0)
	ld e, (ix+3)
	ld d, (ix+4)
_LABEL_1C627_:
	ld a, (de)
	inc de
	cp $E0
	jr nc, _LABEL_1C638_
	cp $80
	jp c, _LABEL_1C35D_
	call _LABEL_1C641_
	jp _LABEL_1C34E_

_LABEL_1C638_:
	ld hl, $863E
	jp _LABEL_1C6A6_

_LABEL_1C63E_:
	inc de
	jr _LABEL_1C627_

_LABEL_1C641_:
	bit 0, a
	jr nz, _LABEL_1C684_
	bit 1, a
	jr nz, _LABEL_1C664_
	bit 2, a
	jr nz, _LABEL_1C67C_
	bit 3, a
	jr nz, _LABEL_1C65C_
	bit 4, a
	jr nz, _LABEL_1C674_
	bit 5, a
	jr nz, _LABEL_1C66C_
	jp _LABEL_1C606_

_LABEL_1C65C_:
	ld a, $02
	ld b, $03
	ld c, $E5
	jr _LABEL_1C68A_

_LABEL_1C664_:
	ld a, $03
	ld b, $03
	ld c, $E4
	jr _LABEL_1C68A_

_LABEL_1C66C_:
	ld a, $04
	ld b, $04
	ld c, $E4
	jr _LABEL_1C68A_

_LABEL_1C674_:
	ld a, $03
	ld b, $03
	ld c, $E6
	jr _LABEL_1C68A_

_LABEL_1C67C_:
	ld a, $01
	ld b, $01
	ld c, $E6
	jr _LABEL_1C68A_

_LABEL_1C684_:
	ld a, $01
	ld b, $04
	ld c, $E4
_LABEL_1C68A_:
	ld (ix+7), a
	ld a, ($DD16)
	add a, b
	ld (ix+8), a
	bit 2, (ix+0)
	ret nz
	ld a, ($DD15)
	add a, c
	ld ($DD11), a
	out ($7F), a
	ret

_LABEL_1C6A3_:
	ld hl, $86B7
_LABEL_1C6A6_:
	push hl
	sub $E0
	ld hl, $86BB
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld c, (hl)
	inc hl
	ld h, (hl)
	ld l, c
	ld a, (de)
	jp (hl)

_LABEL_1C6B7_:
	inc de
	jp _LABEL_1C327_

; Jump Table from 1C6BB to 1C6C4 (5 entries, indexed by unknown)
.dw _LABEL_1C872_ _LABEL_1C86B_ _LABEL_1C6FB_ _LABEL_1C86B_ _LABEL_1C74B_

; Data from 1C6C5 to 1C6FA (54 bytes)
.db $8C $88 $3B $87 $65 $88 $57 $88 $72 $88 $6B $88 $72 $88 $72 $88
.db $6B $88 $72 $88 $8C $88 $57 $88 $8C $88 $C4 $87 $61 $87 $BE $87
.db $BA $87 $BE $87 $40 $88 $13 $88 $2D $88 $5D $87 $56 $87 $8C $88
.db $C4 $87 $72 $88 $72 $88

; 3rd entry of Jump Table from 1C6BB (indexed by unknown)
_LABEL_1C6FB_:
	ld b, (ix+38)
	ld a, ($DD00)
	or a
	jp z, _LABEL_1C711_
	push af
	ld a, $FE
	add a, (ix+8)
	and $0F
	ld (ix+8), a
	pop af
_LABEL_1C711_:
	ld (ix+38), a
	cpl
	ld c, a
	ld a, (ix+1)
	cp $80
	jr z, _LABEL_1C731_
	rlc b
	rlc c
	cp $A0
	jr z, _LABEL_1C731_
	rlc b
	rlc c
	cp $C0
	jr z, _LABEL_1C731_
	rlc b
	rlc c
_LABEL_1C731_:
	ld hl, $DD10
	ld a, (hl)
	or b
	and c
	ld (hl), a
	out ($06), a
	ret

_LABEL_1C73B_:
	ex af, af'
	ld a, ($DD09)
	or a
	ret nz
	ex af, af'
	add a, (ix+8)
	and $0F
	ld (ix+8), a
	ret

; 5th entry of Jump Table from 1C6BB (indexed by unknown)
_LABEL_1C74B_:
	ld c, a
	ld a, ($DD16)
	add a, c
	and $0F
	ld ($DD16), a
	ret

; Data from 1C756 to 1C760 (11 bytes)
.db $DD $86 $05 $DD $77 $05 $C9 $DD $77 $02 $C9

_LABEL_1C761_:
	ex af, af'
	ld a, ($DD0D)
	or a
	jp m, _LABEL_1C78A_
	ex af, af'
	or $FC
	inc a
	jr nz, _LABEL_1C78A_
	ld hl, $DE30
	bit 7, (hl)
	jr z, _LABEL_1C78A_
	ld hl, $DDD0
	res 2, (hl)
	set 4, (hl)
	xor a
	ld (ix+0), a
	dec a
	out ($7F), a
	ld ($DD0D), a
	pop hl
	pop hl
	ret

_LABEL_1C78A_:
	ld a, (de)
	out ($7F), a
	ld hl, $DDA0
	ld iy, $DE30
	or $FC
	inc a
	jr nz, _LABEL_1C7A8_
	ld a, $DF
	out ($7F), a
	res 6, (ix+0)
	set 2, (hl)
	set 2, (iy+0)
	ret

_LABEL_1C7A8_:
	set 6, (ix+0)
	bit 7, (iy+0)
	jr nz, _LABEL_1C7B5_
	res 2, (hl)
	ret

_LABEL_1C7B5_:
	res 2, (iy+0)
	ret

; Data from 1C7BA to 1C7BD (4 bytes)
.db $DD $77 $07 $C9

_LABEL_1C7BE_:
	ex de, hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	dec de
	ret

_LABEL_1C7C4_:
	ld a, (ix+1)
	cp $A0
	jr z, _LABEL_1C7F4_
	cp $C0
	jr z, _LABEL_1C7E8_
	bit 6, (ix+0)
	jr nz, _LABEL_1C7E3_
	ld hl, $DDA0
	res 2, (hl)
	res 6, (hl)
	set 4, (hl)
	ld hl, $DE30
	ld (hl), $00
_LABEL_1C7E3_:
	ld hl, $DDD0
	jr _LABEL_1C7F7_

_LABEL_1C7E8_:
	ld hl, $DE60
	bit 7, (hl)
	jr nz, _LABEL_1C7F7_
	ld hl, $DDA0
	jr _LABEL_1C7F7_

_LABEL_1C7F4_:
	ld hl, $DD70
_LABEL_1C7F7_:
	res 2, (hl)
	set 4, (hl)
	or $1F
	out ($7F), a
	xor a
	ld ($DD0F), a
	ld (ix+0), a
	ld a, ($DD0C)
	or a
	jr z, _LABEL_1C810_
	call _LABEL_1C1FC_
	ex de, hl
_LABEL_1C810_:
	pop bc
	pop bc
	ret

_LABEL_1C813_:
	ld c, a
	inc de
	ld a, (de)
	ld b, a
	push bc
	push ix
	pop hl
	dec (ix+9)
	ld c, (ix+9)
	dec (ix+9)
	ld b, $00
	add hl, bc
	ld (hl), d
	dec hl
	ld (hl), e
	pop de
	dec de
	ret

_LABEL_1C82D_:
	push ix
	pop hl
	ld c, (ix+9)
	ld b, $00
	add hl, bc
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc (ix+9)
	inc (ix+9)
	ret

_LABEL_1C840_:
	inc de
	add a, $27
	ld c, a
	ld b, $00
	push ix
	pop hl
	add hl, bc
	ld a, (hl)
	or a
	jr nz, _LABEL_1C850_
	ld a, (de)
	ld (hl), a
_LABEL_1C850_:
	inc de
	dec (hl)
	jp nz, _LABEL_1C7BE_
	inc de
	ret

_LABEL_1C857_:
	ld (ix+16), e
	ld (ix+17), d
	ld (ix+6), $80
	inc de
	inc de
	inc de
	ret

_LABEL_1C865_:
	set 1, (ix+0)
	dec de
	ret

; 2nd entry of Jump Table from 1C6BB (indexed by unknown)
_LABEL_1C86B_:
	ld ($DD02), a
	ld ($DD01), a
	ret

; 1st entry of Jump Table from 1C6BB (indexed by unknown)
_LABEL_1C872_:
	ld (ix+7), $80
	push ix
	pop hl
	ld b, $00
	ld c, $20
	add hl, bc
	ex de, hl
	ldi
	ldi
	ldi
	ldi
	ldi
	ex de, hl
	dec de
	ret

; Data from 1C88C to 1FFFF (14196 bytes)

