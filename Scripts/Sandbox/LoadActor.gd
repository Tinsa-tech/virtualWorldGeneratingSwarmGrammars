class_name LoadActor extends HBoxContainer

@export
var label : Label

@export
var load_button : Button

signal load_actor(text)

func _ready() -> void:
	load_button.pressed.connect(_on_load_button_pressed)

func _on_load_button_pressed():
	load_actor.emit(label.text)
