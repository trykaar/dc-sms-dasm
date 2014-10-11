UpdateAllSound:
	ld hl, $DD08
	ld a, (hl)
	or a
	jr z, ManageSound
	ret p
	dec (hl)
	jp SilencePSG

ManageSound:
	call DoSoundQueue
	call DoTempo
	call DoFading
	call PlaySoundID
	call PlayExtraSFXID
	ld ix, MusicTrack1
	bit 7, (ix+0)
	call nz, UpdateTrack
	ld ix, MusicTrack2
	bit 7, (ix+0)
	call nz, UpdateTrack
	ld ix, MusicTrack3
	bit 7, (ix+0)
	call nz, UpdateTrack
	ld ix, MusicTrack4_Noise
	bit 7, (ix+0)
	call nz, UpdateNoiseTrack
	ld ix, SFXTrack1_PSG2
	bit 7, (ix+0)
	call nz, UpdateTrack
	ld ix, SFXTrack2_PSG3
	bit 7, (ix+0)
	call nz, UpdateTrack
	ld ix, SFXTrack3_PSG4_Noise
	bit 7, (ix+0)
	call nz, UpdateTrack
	ret

DoTempo:
	ld hl, TempoTimeout
	ld a, (hl)
	or a
	ret z					; Tempo 0- never delayed
	dec (hl)
	ret nz					; Reached 0 - continue and delay all tracks
	ld a, (TempoResetValue)
	ld (hl), a
	ld hl, $DD4A
	ld de, $0030
	ld b, $04
-:
	inc (hl)
	add hl, de
	djnz -
	ret

DoSoundQueue:
	ld de, SoundQueueSlots
	ld ix, CurrentSoundPriority
	ld iy, PlaySoundSlot
	call DoOneSoundQueue
	call DoOneSoundQueue

DoOneSoundQueue:
	ld a, (de)
	and $7F
	jr z, _LABEL_1C0AF_

ProcQueueSlot:
	dec a
	ld hl, SoundPriorities
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

_LABEL_1C0AF_:				; Clear out a queue slot?
	xor a
	ld (de), a
	inc de
	ret

DoFading:
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
	jp z, StopAllSound
	ld hl, $DD48			; DD40 (music tracks) + $08 (volume)
	ld de, $0030
	ld b, $03

_LABEL_1C0DA_:
	call FadeVolume
	add hl, de
	djnz _LABEL_1C0DA_
	ld hl, DrumVolume

FadeVolume:
	ld a, (hl)
	inc a
	cp $0C
	ret nc
	ld (hl), a
	ret

PlaySoundID:
	ld a, (PlaySoundSlot)
	bit 7, a
	jp z, StopAllSound
	cp $90
	jr c, PlayMusic
	cp $B0
	jr c, PlaySFX
	cp $B6
	jp nc, StopAllSound
	sub $B1
	ld hl, $8108
	call ReadPointerTable
	jp (hl)

; Jump Table from 1C108 to 1C111 (5 entries, indexed by PlaySoundSlot)
.dw FadeOutMusic StopAllSound StopSFX _LABEL_1C243_ _LABEL_7000_

; 1st entry of Jump Table from 1C108 (indexed by PlaySoundSlot)
FadeOutMusic:
	ld a, $0C				; Number of fading steps
	ld ($DD09), a
	ld a, $12				; Frames per step
	ld ($DD0A), a
	ld ($DD0B), a
	jp ClearSoundID

; 3rd entry of Jump Table from 1C108 (indexed by PlaySoundSlot)
StopSFX:
	ld iy, SFXTrack1_PSG2
	ld de, $0030
	ld b, $03
	ld hl, TrackEndSequenceData
-:
	ld (iy+3), l
	ld (iy+4), h
	add iy, de
	djnz -
	ret

; Data from 1C139 to 1C139 (1 bytes)
.db $F2

PlayMusic:
	sub $81					; Sound ID -> Music index
	ret m					; Result was 80, dummy command - return
	ex af, af'
	call StopAllSound
	ex af, af'
	ld hl, TempoList
	ld c, a
	ex af, af'
	call GetEnvelopeData			; Read tempo
	ld (TempoTimeout), a	; Tempo work counter
	ld (TempoResetValue), a	; Tempo reset value
	ex af, af'
	ld hl, MusicPointers
	call ReadPointerTable
	ld b, (hl)				; Get track count
	inc hl
	ld de, MusicTrack1
-:
	call LoadSMPSMusicTrack
	djnz -

ClearSoundID:
	ld a, $80
	ld (PlaySoundSlot), a
	ret

