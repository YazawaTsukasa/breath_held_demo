extends Node
class_name PlayerController

var player_character:MainCharacter=null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Player Controller Ready")
	
func set_player_character(new_main_character:MainCharacter):
	player_character=new_main_character
	if player_character:
		print("set_player_character successed")
		player_character.set_team(Team.Type.PLAYER)
		player_character.ready.connect(_set_player_zero_item)

func check_is_player_character(character:MainCharacter):
	if not character:print("not character")
	if not player_character:print("not player_character")
	if not character or not player_character:
		return false
	return character==player_character

func set_player_item_by_index(index:int):
	var item:ItemBase=player_data_manager.get_item_by_index(index)
	_set_player_item(item)

func _set_player_zero_item():
	set_player_item_by_index(0)

func _set_player_item(item:ItemBase):
	if not player_character:
		return
	player_character.set_item(item)
