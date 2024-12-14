class_name Card
extends Container


@onready var Sprite: Sprite2D = $Sprite
@onready var Anim = $Anim
@onready var ClickCD = $ClickCD

const SuitEnum = preload("res://SuitEnum.gd").Suit
var value: int = 1
var suit: SuitEnum = SuitEnum.Spades

const CardStateEnum = {
	NONE = 0,
	SELECTED = 1,
	HOVER = 2,
}
var state = CardStateEnum.NONE
var previous_state = CardStateEnum.NONE

var orig_position_x = 0

signal card_select(Card)
signal card_deselect(Card)
signal card_hover_end(Card)

signal card_swap(Card, int)

var SHORT_CLICK_THREASHOLD: float = 0.1
var click_timer: float = 0.0
@export var HOVER_OFFSET: Vector2 = Vector2(-64, -90)

# Called when the node enters the scene tree for the first time.
func _ready():
	var board: Board = get_tree().get_first_node_in_group("Board")
	var hand: HandContainer = get_tree().get_first_node_in_group("Hand")
	if board != null:
		# Connect signals to the main script
		self.card_select.connect(board.card_select.bind(self))
		self.card_deselect.connect(board.card_deselect.bind(self))
	if hand != null:
		self.card_swap.connect(hand.swap)
		self.card_hover_end.connect(hand._on_child_entered_tree.bind(self))
	
	Sprite.frame_coords = Vector2i(self.value-1, self.suit-1)


func setup(new_suit: SuitEnum, new_value: int):
	self.value = new_value
	self.suit = new_suit

func _on_gui_input(event):
	if not ClickCD.is_stopped() or self.position.y < 0:
		return
	if Input.is_action_just_pressed("click") \
	and state != CardStateEnum.HOVER:
		click_timer = 0.0
	
	if Input.is_action_pressed("click"):
		if state != CardStateEnum.HOVER:
			click_timer += get_process_delta_time()
			if click_timer > SHORT_CLICK_THREASHOLD:
				start_hover()
			return
	
	if Input.is_action_just_released("click"):
		if click_timer > SHORT_CLICK_THREASHOLD or self.value == 14:
			end_hover()
			return
		ClickCD.start()
		if state == CardStateEnum.NONE:
			emit_signal("card_select")
		else:
			emit_signal("card_deselect")
	
	if event is InputEventMouseMotion \
	and state == CardStateEnum.HOVER:
		#position.y = position.y - 80
		global_position.x = get_global_mouse_position().x + HOVER_OFFSET.x
		
		if position.x < orig_position_x - 0.7 * Sprite.get_rect().size.x:
			emit_signal("card_swap", self, -1)
		elif position.x > orig_position_x + 0.7 * Sprite.get_rect().size.x:
			emit_signal("card_swap", self, 1)
			pass
		
		pass

func start_hover():
	#emit_signal("card_deselect")
	previous_state = state
	state = CardStateEnum.HOVER
	orig_position_x = position.x
	
	Sprite.z_index = 10
	if previous_state == CardStateEnum.NONE:
		var tween: Tween = create_tween()
		var duration = 0.08
		tween.tween_property(Sprite, "offset", Vector2(0, HOVER_OFFSET.y), duration)
	#Sprite.position.y = HOVER_OFFSET.y

func end_hover():
	state = previous_state
	emit_signal("card_hover_end")
	
	Sprite.z_index = 0
	if previous_state == CardStateEnum.NONE:
		var tween: Tween = create_tween()
		var duration = 0.08
		tween.tween_property(Sprite, "offset", Vector2.ZERO, duration)
	#Sprite.position.y = 96

func select():
	self.state = CardStateEnum.SELECTED
	Anim.play("Select")
	pass

func deselect():
	self.state = CardStateEnum.NONE
	Anim.play_backwards("Select")
	pass

func move_to(new_position: Vector2, speed_mult: float = 1):
	var tween: Tween = create_tween()
	var duration = 0.3 / speed_mult
	tween.tween_property(self, "position", new_position, duration)
