class_name SelectActor extends Control

@export
var vsg_list : VBoxContainer
var vsg_container_scene : PackedScene = preload("res://Scenes/Sandbox/VsgToLoad.tscn")

@export
var add_button : Button

@export
var saved_grammars : SavedGrammars

var data : Database

func _ready() -> void:
	data = Database.new()
	add_button.pressed.connect(_on_add_button_pressed)
	saved_grammars.loaded.connect(_on_vsg_loaded)

func _on_add_button_pressed():
	saved_grammars.show()
	saved_grammars.get_child(0).show()

func _on_vsg_loaded(vsg_loaded : Database, name_loaded : String):
	var vsg_container : VsgToLoad = vsg_container_scene.instantiate()
	vsg_container.fill(vsg_loaded, name_loaded)
	vsg_list.add_child(vsg_container)
	saved_grammars.hide()
	data.add(vsg_loaded)
