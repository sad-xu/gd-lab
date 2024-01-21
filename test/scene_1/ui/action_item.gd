extends HBoxContainer

signal select_action(anim_name: String, part_name: String)

@export var action: AnimationResource

func _ready():
	$NameLabel.text = action.anim_name

## 发送选中数据
func handle_pressed(part_name: String):
	select_action.emit(action.anim_name, part_name)

func _on_body_button_pressed():
	handle_pressed('body')

func _on_left_arm_button_pressed():
	handle_pressed('left_arm')

func _on_right_arm_button_pressed():
	handle_pressed('right_arm')

func _on_left_leg_button_pressed():
	handle_pressed('left_leg')

func _on_right_leg_button_pressed():
	handle_pressed('right_leg')
