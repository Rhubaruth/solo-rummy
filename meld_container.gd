extends Control
class_name MeldsControl

const StatesEnum = preload("res://StatesEnum.gd").State
var all_melds: Array = []

func add_set(meld: Array[Card]):
	if not _is_valid_meld(meld):
		return false
	
	all_melds.append(meld)
	
	return true

func _is_valid_meld(meld: Array[Card]) -> bool:
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
	if a.value < b.value or a.suit < b.suit:
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
