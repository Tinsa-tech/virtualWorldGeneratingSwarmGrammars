class_name SceneManager

static var instance : SceneManager

static func get_instance() -> SceneManager:
	if !instance:
		instance = SceneManager.new()
	return instance

var agent_scene : PackedScene = preload("res://Scenes/Agent.tscn")
var artifact_scene : PackedScene = preload("res://Scenes/Artifact.tscn")
var terrain_scene : PackedScene = preload("res://Scenes/Terrain.tscn")
var swarm_scene : PackedScene = preload("res://Scenes/SwarmScene.tscn")
var connector : PackedScene = preload("res://Scenes/Connector.tscn")

var swarm_creation : PackedScene = preload("res://Scenes/UI/SwarmCreation.tscn")
var sandbox : PackedScene = preload("res://Scenes/Sandbox/SelectActor.tscn")
var evolution : PackedScene = preload("res://Scenes/UI/EvolutionScreen.tscn")
var saved : PackedScene = preload("res://Scenes/UI/SavedGrammars.tscn")

enum Scenes {CREATION, SANDBOX, EVOLUTION, SAVED}

var scene_stack : Array[Node] = []
var current : Node

func back():
	var root = current.get_tree().root
	root.remove_child(current)
	current.queue_free()
	current = scene_stack.pop_back()
	root.add_child(current)

func go_to(scene : int):
	var inst : Node
	match scene:
		Scenes.CREATION:
			inst = swarm_creation.instantiate()
		Scenes.SANDBOX:
			inst = sandbox.instantiate()
		Scenes.EVOLUTION:
			inst = evolution.instantiate()
		Scenes.SAVED:
			inst = saved.instantiate()
			inst.hide_on_back = false
	
	scene_stack.append(current)
	var root = current.get_tree().root
	root.remove_child(current)
	root.add_child(inst)
	current = inst
	
	
