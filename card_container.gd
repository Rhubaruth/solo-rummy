extends Control
class_name HandControl

var spacing: float = -48
const CARD_WIDTH: int = 128


func _ready():
	_on_child_order_changed()

func get_cards():
	var cards: Array[Card] = []
	for child in get_children():
		if is_instance_of(child, Card):
			cards.append(child)
	return cards

func swap(card: Card, dir: int):
	var node_idx = card.get_index()
	if node_idx + dir < 0 or node_idx + dir >= get_child_count():
		return
	var other_card: Card = get_child(node_idx + dir)
	move_child(card, node_idx + dir)
	
	card.orig_position_x = other_card.position.x
	
	# Move other card
	var new_pos = other_card.position
	new_pos.x = node_idx * (CARD_WIDTH + spacing)
	other_card.move_to(new_pos, 2)
	pass

func move_to_place(node, node_idx: int):
	var new_pos := Vector2.ZERO
	new_pos.x = node_idx * (CARD_WIDTH + spacing)
	if is_instance_of(node, Card):
		node.move_to(new_pos)
	else:
		node.position = new_pos
	pass

func _on_child_entered_tree(node):
	spacing = self.size.x / get_child_count() - CARD_WIDTH
	
	var node_idx = node.get_index()
	move_to_place(node, node_idx)


func _on_child_exiting_tree(node):
	var node_idx = node.get_index()
	spacing = self.size.x / get_child_count() - CARD_WIDTH
	
	for i in range(node_idx+1, get_child_count()):
		var card = get_child(i)
		move_to_place(card, i-1)


func _on_child_order_changed():
	if get_child_count() < 1:
		return
	
	for i in range(0, get_child_count()):
		var card = get_child(i)
		move_to_place(card, i)
	pass # Replace with function body.
