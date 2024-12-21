extends Node
class_name Board

var cardsSelected: Array[Card] = []

const STATES = preload("res://StatesEnum.gd").State
var state = STATES.DISCARDING

signal state_change(state)
signal change_cards_selected(num: int)

# Control nodes
@onready var deckControl: DeckControl = $Deck
@onready var meldsContainer: MeldsControl = $Melds
@onready var handContainer: HandControl = $Hand
@onready var animPlayer: AnimationPlayer = $Overlay/Anim
@onready var endgameLabel: Label = $Overlay/TextLabel

# Interactable nodes
@onready var meldButton: MeldButton = $MeldButton
@onready var discardButton: DiscardButton = $DiscardButton

func _ready():
	Input.emulate_mouse_from_touch = true
	state_change.emit(state)

func card_select(card: Card):
	if card in cardsSelected:
		return
	
	cardsSelected.append(card)
	change_cards_selected.emit(len(cardsSelected))

func card_deselect(card: Card):
	if card not in cardsSelected:
		return
	cardsSelected.erase(card)
	change_cards_selected.emit(len(cardsSelected))


func _on_discard_pressed():
	if state == STATES.MELDING_ONLY or not cardsSelected:
		return

	var card: Card = cardsSelected.pop_front()
	card.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	card.reparent(discardButton)
	card.move_to(Vector2(200, -500), 1.5)
	
	var is_joker_next: bool = deckControl.draw_card()
	if is_joker_next:
		state = STATES.MELDING_ONLY
		meldsContainer.check_endgame()
	state_change.emit(state)
	change_cards_selected.emit(0)


func _on_meld_pressed():
	if not cardsSelected:
		return
	
	if meldsContainer.add_set(cardsSelected):
		for card in cardsSelected:
			card.reparent(meldsContainer)
			card.move_to(Vector2.ZERO)
		cardsSelected.clear()
		handContainer._on_child_order_changed()
	
	if state == STATES.MELDING_ONLY or handContainer.get_child_count() < 1:
		meldsContainer.check_endgame()
	
	for card in cardsSelected:
		card.deselect(false)
	cardsSelected.clear()
	change_cards_selected.emit(0)


func _on_end_checked(win):
	print('Win? ', win)
	
	if win:
		endgameLabel.text = "Výhra!"
	else:
		endgameLabel.text = "Prohra"
	animPlayer.play("Fadeout")
	
	pass # Replace with function body.
