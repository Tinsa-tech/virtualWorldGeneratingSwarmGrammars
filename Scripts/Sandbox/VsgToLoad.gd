class_name VsgToLoad extends VBoxContainer

@export
var agent_list : VBoxContainer

@export
var label : Label

@export
var artifact_list : VBoxContainer

var load_actor : PackedScene = preload("res://Scenes/Sandbox/LoadActor.tscn")

func fill(database : Database, save_name : String):
	label.text = save_name
	for template in database.templates:
		if template is AgentTemplate:
			var la : LoadActor = load_actor.instantiate()
			la.label.text = template.type
			agent_list.add_child(la)
			la.load_actor.connect(_on_actor_load)
		else:
			var la : LoadActor = load_actor.instantiate()
			la.label.text = template.type
			artifact_list.add_child(la)
			la.load_actor.connect(_on_actor_load)

func _on_actor_load(type : String):
	pass
