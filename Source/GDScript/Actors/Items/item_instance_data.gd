extends RefCounted
class_name ItemInstanceData

var _item_type: String
var _item_id: String
var _origin_data: ItemData

func _init(item_id: String, origin_data: ItemData) -> void:
	_item_id = item_id
	_origin_data = origin_data

func get_item_id():
	return _item_id
	
func get_origin_data():
	return _origin_data
	
func get_item_type():
	return _item_type
