extends DataBase
class_name EffectData

enum EffectType{
	DAMAGE,
	HEALING,
}

@export var name:String=""
@export var type:EffectType=EffectType.DAMAGE
@export var value:float=0.0
@export var duration:float=0.0
@export var cycle:float=0.0

var _is_valid:bool=false

func init_by_id(id:String):
	_read_data_from_datatable(id)

func set_effect_value(effect_value:float):
	value=effect_value

func set_effect_duration(effect_duration:float):
	duration=effect_duration

func set_effect_cycle(effect_cycle:float):
	cycle=effect_cycle

func _read_data_from_datatable(effect_id:String):
	var dt_res=\
		resource_manager.get_datatable_resource("effect")
	if not dt_res:
		push_error("Effect DataTable Resource Not Found")
	var effect_dt_res=dt_res as EffectDatatable
	if not effect_dt_res:
		push_error("Effect DataTable Resource Class Not Found")
	var ori_effect:EffectData=\
		effect_dt_res.get_data_by_id(effect_id)
	if ori_effect:
		_is_valid=true
		name=ori_effect.name
		value=ori_effect.value
		type=ori_effect.type
		duration=ori_effect.duration
		cycle=ori_effect.cycle
	else:
		push_warning("No effect_id: ",effect_id)

func is_valid():
	return _is_valid
