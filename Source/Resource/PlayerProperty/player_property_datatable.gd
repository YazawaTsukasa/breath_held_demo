extends DatatableBase
class_name PlayerPropertyDatatable

@export var player_property_dict:Dictionary[String,PlayerPropertyData]

func get_data_by_id(data_id):
	return _get_data_by_id(player_property_dict,data_id)
