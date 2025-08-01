extends "state.gd"

var dash_input = Vector2.ZERO
var dash_speed = 200
var dashing = false
@export var dash_duration = .35
@onready var DashDuration_timer = $DashDuration
@onready var anim_player = $"../../AnimationPlayer"
@export var dash_cooldown = 5.0  # seconds cooldown
@onready var DashCooldownTimer = $DashCooldownTimer

func update(delta):
	if !dashing:
		return STATES.FALL
	return null
	


func enter_state():
	# Check if dash is on cooldown
	if DashCooldownTimer.is_stopped() == false:
		return # Still cooling down, ignore dash attempt

	dash_input = Player.move_input
	if dash_input == Vector2.ZERO:
		return

	anim_player.play("dash")
	Player.can_dash = false
	dashing = true
	Player.input_disabled = true
	DashDuration_timer.start(dash_duration)
	
	# Start the cooldown timer immediately
	DashCooldownTimer.start()
	
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
	Player.input_disabled = false
	
func _on_timer_timeout():
	dashing = false
	pass # Replace with function body.
