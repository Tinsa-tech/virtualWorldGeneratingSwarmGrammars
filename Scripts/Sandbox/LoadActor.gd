class_name LoadActor extends HBoxContainer

@export
var label : Label

var type : String

@export
var load_button : Button

signal load_actor(text)

func _ready() -> void:
	load_button.pressed.connect(_on_load_button_pressed)

func set_type(new_type : String):
	type = new_type

func set_label(text : String):
	label.text = text

func _on_load_button_pressed():
	load_actor.emit(type)
