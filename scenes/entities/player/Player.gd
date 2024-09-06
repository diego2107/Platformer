extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity_value = ProjectSettings.get_setting("physics/2d/default_gravity")

# Player input
var move_input = Vector2.ZERO
var jump_input = false
var jump_input_actuation
var dash_input = false
var danger = false

# Player Movement
const SPEED = 80
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
@onready var catSpring = $"../../Room4/CatSpring/AnimationPlayer"

enum Touching_Side {
	BOTH,
	HORIZONTAL,
	VERTICAL,
	NONE
}


func _ready():
	for state in STATES.get_children():
		state.STATES = STATES
		state.Player = self
	prev_state = STATES.IDLE
	current_state = STATES.IDLE
	#print("Initial Player Position: ", global_position) # Debug log

func _physics_process(delta):
	if !Global.room_pause:
		move_and_slide()
	#print("Jumps Left: ", jump_counter)
	player_input()
	change_state(current_state.update(delta))
	$Label.text = str(current_state.get_name())
	#print("Scale: ", sprite.scale)
	
	if danger == true:
		die()
	

func gravity(delta):
	if not is_on_floor():
		velocity.y += gravity_value * delta
	
	if velocity.y < -1 and Global.room_pause:
		velocity.y = -300
	
	if velocity.y > 0 and Global.room_pause:
		velocity.y = 0

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
	# Gets collision shape and size of room
	var collision_shape: CollisionShape2D = area.get_node("CollisionShape2D")
	var size: Vector2 = collision_shape.shape.extents * 2
	
	# Changes camera's current room and size. check PlayerCamera script for more info
	Global.change_room(collision_shape.global_position, size)
	
# Checks which edge of a touching b. If a and b are overlapping or not touching 
# the function will push_error(). a is the previous room and b is the room being entered
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
			if a_center.y < b_center.y: # up is negative y
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
				
	# Fail safe
	return Global.RIGHT

func _on_area_2d_body_entered(body):
	catSpring.play("startled")
	velocity.y = -500
	await get_tree().create_timer(0.85).timeout
	catSpring.play("sleep")



func hazard_entered(area):
	print("Hazard has been entered!")
	danger = true


func hazard_exited(area):
	print("Hazard has been exited!")
	danger = false
	
func die():
	move_input = Vector2.ZERO
	#var tween = create_tween()
	#tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	#tween.tween_callback(self.queue_free)
	#tween.play()
	position = Global.death_position

func checkpoint_entered(area):
	Global.death_position = position
	print("Position updated!")
