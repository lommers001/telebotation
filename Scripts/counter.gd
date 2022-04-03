extends Sprite

var amount_of_boxes = 0
var anim_interval = 10
var anim_counter = 0
var is_opening = true
var transition_screen

func _ready():
	amount_of_boxes = get_node("/root/Node2D/Boxes").get_child_count()
	transition_screen = get_parent().get_node("Transition")
	
func _physics_process(delta):
	
	frame = (amount_of_boxes - 1) + ($"/root/Global".BOXES_IN_POSITION * 3)
	
	if is_opening:
		transition_screen.color.a -= 0.02
	if transition_screen.color.a <= 0:
		is_opening = false

func fade_out():
	transition_screen.color.a += 0.02
