extends Button
class_name DiscardButton

const StatesEnum = preload("res://StatesEnum.gd").State
const SuitEnum = preload("res://SuitEnum.gd").Suit

@onready var Sprite = $Sprite2D

signal discarding

func _ready():
	var board = get_tree().get_first_node_in_group("Board")
	if board == null:
		return
	
	self.pressed.connect(board._on_discard_pressed.bind(self))

func set_sprite(value: int, suit: SuitEnum):
	Sprite.frame_coords = Vector2i(value-1, suit-1)

func _on_board_state_change(state):
	if state == StatesEnum.DISCARDING:
		self.disabled = false
	else:
		self.disabled = true
