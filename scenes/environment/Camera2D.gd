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
	if Global.platforming_player == null:
		Global.init_world_references()
	# Sets smoothing to 1 and back to follow_smoothing
	# I do this so the camera appears as if it starts at the first room not at (0, 0)

	position_smoothing_enabled = false
	smoothing = 1
	await get_tree().create_timer(0.1).timeout
	smoothing = follow_smoothing


func _physics_process(delta: float) -> void:
	if Global.platforming_player == null:
		return

	zoom_view_size = view_size / zoom

	var player_pos = Global.platforming_player.global_position
	var target_position = calculate_target_position(current_room_center, current_room_size)

	#print("Player Pos:", player_pos)
	#print("Room Center:", current_room_center)
	#print("Room Size:", current_room_size)
	#print("Zoom View Size:", zoom_view_size)
	#print("Target Position:", target_position)

	global_position = lerp(global_position, target_position, smoothing)


func calculate_target_position(room_center: Vector2, room_size: Vector2) -> Vector2:
	var player_pos = Global.platforming_player.global_position
	var target_pos = Vector2.ZERO

	var x_margin = (room_size.x - zoom_view_size.x) / 2.0
	var y_margin = (room_size.y - zoom_view_size.y) / 2.0
	
	#print("x_margin:", x_margin, " y_margin:", y_margin)

	# Clamp only if room is larger than view
	if x_margin > 0:
		var left_limit = room_center.x - x_margin
		var right_limit = room_center.x + x_margin
		target_pos.x = clamp(player_pos.x, left_limit, right_limit)
		#print("Clamping X between", left_limit, "and", right_limit)
	else:
		target_pos.x = room_center.x
		#print("No clamping X, center at", target_pos.x)

	if y_margin > 0:
		var top_limit = room_center.y - y_margin
		var bottom_limit = room_center.y + y_margin
		target_pos.y = clamp(player_pos.y, top_limit, bottom_limit)
		#print("Clamping Y between", top_limit, "and", bottom_limit)
	else:
		target_pos.y = room_center.y
		print("No clamping Y, center at", target_pos.y)

	return target_pos
