extends Node
class_name SpeedManager

@export var normal_speed_scale:float=1.0
@export var accel_speed_scale:float=10.0
@export var decel_speed_scale:float=0.1

enum SpeedType{
	NORMAL,
	ACCEL,
	DECEL
}
var speed_dict:Dictionary={
	SpeedType.NORMAL:normal_speed_scale,
	SpeedType.ACCEL:accel_speed_scale,
	SpeedType.DECEL:decel_speed_scale
}

#var _speed_scale:float=normal_speed_scale

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Speed Manager Ready")
	#pass # Replace with function body.

func switch_to_normal():
	switch_speed_type(SpeedType.NORMAL)
	
func switch_to_accel():
	switch_speed_type(SpeedType.ACCEL)
	
func switch_to_decel():
	switch_speed_type(SpeedType.DECEL)

func switch_speed_type(type:SpeedType):
	var scale=speed_dict.get(type,normal_speed_scale)
	print("switch_speed_type")
	_set_speed_scale(scale)

func _set_speed_scale(scale:float):
	#_speed_scale=scale
	Engine.time_scale=scale
	print("speed_scale: ",scale)
