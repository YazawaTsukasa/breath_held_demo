extends ItemBase
class_name PropBase

var be_used:Callable

var _property_value:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super() # Replace with function body.
	using_registry=using_registry.duplicate()
	using_registry={
		"normal_using":"_normal_using",
		#"special_using":"_special_using",
	}

func _physics_process(delta: float) -> void:
	super(delta)

func _be_used(effect:EffectData):
	if be_used.is_valid():
		be_used.call(effect)

func _normal_using():
	_on_using_start()
	var effect=EffectData.new()
	effect.init_by_id(_normal_effect)
	effect.set_effect_value(_property_value)
	
	_be_used(effect)
	_on_using_end()

func init_property_by_data(item_id:String,item_data:ItemData):
	super(item_id,item_data)
	var prop_data=item_data as PropData
	if not prop_data:
		return
	_property_value=prop_data.property_value
