extends "state.gd"

@onready var CoyoteTimer = $CoyoteTimer
@export var coyote_duration = 0.2
@onready var anim_player = $"../../AnimationPlayer"

var can_jump = true

func update(delta):
	Player.gravity(delta)
	player_movement()
	if Player.is_on_floor():
		Player.jump_counter = 2
		Player.slide_friction = .75 
		
		return STATES.IDLE
	if Player.dash_input and Player.can_dash:
		return STATES.DASH
	if Player.get_next_to_wall() != null:
		return STATES.SLIDE
	if Player.jump_input_actuation and can_jump == true:
		return STATES.JUMP
	return null

func enter_state():
	anim_player.play("fall")
	if Player.prev_state == STATES.IDLE or Player.prev_state == STATES.MOVE or Player.prev_state == STATES.SLIDE:
		can_jump = true
		CoyoteTimer.start(coyote_duration)
	else:
		can_jump = false
	

func _on_coyote_timer_timeout():
	can_jump = false
	
