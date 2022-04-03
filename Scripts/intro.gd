extends Node

var counter = 0.00
var stage = 0

func _ready():
	$"/root/Bgm".stop()
	$"/root/Bgm".play(100)


func _process(delta):
	counter += delta
	
	if counter > 1 and stage == 0:
		stage = 1
		$L1.visible = true
	if counter > 3 and stage == 1:
		stage = 2
		$L2.visible = true
	if counter > 7.5 and stage == 2:
		stage = 3
		$L3.visible = true
	if counter > 9.5 and stage == 3:
		stage = 4
		$L4.visible = true
	if counter > 11 and stage == 4:
		stage = 5
		$L5.visible = true
	if counter > 15 and stage == 5:
		stage = 6
		$L6.visible = true
	if counter > 17 and stage == 6:
		stage = 7
		$L7.visible = true
	if counter > 19 and stage == 7:
		stage = 8
		$L8.visible = true
	if (counter > 24 and stage == 8) or Input.is_action_just_pressed("ui_end"):
		get_tree().change_scene("res://_Scenes/Level_1.tscn")
