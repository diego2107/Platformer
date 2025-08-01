extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_value = ProjectSettings.get_setting("physics/2d/default_gravity")

# Player input
var move_input = Vector2.ZERO
var jump_input = false
var jump_input_actuation
var dash_input = false
var danger = false
var input_disabled = false

# Player Movement
const MAX_SPEED = 80
const ACCELERATION = 300 # How fast the character accelerates
const DECELERATION = 400 # How fast the character decelerates when no input is given
const JUMP_VELOCITY = -250
var last_input = Vector2.RIGHT

# Mechanics
var can_dash = true
var jump_counter = 2
var slide_friction = 0.75
var timer = Timer.new()

# States
var current_state = null
var prev_state = null

# Nodes
@onready var STATES = $STATES
@onready var WallRaycasts = $WallRaycasts
@onready var FloorRaycast = $FloorRaycast
@onready var sprite = $Sprite2D
var save_path = "user://variable.json"

enum Touching_Side {
	BOTH,
	HORIZONTAL,
	VERTICAL,
	NONE
}

func save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		print("Saving position: ", global_position)  # Debugging
		file.store_var(global_position)
	else:
		print("file not created")

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var saved_position = file.get_var()
		print("Loaded position: ", saved_position)

		# Store in the global singleton
		Global.death_position = saved_position

		# Change to the world scene
		get_tree().change_scene_to_file("res://scenes/environment/world.tscn")
	else:
		print("No data saved")

func _ready():
	if Global.death_position != Vector2.ZERO:
		print("Spawning at loaded position: ", Global.death_position)
		global_position = Global.death_position
		Global.death_position = Vector2.ZERO
	for state in STATES.get_children():
		state.STATES = STATES
		state.Player = self
	prev_state = STATES.IDLE
	current_state = STATES.IDLE

#func EscapeMenu():
#	if Input.is_action_pressed("Escape"):
#		get_tree().change_scene_to_file("res://main menu/main_menu.tscn")
#		print("escape pressed!")

func _physics_process(delta):
	#print("Velocity Y: ", velocity.y)
#	EscapeMenu()
	if !Global.room_pause:
		move_and_slide()

	player_input()

	apply_acceleration(delta)
	
	change_state(current_state.update(delta))
	$Container/Label.text = str(current_state.get_name())

	if danger == true:
		die()

func gravity(delta):
	if not is_on_floor():
		velocity.y += gravity_value * delta
	
	if velocity.y < -1 and Global.room_pause:
		velocity.y = -300
	
	if velocity.y > 0 and Global.room_pause:
		velocity.y = 0

func apply_acceleration(delta):
	# Check if the player is on the ground
	if is_on_floor():
		# Accelerate or decelerate based on input
		if move_input.x != 0:
			# Accelerate towards MAX_SPEED
			velocity.x = move_toward(velocity.x, move_input.x * MAX_SPEED, ACCELERATION * delta)
		else:
			# Decelerate when no input is given (only on the ground)
			velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
	else:
		# In the air, retain the current horizontal speed
		if move_input.x != 0:
			# Allow slight adjustment in air but no abrupt deceleration
			velocity.x = move_toward(velocity.x, move_input.x * MAX_SPEED, (ACCELERATION / 2) * delta)

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
	if input_disabled:
		return  # Ignore all input when disabled

	move_input = Vector2.ZERO
	if Input.is_action_pressed("MoveRight"):
		flip_horizontal(false)
		move_input.x += 1
	if Input.is_action_pressed("MoveLeft"):
		flip_horizontal(true)
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

func flip_horizontal(boolean):
	sprite.flip_h = boolean

func _on_RoomDetector_area_entered(area: Area2D) -> void:
	var collision_shape: CollisionShape2D = area.get_node("CollisionShape2D")
	var size: Vector2 = collision_shape.shape.extents * 2
	var center: Vector2 = collision_shape.global_position

	# Update camera directly
	var camera := get_viewport().get_camera_2d()
	if camera:
		camera.current_room_center = center
		camera.current_room_size = size

	# Update global logic (if needed)
	Global.change_room(center, size)


func check_room_edge(a_center: Vector2, a_size: Vector2, b_center: Vector2, b_size: Vector2) -> int:
	var relative_center: Vector2 = a_center - b_center
	var total_size: Vector2 = a_size + b_size
	var horizontal_overlap: int = total_size.x / 2 - abs(relative_center.x)
	var vertical_overlap: int = total_size.y / 2 - abs(relative_center.y)
	var touching: int

	if horizontal_overlap > 0 and vertical_overlap > 0:
		touching = Touching_Side.BOTH
	elif horizontal_overlap > 0 and vertical_overlap == 0:
		touching = Touching_Side.VERTICAL
	elif horizontal_overlap == 0 and vertical_overlap > 0:
		touching = Touching_Side.HORIZONTAL	
	elif horizontal_overlap <= 0 and vertical_overlap <= 0:
		touching = Touching_Side.NONE
	else:
		push_error("error calculating room edge")
		
	match touching:
		Touching_Side.BOTH:
			push_error("rooms overlapping")
		Touching_Side.NONE:
			push_error("player crossed two rooms that are not touching")
		Touching_Side.VERTICAL:
			if a_center.y < b_center.y:
				return Global.DOWN
			elif a_center.y > b_center.y:
				return Global.UP
			else:
				push_error("rooms touching vertically, but at same y coordinate")
		Touching_Side.HORIZONTAL:
			if a_center.x < b_center.x:
				return Global.RIGHT
			elif a_center.x > b_center.x:
				return Global.LEFT
			else:
				push_error("rooms touching horizontally, but at same x coordinate")

	return Global.RIGHT



func hazard_entered(area):
	print("Hazard has been entered!")
	danger = true

func hazard_exited(area):
	print("Hazard has been exited!")
	danger = false
	
func die():
	Global.room_pause = true
	$"../../RoomCamera/AnimationPlayer".play("fade in")
	await get_tree().create_timer(0.5).timeout
	
	move_input = Vector2.ZERO
	position = Global.death_position
	
	await get_tree().create_timer(0.75).timeout
	Global.room_pause = false

func checkpoint_entered(area):
	Global.death_position = position
