class_name MainMenu extends Control

@export
var evo_button : Button
var evo_screen : PackedScene = preload("res://Scenes/UI/EvolutionScreen.tscn")

@export
var saved_button : Button
var saved_scene : PackedScene = preload("res://Scenes/UI/SavedGrammars.tscn")

func _ready() -> void:
	evo_button.pressed.connect(_on_evo_button_pressed)
	saved_button.pressed.connect(_on_saved_button_pressed)

func _on_evo_button_pressed():
	var evo_scene = evo_screen.instantiate()
	get_tree().root.add_child(evo_scene)
	clean_up()

func _on_saved_button_pressed():
	var saved = saved_scene.instantiate()
	get_tree().root.add_child(saved)
	clean_up()

func clean_up():
	$VBoxContainer.hide()
