; Item names are sixteen characters long, including an initial byte for size, padded with spaces ($58) at the end

; Empty slot
EmptySlot:
	.db $01
	.asc "              "

.include "items\weapons.asm"
.include "items\armor.asm"
.include "items\scrolls_identified.asm"
.include "items\scrolls_unidentified.asm"
.include "items\rods_identified.asm"
.include "items\rods_unidentified.asm"
.include "items\potions_identified.asm"
.include "items\potions_unidentified.asm"
.include "items\rings_identified.asm"
.include "items\rings_unidentified.asm"