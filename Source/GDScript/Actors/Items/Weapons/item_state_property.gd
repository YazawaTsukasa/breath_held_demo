extends Object
class_name ItemStateData

var area_monitoring:bool
var freeze:bool
var collision:bool

func _init(_area_monitoring:bool,_freeze:bool,_collision:bool)->void:
	self.area_monitoring=_area_monitoring
	self.freeze=_freeze
	self.collision=_collision
