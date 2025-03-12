class_name FloatValueUI extends Node

@export
var slider : HSlider
@export
var input : LineEdit

var value : float = 0.0
signal value_changed(new_value : float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !slider:
		for child in get_children():
			if child is HSlider:
				slider = child
				slider.value_changed.connect(_on_slider_moved)
	else:
		slider.value_changed.connect(_on_slider_moved)
	
	if !input:
		for child in get_children():
			if child is LineEdit:
				input = child
				input.text_changed.connect(_on_line_edit_changed)
	else:
		input.text_changed.connect(_on_line_edit_changed)

func _on_slider_moved(new_value : float):
	value = new_value
	input.text = str(new_value)

func _on_line_edit_changed(new_text : String):
	value = float(new_text)
	slider.set_value_no_signal(value)
	value_changed.emit(value)

func set_value(to_set : float):
	value = to_set
	slider.set_value_no_signal(to_set)
	input.text = str(to_set)
	
