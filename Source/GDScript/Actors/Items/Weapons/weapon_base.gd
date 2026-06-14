extends ItemBase
class_name WeaponBase

var _attack_power:int=0
var _heavy_attack_multiplier:float=1.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	using_registry=using_registry.duplicate()
	using_registry={
		"normal_using":"_normal_attack",
		"special_using":"_special_attack",
	}
	state_attack_method_registry=state_attack_method_registry.duplicate()
	state_attack_method_registry[State.HELD_ATTACK]="_cause_attack_effect"
	
	state_registry=state_registry.duplicate()
	state_registry["held_attack"]=State.HELD_ATTACK
	state_property=state_property.duplicate()
	state_property[State.HELD_ATTACK]=ItemStateData.new(true,false,false)
	
	super()
	
func _physics_process(delta):
	super(delta)
	
func _normal_attack():
	pass
	
func _special_attack():
	pass

func init_property_by_data(item_id:String,item_data:ItemData):
	super(item_id,item_data)
	var weapon_data=item_data as WeaponData
	if not weapon_data:
		return
	_attack_power=weapon_data.attack_power
	_heavy_attack_multiplier=weapon_data.heavy_attack_multiplier

func _cause_attack_effect(_hurtbox:HurtboxComponent):
	pass
