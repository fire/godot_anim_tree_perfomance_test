extends Node3D

@onready var animTree:AnimationTree = $AnimationTree
@onready var animation_player:AnimationPlayer = $npc_human_rig/AnimationPlayer

@onready var tree_data:Dictionary = {
	"speech_viseme"		 		:"parameters/speech_viseme/current",
	"speech_visemes_blend"	 	:"parameters/speech_visemes_blend/blend_amount",
	
	"face_blink_01_blend" 		:"parameters/face_blink_01_blend/blend_amount",
	"face_blink_01_speed" 		:"parameters/face_blink_01_speed/scale",
	
	"gesture_oneshot"		 	:"parameters/gesture_oneshot/active",
	"gestures_transition" 		:"parameters/gestures_transition/current",
	
	"air_ground_transition" 	:"parameters/air_ground_transition/current",
	"idle_walk_run_blend" 		:"parameters/idle_walk_run_blend/blend_amount",
	"idle01_gesture_oneshot"	:"parameters/idle01_gesture_oneshot/active",
	"idle01_gesture_transition"	:"parameters/idle01_gesture_transition/current",
	
	"turn90left_oneshot"		:"parameters/turn90left_oneshot/active",
	"turn180left_oneshot"		:"parameters/turn180left_oneshot/active",
	"turn90right_oneshot"		:"parameters/turn90right_oneshot/active",
	
	"crouch_walk_blend"			:"parameters/crouch_walk_blend/blend_amount",
	"crouch_legs_blend" 		:"parameters/crouch_legs_blend/blend_amount",
	"crouch_spine_blend"		:"parameters/crouch_spine_blend/blend_amount",
	"crouch_to_idle_oneshot"	:"parameters/crouch_to_idle_oneshot/active",
	"idle_to_crouch_oneshot"	:"parameters/idle_to_crouch_oneshot/active",
	"run_to_crouch_oneshot" 	:"parameters/run_to_crouch_oneshot/active",
	"forward_roll_oneshot"		:"parameters/forward_roll_oneshot/active",
	"strafewalk_blendspace" 	:"parameters/strafewalk_blendspace2D/blend_position",
	"walk_strafe_blend" 		:"parameters/walk_strafe_blend/blend_amount",
	
	# - rifle
	"rifle_idle_blend" 			:"parameters/rifle_idle_blend/blend_amount",
	"rifle_equip_oneshot"		:"parameters/rifle_equip_oneshot/active",
	"rifle_unequip_oneshot"		:"parameters/rifle_unequip_oneshot/active",
	"rifle_unaimed_idle_blend"	:"parameters/rifle_unaimed_idle_blend/blend_amount",
	
	"rifle_aim_blend" 			:"parameters/rifle_aim_blend/blend_amount",
	"rifle_aim_feet_blend"		:"parameters/rifle_aim_feet_blend/blend_amount",
	#"idle_to_rifle_aim_feet_oneshot":"parameters/idle_to_rifle_aim_feet_oneshot/active",
	#"rifle_aim_to_idle_feet_oneshot":"parameters/rifle_aim_to_idle_feet_oneshot/active",
	
	"rifle_aim_fire_blend"		:"parameters/rifle_aim_fire_blend/blend_amount",
	"rifle_aim_fire_speed"		:"parameters/rifle_aim_fire_speed/scale",
	"rifle_unaimed_blend"		:"parameters/rifle_unaimed_blend/blend_amount",
	"rifle_unaimed_fire_blend"	:"parameters/rifle_unaimed_fire_blend/blend_amount",
	"rifle_unaimed_fire_speed"	:"parameters/rifle_unaimed_fire_speed/scale",
	
	"rifle_reload_oneshot"  	:"parameters/rifle_reload_oneshot/active",
	"rifle_blocked_blend"		:"parameters/rifle_blocked_blend/blend_amount",
	"rifle_rise_arms_blend" 	:"parameters/rifle_rise_blend/blend_amount",
}

@onready var keys:Array = tree_data.keys()
@onready var oneshots:Array = []
@onready var timer:Timer = Timer.new()

func tree_set(parameter:String,value:Variant) -> void:
	if !tree_data.keys().has(parameter):
		push_error("npc_base.gd : Don't have this parameter! " + parameter)
		return
	animTree.set(tree_data[parameter],value)

func tree_get_node(node_name:String) -> AnimationNode:
	return animTree.get_tree_root().get_node(node_name)

func _ready():
	_build_oneshots()
	
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_run_randomized_oneshot)
	timer.start( 1.0 + snapped(randf_range(0,1.0),0.01) )
	

# Return a animation length
func anim_player_get_anim_length(anim_name:String) -> float:
	#var anim_name:String = animTree.get_tree_root().get_node("idle_to_crouch").animation
	var anim_res:Animation = animation_player.get_animation(anim_name)
	var anim_length:float = anim_res.get_length()
	return snapped(anim_length,0.01)

func _build_oneshots() -> void:
	for oneshot in keys:
		if (oneshot as String).ends_with("_oneshot"):
			oneshots.append(oneshot)

func _run_randomized_oneshot() -> void:
	var i:int = randi_range( 0, oneshots.size()-1 )
	var param:String = oneshots[i]
	var animation:String = ( oneshots[i] as String ).trim_suffix("_oneshot")
	var anim_length:float = anim_player_get_anim_length( tree_get_node(animation).animation )
	
	tree_set(param,true)
	
#	var tweener:Tween = create_tween()
#	tweener.tween_callback( func()->void:
#		tree_set(animation,false)
#		).set_delay(anim_length)
	
	timer.start( anim_length + 0.25 )
