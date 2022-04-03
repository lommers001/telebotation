extends Area2D

signal hit
var MAX_DISTANCE

var player
var tilemap
var can_teleport
var is_overlapping_tilemap
var swappable
var camera

var teleport_timer = 0.0
var is_teleporting = false
var is_teleporting_out = false
var x_scale = 1.0

func _ready():
	player = get_parent().get_node("Player")
	tilemap = get_parent().get_node("TileMap")
	can_teleport = false
	is_overlapping_tilemap = false
	swappable = null
	$NoGoCast.add_exception(player)
	camera = get_parent().get_node("Player/Camera2D")
	MAX_DISTANCE = player.radius

func _physics_process(delta):
	position = get_viewport().get_mouse_position() + camera.get_camera_screen_center() - Vector2(448, 320)
	$NoGoCast.cast_to = player.position - global_position
	
	if position.distance_to(player.position) > MAX_DISTANCE or $NoGoCast.is_colliding() or (is_overlapping_tilemap and swappable == null):
		$Cursor.frame = 0
		can_teleport = false
	else:
		$Cursor.frame = 1 if swappable == null else 2
		can_teleport = !player.is_dead and !player.is_ending
	
	if Input.is_action_just_pressed("teleport") and can_teleport and not is_teleporting:
		is_teleporting = true
		$sfx_warp.play()
	
	if Input.is_action_just_pressed("teleport") and not can_teleport:
		$sfx_thud.play()
	
	if is_teleporting:
		teleport_timer += 0.1
		if teleport_timer > 1.0 and not is_teleporting_out:
			player.power_left -= 15
			is_teleporting_out = true
			if swappable == null:
				teleport(player, position)
			else:
				var temp = Vector2(swappable.position.x + 0.1, swappable.position.y - 0.1)
				swappable.position_to_swap_to = player.position
				teleport(player, temp)
		if is_teleporting_out:
			x_scale = min(1.0, -0.9 + teleport_timer)
		else:
			x_scale = min(1.0, 1.0 - teleport_timer)
		
		player.get_node("Sprite").scale.x = x_scale
		player.get_node("Sprite").scale.y = x_scale
		if swappable != null:
			swappable.get_node("Sprite").scale.x = x_scale
			swappable.get_node("Sprite").scale.y = x_scale
		if teleport_timer > 2.2:
			is_teleporting = false
			is_teleporting_out = false
			teleport_timer = 0.0
			swappable = null

func teleport(body, tranform):
	body.position.x = tranform.x
	body.position.y = tranform.y

func _on_body_entered(body):
	if body is TileMap:
		is_overlapping_tilemap = true
	if position.distance_to(player.position) <= MAX_DISTANCE and body is RigidBody2D and 'position_to_swap_to' in body:
		swappable = body
		$sfx_blip.play()


func _on_body_exited(body):
	if body is TileMap:
		is_overlapping_tilemap = false
	if body == player:
		return
	if body is RigidBody2D and not is_teleporting:
		swappable = null
