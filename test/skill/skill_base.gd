extends Node
class_name SkillBase

## 技能基类

## 技能状态
enum SKILL_STATUS {
	IDLE, # 空闲 可施放
	CASTED, #
	CASTING,
	FINISHED
}

## 技能名
@export var skill_name:= ''
## 技能图标
@export var skill_icon: Texture
## 冷却时间
@export var cd:= 1.0
## 持续时间
@export var duration:= 1.0

## 当前技能状态
var _skill_status:= SKILL_STATUS.IDLE
## 是否能施放
var _can_cast:= true
## 持续技能倒计时
var _duration_countdown:= -1.0

## 冷却计时器
var _cd_timer:= Timer.new()

func _ready():
	set_physics_process(false)
	# 添加cd计时器
	if not _cd_timer.is_inside_tree():
		_cd_timer.connect('timeout', cd_complete)
		_cd_timer.one_shot = true
		_cd_timer.autostart = false
		add_child(_cd_timer)

func _physics_process(delta):
	if _duration_countdown <= 0:
		cast_over()
		set_physics_process(false)
	else:
		_duration_countdown -= delta
		duration_process(delta)

## 持续时间倒计时
func _start_duration_countdown():
	pass

## 冷却时间倒计时
func _start_cd_countdown():
	_cd_timer.start(cd if cd > 0 else 0.001)

########## 可重写 ##########

## 施放技能
func cast_skill():
	print('cast_skill - ', skill_name)
	_start_duration_countdown()
	_start_cd_countdown()
	_can_cast = false
	_skill_status = SKILL_STATUS.CASTED

## 持续技能过程
func duration_process(delta: float):
	pass

## 施放结束
func cast_over():
	if _skill_status != SKILL_STATUS.IDLE:
		_skill_status = SKILL_STATUS.FINISHED

## 判断是否可以施放技能
func is_can_cast() -> bool:
	return _can_cast && _skill_status == SKILL_STATUS.IDLE

## 冷却完成
func cd_complete():
	_skill_status = SKILL_STATUS.IDLE
	_can_cast = true
	print('cd done')

## 切换技能状态
func switch_status(state: SKILL_STATUS):
	_skill_status = state














