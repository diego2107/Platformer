extends Sprite2D

@onready var animPlayer = $"../AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready():
	animPlayer.play("sleep")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
