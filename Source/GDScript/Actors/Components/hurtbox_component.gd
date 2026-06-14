extends Area2D
class_name HurtboxComponent

#@export var hp_component:HPComponent
@export var effect_component:EffectComponent
@export var attacked_component:AttackedComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if attacked_component:
		attacked_component.on_attacked_anime_end=\
			_on_attacked_anime_end
	#area_entered.connect(_on_area_entered)
	#body_entered.connect(_on_body_entered)

func _on_area_entered(_hit_box):
	pass
	#if hp_component:
		#hp_component.damage(10)

func _on_body_entered(_body):
	pass

func be_attacked(
	effect:EffectData,
	attack_source_position:Vector2,
	force:float
):
	if not effect.is_valid():
		return
	var result=true
	if attacked_component:
		result=\
			attacked_component.on_attacked(attack_source_position,force)
	if result and effect_component:
		effect_component.handle_effect(effect)

# 攻撃されたアニメーションが終わると死亡検査
func _on_attacked_anime_end():
	if not effect_component or not effect_component.get_is_will_die():
		return
	var parent=get_parent()
	if ComponentTool.is_parent_player(parent):
		player_data_manager.player_game_over()
	else:
		ComponentTool.queue_free_parent(get_parent())
