extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_value = ProjectSettings.get_setting("physics/2d/default_gravity")

# Player input
var move_input = Vector2.ZERO
var jump_input = false
var jump_input_actuation
var dash_input = false

# Player Movement
const SPEED = 100.0
const JUMP_VELOCITY = -400.0
var last_input = Vector2.RIGHT

# Mechanics
var can_dash = true
var jump_counter = 2
var slide_friction = 0.75

# States
var current_state = null
var prev_state = null

# Nodes
@onready var STATES = $STATES
@onready var WallRaycasts = $WallRaycasts
@onready var FloorRaycast = $FloorRaycast
@onready var sprite = $Sprite2D

func _ready():
	for state in STATES.get_children():
		state.STATES = STATES
		state.Player = self
	prev_state = STATES.IDLE
	current_state = STATES.IDLE
	#print("Initial Player Position: ", global_position) # Debug log

func _physics_process(delta):
	#print("Jumps Left: ", jump_counter)
	player_input()
	change_state(current_state.update(delta))
	$Label.text = str(current_state.get_name())
	#print("Scale: ", sprite.scale)
	move_and_slide()
	# default_move(delta)

func gravity(delta):
	if not is_on_floor():
		velocity.y += gravity_value * delta

func change_state(input_state):
	if input_state != null:
		prev_state = current_state
		current_state = input_state

		prev_state.exit_state()
		current_state.enter_state()

func get_next_to_wall():
	for raycast in WallRaycasts.get_children():
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if raycast.target_position.x > 0:
				return Vector2.RIGHT
			else:
				return Vector2.LEFT
	return null

func player_input():
	move_input = Vector2.ZERO
	if Input.is_action_pressed("MoveRight"):
		sprite.flip_h = false
		move_input.x += 1
	if Input.is_action_pressed("MoveLeft"):
		sprite.flip_h = true
		move_input.x -= 1
	if Input.is_action_pressed("MoveUp"):
		move_input.y -= 1
	if Input.is_action_pressed("MoveDown"):
		move_input.y += 1

	# Jumps
	if Input.is_action_pressed("Jump"):
		jump_input = true
	else:
		jump_input = false
	if Input.is_action_just_pressed("Jump"):
		jump_input_actuation = true
	else:
		jump_input_actuation = false

	# Dash
	if Input.is_action_just_pressed("Dash"):
		dash_input = true
	else:
		dash_input = false

func _on_RoomDetector_area_entered(area: Area2D) -> void:
	print("AREA ENTERED!")
	var collision_shape: CollisionShape2D = area.get_node("CollisionShape2D")
	var size: Vector2 = collision_shape.shape.extents * 2

	var view_size = get_viewport_rect().size
	if size.y < view_size.y:
		size.y = view_size.y

	if size.x < view_size.x:
		size.x = view_size.x

	print("Room size calculated: ", size)
	var cam = $Camera2D
	cam.limit_top = collision_shape.global_position.y - size.y / 2
	cam.limit_left = collision_shape.global_position.x - size.x / 2

	# Changes camera's current room and size. Check camera script for more info
	Global.change_room(collision_shape.global_position, size)
