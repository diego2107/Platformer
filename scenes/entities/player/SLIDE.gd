extends "state.gd"


@onready var anim_player = $"../../AnimationPlayer"

func update(delta):
	slide_movement(delta)
	if Player.jump_counter == 0:
		print("max jumps!")
		Player.slide_friction = 1
	if Player.get_next_to_wall() == null:
		return STATES.FALL
	if Player.jump_input_actuation:
		return STATES.JUMP
	if Player.is_on_floor():
		Player.jump_counter = 2
		Player.slide_friction = .75
		return STATES.IDLE
	return null

func slide_movement(delta):
	anim_player.play("slide")
	player_movement()
	Player.gravity(delta)
	Player.velocity.y *= Player.slide_friction
