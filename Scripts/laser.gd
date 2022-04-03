extends Area2D

var t_frame = 0
var c_frame = 0
var anim_interval = 6
var anim_counter = 0

func _on_body_entered(body):
	if body is RigidBody2D and body.name == 'Player':
		body.power_left = 0

func _physics_process(delta):
	
	#Animation
	if anim_counter > anim_interval:
		c_frame = 0 if (c_frame + 1) >= 4 else c_frame + 1
		$Sprite.frame = c_frame + t_frame
		anim_counter = 0
	else:
		anim_counter += 1