PlaySFX:
	ld ($DD0D), a
	sub $90					; Sound ID -> SFX Index
	ld hl, SFXPointers
	call ReadPointerTable
	ld b, (hl)				; Get track count
	inc hl

_LABEL_1C174_:
	inc hl
	ld a, (hl)
	dec hl
	cp $A0
	jr z, _LABEL_1C1A3_
	cp $C0
	jr z, _LABEL_1C188_
	ld de, SFXTrack3_PSG4_Noise
	ld iy, MusicTrack4_Noise
	jr _LABEL_1C1AA_

_LABEL_1C188_:
	ld iy, SFXTrack3_PSG4_Noise
	bit 6, (iy+0)
	jr nz, _LABEL_1C19A_
	set 2, (iy+0)
	ld a, $FF
	out ($7F), a
_LABEL_1C19A_:
	ld de, SFXTrack2_PSG3
	ld iy, MusicTrack3
	jr _LABEL_1C1AA_

_LABEL_1C1A3_:
	ld de, SFXTrack1_PSG2
	ld iy, MusicTrack2
_LABEL_1C1AA_:
	call LoadSMPSSFXTrack
	djnz _LABEL_1C174_
	jr ClearSoundID

LoadSMPSSFXTrack:
	set 2, (iy+0)
LoadSMPSMusicTrack:
	ld c, $39
	push de
	pop ix
	ldi						; Copy 9-byte header into track RAM
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

PlayExtraSFXID:
	ld de, $DD07
	ld a, (de)
	cp $80
	jr z, _LABEL_1C24A_
	and $7F
	ret z
	ld ix, $DD0E
	ld iy, $DD0C
	call ProcQueueSlot
	ld a, (iy+0)
_LABEL_1C1FC_:
	call _LABEL_1C24C_
	sub $90
	ld hl, SFXPointers
	call ReadPointerTable
	inc hl
	inc hl
	ld a, (hl)
	dec hl
	cp $C0
	jr z, _LABEL_1C21F_
	ld de, SFXTrack3_PSG4_Noise
	ld iy, MusicTrack4_Noise
	ld a, (de)
	or a
	jp m, _LABEL_1C23F_
	ld a, $01
	jr _LABEL_1C239_

_LABEL_1C21F_:
	ld de, SFXTrack2_PSG3
	ld iy, MusicTrack3
	ld a, (SFXTrack3_PSG4_Noise)
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
	jp LoadSMPSSFXTrack

_LABEL_1C23F_:
	ld ($DD0D), a
	ret

; 4th entry of Jump Table from 1C108 (indexed by PlaySoundSlot)
_LABEL_1C243_:
	xor a
	call _LABEL_1C24C_
	jp ClearSoundID

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
	ld hl, MusicTrack3
	ld a, (hl)
	or a
	jp z, _LABEL_1C26C_
	res 2, (hl)
	ld hl, MusicTrack4_Noise
	ld a, (hl)
	or a
	jp z, _LABEL_1C26C_
	res 2, (hl)
_LABEL_1C26C_:
	pop af
	ld hl, SFXTrack2_PSG3
	jr z, _LABEL_1C275_
	ld hl, SFXTrack3_PSG4_Noise
_LABEL_1C275_:
	ld (hl), a
	inc hl
	ld a, (hl)
	add a, $1F
	out ($7F), a
_LABEL_1C27C_:
	ex af, af'
	ret

PrepareModulation:
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

PrepareADSR:
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

DoModulation:
	ld l, (ix+11)
	ld h, (ix+12)
	ld a, (ix+6)
	or a
	ret z					; Modulation type 0 -> return (modulation off)
	; Note (from ValleyBell): jump to DoModEnv is missing
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

TrackUpdate:
	res 1, (ix+0)
	res 4, (ix+0)
	ld e, (ix+3)
	ld d, (ix+4)
_LABEL_1C327_:
	ld a, (de)
	inc de
	cp $E0
	jp nc, cfHandler
	bit 3, (ix+0)
	jp nz, DoRawFrequencyMode
	cp $80
	jr c, SetDuration
	jr z, DoRest
	ex af, af'
	ld a, (ix+29)					; Clear ADSR control bit 7
	and $7F
	ld (ix+29), a
	ex af, af'
	call GetFrequency
	ld (ix+11), l
	ld (ix+12), h
_LABEL_1C34E_:
	ld a, (de)
	inc de
	or a
	jp p, SetDuration
	ld a, (ix+13)
	ld (ix+10), a
	dec de
	jr _LABEL_1C366_

