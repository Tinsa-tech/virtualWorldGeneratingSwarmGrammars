class_name VsgToLoad extends VBoxContainer

@export
var agent_list : VBoxContainer

@export
var label : Label

@export
var artifact_list : VBoxContainer

var load_actor : PackedScene = preload("res://Scenes/Sandbox/LoadActor.tscn")

signal actor_loaded(type)

func fill(database : Database, save_name : String, type_names : Array[String]):
	label.text = save_name
	for template in database.templates:
		if template is AgentTemplate:
			var la : LoadActor = load_actor.instantiate()
			var type = template.type
			la.set_label(type)
			while type_names.has(type):
				type = type + "double"
			la.set_type(type)
			agent_list.add_child(la)
			la.load_actor.connect(_on_actor_load)
		else:
			var la : LoadActor = load_actor.instantiate()
			var type = template.type
			la.set_label(type) 
			while type_names.has(type):
				type = type + "double"
			la.set_type(type)
			artifact_list.add_child(la)
			la.load_actor.connect(_on_actor_load)

func _on_actor_load(type : String):
	actor_loaded.emit(type)
