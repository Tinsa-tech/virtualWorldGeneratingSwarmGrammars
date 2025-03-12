class_name MainMenu extends Control

@export
var evo_button : Button
var evo_screen : PackedScene = preload("res://Scenes/UI/EvolutionScreen.tscn")

func _ready() -> void:
	evo_button.pressed.connect(_on_evo_button_pressed)

func _on_evo_button_pressed():
	var evo_scene = evo_screen.instantiate()
	get_tree().root.add_child(evo_scene)
	$VBoxContainer/Evolution.queue_free()
	$VBoxContainer.queue_free()
