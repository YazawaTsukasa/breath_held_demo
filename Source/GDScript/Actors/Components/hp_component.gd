extends Node2D
class_name HPComponent

@export var is_hp_bar_visible: bool = true
@export var non_player_max_hp: int = 20
@export var non_player_init_hp: int = 19

@onready var hp_bar: ProgressBar = %HPBar

var _max_hp: int = non_player_max_hp
var _init_hp: int = non_player_init_hp
@onready var _current_hp: int = _max_hp

signal hp_changed_by_damage(hp: int)
signal hp_changed_by_heal(hp: int)
signal hp_become_zero()

var _is_player_child: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# NOTE: テスト用 HPバー初期化
	initialize()
	set_hp_bar_visible(is_hp_bar_visible)

func initialize():
	var parent = get_parent()
	if not parent:
		return
	var is_player = ComponentTool.is_parent_player(parent)
	if is_player:
		_is_player_child = true
		_max_hp = \
			player_data_manager.get_property_attribute(
				"hp", "max_value")
		_init_hp = \
			player_data_manager.get_property_attribute(
				"hp", "current_value")
	else:
		_is_player_child = false
		_max_hp = non_player_max_hp
		_init_hp = non_player_init_hp
	if hp_bar:
		hp_bar.max_value = _max_hp
	_change_hp(_init_hp)

func set_hp_bar_visible(visibility: bool):
	is_hp_bar_visible = visibility
	if hp_bar:
		hp_bar.visible = is_hp_bar_visible

func _update_hp_bar_value():
	hp_bar.value = _current_hp

func take_damage(value: int):
	_change_hp_by_difference(-value)
	hp_changed_by_damage.emit(_current_hp)
	print("damage: ", value)
	
func take_healing(value: int):
	_change_hp_by_difference(value)
	hp_changed_by_heal.emit(_current_hp)
	print("healing: ", value)

func _change_hp_by_difference(delta: int):
	var expect_hp = _current_hp + delta
	_change_hp(expect_hp)

func _change_hp(expect_hp: int):
	if expect_hp < 0:
		expect_hp = 0
	elif expect_hp > _max_hp:
		expect_hp = _max_hp
	_current_hp = expect_hp
	_update_hp_bar_value()
	print("current hp: ", _current_hp)
	if _current_hp == 0:
		_on_hp_become_zero()
	
	if _is_player_child:
		player_data_manager.change_property_value(
			"hp", _current_hp)

func _on_hp_become_zero():
	print("hp became zero")
	hp_become_zero.emit()
