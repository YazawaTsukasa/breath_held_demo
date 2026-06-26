extends Node
class_name UIManager

var ui_inventory_ref: String = \
	"res://Content/UI/HUD/Inventory/ui_inventory.tscn"
var ui_ui_player_value_ref: String = \
	"res://Content/UI/HUD/PlayerValue/ui_player_value.tscn"
var ui_game_over_ref: String = \
	"res://Content/UI/GameOverScene/ui_game_over.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("UI Manager Ready")
	game_manager.on_scene_start.connect(_on_scene_start)
	player_data_manager.on_player_game_over.connect(_on_game_over)

func _init_ui(ui_ref: String):
	var ui_scene: Resource = load(ui_ref)
	var ui_instance = ui_scene.instantiate()
	var current_scene = game_manager.get_current_game_scene()
	if not current_scene:
		return
	var ui_root = current_scene.get_node_or_null("UI_Root")
	if ui_root:
		ui_root.add_child(ui_instance)

func _on_scene_start():
	_init_ui(ui_inventory_ref)
	_init_ui(ui_ui_player_value_ref)

func _on_game_over():
	#pass
	_init_ui(ui_game_over_ref)
