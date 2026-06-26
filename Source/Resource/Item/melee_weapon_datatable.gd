extends DatatableBase
class_name MeleeWeaponDatatable

@export var data_dict: Dictionary[String, MeleeWeaponData]

func get_data_by_id(data_id):
	return _get_data_by_id(data_dict, data_id)
