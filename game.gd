extends Node
class_name Board

var cardsSelected: Array[Card] = []

const StatesEnum = preload("res://StatesEnum.gd").State
var state = StatesEnum.DISCARDING

signal state_change(state)

@onready var meldsContainer: MeldsControl = $Melds
@onready var handContainer: HandContainer = $Hand

func _ready():
	Input.emulate_mouse_from_touch = true
	state_change.emit(state)

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
		state = StatesEnum.MELDING_END
	state_change.emit(state)

func _on_discard_pressed(discardButton: DiscardButton):
	if state != StatesEnum.DISCARDING or not cardsSelected:
		return
	
	state = StatesEnum.DRAWING
	var card: Card = cardsSelected.pop_front()
	var card_pos = card.global_position
	card.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	card.reparent(discardButton)
	card.global_position = card_pos
	
	cardsSelected.erase(card)
	
	card.move_to(Vector2.ZERO, 1.5)
	
	emit_signal("state_change", state)


func _on_meld_button_toggled(toggled_on):
	if state == StatesEnum.MELDING_END:
		_meld_end()
		return
	if toggled_on:
		_meld_start()
		return
	_meld_end()
	pass # Replace with function body.

func _meld_start():
	state = StatesEnum.MELDING
	state_change.emit(state)
	pass # Replace with function body.

func _meld_end():
	if state == StatesEnum.MELDING:
		state = StatesEnum.DISCARDING
		state_change.emit(state)
	elif state != StatesEnum.MELDING_END:
		return
	
	if not cardsSelected:
		return
	
	if meldsContainer.add_set(cardsSelected):
		for card in cardsSelected:
			card.reparent(meldsContainer)
			card.move_to(Vector2.ZERO)
		
	for card in cardsSelected:
		card.deselect()
	cardsSelected.clear()
