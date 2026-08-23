extends Node3D

@export_file_path() var main_menu_path = "res://ui/menus/main_menu/custom_main_menu.tscn"

#TODO update
@export var lose_text = '''
[font_size=50]The [font_size=60][color=gray][b]Castle[/b][/color][/font_size] is overrun![/font_size]
The [color=deepskyblue][b]OmniSpark[/b][/color] has been [color=maroon]lost[/color]...       
'''

# TODO update
@export var try_again = '''[wave]Try Again![/wave]
[shake][font_size=50]The Knights need you![/font_size][/shake]
'''

func _ready():
	# initialize parts of scene
	$TextLabel.visible_ratio = 0.0
	$TextLabel.text = lose_text
	
	$TryAgain.modulate.a = 0
	$TryAgain.text = try_again
	
	$Button.visible = false
	
	# fade in from black
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property($ColorRect, "color", Color(0,0,0,0), 3)
	await fade_in_tween.finished
	
	# wait a bit
	await get_tree().create_timer(2).timeout
	
	# scroll story text
	var text_tween = create_tween()
	text_tween.tween_property($TextLabel, "visible_ratio", 1.0, 10)
	
	AudioManager.play_lose_music()
	
	await get_tree().create_timer(5).timeout
	
	await text_tween.finished
	await get_tree().create_timer(2).timeout
	
	# fade story text out, start lose music
	var fade_tween = create_tween()
	fade_tween.tween_property($TextLabel, "modulate:a", 0, 3)
	await fade_tween.finished
	
	# fade in lose text
	var win_tween = create_tween()
	win_tween.tween_property($TryAgain, "modulate:a", 1, 3)
	
	await get_tree().create_timer(3).timeout
	$Button.visible = true

func _on_button_pressed():
	get_tree().change_scene_to_file(main_menu_path)
