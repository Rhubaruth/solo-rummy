extends Control
class_name DeckClass

const StatesEnum = preload("res://StatesEnum.gd").State
const SuitEnum = preload("res://SuitEnum.gd").Suit
var deck: Array[Card] = []

var card_tscn = preload("res://card.tscn")
@export_node_path("Control") var handContainerPath
var handContainer: Control

signal drawing

# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.global_position)
	handContainer = get_node(handContainerPath)
	if handContainer == null:
		push_error("handContainer not selected")
	
	var card: Card
	# Create deck
	for suit in SuitEnum:
		for value in range(1, 14):
			card = card_tscn.instantiate()
			card.setup(SuitEnum[suit], value)
			deck.append(card)
	
	deck.shuffle()
	for i in range(12):
		draw_card()
	
	var joker_position = randi_range(10, len(deck)-2)
	card = card_tscn.instantiate()
	card.setup(SuitEnum.Spades, 14)
	deck.insert(joker_position, card)
	

func draw_card() -> bool:
	if len(deck) < 1:
		return true
	var card: Card = deck.pop_front()
	handContainer.add_child(card)
	card.global_position = global_position
	return card.value == 14

func _on_board_state_change(state):
	if state == StatesEnum.DRAWING:
		drawing.emit(self)
	pass # Replace with function body.
