extends Node3D

@export var win_text = '''
Finally...                           
    The [color=deepskyblue][b]OmniSpark[/b][/color] is charged...       
  The [color=skyblue][b]Shields[/b][/color] are full strength...       
[font_size=50]And the [font_size=60][color=gray][b]Castle[/b][/color][/font_size] is safe![/font_size]
'''

func _ready():
	$TextLabel.visible_ratio = 0.0
	$TextLabel.text = win_text
	
	$YouWin.modulate.a = 0
	
	await get_tree().create_timer(2).timeout
	
	var text_tween = create_tween()
	text_tween.tween_property($TextLabel, "visible_ratio", 1.0, 10)
	
	await get_tree().create_timer(5).timeout
		
	await text_tween.finished
	await get_tree().create_timer(2).timeout
	
	var fade_tween = create_tween()
	fade_tween.tween_property($TextLabel, "modulate:a", 0, 3)
	AudioManager.play_win_music()
	await fade_tween.finished
	
	var win_tween = create_tween()
	win_tween.tween_property($YouWin, "modulate:a", 1, 3)
