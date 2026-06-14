extends Node
class_name EffectComponent

@export var hp_component:HPComponent

var _effect_processors:Array[EffectProcessor]=[]

var _is_will_die:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if hp_component:
		hp_component.hp_become_zero.connect(_on_hp_become_zero)

func handle_effect(effect:EffectData):
	if not effect.is_valid():
		return
	var _effect_processor=EffectProcessor.new()
	_effect_processors.append(_effect_processor)
	_effect_processor.on_damage=_take_damage
	_effect_processor.on_healing=_take_healing
	_effect_processor.on_process_complete=_remove_effect_processor
	_effect_processor.process_effect(self,effect)

func _remove_effect_processor(effect_processor:EffectProcessor):
	_effect_processors.erase(effect_processor)
	print("effect_processors size: ",_effect_processors.size())

func _take_damage(value:float):
	if hp_component:
		hp_component.take_damage(int(round(value)))

func _take_healing(value:float):
	if hp_component:
		hp_component.take_healing(int(round(value)))

func _on_hp_become_zero():
	_is_will_die=true

func get_is_will_die():
	return _is_will_die
