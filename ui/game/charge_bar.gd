class_name ChargeBar extends TextureProgressBar

func _on_charge_modified(p_value):
	value = p_value
	$Label.text = "%.0f" % ((value / max_value) * 100) + "%"
