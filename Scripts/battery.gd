extends Sprite

var player
var t_frame = 0
var c_frame = 0
var anim_interval = 10
var anim_counter = 0

func _ready():
	player = get_parent().get_node("Player")

func _physics_process(delta):
	
	if position.distance_to(player.position) < 40:
		$sfx_heal.play()
		position.x = -4000
		player.power_left = min(128.00, player.power_left + 60)
	
	#Animation
	if anim_counter > anim_interval:
		c_frame = 0 if (c_frame + 1) >= 4 else c_frame + 1
		frame = c_frame + t_frame
		anim_counter = 0
	else:
		anim_counter += 1
