extends "state.gd"

@onready var anim_player = $"../../AnimationPlayer"

func update(delta):
	Player.gravity(delta)
	player_movement()
	if Player.velocity.y > 0:
		return STATES.FALL
	if Player.dash_input and Player.can_dash:
		return STATES.DASH
	return null
func enter_state():
	anim_player.play("jump")
	Player.jump_counter -= 1
	if Player.jump_counter < 0:
		return STATES.SLIDE
	if Player.prev_state == STATES.JUMP:
		return STATES.FALL
	else:
		Player.velocity.y = Player.JUMP_VELOCITY
