class_name WaveDisplay extends Control

# TODO: update label or progress bar with status
func update_label(wave_number: int, remaining: int):
	var text = "Wave {0}: {1} Remaining".format([wave_number, remaining])
	$Label.text = text
