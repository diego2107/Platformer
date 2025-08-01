extends Node

# Singleton which stores references to other Nodes

@onready var player_camera: Camera2D = null
@onready var platforming_player: Node2D = null

@export var room_pause: bool = false
@export var room_pause_time: float = 0.75
@export var death_position: Vector2

func _ready():
	# Check if the current scene is the World scene
	if get_tree().current_scene.name == "World":
		init_world_references()

func init_world_references() -> void:
	# Safely assign the camera and player references if available
	if player_camera == null or platforming_player == null:
		player_camera = get_tree().current_scene.get_node("RoomCamera") as Camera2D
		platforming_player = get_tree().current_scene.get_node("Chapter 1/PlatformingPlayer") as Node2D
		print("References set for player camera and platforming player")

func change_room(room_position: Vector2, room_size: Vector2) -> void:
	if player_camera == null:
		init_world_references()
	
	if player_camera:
		player_camera.current_room_center = room_position
		player_camera.current_room_size = room_size

	room_pause = true
	await get_tree().create_timer(room_pause_time).timeout
	room_pause = false
