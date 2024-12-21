class_name Card
extends Control


@onready var Sprite: Sprite2D = $Sprite
@onready var Anim = $Anim
@onready var ClickCD = $ClickCD

@onready var BoardObj: Board = get_tree().get_first_node_in_group("Board")
@onready var HandObj: HandControl = get_tree().get_first_node_in_group("Hand")

const SUITS = preload("res://SuitEnum.gd").Suit
var value: int = 1
var suit: SUITS = SUITS.Spades

const CARD_STATES = {
	NONE = 0,
	SELECTED = 1,
	HOVER = 2,
}
var state = CARD_STATES.NONE
var previous_state = CARD_STATES.NONE

var orig_position_x = 0

signal card_selected(Card)
signal card_deselected(Card)
signal card_hover_end(Card)

signal card_swaped(Card, int)

var SHORT_CLICK_THREASHOLD: float = 0.1
var click_timer: float = 0.0
@export var HOVER_OFFSET: Vector2 = Vector2(-64, -70)

# Called when the node enters the scene tree for the first time.
func _ready():
	if BoardObj != null:
		# Connect signals to the main script
		card_selected.connect(BoardObj.card_select.bind(self))
		card_deselected.connect(BoardObj.card_deselect.bind(self))
	if HandObj != null:
		# Connect signals to HandObj
		card_swaped.connect(HandObj.swap) # Swapping transition
		card_hover_end.connect(HandObj.move_to_place)	# Move into correct place after moving
	
	Sprite.frame_coords = Vector2i(self.value-1, self.suit-1)


func setup(new_suit: SUITS, new_value: int):
	self.value = new_value
	self.suit = new_suit

func _on_gui_input(event):
	if not ClickCD.is_stopped() or self.position.y < 0:
		return
	if Input.is_action_just_pressed("click") \
	and state != CARD_STATES.HOVER:
		click_timer = 0.0
	
	if Input.is_action_pressed("click"):
		if state != CARD_STATES.HOVER:
			click_timer += get_process_delta_time()
			if click_timer > SHORT_CLICK_THREASHOLD:
				start_hover()
			return
	
	if Input.is_action_just_released("click"):
		if click_timer > SHORT_CLICK_THREASHOLD or self.value == 14 \
		or state == CARD_STATES.HOVER:
			end_hover()
			return
		ClickCD.start()
		if self.state == CARD_STATES.NONE:
			self.select()
		else:
			self.deselect()
	
	if event is InputEventMouseMotion \
	and state == CARD_STATES.HOVER:
		#position.y = position.y - 80
		global_position.x = get_global_mouse_position().x + HOVER_OFFSET.x
		
		if position.x < orig_position_x - 0.7 * Sprite.get_rect().size.x:
			card_swaped.emit(self, -1)
		elif position.x > orig_position_x + 0.7 * Sprite.get_rect().size.x:
			card_swaped.emit(self, 1)
			pass
		
		pass

func start_hover():
	previous_state = state
	state = CARD_STATES.HOVER
	orig_position_x = position.x
	
	Sprite.z_index = 10
	if previous_state == CARD_STATES.NONE:
		var tween: Tween = create_tween()
		var duration = 0.08
		tween.tween_property(Sprite, "offset", Vector2(0, HOVER_OFFSET.y), duration)

func end_hover():
	state = previous_state
	card_hover_end.emit(self, get_index())
	
	Sprite.z_index = 0
	if previous_state == CARD_STATES.NONE:
		var tween: Tween = create_tween()
		var duration = 0.08
		tween.tween_property(Sprite, "offset", Vector2.ZERO, duration)

func select(emit: bool = true):
	self.state = CARD_STATES.SELECTED
	Anim.play("Select")
	if emit:
		card_selected.emit()

func deselect(emit: bool = true):
	self.state = CARD_STATES.NONE
	Anim.play_backwards("Select")
	if emit:
		card_deselected.emit()

func move_to(new_position: Vector2, speed_mult: float = 1):
	
	var tween: Tween = create_tween()
	var duration = 0.3 / speed_mult
	tween.tween_property(self, "position", new_position, duration)
