; These values are offsets into the Item Action Table to select the appropriate
; action for each item. The item IDs (eg $21 = Shield Scroll) are offsets into
; _this_ table. There are unused IDs for each type of item.

; Scrolls
.db $00		; Blade Scroll
.db $01		; Shield Scroll
.db $02		; Norust Scroll
.db $03		; Bless Scroll
.db $05		; Map Scroll
.db $06		; Shift Scroll
.db $07		; Daze/Mad Scroll
.db $0A		; Magi Scroll
.db $0B		; Cyber/Gas Scroll
.db $0C		; Ninja/Ghost Scroll
.db $0D		; Dragon Scroll
.db $09		; Summon Scroll
.db $0E		; Blank Scroll
.db $30		; Potion Scroll
.db $FF
.db $FF

; Rods
.db $0F		; Flame Rod
.db $10		; Flash Rod
.db $11		; Thunder Rod
.db $16		; Travel Rod
.db $12		; Wind Rod
.db $13		; Berserk Rod
.db $15		; Reshape Rod
.db $14		; Silent Rod
.db $17		; Drain Rod
.db $31		; Spirit Rod
.db $04		; Wood Rod
.db $18		; Wither Rod
.db $FF
.db $FF
.db $FF
.db $FF

; Potions
.db $19		; Minheal Potion
.db $1A		; Midheal Potion
.db $1B		; Slow Potion
.db $1C		; Slowfix Potion
.db $1D		; Fog Potion
.db $33		; Daze Potion
.db $1F		; Cure Potion
.db $08		; Freeze Potion
.db $2E		; Power Potion
.db $2F		; Reflex Potion
.db $20		; Maxheal Potion
.db $32		; Water Potion
.db $21		; Wither Potion
.db $FF
.db $FF
.db $FF

; Rings
.db $22		; Heal Ring
.db $23		; Magic Ring
.db $22		; Food Ring
.db $24		; Sight Ring
.db $25		; Shield Ring
.db $26		; Ogre Ring
.db $28		; Cursed Ring
.db $29		; Hunger Ring
.db $2A		; Toy Ring
.db $27		; Shift Ring
.db $FF
.db $FF
.db $FF
.db $FF
.db $FF
.db $FF
