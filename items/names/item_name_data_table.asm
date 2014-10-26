; Item names are sixteen characters long, including an initial byte for size, padded with spaces ($58) at the end

; Empty slot
EmptySlot:
	.db $01
	.asc "              "

.include "items\names\weapons.asm"
.include "items\names\armor.asm"
.include "items\names\scrolls_identified.asm"
.include "items\names\scrolls_unidentified.asm"
.include "items\names\rods_identified.asm"
.include "items\names\rods_unidentified.asm"
.include "items\names\potions_identified.asm"
.include "items\names\potions_unidentified.asm"
.include "items\names\rings_identified.asm"
.include "items\names\rings_unidentified.asm"