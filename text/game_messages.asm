; Battle and exploration messages
MonsterDamagedMessage1Ptr:
	.db $0d
	.asc "MONSTER DOWN "

MonsterDamagedMessage2Ptr:
	.db $0e
	.asc " HIT POINT(S)!"

PlayerDamagedMessage1Ptr:
	.db $0c
	.asc "YOU'RE DOWN "

PlayerDamagedMessage2Ptr:
	.db $0e
	.asc " HIT POINT(S)!"

ItemFoundMessage1Ptr:
	.db $0c
	.asc "YOU FOUND A "

ItemFoundMessage2Ptr:
	.db $01
	.asc "."

PlayerMissedMessagePtr:
	.db $07
	.asc "MISSED!"

VictoryMessagePtr:
	.db $08
	.asc "VICTORY!"

LevelUpMessagePtr:
	.db $0d
	.asc "LEVEL GAINED!"

PlayerDodgedMessagePtr:
	.db $16
	.asc "YOU DODGER THE ATTACK!"	; Typo

FoodFoundMessagePtr:
	.db $14
	.asc "YOU FOUND SOME FOOD."

GoldFoundMessagePtr:
	.db $05
	.asc "GOLD!"

SecretPathFoundMessagePtr:
	.db $07
	.asc "A PATH!"

OutOfFoodMessagePtr:
	.db $10
	.asc "I'M OUT OF FOOD."

RecoveryMessagePtr:
	.db $09
	.asc "RECOVERY!"

HandsFullMessagePtr:
	.db $14
	.asc "YOUR HANDS ARE FULL."

MonsterEnragedMessagePtr:
	.db $1b
	.asc "YOU'VE ENRAGED THE MONSTER!"

MonsterConfusedMessagePtr:
	.db $1c
	.asc "YOU'VE CONFUSED THE MONSTER!"

MonsterParalyzedMessagePtr:
	.db $1d
	.asc "YOU'VE PARALYZED THE MONSTER!"

MonsterSlowMessagePtr:
	.db $16
	.asc "THE MONSTER HESITATES!"

NothingHappenedMessagePtr:
	.db $11
	.asc "NOTHING HAPPENED."

MonsterBlownAwayMessagePtr:
	.db $1a
	.asc "THE MONSTER IS BLOWN AWAY!"

PlayerAwakenedMessagePtr:
	.db $10
	.asc "YOU'VE AWAKENED!"

WeaponStrongerMessagePtr:
	.db $10
	.asc "MY WEAPON BECAME SHARPER."		; The length should be $19- the message cuts off

ArmorStrongerMessagePtr:
	.db $16
	.asc "MY ARMOR GOT STRONGER."

NoRustMessagePtr:
	.db $14
	.asc "MY ARMOR WON'T RUST."

CurseRemovedMessagePtr:
	.db $17
	.asc "I AWOKE FROM THE SPELL."

FloorMapRevealedMessagePtr:
	.db $10
	.asc "I FOUND THE MAP."

TeleportRandomRoomMessagePtr:
	.db $0f
	.asc "I FEEL LIGHTER."

NoEffectMessagePtr:
	.db $0a
	.asc "NO EFFECT!"

PlayerParalyzedMessagePtr:
	.db $11
	.asc "YOU'RE PARALYZED!"

EnemySummonedMessagePtr:
	.db $06
	.asc "ENEMY!"

SwordTransformedMessagePtr:
	.db $11
	.asc "MY SWORD CHANGED!"

BlankScrollNothingMessagePtr:
	.db $0b
	.asc "IT'S BLANK!"

PlayerUsedMagicMessagePtr:
	.db $0d
	.asc "I USED MAGIC."

PlayerBerserkMessagePtr:
	.db $0f
	.asc "YOU GO BERSERK!"

MonsterNoMagicMessagePtr:
	.db $1d
	.asc "THE ENEMY SPELL IS DEFLECTED!"

EnemyTransformedMessagePtr:
	.db $12
	.asc "THE ENEMY MUTATES!"

TeleportNextFloorMessagePtr:
	.db $1d
	.asc "YOU'RE SLIPPING THROUGH TIME!"

