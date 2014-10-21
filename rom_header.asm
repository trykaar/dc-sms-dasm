; ROM header
; "TMR SEGA"
.db $54 $4d $52 $20 $53 $45 $47 $41

; Reserved word
.dw $0000

; Checksum
.dw $E43B

; Product code 05123, version 0
.db $23 $51 $00

; Region SMS export, ROM size $F, 128KB
.db $4f