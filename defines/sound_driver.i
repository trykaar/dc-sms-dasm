.define PSGHCounter				$7F

.define TempoTimeout			$DD01
.define TempoResetValue			$DD02
.define PlaySoundSlot			$DD03	; Indexes jump table
.define SoundQueueSlots			$DD04
.define CurrentSoundPriority	$DD0F

.define DrumVolume				$DD16

.define	MusicTrack1				$DD40
.define MusicTrack2				$DD70
.define MusicTrack3				$DDA0
.define MusicTrack4_Noise		$DDD0
.define SFXTrack1_PSG2			$DE00
.define SFXTrack2_PSG3			$DE30
.define SFXTrack3_PSG4_Noise	$DE60

.define TrackEndSequenceData	$8139
.define PSGMuteValues			$83D4
.define VolumeEnvelopePointers	$888C
.define SoundPriorities			$8938
.define TempoList				$896D
.define MusicPointers			$897C
.define SFXPointers				$899A