SetDuration:
	call TickMultiplier
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

DoRest:
	call SetRest
	jr _LABEL_1C34E_

DoRawFrequencyMode:
	ld h, a
	ld a, (de)
	inc de
	ld l, a
	or h
	jr z, _LABEL_1C3A6_
	ld b, $00
	ld a, (ix+5)
	or a						; Get transpose value
	ld c, a
	jp p, _LABEL_1C3A5_
	dec b						; Sign-extend
_LABEL_1C3A5_:
	add hl, bc					; Add to raw frequency value
_LABEL_1C3A6_:
	ld (ix+11), l
	ld (ix+12), h
	ld a, (de)
	inc de
	jp SetDuration

; 2nd entry of Jump Table from 1C108 (indexed by PlaySoundSlot)
StopAllSound:
	push hl
	push bc
	push de
	ld hl, PlaySoundSlot
	ld de, SoundQueueSlots
	ld bc, $018C
	ld (hl), $00
	ldir
	pop de
	pop bc
	pop hl

SilencePSG:
	push hl
	push bc
	ld hl, PSGMuteValues
	ld b, $0A
	ld c, $7F
	otir
	pop bc
	pop hl
	jp ClearSoundID

PSGMuteVals:
	.db $80 $00
	.db $A0 $00
	.db $C0 $00
	.db $9F $BF $DF $FF

GetFrequency:
	and $7F
	add a, (ix+5)			; Add transpose
	ld hl, PSGFrequencies

ReadPointerTable:
	ld c, a
	ld b, $00
	add hl, bc
	add hl, bc
	ld c, (hl)
	inc hl
	ld h, (hl)
	ld l, c
	ret

GetEnvelopeData:
	ld b, $00
	add hl, bc
	ld a, (hl)
	ret

TickMultiplier:
	ld b, (ix+2)
	dec b
	ret z
	ld c, a
-:
	add a, c
	djnz -
	ret

PSGFrequencies:
	.dw $03FF $03C7 $0390 $035D $032D $02FF $02D4 $02AB $0285 $0261 $023F $021E
	.dw $0200 $01E3 $01C8 $01AF $0196 $0180 $016A $0156 $0143 $0130 $011F $010F
	.dw $0100 $00F2 $00E4 $00D7 $00CB $00C0 $00B5 $00AB $00A1 $0098 $0090 $0088
	.dw $0080 $0079 $0072 $006C $0066 $0060 $005B $0055 $0051 $004C $0048 $0044
	.dw $0040 $003C $0039 $0036 $0033 $0030 $002D $002B $0028 $0026 $0024 $0022
	.dw $0020 $001E $001C $001B $0019 $0018 $0016 $0015 $0014 $0013 $0012 $0011

UpdateTrack:
	dec (ix+10)
	jr nz, _LABEL_1C4A9_
	call TrackUpdate
	bit 4, (ix+0)
	ret nz
	bit 2, (ix+0)
	ret nz
	call PrepareModulation
	call PrepareADSR
	jr _LABEL_1C4C6_

_LABEL_1C4A9_:
	bit 2, (ix+0)
	ret nz
	ld a, (ix+14)
	or a
	jr z, _LABEL_1C4BA_
	dec (ix+14)				; Do Note Stop effect
	call z, SetRest

_LABEL_1C4BA_:
	ld a, (ix+6)
	or a
	jr z, DoPSGVolume
	bit 5, (ix+0)
	jr nz, DoPSGVolume

_LABEL_1C4C6_:
	bit 6, (ix+0)
	jr nz, DoPSGVolume
	call DoModulation
	ld d, $00
	ld a, (ix+37)
	or a
	jp p, _LABEL_1C4D9_
	dec d

_LABEL_1C4D9_:
	ld e, a
	add hl, de				; Add detune
	ld a, (ix+1)
	cp $E0
	jr nz, _LABEL_1C4E4_
	ld a, $C0				; Noise channel- frequency is controlled by PSG 3

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

DoPSGVolume:
	call DoADSR
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

DoADSR:
	ld a, (ix+7)
	or a
	ret z
	jp p, DoVolumeEnvelope
	bit 4, (ix+29)
	jr z, _LABEL_1C53B_
	ld d, (ix+32)			; Attack phase
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
	ld a, (ix+31)			; Decay phase
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
	ld a, (ix+31)			; Sustain phase
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

