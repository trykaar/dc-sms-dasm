; Port definitions
.define VDPData					$BE
.define VDPControl				$BF

; Reset status
.define CurrentlyResetting		$C004

; Autoplaying demo- starts after title screen
; Autoplay mode can be turned on during gameplay with PAR code 00C006?? where ?? is $02 or greater
.define Autoplay 				$C006	; 00 is off, 01 during play goes to title screen
.define AutoplayDirection 		$C007	; high bit 1 is button 1 2 is button 2; low bit 1 is up 2 is down 4 is left 8 is right
.define AutoplayCountdownLow	$C008
.define AutoplayCountdownHigh 	$C009
.define AutoplayVar3 			$C00A	; possibly randomly generated number

; Controller status
.define CurrentControllerState 	$C00C
.define LastControllerState 	$C00D

; Title
.define TitleScreenCounterLow	$C012
.define TitleScreenCounterHigh	$C013

; Random Number Generation
.define RNGSeed					$C016

; Palette mirrors
.define PaletteInRAM			$C020
.define PaletteInRAM2			$C060
.define PaletteInRAMStatus		$C01E

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

.define CurrentHPLow			$C621
.define CurrentHPHigh			$C622
.define MaxHPLow				$C623
.define MaxHPHigh				$C624

.define ExperienceLow			$C625
.define ExperienceHigh			$C626
.define NextLevelLow			$C628
.define NextLevelHigh			$C629

.define MoneyLow				$C62B
.define MoneyMid				$C62C
.define MoneyHigh				$C62D

.define BasePW 					$C62F
.define BaseAC 					$C630

.define PreventArmorRust		$C631

.define ParalysisTicksLeft		$C632
.define SluggishTicksLeft 		$C633
.define PoisonTicksLeft 		$C634
.define BlindnessTicksLeft 		$C635
.define DizzinessTicksLeft 		$C636

.define FoodTimer 				$C63C
.define HealTimer 				$C63D
.define ContinuesSpent			$C63E

.define EquippedWeapon			$C900
.define EquippedArmor			$C908
.define EquippedRing			$C928

.define CurrentItem				$C931

.define NextMessage				$C975
.define CurrentMessage			$CAC4

.define PlayerIdleTimer			$CAC8