extends Control
class_name MeldsControl

const STATES = preload("res://StatesEnum.gd").State
const SUITS = preload("res://SuitEnum.gd").Suit
var all_melds: Array = []

@onready var HandObj: HandControl = get_tree().get_first_node_in_group("Hand")

signal on_end_checked(win: bool)

func add_set(meld: Array[Card]) -> bool:
	if not is_valid_meld(meld):
		return false
	
	all_melds.append(meld)
	return true

func is_valid_meld(meld: Array[Card]) -> bool:
	if len(meld) < 3: 
		return false
	
	var simple_list = meld.map(func(x: Card): return {"value": x.value, "suit": x.suit})
	return self._is_set(simple_list.duplicate()) or self._is_run(simple_list.duplicate())

func _is_set(meld: Array) -> bool:
	var base_card = meld.pop_front()
	for card in meld:
		if card.value != base_card.value:
			return false
	return true


func _sort_cards(a, b) -> bool:
	if a.suit * 100 + a.value < b.suit * 100 + b.value:
		return true
	return false


func _is_run(meld: Array) -> bool:
	meld.sort_custom(_sort_cards)
	if meld[0].value == 1 and meld[len(meld)-1].value == 13:
		meld[0].value = 14
		meld.sort_custom(_sort_cards)
		pass
	
	var previous_card = meld.pop_front()
	
	for card in meld:
		if abs(card.value - previous_card.value) != 1 \
		or card.suit != previous_card.suit:
			return false
		previous_card = card
	return true

func check_endgame(state: STATES) -> bool:
	var cards_left: Array[Card] = HandObj.get_cards()
	if len(cards_left) < 1:
		on_end_checked.emit(true)
		return true
	elif len(cards_left) < 3:
		on_end_checked.emit(false)
		return true
	
	if state != STATES.MELDING_ONLY:
		return false
	
	cards_left.sort_custom(_sort_cards)
	var simple_list: Array = cards_left.map(func(x: Card): return {"value": x.value, "suit": x.suit})
	# Add num 14 Aces
	for x in simple_list:
		if x.value == 1:
			simple_list.append({"value": 14, "suit": x.suit})
	
	
	# Check if there's Run
	var val: int = simple_list[0].value
	var suit: int = simple_list[0].suit
	var count: int = 1
	
	for i in range(1, len(simple_list)):
		if suit != simple_list[i].suit or val+1 != simple_list[i].value:
			val = simple_list[i].value
			suit = simple_list[i].suit
			count = 1
			continue
		val = simple_list[i].value
		count += 1
		if count >= 3:
			return false
	
	# Check if there's Set
	simple_list.sort_custom(func(a, b): return a.value < b.value)
	val = simple_list[0].value
	count = 1
	
	for i in range(1, len(simple_list)):
		if val != simple_list[i].value:
			val = simple_list[i].value
			count = 1
			continue
		count += 1
		if count >= 3:
			return false
	
	on_end_checked.emit(false)
	return true