_LABEL_1C58D_:				; Release phase
	ld a, (ix+31)
	ld d, (ix+36)
	add a, d
	jr nc, _LABEL_1C5A6_
	ld a, (ix+29)
	and $0F
	ld (ix+29), a
	ld a, $FF
	ld (ix+31), a
	jp SilencePSGChannel

_LABEL_1C5A6_:
	ld (ix+31), a
_LABEL_1C5A9_:
	ld a, (ix+31)
	rrca					; The upper four bits of the ADSR level are the PSG volume
	rrca
	rrca
	rrca
	and $0F
	ret

SetRest:
	bit 1, (ix+0)
	ret nz
	bit 7, (ix+7)
	jp z, SilencePSGChannel
	ld a, (ix+29)
	and $0F
	or $80
	ld (ix+29), a
	ret

DoVolumeEnvelope:
	dec a
	ld hl, VolumeEnvelopePointers
	call ReadPointerTable
	jr _LABEL_1C5D6_

_LABEL_1C5D3_:
	ld (ix+31), a

_LABEL_1C5D6_:
	push hl
	ld c, (ix+31)
	call GetEnvelopeData
	pop hl
	bit 7, a
	jr z, VolumeEnvelope_Next
	cp $82
	jr z, VolumeEnvelope_Off		; $82 - Stop the tone
	cp $81
	jr z, VolumeEnvelope_Hold		; $81 - Hold the envelope at the currnent level
	cp $80
	jr z, VolumeEnvelope_Reset		; $80 - Loop back to the beginnning
	inc de
	ld a, (de)
	jr _LABEL_1C5D3_

VolumeEnvelope_Off:
	set 4, (ix+0)
	pop hl
	jr SilencePSGChannel

VolumeEnvelope_Reset:
	xor a
	jr _LABEL_1C5D3_

VolumeEnvelope_Hold:
	set 4, (ix+0)
	pop hl
	ret

VolumeEnvelope_Next:
	inc (ix+31)
	ret

SilencePSGChannel:
	set 4, (ix+0)
	bit 2, (ix+0)
	ret nz
	ld a, $1F
	add a, (ix+1)
	out ($7F), a
	ret

UpdateNoiseTrack:
	dec (ix+10)
	jp nz, DoPSGVolume
	res 4, (ix+0)
	ld e, (ix+3)
	ld d, (ix+4)
_LABEL_1C627_:
	ld a, (de)
	inc de
	cp $E0
	jr nc, cfHandler_Drum
	cp $80
	jp c, SetDuration
	call SetDrumNote
	jp _LABEL_1C34E_

cfHandler_Drum:
	ld hl, cfReturn_Drum
	jp DoCfPointerTable

cfReturn_Drum:
	inc de
	jr _LABEL_1C627_

SetDrumNote:
	bit 0, a
	jr nz,SetDrumNote81
	bit 1, a
	jr nz,SetDrumNote82
	bit 2, a
	jr nz,SetDrumNote84
	bit 3, a
	jr nz,SetDrumNote88
	bit 4, a
	jr nz,SetDrumNote90
	bit 5, a
	jr nz,SetDrumNoteA0
	jp SilencePSGChannel

SetDrumNote88:
	ld a, $02
	ld b, $03
	ld c, $E5
	jr DoDrumNote

SetDrumNote82:
	ld a, $03
	ld b, $03
	ld c, $E4
	jr DoDrumNote

SetDrumNoteA0:
	ld a, $04
	ld b, $04
	ld c, $E4
	jr DoDrumNote

SetDrumNote90:
	ld a, $03
	ld b, $03
	ld c, $E6
	jr DoDrumNote

SetDrumNote84:
	ld a, $01
	ld b, $01
	ld c, $E6
	jr DoDrumNote

SetDrumNote81:
	ld a, $01
	ld b, $04
	ld c, $E4				; Fall through

DoDrumNote:
	ld (ix+7), a			; Set volume envelope
	ld a, (DrumVolume)		; Get noise drum volume
	add a, b				; Add per-drum volume
	ld (ix+8), a			; Save final drum volume
	bit 2, (ix+0)
	ret nz
	ld a, ($DD15)
	add a, c
	ld ($DD11), a
	out ($7F), a
	ret

cfHandler:
	ld hl, cfReturn			; Fall through

DoCfPointerTable:
	push hl
	sub $E0
	ld hl, cfPointerTable
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

cfReturn:
	inc de
	jp _LABEL_1C327_

