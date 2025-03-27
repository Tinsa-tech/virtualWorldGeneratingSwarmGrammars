class_name StringValueUI extends Node

@export
var line_edit : LineEdit

var value : String
signal value_changed(new_value : String)

func _ready() -> void:
	if !line_edit:
		for child in get_children():
			if child is LineEdit:
				line_edit = child
	line_edit.text_changed.connect(_on_text_changed)

func _on_text_changed(new_text : String):
	value = new_text
	value_changed.emit(value)

func set_value(to_set : String):
	value = to_set
	line_edit.text = to_set

func lock():
	line_edit.editable = false

func unlock():
	line_edit.editable = true
