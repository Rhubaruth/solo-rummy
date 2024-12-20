extends Button
class_name MeldButton

const STATES = preload("res://StatesEnum.gd").State


func _on_selection_changed(num):
	self.disabled = num < 3
	pass # Replace with function body.
