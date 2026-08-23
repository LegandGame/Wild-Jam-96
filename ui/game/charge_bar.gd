class_name ChargeBar extends TextureProgressBar

var rate = Upgrades.CHARGE_PRODUCTION_LEVEL_AMOUNTS[0]

func _set_tooltip():
	tooltip_text = '''
	Current charge: {0}/{1}
	Producing {2} charge per second.
	'''.format(["%.0f" % value, "%.0f" % max_value, "%.0f" % rate])

func _on_charge_modified(p_value):
	value = p_value
	$Label.text = "%.0f" % ((value / max_value) * 100) + "%"
	_set_tooltip()

func _on_charge_level_changed(level):
	rate = Upgrades.CHARGE_PRODUCTION_LEVEL_AMOUNTS[level]
