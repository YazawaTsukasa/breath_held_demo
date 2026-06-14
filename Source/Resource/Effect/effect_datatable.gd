extends DatatableBase
class_name EffectDatatable

#@export var effect_list:Array[EffectData]
@export var effect_dict:Dictionary[String,EffectData]={}

func get_data_by_id(data_id):
	return _get_data_by_id(effect_dict,data_id)
