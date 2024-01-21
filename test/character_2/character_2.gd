extends CharacterBody3D

## 骨骼动画自定义 
## 
## 中心动画 idle 
## 其他动作动画 []
##


## 骨骼分组 = 躯干 左臂 右臂 左腿 右腿
const BONES_PART = {
	BODY = ['Hips', 'Spine', 'Chest', 'UpperChest', 'Neck', 'Head', 'mixamorig_HeadTopEnd'],
	LEFT_ARM = [
		'LeftShoulder', 'LeftUpperArm', 'LeftLowerArm', 'LeftHand', 
		'mixamorig_LeftHandThumb1', 'LeftThumbMetacarpal', 'LeftThumbProximal', 'LeftThumbDistal',
		'mixamorig_LeftHandIndex1', 'LeftIndexProximal', 'LeftIndexIntermediate', 'LeftIndexDistal',
		'mixamorig_LeftHandMiddle1', 'LeftMiddleProximal', 'LeftMiddleIntermediate', 'LeftMiddleDistal',
		'mixamorig_LeftHandRing1', 'LeftRingProximal', 'LeftRingIntermediate', 'LeftRingDistal',
		'mixamorig_LeftHandPinky1', 'LeftLittleProximal', 'LeftLittleIntermediate', 'LeftLittleDistal',
	],
	RIGHT_ARM = [
		'RightShoulder', 'RightUpperArm', 'RightLowerArm', 'RightHand',
		'mixamorig_RightHandThumb1', 'RightThumbMetacarpal', 'RightThumbProximal', 'RightThumbDistal',
		'mixamorig_RightHandIndex1', 'RightIndexProximal', 'RightIndexIntermediate', 'RightIndexDistal',
		'mixamorig_RightHandMiddle1', 'RightMiddleProximal', 'RightMiddleIntermediate', 'RightMiddleDistal',
		'mixamorig_RightHandRing1', 'RightRingProximal', 'RightRingIntermediate', 'RightRingDistal',
		'mixamorig_RightHandPinky1', 'RightLittleProximal', 'RightLittleIntermediate', 'RightLittleDistal',
	],
	LEFT_LEG = ['LeftUpperLeg', 'LeftLowerLeg', 'LeftFoot', 'LeftToes', 'mixamorig_RightToe_End'],
	RIGHT_LEG = ['RightUpperLeg', 'RightLowerLeg', 'RightFoot', 'RightToes', 'mixamorig_RightToe_End']
}
## 动作部位名
const ACTION_LIST = ['body', 'left_arm', 'right_arm', 'left_leg', 'right_leg']

@onready var bodyTree = $AnimateGroup/BodyTree
@onready var leftArmTree = $AnimateGroup/LeftArmTree
@onready var rightArmTree = $AnimateGroup/RightArmTree
@onready var leftLegTree = $AnimateGroup/LeftLegTree
@onready var rightLegTree = $AnimateGroup/RightLegTree
@onready var tree_list = [bodyTree, leftArmTree, rightArmTree, leftLegTree, rightLegTree]

## 使用到的动作资源
@export var anim_list: Array[AnimationResource] = []
## 组合后的各部位动作名
@export var action_list: Array[CombinedActionResource] = []

func _ready():
	# 初始化, 新增所有 animationPlayer
	for p in [[$AnimateGroup/BodyPlayer, 'BODY'], [$AnimateGroup/LeftArmPlayer, 'LEFT_ARM'], [$AnimateGroup/RightArmPlayer, 'RIGHT_ARM'], [$AnimateGroup/LeftLegPlayer, 'LEFT_LEG'], [$AnimateGroup/RightLegPlayer, 'RIGHT_LEG']]:
		add_body_animation(p[0], p[1], anim_list)
	for tree in tree_list:
		generate_animate_tree(tree, anim_list)

#func _input(event):
	#if event.is_action_pressed('skill_1'):
		#play_animation_action('idle')
	#elif event.is_action_pressed('skill_2'):
		#play_animation_action('kick')
	#elif event.is_action_pressed('skill_3'):
		#play_animation_action('magic')