cfPointerTable:
	.dw cfE0_ADSR cfED_SetTempo cfE2_GGStereo cfED_SetTempo
	.dw cfE4_ChgDrumVol VolumeEnvelopePointers cfE6_ChangeVolume cfE7_Hold
	.dw cfF0_ModulationSetup cfE0_ADSR cfED_SetTempo cfE0_ADSR
	.dw cfE0_ADSR cfED_SetTempo cfE0_ADSR VolumeEnvelopePointers
	.dw cfF0_ModulationSetup VolumeEnvelopePointers cfF2_StopTrack cfF3_PSGNoise
	.dw cfF6_GoTo cfF5_VolumeEnvelope cfF6_GoTo cfF7_Loop
	.dw cfF8_GoSub cfF9_Return cfFA_TickMult cfFB_ChgTransp
	.dw VolumeEnvelopePointers cfF2_StopTrack cfE0_ADSR cfE0_ADSR

; 3rd entry of Jump Table from 1C6BB (indexed by unknown)
cfE2_GGStereo:
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

; 7th entry of Jump Table from 1C6BB (indexed by unknown)
cfE6_ChangeVolume:
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
cfE4_ChgDrumVol:
	ld c, a
	ld a, (DrumVolume)
	add a, c
	and $0F
	ld (DrumVolume), a
	ret

; 28th entry of Jump Table from 1C6BB (indexed by unknown)
cfFB_ChgTransp:
	add a, (ix+5)
	ld (ix+5), a
	ret

; 27th entry of Jump Table from 1C6BB (indexed by unknown)
cfFA_TickMult:
	ld (ix+2), a
	ret

; 20th entry of Jump Table from 1C6BB (indexed by unknown)
cfF3_PSGNoise:
	ex af, af'
	ld a, ($DD0D)
	or a
	jp m, _LABEL_1C78A_
	ex af, af'
	or $FC
	inc a
	jr nz, _LABEL_1C78A_
	ld hl, SFXTrack2_PSG3
	bit 7, (hl)
	jr z, _LABEL_1C78A_
	ld hl, MusicTrack4_Noise
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
	ld hl, MusicTrack3
	ld iy, SFXTrack2_PSG3
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

; 22nd entry of Jump Table from 1C6BB (indexed by unknown)
cfF5_VolumeEnvelope:
	ld (ix+7), a
	ret

; 21st entry of Jump Table from 1C6BB (indexed by unknown)
cfF6_GoTo:
	ex de, hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	dec de
	ret

; 19th entry of Jump Table from 1C6BB (indexed by unknown)
cfF2_StopTrack:
	ld a, (ix+1)
	cp $A0
	jr z, _LABEL_1C7F4_
	cp $C0
	jr z, _LABEL_1C7E8_
	bit 6, (ix+0)
	jr nz, _LABEL_1C7E3_
	ld hl, MusicTrack3
	res 2, (hl)
	res 6, (hl)
	set 4, (hl)
	ld hl, SFXTrack2_PSG3
	ld (hl), $00
_LABEL_1C7E3_:
	ld hl, MusicTrack4_Noise
	jr _LABEL_1C7F7_

_LABEL_1C7E8_:
	ld hl, SFXTrack3_PSG4_Noise
	bit 7, (hl)
	jr nz, _LABEL_1C7F7_
	ld hl, MusicTrack3
	jr _LABEL_1C7F7_

_LABEL_1C7F4_:
	ld hl, MusicTrack2
_LABEL_1C7F7_:
	res 2, (hl)
	set 4, (hl)
	or $1F
	out ($7F), a
	xor a
	ld (CurrentSoundPriority), a
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

; 25th entry of Jump Table from 1C6BB (indexed by unknown)
cfF8_GoSub:
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

; 26th entry of Jump Table from 1C6BB (indexed by unknown)
cfF9_Return:
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

; 24th entry of Jump Table from 1C6BB (indexed by unknown)
cfF7_Loop:
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
	jp nz, cfF6_GoTo
	inc de
	ret

; 9th entry of Jump Table from 1C6BB (indexed by unknown)
cfF0_ModulationSetup:
	ld (ix+16), e
	ld (ix+17), d
	ld (ix+6), $80
	inc de
	inc de
	inc de
	ret

; 8th entry of Jump Table from 1C6BB (indexed by unknown)
cfE7_Hold:
	set 1, (ix+0)
	dec de
	ret

; 2nd entry of Jump Table from 1C6BB (indexed by unknown)
cfED_SetTempo:
	ld (TempoResetValue), a
	ld (TempoTimeout), a
	ret

; 1st entry of Jump Table from 1C6BB (indexed by unknown)
cfE0_ADSR:
	ld (ix+7), $80			; Set Volume Envelope (PSG Instrument) to ADSR
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
