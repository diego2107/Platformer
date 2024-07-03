extends "state.gd"

var dash_input = Vector2.ZERO
var dash_speed = 240
var dashing = false
@export var dash_duration = .3
@onready var DashDuration_timer = $DashDuration
@onready var anim_player = $"../../AnimationPlayer"

func update(delta):
	if !dashing:
		return STATES.FALL
	return null
	
func enter_state():
	anim_player.play("dash")
	Player.can_dash = false
	dashing = true
	DashDuration_timer.start(dash_duration)

	dash_input = Player.move_input
	if dash_input == Vector2.ZERO:
		dash_input = Player.last_input
	
	Player.sprite.scale = Vector2(0.60, 0.60)
	Player.sprite.rotation = dash_input.angle()
	
	if dash_input.x < 0:
		Player.sprite.flip_h = true
		Player.sprite.rotation += PI  # Rotate 180 degrees to correct the left side rotation
	else:
		Player.sprite.flip_h = false

	Player.velocity = dash_input.normalized() * dash_speed

func exit_state():
	Player.sprite.scale = Vector2(0.35, 0.35)
	Player.sprite.rotation = 0
	dashing = false
	
func _on_timer_timeout():
	dashing = false
	pass # Replace with function body.
