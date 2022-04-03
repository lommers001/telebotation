extends Area2D

var player
var t_frame = 0
var c_frame = 0
var anim_interval = 10
var anim_counter = 0

func _ready():
	player = get_parent().get_parent().get_node("Player")

func _on_body_entered(body):
	if body is RigidBody2D and 'position_to_swap_to' in body:
		$"/root/Global".BOXES_IN_POSITION += 1
		t_frame = 4
		get_parent().get_parent().get_node("Bg/BgShader").color.a -= 0.1
		if $"/root/Global".BOXES_IN_POSITION != player.amount_of_boxes:
			$sfx_active.play()
			$"/root/Bgm".pitch_scale += 0.1
		else:
			$"/root/Bgm".pitch_scale = 1

func _on_body_exited(body):
	if body is RigidBody2D and 'position_to_swap_to' in body:
		$"/root/Global".BOXES_IN_POSITION -= 1
		t_frame = 0
		$"/root/Bgm".pitch_scale -= 0.1
		get_parent().get_parent().get_node("Bg/BgShader").color.a += 0.1
		$sfx_wrong.play()

func _physics_process(delta):
	
	#Animation
	if anim_counter > anim_interval:
		c_frame = 0 if (c_frame + 1) >= 4 else c_frame + 1
		$Sprite.frame = c_frame + t_frame
		anim_counter = 0
	else:
		anim_counter += 1

func stop_anim():
	anim_counter = -19999
	$Sprite.frame = 0
