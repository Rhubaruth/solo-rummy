extends Node
class_name Board

var cardsSelected: Array[Card] = []

const StatesEnum = preload("res://StatesEnum.gd").State
var state = StatesEnum.DISCARDING

signal state_change(state)


func _ready():
	Input.emulate_mouse_from_touch = true
	emit_signal("state_change", state)

func card_select(card: Card):
	if state == StatesEnum.DRAWING:
		return
	if card in cardsSelected:
		return
	
	cardsSelected.append(card)
	card.select()
	
	if state == StatesEnum.DISCARDING and len(cardsSelected) > 1:
		card_deselect(cardsSelected[0])

func card_deselect(card: Card):
	if card not in cardsSelected:
		return
	cardsSelected.erase(card)
	card.deselect()
	pass

func _on_deck_drawing(deck: DeckClass):
	var drawen_joker: bool = deck.draw_card()
	if not drawen_joker:
		state = StatesEnum.DISCARDING
	else:
		state = StatesEnum.MELDING
	emit_signal("state_change", state)

func _on_discard_pressed(discardButton: DiscardButton):
	if state != StatesEnum.DISCARDING or not cardsSelected:
		return
	
	state = StatesEnum.DRAWING
	var card: Card = cardsSelected.pop_front()
	var card_pos = card.global_position
	card.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	if card.get_parent() != null:
		card.get_parent().remove_child(card)
	discardButton.add_child(card)
	card.global_position = card_pos
	
	discardButton.set_sprite(card.value, card.suit)
	cardsSelected.erase(card)
	
	card.move_to(Vector2.ZERO, 1.5)
	# Queue for deletion
	#card.queue_free()
	
	emit_signal("state_change", state)
