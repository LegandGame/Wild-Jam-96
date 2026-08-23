extends Node3D

@export_file_path() var main_menu_path = "res://ui/menus/main_menu/custom_main_menu.tscn"

@export var win_text = '''
Finally...                           
    The [color=deepskyblue][b]OmniSpark[/b][/color] is charged...       
  The [color=skyblue][b]Shields[/b][/color] are full strength...       
[font_size=50]And the [font_size=60][color=gray][b]Castle[/b][/color][/font_size] is safe![/font_size]
'''

@export var you_win = '''  [wave]You Win![/wave]
[shake][font_size=50]The Knights are ec[color=skyblue]static[/color]![/font_size][/shake]
'''

func _ready():
	AudioManager.play_menu_music()
	
	# initialize parts of scene
	$TextLabel.visible_ratio = 0.0
	$TextLabel.text = win_text
	
	$YouWin.modulate.a = 0
	$YouWin.text = you_win
	
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
	
	await get_tree().create_timer(5).timeout
		
	await text_tween.finished
	await get_tree().create_timer(2).timeout
	
	# fade story text out, start win music
	var fade_tween = create_tween()
	fade_tween.tween_property($TextLabel, "modulate:a", 0, 3)
	AudioManager.play_win_music()
	await fade_tween.finished
	
	# fade in win text
	var win_tween = create_tween()
	win_tween.tween_property($YouWin, "modulate:a", 1, 3)
	
	await get_tree().create_timer(3).timeout
	$Button.visible = true

func _on_button_pressed():
	get_tree().change_scene_to_file(main_menu_path)
