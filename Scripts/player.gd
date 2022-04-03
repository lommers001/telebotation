extends RigidBody2D

var SPEED = 300
var MAX_GROUNDSPEED = 160
var MAX_AIRSPEED = 150
var MAX_SPEED
var JUMP_POWER = 1200
var JUMP_POWER_ACCEL = 200
var MAX_VERT_VELOCITY = 800
var MAX_COYOTE_TIME = 0.15

var ANIM_IDLE = [[0,1,2,3,4,3,2,1],[10,10,12,10,10,10,12,10],0]
var ANIM_RUN = [[4,15,16,17,18,19],[4,4,4,4,4,4],1]
var ANIM_JUMP = [[10,11,12,13,14],[1,3,6,18,999999],2]
var ANIM_WIN = [[20,21,22,23,24,23,22,21],[6,6,6,6,10,6,6,6],3]
var ANIM_DIE = [[25,26,27,28,29],[12,6,6,6,999999],4]

var center = Vector2.ZERO
var radius = 220
var angle_from = 0
var angle_to = 360
var color = Color(0.0, 0.0, 0.0)
var on_ground = true
var not_on_wall = true
var is_moving = false
var coyote_time = MAX_COYOTE_TIME
var anim_counter = 0
var curr_anim = ANIM_IDLE
var curr_anim_id = 0
var curr_frame = 0
var anim_interval = 0
var is_accelerating = false
var can_move = true
var amount_of_boxes = 0
var transition_delay = 150
var is_dead = false
var is_ending = false
var endgame_phase = 0

var power_left = 128.00
var curr_level

var velo
var stopping_force
var camera_bounds
var power_bar

func _ready():
	velo = Vector2.ZERO
	camera_bounds = get_parent().get_node("CameraBound")
	$Camera2D.limit_right = camera_bounds.position.x
	$Camera2D.limit_top = camera_bounds.position.y
	amount_of_boxes = get_parent().get_node("Boxes").get_child_count()
	power_bar = get_parent().get_node("CanvasLayer/MeterBar")
	get_parent().get_node("Bg").texture.fps = 4
	curr_level = $"/root/Global".CURR_LEVEL
	$"/root/Global".BOXES_IN_POSITION = 0
	$"/root/Bgm".pitch_scale = 0.7

func _draw():
	draw_circle_arc(center, radius, angle_from, angle_to, color)

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)


