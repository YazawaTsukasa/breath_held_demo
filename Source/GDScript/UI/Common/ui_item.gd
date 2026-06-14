extends TextureRect
class_name UIItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_icon(icon:Texture2D):
	if icon:
		print("set icon")
	else:
		print("icon is null")
	self.texture=icon
