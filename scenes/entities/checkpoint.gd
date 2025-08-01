extends Area2D

var triggered := false

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	if body.has_method("save_data"):
		body.save_data()
	triggered = true
	$Sprite2D/AnimationPlayer.play("Jump")
	$Sprite2D/Timer.start(0.1)
	set_deferred("monitoring", false)

func onTimerTimeout():
	$Sprite2D/AnimationPlayer.play("Cycle")
