class_name EvolutionScreen extends Control

var evo_element : PackedScene = preload("res://Scenes/UI/EvolutionElement.tscn")

@export
var grid_container : GridContainer

@export
var play_button : Button
var is_playing : bool = false
@export
var step_button : Button

var vsgs : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	play_button.pressed.connect(_on_play_button_pressed)
	step_button.pressed.connect(_on_step_button_pressed)
	
	for i in range(10):
		var evo = evo_element.instantiate()
		grid_container.add_child(evo)
		vsgs.append(evo)
	
func _on_play_button_pressed():
	for vsg in vsgs:
		vsg._on_play_button_pressed()
	if is_playing:
		play_button.text = "Play"
	else:
		play_button.text = "Pause"
	is_playing = !is_playing

func _on_step_button_pressed():
	for vsg in vsgs:
		vsg._on_step_button_pressed()
