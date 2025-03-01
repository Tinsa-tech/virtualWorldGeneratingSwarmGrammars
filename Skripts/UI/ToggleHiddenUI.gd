class_name ToggleHiddenUI extends Node

@export
var hidden : bool = true
@export
var to_toggle : Control
@export
var toggle_button : Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !toggle_button:
		print("toggle button not set in ToggleHiddenUI in " + name)
	else:
		toggle_button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	if hidden:
		to_toggle.show()
		hidden = false
		toggle_button.text = "v"
	else:
		to_toggle.hide()
		hidden = true
		toggle_button.text = "<"
