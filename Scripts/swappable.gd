extends RigidBody2D

var position_to_swap_to = null
var anim_interval = 10
var anim_counter = 0

func _ready():
	pass

func _integrate_forces(state):
	if position_to_swap_to != null:
		state.transform.origin = position_to_swap_to
		position_to_swap_to = null
	
	#Animation
	if anim_counter > anim_interval:
		$Sprite.frame = 0 if ($Sprite.frame + 1) >= 4 else $Sprite.frame + 1
		anim_counter = 0
	else:
		anim_counter += 1
