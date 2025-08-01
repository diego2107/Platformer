extends CanvasLayer
@onready var pauseMenu = $"."

func _ready():
	pauseMenu.process_mode = 3

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Escape"):
		if $".".visible == false:
			get_tree().paused = true
			$".".visible = true
		else:
			get_tree().paused = false
			$".".visible = false

func resumePressed():
	get_tree().paused = false
	$".".visible = false
