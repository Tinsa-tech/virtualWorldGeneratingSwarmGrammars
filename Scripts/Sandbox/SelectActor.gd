class_name SelectActor extends Control

@export
var vsg_list : VBoxContainer
var vsg_container_scene : PackedScene = preload("res://Scenes/Sandbox/VsgToLoad.tscn")

@export
var add_button : Button

@export
var saved_grammars : SavedGrammars
@export
var swarm_scene : SwarmScene

@export
var subviewport : SubViewportContainer

var data : Database

var type_names : Array[String] = []

var selection : Selection

@export
var back_button : Button

func _ready() -> void:
	
	data = Database.new()
	add_button.pressed.connect(_on_add_button_pressed)
	saved_grammars.loaded.connect(_on_vsg_loaded)
	saved_grammars.hide_on_back = true
	back_button.pressed.connect(_on_back_button_pressed)
	
	subviewport.focus_entered.connect(_viewport_gets_focus)
	subviewport.focus_exited.connect(_viewport_looses_focus)
	
	swarm_scene.enable_camera()
	swarm_scene.has_focus = true
	swarm_scene.set_keep_running(true)

func _on_add_button_pressed():
	saved_grammars.show()
	saved_grammars.get_child(0).show()

func _on_vsg_loaded(vsg_loaded : Database, name_loaded : String):
	var vsg_container : VsgToLoad = vsg_container_scene.instantiate()
	vsg_list.add_child(vsg_container)
	
	
	type_names.clear()
	for template in data.templates:
		type_names.append(template.type)
	
	vsg_container.fill(vsg_loaded, name_loaded, type_names)
	vsg_container.actor_loaded.connect(_load_actor)
	saved_grammars.hide()
	data.add(vsg_loaded)
	data.first_generation.clear()
	data.colors.clear()
	data.create_colors()
	swarm_scene.new_data(data)
	swarm_scene.vsg.editable = true

func _load_actor(loaded_type : String):
	swarm_scene.add_actor(loaded_type)
	#loaded.selected.connect(selection.other_selected)
	#selection.other_selected(loaded)
	# swarm_scene.show_scene()

func _viewport_gets_focus():
	var sv : SubViewport = subviewport.get_child(0)
	sv.physics_object_picking = true

func _viewport_looses_focus():
	subviewport.get_child(0).physics_object_picking = false

func _on_back_button_pressed():
	SceneManager.get_instance().back()
