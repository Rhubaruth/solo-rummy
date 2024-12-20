extends Button
class_name DiscardButton

func _on_selection_changed(num):
	self.disabled = num != 1
	pass # Replace with function body.
