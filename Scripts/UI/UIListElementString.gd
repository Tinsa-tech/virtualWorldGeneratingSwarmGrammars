class_name UIListElementString extends UIListElement

var value : String

@export
var input : LineEdit
@export
var label : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	if !input:
		for child in get_children():
			if child is LineEdit:
				input = child
	input.text_changed.connect(_text_changed)
	
	if !label:
		for child in get_children():
			if child is Label:
				label = child

func _text_changed(new_text : String):
	value = new_text

func set_index(new_index : int):
	super.set_index(new_index)
	label.text = str(new_index) + ": "

func set_value(new_value : String):
	value = new_value
	input.text = new_value

func lock():
	input.editable = false
	super.lock()

func unlock():
	input.editable = true
	super.unlock()
