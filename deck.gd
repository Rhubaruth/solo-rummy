extends Control
class_name DeckControl

const STATES = preload("res://StatesEnum.gd").State
const SUITS = preload("res://SuitEnum.gd").Suit
var deck: Array[Card] = []

var card_tscn = preload("res://Card/card.tscn")

@onready var HandObj: Control = get_tree().get_first_node_in_group("Hand")
@onready var CardPreview: Sprite2D = $Sprite2D

@export var hand_size: int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	var card: Card
	# Create the deck
	for suit in SUITS:
		for value in range(1, 14):
			card = card_tscn.instantiate()
			card.setup(SUITS[suit], value)
			card.position = Vector2.ZERO
			deck.append(card)
	
	# Shuffle the deck
	deck.shuffle()
	var start_hand = deck.slice(0, hand_size)
	start_hand.sort_custom(_sort_cards)

	for i in range(hand_size):
		deck[0] = start_hand[i]
		draw_card()
	
	var joker_position = randi_range(10, len(deck)-2)
	#var joker_position = 5
	card = card_tscn.instantiate()
	card.setup(SUITS.Spades, 14)
	deck.insert(joker_position, card)
	

func _sort_cards(a, b) -> bool:
	if a.suit * 100 + a.value < b.suit * 100 + b.value:
		return true
	return false

func draw_card() -> bool:
	if len(deck) < 1:
		return true
	var card: Card = deck.pop_front()
	HandObj.add_child(card)
	card.global_position = self.global_position
	
	# Next card
	card = deck[0]
	CardPreview.frame_coords = Vector2i(card.value-1, card.suit-1)
	return card.value == 14
