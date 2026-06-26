extends Resource
class_name DatatableBase

func get_data_by_id(_data_id):
	push_error("DatatableBase Subclass DidNot Override get_data_by_id !")
	return null

func _get_data_by_id(data_dict: Dictionary, data_id):
	if data_id not in data_dict:
		return null
	return data_dict.get(data_id)
