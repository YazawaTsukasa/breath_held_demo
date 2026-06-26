extends DatatableBase
class_name LongRangeWeaponDatatable

@export var data_dict: Dictionary[String, LongRangeWeaponData]

func get_data_by_id(data_id):
	return _get_data_by_id(data_dict, data_id)
