extends Node2D
class_name SensorComponent

@export var detection_area: Area2D
@export var melee_attack_area: Area2D
@export var vision_ray: RayCast2D

@export var target_team: Array[Team.Type] = [Team.Type.PLAYER]

var on_target_sensored: Callable
var on_target_lost: Callable

var on_melee_body_entered: Callable
var on_melee_body_exited: Callable

var _targets: Array[PhysicsBody2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if detection_area:
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)
	if melee_attack_area:
		melee_attack_area.body_entered.connect(_on_melee_body_entered)
		melee_attack_area.body_exited.connect(_on_melee_body_exited)

func _process(_delta: float) -> void:
	_vision_ray_check_targets()

func _on_detection_body_entered(body: PhysicsBody2D):
	#print("_on_detection_body_entered")
	var character = body as CharacterBase
	if character:
		if character.get_team() in target_team:
			_targets.append(body)
	
func _on_detection_body_exited(body: PhysicsBody2D):
	#print("_on_detection_body_exited")
	_targets.erase(body)
	if on_target_lost.is_valid():
		on_target_lost.call(body)
	
func _on_melee_body_entered(body: PhysicsBody2D):
	#print("_on_melee_body_entered")
	if on_melee_body_entered.is_valid():
		on_melee_body_entered.call(body)
func _on_melee_body_exited(body: PhysicsBody2D):
	#print("_on_melee_body_exited")
	if on_melee_body_exited.is_valid():
		on_melee_body_exited.call(body)

func _vision_ray_check_targets():
	for target in _targets:
		_vision_ray_check(target)

func _vision_ray_check(target: PhysicsBody2D):
	if not vision_ray:
		return
	var vector = target.global_position - global_position
	vision_ray.target_position = vector
	var _is_visible = vision_ray.get_collider() == target
	if _is_visible and on_target_sensored.is_valid():
		on_target_sensored.call(target)
	elif on_target_lost.is_valid():
		on_target_lost.call(target)
	return _is_visible

func rotate_areas(direction: Vector2, offset: float = - PI / 2):
	if detection_area:
		detection_area.rotation = direction.angle() + offset
	if melee_attack_area:
		melee_attack_area.rotation = direction.angle() + offset
