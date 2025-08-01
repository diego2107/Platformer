extends Area2D
class_name SecretArea

@export var target_tilemap_layer: TileMapLayer
@export var fade_duration: float = 0.35

func _ready():
	# Connect the Area2D signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
		print("Player entered secret area")  # Debug
		fade_layer(0.0)

func _on_body_exited(body):
		print("Player exited secret area")  # Debug
		fade_layer(1.0)

func fade_layer(target_opacity: float):
	if target_tilemap_layer == null:
		print("No tilemap layer assigned to SecretArea!")
		return
	
	print("Fading layer to opacity: ", target_opacity)  # Debug
	var current_opacity = target_tilemap_layer.modulate.a
	
	var tween = create_tween()
	tween.tween_method(
		set_layer_opacity, 
		current_opacity, 
		target_opacity, 
		fade_duration
	)

func set_layer_opacity(opacity: float):
	if target_tilemap_layer == null:
		return
	
	# Create a new Color instead of modifying alpha directly
	var current_color = target_tilemap_layer.modulate
	target_tilemap_layer.modulate = Color(current_color.r, current_color.g, current_color.b, opacity)
