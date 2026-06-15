extends Node
class_name PlayerController

var _player_character:MainCharacter=null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Player Controller Ready")
	
func set_player_character(new_main_character:MainCharacter):
	_player_character=new_main_character
	if _player_character:
		print("set_player_character successed")
		_player_character.set_team(Team.Type.PLAYER)
		_player_character.ready.connect(_set_player_zero_item)
		
		_player_character.on_ready=_init_player_data

func _init_player_data():
	if not _player_character:
		return
	var data_asset=\
		resource_manager.get_data_asset_resource("player_data")
	if data_asset:
		_player_character.init_data(data_asset)

func check_is_player_character(character:MainCharacter):
	if not character:print("not character")
	if not _player_character:print("not player_character")
	if not character or not _player_character:
		return false
	return character==_player_character

func set_player_item_by_index(index:int):
	var item:ItemBase=player_data_manager.get_item_by_index(index)
	_set_player_item(item)

func _set_player_zero_item():
	set_player_item_by_index(0)

func _set_player_item(item:ItemBase):
	if not _player_character:
		return
	_player_character.set_item(item)

# NOTE: Temporary Player Input
func _input(event):
	if not is_instance_valid(_player_character):
		return
	
	if Input.is_key_pressed(KEY_SHIFT):
		_player_character.set_running_state(true)
	else:
		_player_character.set_running_state(false)
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			_player_character.dash()
		if event.pressed and event.keycode == KEY_C:
			speed_manager.switch_to_decel()
		if not event.pressed and event.keycode == KEY_C:
			speed_manager.switch_to_normal()
		if event.pressed and event.keycode == KEY_V:
			speed_manager.switch_to_accel()
		if not event.pressed and event.keycode == KEY_V:
			speed_manager.switch_to_normal()
		if not event.pressed and event.keycode == KEY_R:
			#attack_type="reload"
			_player_character.use_pivot_item("reload")
	
	# Weapon Attack
	var attack_type=""
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			#print("MOUSE_BUTTON_LEFT pressed")
			attack_type="normal_using"
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			#print("MOUSE_BUTTON_RIGHT pressed")
			attack_type="special_using"
		elif event.pressed and event.button_index == MOUSE_BUTTON_MIDDLE:
			#print("MOUSE_BUTTON_MIDDLE pressed")
			_player_character._start_throw_gauge()
		elif not event.pressed and event.button_index == MOUSE_BUTTON_MIDDLE:
			#print("MOUSE_BUTTON_MIDDLE released")
			_player_character._end_throw_gauge()
	
		if attack_type!="":
			_player_character.use_pivot_item(attack_type)
