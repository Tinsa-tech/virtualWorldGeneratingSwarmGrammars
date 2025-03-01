class_name ActorObject extends Node3D

var actor : Actor

signal destroyed

func _on_destroyed():
	destroyed.emit()
