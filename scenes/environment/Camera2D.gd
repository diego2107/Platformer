extends Camera2D

# Amount of smoothing used to follow the player value is from 0 to 1
@export var follow_smoothing: float = 0.1

# The amount of smoothing used by the code
var smoothing: float

var current_room_center: Vector2
var current_room_size: Vector2

@onready var view_size: Vector2 = get_viewport_rect().size
var zoom_view_size: Vector2 

func _ready() -> void:
	# Sets smoothing to 1 and back to follow_smoothing
	# I do this so the camera appears as if it starts at the first room not at (0, 0)
	position_smoothing_enabled = false
	smoothing = 1
	await get_tree().create_timer(0.1).timeout
	smoothing = follow_smoothing
	print("Initial Camera Position: ", position) # Debug log

func _physics_process(delta: float) -> void:
	# Get view size considering camera zoom
	zoom_view_size = view_size * zoom 
	
	# Get target position
	var target_position = calculate_target_position(current_room_center, current_room_size)
	
	# Interpolate(lerp) camera position to target position by the smoothing
	position = position.lerp(target_position, smoothing)
	#print("current room size: ", current_room_size)
	#print("Camera Target Position: ", target_position) # Debug log

func calculate_target_position(room_center: Vector2, room_size: Vector2) -> Vector2:
	var x_margin: float = (room_size.x - zoom_view_size.x) / 2
	var y_margin: float = (room_size.y - zoom_view_size.y) / 2
	
	var return_position: Vector2 = Vector2.ZERO
	
	if x_margin <= 0:
		return_position.x = room_center.x
	else:
		var left_limit: float = room_center.x - x_margin
		var right_limit: float = room_center.x + x_margin
		return_position.x = clamp(Global.platforming_player.position.x, left_limit, right_limit)
	
	if y_margin <= 0:
		return_position.y = room_center.y
	else:
		var top_limit: float = room_center.y - y_margin
		var bottom_limit: float = room_center.y + y_margin
		return_position.y = clamp(Global.platforming_player.position.y, top_limit, bottom_limit)
	
	return return_position
