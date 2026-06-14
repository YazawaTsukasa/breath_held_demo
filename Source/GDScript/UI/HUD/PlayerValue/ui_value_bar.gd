extends HBoxContainer
class_name UIValueBar

@onready var ui_value_name:Label=%ValueName
@onready var ui_value_bar:ProgressBar=%ValueBar
@onready var ui_value_text:Label=%ValueText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("UIValueBar Onready")
	#pass # Replace with function body.

func set_value_min_max(_min_value:int,_max_value:int):
	if not ui_value_bar:
		return
	ui_value_bar.min_value=_min_value
	ui_value_bar.max_value=_max_value

func set_value_name(value_name:String):
	if ui_value_name:
		ui_value_name.text=value_name

func set_value(value:int):
	if not ui_value_bar:
		return
	if value<ui_value_bar.min_value:
		value=int(round(ui_value_bar.min_value))
	elif value>ui_value_bar.max_value:
		value=int(round(ui_value_bar.max_value))
	ui_value_bar.value=value
	if ui_value_text:
		ui_value_text.text=str(value)

func set_progress_style(style:StyleBox):
	if not style:
		return
	ui_value_bar.add_theme_stylebox_override("fill",style)
