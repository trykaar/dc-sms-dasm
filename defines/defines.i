; Port definitions
.define VDPData					$BE
.define VDPControl				$BF

; Autoplaying demo- starts after title screen
; Autoplay mode can be turned on during gameplay with PAR code 00C006?? where ?? is $02 or greater
.define Autoplay 				$C006	; 00 is off, 01 during play goes to title screen
.define AutoplayDirection 		$C007	; high bit 1 is button 1 2 is button 2; low bit 1 is up 2 is down 4 is left 8 is right
.define AutoplayCountdownLow	$C008
.define AutoplayCountdownHigh 	$C009
.define AutoplayVar3 			$C00A	; possibly randomly generated number

.define ControllerDirection 	$C00C

; Title
.define TitleScreenCounterLow	$C012
.define TitleScreenCounterHigh	$C013

; Random Number Generation
.define RNGSeed					$C016

; Palette mirrors
.define PaletteInRAM			$C020
.define PaletteInRAM2			$C060

; Control
.define PlayerSpeed				$C0CF	; Also controls animation speed?

; Game State
.define Floor					$C01C

; Jump Tables
.define TableIndex1				$C018	; Table at $17F
.define VBlankAction			$C011	; Table at $1D1
.define TableIndex3				$C0A0	; Table at $4ED
; Table at $2012 index not yet known
; Additional tables start at $25FB? Odd format, possibly a single table
; Table at $3CC0 index not yet known
; Table at $3E68 index not yet known
.define TableIndex8				$C438	; Table at $4CB4

.define WeaponHit 				$C617
.define WeaponPW 				$C618
.define ArmorEvd 				$C619
.define ArmorAC 				$C61A

.define CharacterLevel 			$C61F	; Also determines Dragon state- seems to be checked every frame?

.define Food 					$C620

.define CurrentHPHigh			$C621
.define CurrentHPLow			$C622
.define MaxHPHigh				$C623
.define MaxHPLow				$C624

.define ExperienceHigh			$C625
.define ExperienceLow			$C626
.define NextLevelHigh			$C628
.define NextLevelLow			$C629

.define MoneyHigh				$C62B
.define MoneyMid				$C62C
.define MoneyLow				$C62D

.define BasePW 					$C62F
.define BaseAC 					$C630

; C631 is written every floor to 00

.define ParalysisTicksLeft		$C632
.define SluggishTicksLeft 		$C633
.define PoisonTicksLeft 		$C634
.define BlindnessTicksLeft 		$C635
.define DizzinessTicksLeft 		$C636

.define FoodTimer 				$C63C
.define HealTimer 				$C63D
.define ContinuesSpent			$C63E

.define CurrentItem				$C931
.define EquippedWeapon			$C900
.define EquippedArmor			$C908

.define CurrentMessage			$CAC4
