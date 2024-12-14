extends Button

const StatesEnum = preload("res://StatesEnum.gd").State


func _on_board_state_change(state):
	if state == StatesEnum.MELDING_END:
		button_pressed = true
	
	pass # Replace with function body.
