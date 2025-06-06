class_name EvolutionScreen extends Control

var evo_element : PackedScene = preload("res://Scenes/UI/EvolutionElement.tscn")

@export
var grid_container : GridContainer

@export
var play_button : Button
var is_playing : bool = false
@export
var step_button : Button

@export
var generation_label : Label
var generation : int = 0

@export
var next_button : Button

@export
var back_button : Button

var vsgs : Array

var evolution : Evolution

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	play_button.pressed.connect(_on_play_button_pressed)
	step_button.pressed.connect(_on_step_button_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	evolution = Evolution.new()
	evolution.initialize_population(10)
	
	var show_controls = true
	for member : EvolutionElement in evolution.population:
		var em : EvoElementUI = evo_element.instantiate()
		grid_container.add_child(em)
		if show_controls:
			em.swarm_scene.show_controls()
			show_controls = false
		else:
			em.swarm_scene.hide_controls()
		em.init_vsg(member.genotypes)
		em.slider.value_changed.connect(member.set_fitness)
		vsgs.append(em)
	
	
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

func _on_next_button_pressed():
	var img = get_viewport().get_texture().get_image()
	
	img.save_png("res://Saved/Generation" + str(generation) + ".png")
	
	evolution.perform_cycle()
	for i in range(evolution.population.size()):
		var member : EvolutionElement = evolution.population[i]
		var vsg : EvoElementUI = vsgs[i]
		if i != 0:
			vsg.swarm_scene.hide_controls()
		vsg.init_vsg(member.genotypes)
		vsg.slider.value_changed.connect(member.set_fitness)
		vsg.slider.set_value(1)
	generation += 1
	generation_label.text = "Generation: " + str(generation)
		
func _on_back_button_pressed():
	SceneManager.get_instance().back()
