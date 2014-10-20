; Battle and exploration messages
MonsterDamagedMessage1:
	.db $0d
	.asc "MONSTER DOWN "

MonsterDamagedMessage2:
	.db $0e
	.asc " HIT POINT(S)!"

PlayerDamagedMessage1:
	.db $0c
	.asc "YOU'RE DOWN "

PlayerDamagedMessage2:
	.db $0e
	.asc " HIT POINT(S)!"

ItemFoundMessage1:
	.db $0c
	.asc "YOU FOUND A "

ItemFoundMessage2:
	.db $01
	.asc "."

PlayerMissedMessage:
	.db $07
	.asc "MISSED!"

VictoryMessage:
	.db $08
	.asc "VICTORY!"

LevelUpMessage:
	.db $0d
	.asc "LEVEL GAINED!"

PlayerDodgedMessage:
	.db $16
	.asc "YOU DODGER THE ATTACK!"	; Typo

FoodFoundMessage:
	.db $14
	.asc "YOU FOUND SOME FOOD."

GoldFoundMessage:
	.db $05
	.asc "GOLD!"

SecretPathFoundMessage:
	.db $07
	.asc "A PATH!"

OutOfFoodMessage:
	.db $10
	.asc "I'M OUT OF FOOD."

RecoveryMessage:
	.db $09
	.asc "RECOVERY!"

HandsFullMessage:
	.db $14
	.asc "YOUR HANDS ARE FULL."

MonsterEnragedMessage:
	.db $1b
	.asc "YOU'VE ENRAGED THE MONSTER!"

MonsterConfusedMessage:
	.db $1c
	.asc "YOU'VE CONFUSED THE MONSTER!"

MonsterParalyzedMessage:
	.db $1d
	.asc "YOU'VE PARALYZED THE MONSTER!"

MonsterSlowMessage:
	.db $16
	.asc "THE MONSTER HESITATES!"

NothingHappenedMessage:
	.db $11
	.asc "NOTHING HAPPENED."

MonsterBlownAwayMessage:
	.db $1a
	.asc "THE MONSTER IS BLOWN AWAY!"

PlayerAwakenedMessage:
	.db $10
	.asc "YOU'VE AWAKENED!"

WeaponStrongerMessage:
	.db $10
	.asc "MY WEAPON BECAME SHARPER."		; The length should be $19- the message cuts off

ArmorStrongerMessage:
	.db $16
	.asc "MY ARMOR GOT STRONGER."

NoRustMessage:
	.db $14
	.asc "MY ARMOR WON'T RUST."

CurseRemovedMessage:
	.db $17
	.asc "I AWOKE FROM THE SPELL."

FloorMapRevealedMessage:
	.db $10
	.asc "I FOUND THE MAP."

TeleportRandomRoomMessage:
	.db $0f
	.asc "I FEEL LIGHTER."

NoEffectMessage:
	.db $0a
	.asc "NO EFFECT!"

PlayerParalyzedMessage:
	.db $11
	.asc "YOU'RE PARALYZED!"

EnemySummonedMessage:
	.db $06
	.asc "ENEMY!"

SwordTransformedMessage:
	.db $11
	.asc "MY SWORD CHANGED!"

BlankScrollNothingMessage:
	.db $0b
	.asc "IT'S BLANK!"

PlayerUsedMagicMessage:
	.db $0d
	.asc "I USED MAGIC."

PlayerBerserkMessage:
	.db $0f
	.asc "YOU GO BERSERK!"

MonsterNoMagicMessage:
	.db $1d
	.asc "THE ENEMY SPELL IS DEFLECTED!"

EnemyTransformedMessage:
	.db $12
	.asc "THE ENEMY MUTATES!"

TeleportNextFloorMessage:
	.db $1d
	.asc "YOU'RE SLIPPING THROUGH TIME!"

HitPointSwapMessage:
	.db $1a
	.asc "YOU'VE SWAPPED HIT POINTS!"

LevelDownMessage1:
	.db $17
	.asc "YOU'VE DROPPED A LEVEL!"

PlayerHealedMessage:
	.db $15
	.asc "YOUR HEALTH IMPROVES."

PlayerSlowMessage:
	.db $12
	.asc "YOU FEEL SLUGGISH!"

PlayerSlowHealedMessage:
	.db $14
	.asc "YOUR SPEED IMPROVES!"

PlayerFogMessage:
	.db $1c
	.asc "YOU'RE BLINDED BY DENSE FOG!"

PlayerLightheadedMessage:
	.db $17
	.asc "YOU FEEL LIGHTHEADED..."

PlayerStatusHealedMessage:
	.db $1c
	.asc "YOU RECOVER FROM THE POISON!"

PlayerStrengthDownMessage1:
	.db $1a
	.asc "YOU'RE STRENGTH DECREASES!"	; Typo

PlayerMagicUpMessage:
	.db $1b
	.asc "YOU FEEL A SURGE OF ENERGY!"

PlayerSightUpMessage:
	.db $19
	.asc "YOUR SENSES ARE ENHANCED!"

PlayerDefenseUpMessage1:
	.db $19
	.asc "YOU CONJURE A MAGIC WALL!"

PlayerStrengthUpMessage1:
	.db $17
	.asc "YOUR STRENGTH IMPROVES!"

PlayerCursedMessage:
	.db $13
	.asc "YOU'VE BEEN CURSED!"

RingDoesNothingMessage:
	.db $0a
	.asc "NO EFFECT."

SwordDoesNothingMessage:
	.db $17
	.asc "YOUR SWORD DOESN'T CUT!"

PlayerDeadMessage:
	.db $13
	.asc "YOU CAN'T GO ON...."

SwordCursedMessage:
	.db $14
	.asc "THE SWORD IS CURSED!"

ArmorCursedMessage:
	.db $14
	.asc "THE ARMOR IS CURSED!"

WarpMessage:
	.db $05
	.asc "WARP!"

PlayerPoisonedMessage:
	.db $12
	.asc "YOU'RE POISONED..."

ArmorRustMessage:
	.db $11
	.asc "YOUR ARMOR RUSTS!"

WeaponRustMessage:
	.db $12
	.asc "YOUR WEAPON RUSTS!"

FoodStolenMessage:
	.db $1c
	.asc "THE MONSTER STOLE YOUR FOOD!"

PlayerStrengthDownMessage2:
	.db $10
	.asc "I LOST STRENGTH!"

LevelDownMessage2:
	.db $14
	.asc "MY LEVEL WENT DOWN!!"

PlayerStrengthUpMessage2:
	.db $1b
	.asc "YOU FEEL A SURGE OF ENERGY!"

PlayerDefenseUpMessage2:
	.db $1d
	.asc "YOUR REACTIONS ARE SHARPENED!"

PotionTransformedMessage:
	.db $14
	.asc "THE POTIONS CHANGED."

PlayerIdleMessage:
	.db $12
	.asc "WHAT SHALL YOU DO?"

CursedSwordEquippedMessage:
	.db $1b
	.asc "THE SWORD CAN'T BE DROPPED!"

CursedArmorEquippedMessage:
	.db $1b
	.asc "THE ARMOR CAN'T BE REMOVED!"

CursedRingEquippedMessage:
	.db $1a
	.asc "THE RING CAN'T BE REMOVED!"

MonsterSummonedMessage:
	.db $16
	.asc "A MONSTER IS SUMMONED!"

WaterPotionMessage:
	.db $18
	.asc "YOUR THIRST IS QUENCHED."

PlayerDizzinessMessage:
	.db $1d
	.asc "YOUR HEAD SPINS IN CONFUSION!"