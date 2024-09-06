extends Sprite2D
@onready var animPlayer = $"../AnimationPlayer"

func _ready():
	animPlayer.play("sleep")
