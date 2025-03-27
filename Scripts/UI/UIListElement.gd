class_name UIListElement extends Node

@export 
var delete_button : Button

var index : int

signal delete(index : int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	delete_button.pressed.connect(_on_delete_button_pressed)

func _on_delete_button_pressed():
	delete.emit(index)
	queue_free()

func set_index(new_index : int):
	index = new_index

func lock():
	delete_button.hide()

func unlock():
	delete_button.show()
