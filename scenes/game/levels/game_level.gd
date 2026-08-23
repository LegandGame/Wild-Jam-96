extends Node3D

@export_file_path() var win_file_path = "res://scenes/game/levels/Win.tscn"
@export_file_path() var lose_file_path = "res://scenes/game/levels/Lose.tscn"

func _ready():
	AudioManager.play_level_music()

func _on_min_charge_reached():
	# TODO play loss screen
	get_tree().change_scene_to_file(lose_file_path)

func _on_max_charge_reached():
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property($Blackout, "color:a", 1, 2)
	await fade_out_tween.finished
	
	AudioManager.play_menu_music()
	get_tree().change_scene_to_file(win_file_path)
