extends CollisionPolygon2D
class_name SectorCollisionPolygon2D

@export var centerline_direction:Vector2=Vector2.DOWN
@export var sector_radius: float=20.0
@export var sector_angle_deg: float=90.0
@export var sector_segments: int=10

#func _init() -> void:

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	polygon=create_fov_polygon(
		centerline_direction.normalized(),
		sector_radius,
		sector_angle_deg,
		sector_segments)

func create_fov_polygon(centerline:Vector2,radius: float, angle_deg: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.append(Vector2.ZERO)

	var half_angle = deg_to_rad(angle_deg / 2.0)

	for i in range(segments + 1):
		var t = float(i) / segments
		var a = lerp(-half_angle, half_angle, t)
		points.append(centerline.rotated(a) * radius)
	return points
