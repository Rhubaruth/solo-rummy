extends Button
class_name MeldButton

func _on_selection_changed(num):
	self.disabled = num < 3
	pass # Replace with function body.
