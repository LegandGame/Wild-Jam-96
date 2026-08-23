class_name Tutorial extends Node3D

const GAME_LEVEL_PATH = "res://scenes/game/levels/game_level.tscn"

@export var tutorial1 = '''
[font_size=30]My lord! [shake]The Castle is under siege![/shake]
These [b]brigands[/b] are after the [i]very source[/i] of our power.

    ... The Blessed Battery ...
        ... The Celestial Cell ...
	        ... The Angelic Accumulator ...        

[/font_size][font_size=50][b]The [color=deepskyblue]OmniSpark![/color][/b][/font_size]         

[font_size=30]We must protect the castle until it is fully charged![/font_size]
'''

@export var tutorial2 = '''
[font_size=30]Thank heavens! The OmniSpark, praise its cogs, still retains some charge!

If ever it runs dry, we will be powerless against these knaves.

   [shake]Both [b]figuratively[/b] and [b]literally[/b]![/shake]

You must carefully direct the charge to power up our brethren - and the OmniSpark itself! -
without ever letting its bulbs fully dim.[/font_size]
'''

@export var tutorial3 = '''
[font_size=40]Good luck and praise the spark![/font_size]

[font_size=60]CHARGE![/font_size]
'''

func _ready():
	# initialize
	$Description.visible_ratio = 0.0
	$Description.text = tutorial1
	$ChargeBar.modulate.a = 0.0
	
	# play tutorial message 1
	await get_tree().create_timer(2).timeout
	
	var description_1_tween = create_tween()
	description_1_tween.tween_property($Description, "visible_ratio", 1.0, 10)
	await description_1_tween.finished
	
	await get_tree().create_timer(3).timeout
	
	var description_1_fade_tween = create_tween()
	description_1_fade_tween.tween_property($Description, "modulate:a", 0.0, 1)
	await description_1_fade_tween.finished
	
	# play tutorial message 2
	$Description2.visible_ratio = 0.0
	$Description2.text = tutorial2
	
	var charge_bar_tween = create_tween()
	charge_bar_tween.tween_property($ChargeBar, "modulate:a", 1.0, 1)
	
	var description_2_tween = create_tween()
	description_2_tween.tween_property($Description2, "visible_ratio", 1.0, 10)
	await description_2_tween.finished
	
	await get_tree().create_timer(3).timeout
	
	var description_2_fade_tween = create_tween()
	description_2_fade_tween.tween_property($Description2, "modulate:a", 0.0, 1)
	description_2_fade_tween.tween_property($ChargeBar, "modulate:a", 0.0, 1)
	await description_2_fade_tween.finished
	
	# play tutorial message 3
	$Description3.visible_ratio = 0.0
	$Description3.text = tutorial3
	var description_3_tween = create_tween()
	description_3_tween.tween_property($Description3, "visible_ratio", 1.0, 3)
	await description_3_tween.finished
	
	await get_tree().create_timer(3).timeout
	
	var fade_to_black_tween = create_tween()
	fade_to_black_tween.tween_property($ColorRect, "color:a", 1.0, 3)
	await fade_to_black_tween.finished
	
	get_tree().change_scene_to_file(GAME_LEVEL_PATH)

func _on_button_pressed():
	var fade_to_black_tween = create_tween()
	fade_to_black_tween.tween_property($ColorRect, "color:a", 1.0, 3)
	await fade_to_black_tween.finished
	
	get_tree().change_scene_to_file(GAME_LEVEL_PATH)
