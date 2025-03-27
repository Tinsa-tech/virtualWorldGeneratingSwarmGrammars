class_name EnumValueUI extends Node

@export
var options_button : OptionButton

var enum_to_display : Dictionary
var value : int = 0

signal value_changed(new_value : int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# for test
	if !options_button:
		for child in get_children():
			if child is OptionButton:
				options_button = child
	options_button.item_selected.connect(_on_item_selected)

func _on_item_selected(index : int):
	value = index
	value_changed.emit(value)

func fill_options():
	for key in enum_to_display.keys():
		options_button.add_item(key, enum_to_display[key])

func set_value(to_set : int):
	value = to_set
	options_button.select(to_set)

func lock():
	options_button.disabled = true

func unlock():
	options_button.disabled = false
