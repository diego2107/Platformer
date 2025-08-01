extends Area2D

var bounceStrength: float = -500

func _ready():
	$"../AnimationPlayer".play("sleep")

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("body entered into spring!")
		body.velocity.y = bounceStrength
		$"../AnimationPlayer".play("startled")
		await get_tree().create_timer(0.5).timeout
		$"../AnimationPlayer".play("sleep")
