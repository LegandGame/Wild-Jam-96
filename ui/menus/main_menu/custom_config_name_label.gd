@tool
extends Label
## Displays the value of `application/config/name`, set in project settings.

const NO_NAME_STRING : String = "Title"

## If true, update the title when ready.
@export var auto_update : bool = true

func update_name_label():
	var config_name : String = ProjectSettings.get_setting("application/config/name", NO_NAME_STRING)
	if config_name.is_empty():
		config_name = NO_NAME_STRING
	
	# Scale differently based on font
	if not DirAccess.get_files_at("res://assets/fonts/").is_empty():
		text = config_name.to_upper()
		add_theme_font_size_override("font_size", 80)
	else:
		text = config_name
		add_theme_font_size_override("font_size", 60)

func _ready():
	if auto_update:
		update_name_label()
