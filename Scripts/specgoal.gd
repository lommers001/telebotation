extends Area2D

var player
var t_frame = 0
var c_frame = 0
var anim_interval = 10
var anim_counter = 0

export var connect_to = ""
var connected_item

func _ready():
	player = get_parent().get_parent().get_node("Player")
	connected_item = get_parent().get_node("NoGoZones").get_node(connect_to)

func _on_body_entered(body):
	if body is RigidBody2D and 'position_to_swap_to' in body:
		t_frame = 4
		connected_item.position.x -= 6000
		$sfx_active.play()

func _on_body_exited(body):
	if body is RigidBody2D and 'position_to_swap_to' in body:
		t_frame = 0
		connected_item.position.x += 6000
		$sfx_wrong.play()

func _physics_process(delta):
	
	#Animation
	if anim_counter > anim_interval:
		c_frame = 0 if (c_frame + 1) >= 4 else c_frame + 1
		$Sprite.frame = c_frame + t_frame
		anim_counter = 0
	else:
		anim_counter += 1
