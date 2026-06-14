extends Control
class_name UIPlayerValue

@onready var box_container:VBoxContainer=$VBoxContainer

@export var player_property_id_sbf:Dictionary[String,StyleBoxFlat]
@export var ui_value_bar_ref:String=\
	"res://Content/UI/HUD/PlayerValue/ui_value_bar.tscn"

var _bars:Dictionary[String,UIValueBar]={}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("UIPlayerValue Onready")
	_init_value_bars()

func _init_value_bars():
	for id in player_property_id_sbf:
		_init_value_bar(
			id,player_property_id_sbf.get(id))

func _init_value_bar(
	player_property_id:String,
	sbf_res:StyleBoxFlat
):
	if not player_data_manager.has_property(player_property_id):
		return
	var new_bar=_create_value_bar(
		player_data_manager.get_property_attribute(
			player_property_id,"name"),
		player_data_manager.get_property_attribute(
			player_property_id,"min_value"),
		player_data_manager.get_property_attribute(
			player_property_id,"max_value"),
		player_data_manager.get_property_attribute(
			player_property_id,"current_value"),
		sbf_res)
	if new_bar:
		_bars[player_property_id]=new_bar
		player_data_manager.connect_property_changed(
			player_property_id,
			_on_value_changed.bind(player_property_id))

func _create_value_bar(
	value_name:String,
	min_value:int,max_value:int,
	init_value:int,
	style_box:StyleBox=null
):
	print("_create_value_bar")
	if not box_container:
		print("No box_container")
		return
	var ui_value_bar_scene:Resource=load(ui_value_bar_ref)
	var ui_value_bar_instance:UIValueBar=ui_value_bar_scene.instantiate()
	box_container.add_child(ui_value_bar_instance)
	ui_value_bar_instance.set_value_name(value_name)
	ui_value_bar_instance.set_value_min_max(min_value,max_value)
	ui_value_bar_instance.set_value(init_value)
	ui_value_bar_instance.set_progress_style(style_box)
	return ui_value_bar_instance

func _on_value_changed(value:int,id:String):
	var _bar:UIValueBar=_get_bar_by_id(id)
	if _bar:
		_bar.set_value(value)
	

func _get_bar_by_id(id:String):
	if id not in _bars:
		return null
	return _bars.get(id)
