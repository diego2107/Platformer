extends CollisionShape2D

@onready var Global = "res://scenes/entities/player/global.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	if Area2D.area_entered == true:
		Global.position = player_position
