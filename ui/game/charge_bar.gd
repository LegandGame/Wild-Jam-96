class_name ChargeBar extends TextureProgressBar

const BLUE_BAR = preload("res://assets/ui/bar/full_bar_2.png")
const RED_BAR = preload("res://assets/ui/bar/red_bar.png")

var rate = Upgrades.CHARGE_PRODUCTION_LEVEL_AMOUNTS[0]

func _process(_delta):
	if (value / max_value) < 0.1:
		texture_progress = RED_BAR
	else:
		texture_progress = BLUE_BAR

func _set_tooltip():
	tooltip_text = '''
	Current charge: {0}/{1}
	Producing {2} charge per second.
	'''.format(["%.0f" % value, "%.0f" % max_value, "%.0f" % rate])

func _on_charge_modified(p_value):
	var delta = p_value - value
	value = p_value
	$Label.text = "%.0f" % ((value / max_value) * 100) + "%"
	_set_tooltip()

func _on_charge_level_changed(level):
	rate = Upgrades.CHARGE_PRODUCTION_LEVEL_AMOUNTS[level]
