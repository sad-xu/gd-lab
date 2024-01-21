extends Node

## 所有动作资源
@export var anim_list: Array[AnimationResource] = []

var ActionItem = preload("res://test/scene_1/ui/action_item.tscn")
var CurrentItem = preload("res://test/scene_1/ui/current_item.tscn")

@onready var player = $Character2

const COLOR_LIST = [Color.CADET_BLUE, Color.DARK_ORANGE, Color.DEEP_SKY_BLUE, Color.GOLD, Color.LIGHT_PINK]

var current_action:CombinedActionResource

func _ready():
	for i in anim_list.size():
		var item = ActionItem.instantiate()
		item.action = anim_list[i]
		item.modulate = COLOR_LIST[i]
		item.select_action.connect(select_action)
		%AllActionVBox.add_child(item)

## 新增动作
func _on_add_button_pressed():
	var item = CurrentItem.instantiate()
	item.play_action.connect(play_action)
	item.select_item.connect(select_item)
	%CurrentVBox.add_child(item)
	
## 同步动作
func _on_sync_button_pressed():
	var children = %CurrentVBox.get_children()
	var list: Array[CombinedActionResource] = []
	for child in children:
		list.push_back(child.combined_action)
	player.action_list = list

## 播放动作
func play_action(combined_action: CombinedActionResource):
	player.play_animation_action(combined_action.action_name)

## 选择动作
func select_item(combined_action: CombinedActionResource):
	current_action = combined_action

## 选择部位
func select_action(anim_name: String, part_name: String):
	print(anim_name, part_name)
	if current_action != null:
		current_action[part_name] = anim_name