HitPointSwapMessagePtr:
	.db $1a
	.asc "YOU'VE SWAPPED HIT POINTS!"

LevelDownMessage1Ptr:
	.db $17
	.asc "YOU'VE DROPPED A LEVEL!"

PlayerHealedMessagePtr:
	.db $15
	.asc "YOUR HEALTH IMPROVES."

PlayerSlowMessagePtr:
	.db $12
	.asc "YOU FEEL SLUGGISH!"

PlayerSlowHealedMessagePtr:
	.db $14
	.asc "YOUR SPEED IMPROVES!"

PlayerFogMessagePtr:
	.db $1c
	.asc "YOU'RE BLINDED BY DENSE FOG!"

PlayerLightheadedMessagePtr:
	.db $17
	.asc "YOU FEEL LIGHTHEADED..."

PlayerStatusHealedMessagePtr:
	.db $1c
	.asc "YOU RECOVER FROM THE POISON!"

PlayerStrengthDownMessage1Ptr:
	.db $1a
	.asc "YOU'RE STRENGTH DECREASES!"	; Typo

PlayerMagicUpMessagePtr:
	.db $1b
	.asc "YOU FEEL A SURGE OF ENERGY!"

PlayerSightUpMessagePtr:
	.db $19
	.asc "YOUR SENSES ARE ENHANCED!"

PlayerDefenseUpMessage1Ptr:
	.db $19
	.asc "YOU CONJURE A MAGIC WALL!"

PlayerStrengthUpMessage1Ptr:
	.db $17
	.asc "YOUR STRENGTH IMPROVES!"

PlayerCursedMessagePtr:
	.db $13
	.asc "YOU'VE BEEN CURSED!"

RingDoesNothingMessagePtr:
	.db $0a
	.asc "NO EFFECT."

SwordDoesNothingMessagePtr:
	.db $17
	.asc "YOUR SWORD DOESN'T CUT!"

PlayerDeadMessagePtr:
	.db $13
	.asc "YOU CAN'T GO ON...."

SwordCursedMessagePtr:
	.db $14
	.asc "THE SWORD IS CURSED!"

ArmorCursedMessagePtr:
	.db $14
	.asc "THE ARMOR IS CURSED!"

WarpMessagePtr:
	.db $05
	.asc "WARP!"

PlayerPoisonedMessagePtr:
	.db $12
	.asc "YOU'RE POISONED..."

ArmorRustMessagePtr:
	.db $11
	.asc "YOUR ARMOR RUSTS!"

WeaponRustMessagePtr:
	.db $12
	.asc "YOUR WEAPON RUSTS!"

FoodStolenMessagePtr:
	.db $1c
	.asc "THE MONSTER STOLE YOUR FOOD!"

PlayerStrengthDownMessage2Ptr:
	.db $10
	.asc "I LOST STRENGTH!"

LevelDownMessage2Ptr:
	.db $14
	.asc "MY LEVEL WENT DOWN!!"

PlayerStrengthUpMessage2Ptr:
	.db $1b
	.asc "YOU FEEL A SURGE OF ENERGY!"

PlayerDefenseUpMessage2Ptr:
	.db $1d
	.asc "YOUR REACTIONS ARE SHARPENED!"

PotionTransformedMessagePtr:
	.db $14
	.asc "THE POTIONS CHANGED."

PlayerIdleMessagePtr:
	.db $12
	.asc "WHAT SHALL YOU DO?"

CursedSwordEquippedMessagePtr:
	.db $1b
	.asc "THE SWORD CAN'T BE DROPPED!"

CursedArmorEquippedMessagePtr:
	.db $1b
	.asc "THE ARMOR CAN'T BE REMOVED!"

CursedRingEquippedMessagePtr:
	.db $1a
	.asc "THE RING CAN'T BE REMOVED!"

MonsterSummonedMessagePtr:
	.db $16
	.asc "A MONSTER IS SUMMONED!"

WaterPotionMessagePtr:
	.db $18
	.asc "YOUR THIRST IS QUENCHED."

PlayerDizzinessMessagePtr:
	.db $1d
	.asc "YOUR HEAD SPINS IN CONFUSION!"

EndOfMessageTablePtr:
	.db $00 $00