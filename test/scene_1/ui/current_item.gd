extends HBoxContainer

signal select_item(combined_action: CombinedActionResource)
signal play_action(combined_action: CombinedActionResource)

@export var combined_action = CombinedActionResource.new()

func _ready():
	combined_action.changed.connect(update_text)


## 切换选中
func _on_check_box_toggled(toggled_on):
	if toggled_on:
		select_item.emit(combined_action)

## 播放动作
func _on_play_button_pressed():
	play_action.emit(combined_action)


func update_text():
	print(combined_action)
	$BodyButton.text = '躯干' if combined_action.body.is_empty() else combined_action.body
	$LeftArmButton.text = '左臂' if combined_action.left_arm.is_empty() else combined_action.left_arm
	$RightArmButton.text = '右臂' if combined_action.right_arm.is_empty() else combined_action.right_arm
	$LeftLegButton.text = '左腿' if combined_action.left_leg.is_empty() else combined_action.left_leg
	$RightLegButton.text = '右腿' if combined_action.right_leg.is_empty() else combined_action.right_leg


func _on_line_edit_text_changed(new_text):
	combined_action.action_name = new_text
