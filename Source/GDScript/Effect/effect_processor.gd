extends RefCounted
class_name EffectProcessor

#var on_value_changed:Callable
var on_damage: Callable
var on_healing: Callable
var on_process_complete: Callable

var _effect_value: float = 0.0
var _effect_type: EffectData.EffectType
var _waiting_duration: float = 0.0
var _cycle: float = 0.0

func process_effect(parent: Node, effect: EffectData):
	if not effect.is_valid():
		return
	if not is_instance_valid(parent):
		return
	print("process_effect=========================")
	print("name: ", effect.name, ", value: ", effect.value)
	print("type: ", effect.type, ", duration: ", effect.duration, ", cycle: ", effect.cycle)
	print("=======================================")
	
	_effect_value = effect.value
	_effect_type = effect.type
	_waiting_duration = effect.duration
	_cycle = effect.cycle
	#print("_waiting_duration: ",_waiting_duration)
	#print("_cycle: ",_cycle)
	_change_value()
	if _waiting_duration > 0.0 and _cycle > 0.0:
		_waiting_duration -= _cycle
		if _waiting_duration >= 0.0:
			_start_cycle(parent)
	else:
		_process_complete()

func _start_cycle(parent: Node):
	print("Start Effect Cycle")
	var timer = Timer.new()
	timer.wait_time = _cycle
	timer.one_shot = false
	timer.autostart = false
	parent.add_child(timer) # シーントレーに入る
	timer.timeout.connect(_continue_cycle.bind(timer))
	timer.start()

func _continue_cycle(timer: Timer):
	if not timer:
		return
	print("Continue Effect Cycle")
	_waiting_duration -= _cycle
	#print("_waiting_duration: ",_waiting_duration)
	#print("_cycle: ",_cycle)
	_change_value()
	if _waiting_duration <= 0.0:
		_end_cycle(timer)

func _end_cycle(timer: Timer):
	print("End Effect Cycle")
	timer.stop()
	timer.queue_free()
	_process_complete()

func _change_value():
	print("Change Value")
	if _effect_type == EffectData.EffectType.DAMAGE:
		if on_damage.is_valid():
			on_damage.call(_effect_value)
	elif _effect_type == EffectData.EffectType.HEALING:
		if on_healing.is_valid():
			on_healing.call(_effect_value)

func _process_complete():
	if on_process_complete.is_valid():
		on_process_complete.call(self)
