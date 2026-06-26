extends CharacterBase
class_name MainCharacter

@export var run_sp_consume_per_cycle: int = 1
@export var run_sp_consume_cycle: float = 0.03
		
@export var dush_sp_consume: int = 50

@export var sp_replies_per_cycle: int = 1
@export var sp_replies_cycle: float = 0.03

var _min_run_sp_consume_cycle: float = 0.01
var _min_sp_replies_cycle: float = 0.01

var _is_tired: bool = false

# func _init() -> void:
# 	# プレイヤーキャラの登録
# 	player_controller.set_player_character(self)

func _ready() -> void:
	super()
	
	# SPはゼロの場合、疲労状態になる
	player_data_manager.connect_property_simple_signal(
		"sp", "on_min", _on_sp_empty)
	# SPは全部回復の場合、疲労状態が解除
	player_data_manager.connect_property_simple_signal(
		"sp", "on_max", _on_sp_full)

func _physics_process(delta: float) -> void:
	super(delta)
	
	# Character Movement
	# Temporary Input
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	_process_input(direction, delta)
	
	# アイテム回転
	_change_item_angle()
	
	# SP回復
	_sp_replies(delta)

func init_data(data_asset: CharacterDataAsset):
	super(data_asset)
	var player_data_asset = \
		data_asset as PlayerDataAsset
	if not player_data_asset:
		return
	print("player init_data")
	run_sp_consume_per_cycle = \
		player_data_asset.run_sp_consume_per_cycle
	run_sp_consume_cycle = \
		max(_min_run_sp_consume_cycle, \
			player_data_asset.run_sp_consume_cycle)
		
	dush_sp_consume = player_data_asset.dush_sp_consume

	sp_replies_per_cycle = player_data_asset.sp_replies_per_cycle
	sp_replies_cycle = \
		max(_min_sp_replies_cycle, \
			player_data_asset.sp_replies_cycle)

# SP相関
var _sp_replies_elapsed_time: float = 0.0
func _sp_replies(delta: float):
	if _is_running:
		return
	_sp_replies_elapsed_time += delta
	while _sp_replies_elapsed_time >= sp_replies_cycle:
		_sp_replies_elapsed_time -= sp_replies_cycle
		_change_sp(sp_replies_per_cycle)
	
func _on_sp_empty():
	_is_tired = true
func _on_sp_full():
	_is_tired = false
	
func _change_sp(difference: int):
	player_data_manager.change_property_value_by_difference("sp", difference)

func _check_sp_enough(need: int):
	var current_sp = player_data_manager.get_property_attribute("sp", "current_value")
	if current_sp == null:
		return false
	if current_sp < need:
		return false
	else:
		return true

var _run_sp_consum_elapsed_time: float = 0.0
func _on_running(delta: float):
	_run_sp_consum_elapsed_time += delta
	while _run_sp_consum_elapsed_time >= run_sp_consume_cycle:
		_change_sp(-run_sp_consume_per_cycle)
		_run_sp_consum_elapsed_time -= run_sp_consume_cycle
	
func _on_dush():
	_change_sp(-dush_sp_consume)

func set_running_state(is_running: bool):
	if _is_tired and is_running:
		is_running = false
	super(is_running)
	
func dash():
	if _is_tired:
		return
	super()

func use_pivot_item(using_type: String):
	if not item_pivot:
		return
	print("Main Character Using Item By ItemPivot")
	item_pivot.use_item(using_type)