## 切换动作 可外部调用
func play_animation_action(_name: String):
	for action in action_list:
		if action.action_name == _name:
			for i in tree_list.size():
				var part_name: String = action[ACTION_LIST[i]]
				if !part_name.is_empty():
					if _name == 'idle':
						tree_list[i]["parameters/playback"].next() # 立即过渡到下一状态
					else: 
						tree_list[i]["parameters/playback"].travel(part_name)
			return

## 根据原始动画生成部位动画
func generate_part_animation(origin_anim: Animation, track_name_list) -> Animation:
	var new_anim = Animation.new()
	new_anim.length = origin_anim.length
	new_anim.loop_mode = origin_anim.loop_mode
	for t_name in track_name_list:
		var node_path = '%GeneralSkeleton:' + t_name
		var i = origin_anim.find_track(node_path, Animation.TYPE_POSITION_3D)
		if i != -1:
			origin_anim.copy_track(i, new_anim)
		var j = origin_anim.find_track(node_path, Animation.TYPE_ROTATION_3D)
		if j != -1:
			origin_anim.copy_track(j, new_anim)
	return new_anim

## 动态添加动画 animationPlayer 先清空
func add_body_animation(body_player: AnimationPlayer, part_name: String, _anim_list: Array[AnimationResource]):
	#var library = body_player.get_animation_library("")
	#if library == null:
	var library = AnimationLibrary.new()
	body_player.add_animation_library("", library)
	var list = library.get_animation_list()
	for n in list:
		library.remove_animation(n)
	# idle
	library.add_animation('idle', generate_part_animation(ResourceLoader.load('res://test/character_2/animation/idle.res'), BONES_PART[part_name]))
	for anim in _anim_list:
		library.add_animation(anim.anim_name, generate_part_animation(anim.anim_res, BONES_PART[part_name]))

## 动态构造动画树 新建状态树
func generate_animate_tree(anim_tree: AnimationTree, _anim_list: Array[AnimationResource]):
	var stateMachine = AnimationNodeStateMachine.new()
	anim_tree['tree_root'] = stateMachine
	# 添加中心节点
	var reset_node = AnimationNodeAnimation.new()
	reset_node.animation = 'idle'
	stateMachine.add_node('idle', reset_node)
	# 连接start节点
	var start_transition = AnimationNodeStateMachineTransition.new()
	start_transition.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
	stateMachine.add_transition('Start', 'idle', start_transition)
	# 添加其他动作节点 & 连接该节点与RESET节点 & 设置缓动曲线
	var curve = Curve2D.new()
	curve.add_point(Vector2(0,0))
	curve.add_point(Vector2(1,1))
	for anim in _anim_list:
		var anim_name = anim.anim_name
		var node = AnimationNodeAnimation.new()
		node.animation = anim_name
		stateMachine.add_node(anim_name, node)
		var from_transition = AnimationNodeStateMachineTransition.new()
		from_transition.xfade_curve = curve
		from_transition.xfade_time = 0.3
		stateMachine.add_transition('idle', anim_name, from_transition)
		var to_transition = AnimationNodeStateMachineTransition.new()
		to_transition.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_AUTO
		to_transition.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
		to_transition.xfade_curve = curve
		to_transition.xfade_time = 0.3
		stateMachine.add_transition(anim_name, 'idle', to_transition)
	# 建立各个动作之间的连接
	var _len = _anim_list.size()
	if _len <= 1: return
	var action_transition = AnimationNodeStateMachineTransition.new()
	action_transition.xfade_curve = curve
	action_transition.xfade_time = 0.3
	for i in range(1, _len):
		for j in range(0, i):
			stateMachine.add_transition(_anim_list[i].anim_name, _anim_list[j].anim_name, action_transition)
			stateMachine.add_transition(_anim_list[j].anim_name, _anim_list[i].anim_name, action_transition)
			
	print(stateMachine, stateMachine.get_transition_count())

