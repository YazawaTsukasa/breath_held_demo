extends Node
class_name PlayerDataManager

# アイテム更新時の信号
#signal player_item_update(index:int,item:ItemBase)
signal player_item_update(index: int, item: ItemInstanceData)
signal on_player_game_over

# 自動的にロードするプロパティ名
var _properties_names: Array[String] = [
	"hp", "sp",
]
var _properties: Dictionary = {}

#var _item_dict:Dictionary[int,ItemBase]={}
var _item_dict: Dictionary[int, ItemInstanceData] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.on_game_start.connect(_on_game_start)
	
func _on_game_start():
	_init_properties()
	_item_dict.clear()
	# Temporary
	_test_init_item_list()

# Items-----------------------------------------------------------
# NOTE: テスト用のアイテムリストの初期化
func _test_init_item_list():
	#var sword=ItemFactory.create_melee_weapon("sword")
	var sword = ItemFactory.get_melee_weapon_data("sword")
	add_item(sword)
	#var band_aid=ItemFactory.create_prop("band_aid")
	var band_aid = ItemFactory.get_prop_data("band_aid")
	add_item(band_aid)
	#var bow=ItemFactory.create_long_range_weapon("bow")
	var bow = ItemFactory.get_long_range_weapon_data("bow")
	add_item(bow)
	#var arrow_1=ItemFactory.create_projectile("arrow")
	var arrow_1 = ItemFactory.get_projectile_data("arrow")
	add_item(arrow_1)
	#var arrow_2=ItemFactory.create_projectile("arrow")
	var arrow_2 = ItemFactory.get_projectile_data("arrow")
	add_item(arrow_2)
	#var arrow_3=ItemFactory.create_projectile("arrow")
	var arrow_3 = ItemFactory.get_projectile_data("arrow")
	add_item(arrow_3)

#func add_item_list(items:Array[ItemBase]):
func add_item_list(items: Array[ItemInstanceData]):
	for item in items:
		add_item(item)
	
#func add_item(new_item:ItemBase):
func add_item(new_item: ItemInstanceData):
	if not new_item:
		return
	# 元の親から解放
	#var pre_parent = new_item.get_parent()
	#if pre_parent:
		#pre_parent.remove_child(new_item)
	
	var index_list: Array[int] = []
	index_list.assign(_item_dict.keys())
	index_list.sort()
	var new_index = 0
	while _item_dict.has(new_index):
		new_index += 1
	_item_dict[new_index] = new_item
	
	player_item_update.emit(new_index, new_item)

func remove_item_by_index(index: int):
	if not index in _item_dict:
		return
	_item_dict.erase(index)
	player_item_update.emit(index, null)
	
func remove_item_by_instance(item: ItemBase):
	if not is_instance_valid(item):
		return
	var has_removed_index: int = -1
	for key in _item_dict.keys():
		if _item_dict[key] == item.get_item_instance_data():
			_item_dict.erase(key)
			has_removed_index = key
	if has_removed_index != -1:
		player_item_update.emit(has_removed_index, null)

func get_items():
	return _item_dict

func get_item_by_index(index: int):
	if not index in _item_dict:
		return null
	return _item_dict.get(index)

func has_item_by_id(item_id: String):
	for key in _item_dict.keys():
		if not _item_dict[key]:
			continue
		if _item_dict[key].get_item_id() == item_id:
			return true
	return false

func pop_first_item_by_id(item_id: String):
	var keys = _item_dict.keys()
	keys.sort()
	for key in keys:
		print("Key: ", key)
		if not _item_dict[key]:
			continue
		if _item_dict[key].get_item_id() == item_id:
			var item = _item_dict[key]
			remove_item_by_index(key)
			return item
	return null
 
# Properties-----------------------------------------------------------
func _init_properties():
	print("Player Data Initialize")
	_properties.clear()
	
	for property_name in _properties_names:
		_init_property(property_name)

func _init_property(prop_id: String):
	if prop_id in _properties:
		return false
	
	# NOTE: テータ汚染避けるため、クリエイト必要
	var new_property = PlayerPropertyData.new()
	new_property.init_by_id(prop_id)
	_properties[prop_id] = new_property
	
	print("Init Player Property ID: ", prop_id, " Successed")
	return true

func has_property(prop_id: String):
	if prop_id not in _properties:
		return false
	else:
		return true

func _get_property_by_id(prop_id: String):
	if not has_property(prop_id):
		push_error("prop_id Not Found ")
		return null
	else:
		return _properties.get(prop_id)

func get_property_attribute(prop_id: String, attr_name: String):
	var _property: PlayerPropertyData = _get_property_by_id(prop_id)
	if not _property or not is_instance_valid(_property):
		push_error("_property Not Found ")
		return null
	return _property.get_atribute_in_registry(attr_name)

func connect_property_changed(prop_id: String, callback: Callable):
	if not callback:
		return
	var _property: PlayerPropertyData = _get_property_by_id(prop_id)
	if not _property or not is_instance_valid(_property):
		return
	_property.value_changed.connect(callback)
	
func connect_property_simple_signal(
	prop_id: String, sig_name: String, callback: Callable
):
	if not callback or callback.get_argument_count() != 0:
		return
	var _property: PlayerPropertyData = _get_property_by_id(prop_id)
	if not _property or not is_instance_valid(_property):
		return
	var simple_signal = \
		_property.get_simple_signal_in_registry(sig_name)
	if simple_signal:
		simple_signal.connect(callback)
	
func change_property_value_by_difference(prop_id: String, delta: int):
	var _property: PlayerPropertyData = _get_property_by_id(prop_id)
	if not _property or not is_instance_valid(_property):
		return
	_property.change_value_by_difference(delta)

func change_property_value(prop_id: String, new_value: int):
	var _property: PlayerPropertyData = _get_property_by_id(prop_id)
	if not _property or not is_instance_valid(_property):
		return
	print("PlayerData ", prop_id, " Change to ", new_value)
	_property.change_value(new_value)

#func _connect_hp_on_min_signal():
	#connect_property_simple_signal("hp","on_min",_player_game_over)

func player_game_over():
	on_player_game_over.emit()
