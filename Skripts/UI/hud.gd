class_name HUD extends CanvasLayer

@export
var agent_count : Label
@export
var artifact_count : Label

func set_agent_count(count : int):
	agent_count.text = str(count)

func set_artifact_count(count : int):
	artifact_count.text = str(count)
