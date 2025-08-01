extends Area2D


func _on_body_entered(body: Node2D) -> void:
	$AnimationPlayer.play("loop")
	$signTutorial.visible = true


func _on_body_exited(body: Node2D) -> void:
	$signTutorial.visible = false
