class_name SceneManager

static var instance : SceneManager

static func get_instance() -> SceneManager:
	if !instance:
		instance = SceneManager.new()
	return instance

var agent_scene : PackedScene = preload("res://Scenes/Agent.tscn")
var artifact_scene : PackedScene = preload("res://Scenes/Artifact.tscn")
var terrain_scene : PackedScene = preload("res://Scenes/Terrain.tscn")
var swarm_creation : PackedScene = preload("res://Scenes/UI/SwarmCreation.tscn")
var swarm_scene : PackedScene = preload("res://Scenes/SwarmScene.tscn")
