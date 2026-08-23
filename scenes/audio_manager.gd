extends Node

const MENU_MUSIC = preload("res://assets/audio/mus_menu.ogg")
const LEVEL_INTRO_MUSIC = preload("res://assets/audio/mus_serious_w_intro.ogg")
const LEVEL_LOOP_MUSIC = preload("res://assets/audio/mus_serious_loop.ogg")
const LOSE_MUSIC = preload("res://assets/audio/mus_lose.ogg")
const WIN_MUSIC = preload("res://assets/audio/mus_win.ogg")

const CLICK_EFFECT = preload("res://assets/audio/click.wav")
const UPGRADE_EFFECT = preload("res://assets/audio/mus_upgrade.ogg")

@export var BASE_MUSIC_DB = -6

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

func _ready():
	# set up music player, start quiet for fade in
	music_player.bus = "Music"
	music_player.volume_db = -80
	
	# set up sfx player, allow up to 4 concurrent sounds
	sfx_player.bus = "SFX"
	sfx_player.max_polyphony = 4
	
	# start menu music
	play_menu_music()

func _fade_out(audio_player, seconds):
	if seconds <= 0:
		audio_player.volume_db = -80
		return
	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", -80, seconds)
	await tween.finished

func _fade_in(audio_player, seconds):
	if seconds <= 0:
		audio_player.volume_db = BASE_MUSIC_DB
		return
	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", BASE_MUSIC_DB, seconds).set_ease(Tween.EASE_OUT)
	await tween.finished

#region MusicPlayer
func _play_music(stream, fade_out_duration = 1, fade_in_duration = 1):
	if music_player.playing:
		await _fade_out(music_player, fade_out_duration)
	
	# kick off intro - follow-up loop is handled on finished signal
	music_player.stream = stream
	music_player.play()
	_fade_in(music_player, fade_in_duration)

func play_menu_music():
	_play_music(MENU_MUSIC, 1, 3)

func play_level_music():
	# kick off intro - follow-up loop is handled on finished signal
	_play_music(LEVEL_INTRO_MUSIC, 1, 0)

func play_lose_music():
	_play_music(LOSE_MUSIC, 1, 0)

func play_win_music():
	_play_music(WIN_MUSIC, 1, 0)

func _on_music_player_finished():
	# handle tracks with intro then loop
	if music_player.stream == LEVEL_INTRO_MUSIC:
		music_player.stream = LEVEL_LOOP_MUSIC
		music_player.play()
	elif music_player.stream == WIN_MUSIC or music_player.stream == LOSE_MUSIC:
		play_menu_music()
#endregion

#region SFXPlayer
func play_click():
	if sfx_player.stream != CLICK_EFFECT:
		sfx_player.stream = CLICK_EFFECT
		sfx_player.volume_db = 15
	sfx_player.play()

func play_upgrade():
	sfx_player.stream = UPGRADE_EFFECT
	sfx_player.volume_db = 0
	sfx_player.play()

func _on_sfx_player_finished():
	pass
#endregion
