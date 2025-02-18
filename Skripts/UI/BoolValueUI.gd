class_name BoolValueUI extends Node

@export
var check_button : CheckButton

var value : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !check_button:
		for child in get_children():
			if child is CheckButton:
				check_button = child
				check_button.toggled.connect(_on_button_toggled)
	else:
		check_button.toggled.connect(_on_button_toggled)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_toggled(new_value : bool):
	value = new_value

func set_value(to_set : bool):
	value = to_set
	check_button.set_pressed_no_signal(to_set)
