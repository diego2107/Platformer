extends Node

var STATES = null
var Player = null

func enter_state():
	pass
	
func exit_state():
	pass
	
func update(delta):
	return null
	
func player_movement():
	if Player.move_input.x > 0:
		Player.velocity.x = Player.SPEED
		Player.last_input = Vector2.RIGHT
	elif Player.move_input.x < 0:
		Player.velocity.x = - Player.SPEED
		Player.last_input = Vector2.LEFT
	else:
		Player.velocity.x = 0
		
		
