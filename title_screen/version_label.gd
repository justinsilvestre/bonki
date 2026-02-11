extends Label
var build_number: String = "dev-build"

func _ready():
	# 1. Get the version from Project Settings
	if FileAccess.file_exists("res://build_info.txt"):
		var file = FileAccess.open("res://build_info.txt", FileAccess.READ)
		build_number = file.get_as_text().strip_edges()
	
	print("Build Number: ", build_number)
	
	# 2. Check if this is a debug build
	var build_type_prefix = ""
	if OS.is_debug_build():
		build_type_prefix = "DEBUG_BUILD "
		# Optional: Change color to red for debug builds so it stands out
		add_theme_color_override("font_color", Color.CORAL)
	
	# 3. Update the text
	text = build_type_prefix + str(build_number)