func _integrate_forces(state):
	#Collisions and Movement
	if ($RayCast_1.is_colliding() or $RayCast_2.is_colliding()) and !Input.is_action_pressed("ui_up"):
		coyote_time = MAX_COYOTE_TIME
	else:
		coyote_time -= 0.01
	
	velo = Vector2.ZERO
	on_ground = coyote_time > 0.0
	stopping_force = -linear_velocity.x * 8
	not_on_wall = on_ground or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right") or linear_velocity.x != 0.0
	if !not_on_wall:
		not_on_wall = get_colliding_bodies().size() == 0
	
	if can_move:
		MAX_SPEED = MAX_GROUNDSPEED if on_ground else MAX_AIRSPEED
		if Input.is_action_pressed("ui_left") and linear_velocity.x > -MAX_SPEED and not_on_wall:
			velo.x = -SPEED
			change_anim(ANIM_RUN)
			if not $Sprite.flip_h:
				turn()
				$Sprite.flip_h = true
			is_moving = true
			power_left -= 0.02
		if (Input.is_action_just_released("ui_left") and linear_velocity.x < 0) or (Input.is_action_just_released("ui_right") and linear_velocity.x > 0):
			velo.x = stopping_force
			decellerate()
		if Input.is_action_pressed("ui_right") and linear_velocity.x < MAX_SPEED and not_on_wall:
			velo.x = SPEED
			change_anim(ANIM_RUN)
			if $Sprite.flip_h:
				turn()
				$Sprite.flip_h = false
			is_moving = true
			power_left -= 0.02
		if Input.is_action_just_pressed("ui_up") and on_ground:
			velo.y = -JUMP_POWER
			velo.x = 0
			is_moving = true
			$sfx_jump.play()
			change_anim(ANIM_JUMP)
		if Input.is_action_pressed("ui_up") and on_ground:
			velo.y -= JUMP_POWER_ACCEL
			is_moving = true
			power_left -= 0.1
		if abs(linear_velocity.x) < 0.01:
			is_moving = false
		if not is_moving and on_ground and (curr_anim_id != 2 or $Sprite.frame == 14):
			change_anim(ANIM_IDLE)
		
		apply_central_impulse (velo)
		
		#Check if level is completed
		if $"/root/Global".BOXES_IN_POSITION == amount_of_boxes or Input.is_key_pressed(KEY_0):
			change_anim(ANIM_WIN)
			can_move = false
			get_parent().get_node("Bg").texture.fps = 16
			get_parent().get_node("Bg/BgShader").color.a = 0
			transition_delay = 260
			$sfx_win.play()
			if curr_level == 6:
				is_ending = true
				transition_delay = 1300
	#DEAD - Reload scene
	elif is_dead:
		transition_delay -= 1
		if transition_delay < 30:
			get_parent().get_node("CanvasLayer/UI").fade_out()
		if transition_delay < 0:
			get_tree().reload_current_scene()
	#WIN - Go to next level
	elif not is_ending:
		transition_delay -= 1
		if transition_delay < 30:
			get_parent().get_node("CanvasLayer/UI").fade_out()
		if transition_delay < 0:
			$"/root/Global".CURR_LEVEL += 1
			get_tree().change_scene("res://_Scenes/Level_" + String(curr_level + 1) + ".tscn")
	#End the game
	else:
		if endgame_phase != 1:
			transition_delay -= 1
		if transition_delay < 1000:
			endgame()
	
	#Animation
	anim_interval = 4 if is_accelerating else curr_anim[1][curr_frame]
	if anim_counter > anim_interval:
		curr_frame = 0 if (curr_frame + 1) >= curr_anim[0].size() else curr_frame + 1
		$Sprite.frame = curr_anim[0][curr_frame]
		anim_counter = 0
	else:
		anim_counter += 1
	
	#RESET
	if not is_dead and (Input.is_key_pressed(KEY_R) or power_left < 0):
		change_anim(ANIM_DIE)
		can_move = false
		is_dead = true
		$sfx_dead.play()
	
	#Draw power bar
	power_bar.rect_size.x = power_left
	power_bar.rect_position.x = 858 - power_left
	power_bar.color.g = power_left * 0.007
	power_bar.color.r = 1 - (power_left * 0.007)

func change_anim(anim, only_once = false):
	if anim[2] == curr_anim_id:
		return
	if anim[2] == 1:
		is_accelerating = true
		if $Sprite.frame < 4:
			if curr_frame > 4:
				curr_frame = 3
			return
	is_accelerating = false
	curr_anim_id = anim[2]
	curr_anim = anim
	curr_frame = 0
	anim_counter = min(anim_counter, 0)
	if curr_anim_id == 2:
		$Sprite.frame = anim[0][0]
		anim_counter = 0

func turn():
	$Sprite.frame = 5
	anim_counter = -5

func decellerate():
	if($Sprite.frame != 5):
		$Sprite.frame = 0
		anim_counter = -10

func endgame():
	if endgame_phase == 0:
		endgame_phase = 1
	if endgame_phase == 1:
		$"/root/Bgm".pitch_scale -= 0.01
		get_parent().get_node("Bg/BgShader").color.a += 0.01
		if $"/root/Bgm".pitch_scale < 0.5:
			get_parent().get_node("CanvasLayer/Transition").color.a += 0.01
			power_left = max(0, power_left - 5)
		if $"/root/Bgm".pitch_scale < 0.2:
			endgame_phase = 2
			change_anim(ANIM_DIE)
			$"/root/Bgm".stop()
			var goals = get_parent().get_node("Boxes").get_children()
			for goal in goals:
				goal.stop_anim()
	if endgame_phase == 2 and transition_delay < 900:
		get_parent().get_node("CanvasLayer/Label").visible = true
	
