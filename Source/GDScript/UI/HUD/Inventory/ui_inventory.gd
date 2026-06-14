extends Control
class_name UIInventory

@onready var gc_item:GridContainer=%GCItem
@onready var gc_item_frame:GridContainer=%GCFrame
@onready var gc_item_selection:GridContainer=%GCSelection

@export var item_frame_scene_ref:String="res://Content/UI/Common/ui_item_frame.tscn"
@export var item_selection_scene_ref:String="res://Content/UI/Common/ui_item_selection.tscn"
@export var item_ui_scene_ref:String="res://Content/UI/Common/ui_item.tscn"
@export var col_num:int=5
@export var item_size:Vector2=Vector2(32.0,32.0)

var frame_size:Vector2=Vector2(48.0,48.0)

var item_pivot_list:Array[Control]=[]
var item_ui_list:Array[UIItem]=[]
var selection_list:Array[TextureRect]=[]
var _current_selected_item_index:int=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("UIInventory ready")
	init_grid_containers()
	
	# 最初のアイテム初期化
	var item_dict=player_data_manager.get_items()
	print("item_list length: ",len(item_dict))
	_init_item_by_data(item_dict)
	
	player_data_manager.player_item_update.connect(_on_item_update)
	
func init_grid_containers():
	_init_gc_item_frame()
	_init_gc_item_pivot()
	_init_gc_item_selection()

func _init_gc_item_frame():
	if not gc_item_frame:
		print("gc_item_frame invalid")
		return
	gc_item_frame.get_children().map(func(child): child.queue_free())
	gc_item_frame.columns=col_num
	var itemframe_scene = load(item_frame_scene_ref)
	for i in range(col_num):
		var itemframe_instance = itemframe_scene.instantiate()
		gc_item_frame.add_child(itemframe_instance)
		frame_size=itemframe_instance.size

func _init_gc_item_selection():
	if not gc_item_selection:
		print("gc_item_selection invalid")
		return
	gc_item_selection.get_children().map(func(child): child.queue_free())
	gc_item_selection.columns=col_num
	var item_selection_scene = load(item_selection_scene_ref)
	for i in range(col_num):
		var item_selection_instance = item_selection_scene.instantiate()
		gc_item_selection.add_child(item_selection_instance)
		selection_list.append(item_selection_instance)
		frame_size=item_selection_instance.size
	select_item_by_index(_current_selected_item_index)

func _init_gc_item_pivot():
	item_pivot_list=[]
	if not gc_item:
		print("gc_item invalid")
		return
	gc_item.get_children().map(func(child): child.queue_free())
	gc_item.columns=col_num
	for i in range(col_num):
		var new_cc=CenterContainer.new()
		gc_item.add_child(new_cc)
		item_pivot_list.append(new_cc)
		new_cc.custom_minimum_size=frame_size

func _init_item_by_data(item_dict:Dictionary):
	item_ui_list=[]
	for item_pivot in item_pivot_list:
		for n in item_pivot.get_children(): 
			item_pivot.remove_child(n)
			n.queue_free()
	for index in item_dict.keys():
		if index>=col_num:
			break
		var item=item_dict.get(index)
		var ui_item_instance=_create_new_ui_item(
			item.get_icon())
		item_pivot_list[index].add_child(ui_item_instance)
	select_item_by_index(_current_selected_item_index)

func _on_item_update(index:int,item:ItemBase):	
	if index<0 or index>=col_num:
		return
	if item!=null:
		var ui_item_instance=_create_new_ui_item(
			item.get_icon())
		item_pivot_list[index].add_child(ui_item_instance)
	else:
		_remove_ui_item(index)
	if index==_current_selected_item_index:
		select_item_by_index(_current_selected_item_index)

func _create_new_ui_item(texture:Texture2D):
	var item_ui_scene = load(item_ui_scene_ref)
	var item_ui_instance:UIItem = item_ui_scene.instantiate()
	item_ui_instance.set_icon(texture)
	item_ui_list.append(item_ui_instance)
	item_ui_instance.custom_minimum_size=item_size
	return item_ui_instance

func _remove_ui_item(index:int):
	for n in item_pivot_list[index].get_children():
		if n in item_ui_list:
			print("Remove item ui")
			item_ui_list.erase(n)
		item_pivot_list[index].remove_child(n)
		n.queue_free()

func select_item_by_index(index:int):
	if index<0:
		index=selection_list.size()-1
	elif index>=selection_list.size():
		index=0
	_current_selected_item_index=index
	for i in range(selection_list.size()):
		if i==index:
			continue
		selection_list[i].self_modulate.a = 0
	selection_list[index].self_modulate.a = 1
	player_controller.set_player_item_by_index(index)

# NOTE: Temporary Input
# NOTE: マウススクロールで選択アイテムの変更
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				select_item_by_index(_current_selected_item_index-1)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				select_item_by_index(_current_selected_item_index+1)
