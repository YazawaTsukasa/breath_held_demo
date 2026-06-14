extends DataBase
class_name PlayerPropertyData

@export var property_name:String="default"
@export var min_value:int=0
@export var max_value:int=100
@export var init_value:int=max_value

var _current_value:int=init_value

var atribute_registry:Dictionary={
	"name":"property_name",
	"min_value":"min_value",
	"max_value":"max_value",
	"current_value":"_current_value"
}

signal value_changed(value:int)
signal value_become_min()
signal value_become_max()
var simple_signal_registry:Dictionary={
	"on_min":"value_become_min",
	"on_max":"value_become_max"
}

func init_by_id(id:String):
	_read_data_from_datatable(id)
	print("PlayerPropertyData: ",id," InitValue: ",init_value)
	_current_value=init_value
	
func _read_data_from_datatable(id:String):
	var dt_res=\
		resource_manager.get_datatable_resource("player_property")
	if not dt_res:
		push_error("PlayerProperty DataTable Resource Not Found")
	var pp_dt_res=dt_res as PlayerPropertyDatatable
	if not pp_dt_res:
		push_error("Effect DataTable Resource Class Not Found")
	var ori_data:PlayerPropertyData=\
		pp_dt_res.get_data_by_id(id)
	if ori_data:
		print("ori_data.min_value: ",ori_data.min_value)
		print("ori_data.max_value: ",ori_data.max_value)
		print("ori_data.init_value: ",ori_data.init_value)
		property_name=ori_data.property_name
		min_value=ori_data.min_value
		max_value=ori_data.max_value
		init_value=ori_data.init_value
	else:
		push_warning("No player_property_id: ",id)


func get_atribute_in_registry(atrproperty_name:String):
	if atrproperty_name not in atribute_registry:
		push_error("atrproperty_name Not Found ")
		return null
	var _atribute=atribute_registry.get(atrproperty_name)
	return get(_atribute)

func change_value_by_difference(delta:int):
	var _except_value=_current_value+delta
	change_value(_except_value)
	
func change_value(_except_value:int):
	if _except_value<min_value:
		_except_value=min_value
	elif _except_value>max_value:
		_except_value=max_value
	_current_value=_except_value
	_on_current_value_changed()
	_check_current_value()

func _check_current_value():
	if _current_value==min_value:
		_on_current_value_become_min()
	if _current_value==max_value:
		_on_current_value_become_max()

func _on_current_value_changed():
	#print(property_name," value change to ",_current_value)
	value_changed.emit(_current_value)

func _on_current_value_become_min():
	value_become_min.emit()

func _on_current_value_become_max():
	value_become_max.emit()

func get_simple_signal_in_registry(sigproperty_name:String):
	if sigproperty_name not in simple_signal_registry:
		return null
	return self[simple_signal_registry.get(sigproperty_name)]
