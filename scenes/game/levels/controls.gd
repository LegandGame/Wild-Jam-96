class_name Controls extends Node3D

const GAME_LEVEL_PATH = "res://scenes/game/levels/game_level.tscn"

@export var text = '''
Defend the castle!

Enemies are closing in from all sides. 
Hold down the fort until the OmniSpark is fully charged,
but you'll need to use some of that charge on units and upgrades
if you want to survive!

Units you summon spawn around your castle.
Move the camera with WASD and Q/E to rotate.
Hover over the buttons on the right for info on their effects and charge cost. 
'''

func _ready():
	$Blackout.color.a = 1
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property($Blackout, "color:a", 0.0, 2)
	await fade_in_tween.finished
	
	await get_tree().create_timer(12).timeout
	
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property($Blackout, "color:a", 1.0, 2)
	await fade_out_tween.finished
	
	get_tree().change_scene_to_file(GAME_LEVEL_PATH)


func _on_button_pressed():
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property($Blackout, "color:a", 1.0, 2)
	await fade_out_tween.finished
	
	get_tree().change_scene_to_file(GAME_LEVEL_PATH)
