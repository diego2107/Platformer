extends "state.gd"

@onready var anim_player = $"../../AnimationPlayer"

func update(delta):
	Player.gravity(delta)
	if Player.move_input.x != 0:
		return STATES.MOVE
	if Player.jump_input_actuation:
		Player.jump_counter = 2
		Player.slide_friction = .75
		return STATES.JUMP
	if Player.velocity.y > 0:
		return STATES.FALL
	return null
func enter_state():
	anim_player.play("idle")
	Player.can_dash = true
