extends Area2D

var bounceStrength: float = -500

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("body entered into spring!")
		body.velocity.y = bounceStrength
