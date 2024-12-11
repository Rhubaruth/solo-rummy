extends Control
class_name HandContainer

const SPACING: int = -48
const CARD_WIDTH: int = 128


func swap(card: Card, dir: int):
	var node_idx = card.get_index()
	var other_card: Card = get_child(node_idx + dir)
	move_child(card, node_idx + dir)
	
	card.orig_position_x = other_card.position.x
	
	# Move other card
	var new_pos = other_card.position
	new_pos.x = node_idx * (CARD_WIDTH + SPACING)
	other_card.move_to(new_pos, 2)
	pass

func _on_child_entered_tree(node):
	print('Enter')
	var node_idx = node.get_index()
	var new_pos := Vector2.ZERO
	new_pos.x = node_idx * (CARD_WIDTH + SPACING)
	if is_instance_of(node, Card):
		node.move_to(new_pos)
	else:
		node.position = new_pos
	pass # Replace with function body.


func _on_child_exiting_tree(node):
	print('Exit')
	var node_idx = node.get_index()
	
	for i in range(node_idx+1, get_child_count()):
		var card = get_child(i)
		var new_pos = card.position
		new_pos.x = (i-1) * (CARD_WIDTH + SPACING)
		card.move_to(new_pos)
	
	pass # Replace with function body.


func _on_child_order_changed():
	if get_child_count() < 1:
		return
	print('Order')
	for i in range(0, get_child_count()):
		var card = get_child(i)
		var new_pos = card.position
		new_pos.x = i * (CARD_WIDTH + SPACING)
		card.move_to(new_pos)
	pass # Replace with function body.
