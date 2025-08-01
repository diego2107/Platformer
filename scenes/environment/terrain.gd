extends TileMapLayer

@onready var shader_material := $".".material as ShaderMaterial

func ready():
	shader_material.set_shader_param("desaturation", 1.0)  # full grayscale
