extends Node

# Singleton which stores references to other Nodes

@onready var player_camera := get_tree().current_scene.get_node("RoomCamera")
@onready var platforming_player := get_tree().current_scene.get_node("Chapter 1/PlatformingPlayer")

@export var room_pause: bool = false
@export var room_pause_time: float = 0.5

func change_room(room_position: Vector2, room_size: Vector2) -> void:
	player_camera.current_room_center = room_position
	player_camera.current_room_size = room_size
	
	room_pause = true
	await get_tree().create_timer(room_pause_time).timeout
	room_pause = false
	
