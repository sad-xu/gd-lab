extends Resource
class_name CombinedActionResource
## 组合后的动作

## 动作名
@export var action_name: String
## 躯干动画名
@export var body := '':
	set(val):
		body = val
		emit_changed()

## 左臂动画名
@export var left_arm := '':
	set(val):
		left_arm = val
		emit_changed()

## 右臂动画名
@export var right_arm := '':
	set(val):
		right_arm = val
		emit_changed()

## 左腿动画名
@export var left_leg := '':
	set(val):
		left_leg = val
		emit_changed()

## 右腿动画名
@export var right_leg := '':
	set(val):
		right_leg = val
		emit_changed()

