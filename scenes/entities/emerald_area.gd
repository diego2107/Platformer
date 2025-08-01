extends Area2D


func _on_player_entered(body: Node2D) -> void:
	$"../..".queue_free()
