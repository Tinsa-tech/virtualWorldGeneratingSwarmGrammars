class_name HUD extends CanvasLayer

@export
var agent_count : Label
@export
var artifact_count : Label

@export
var controls : Control
@export
var control_text : Label

func _ready() -> void:
	$MarginContainer.resized.connect(_on_resize)
	var size = $MarginContainer.size
	var height = size.y
	var font_size = height / 50

func set_agent_count(count : int):
	agent_count.text = str(count)

func set_artifact_count(count : int):
	artifact_count.text = str(count)

func hide_controls():
	controls.hide()

func show_controls():
	controls.show()

func _on_resize():
	var size = $MarginContainer.size
	var height = size.y
	var font_size = height / 50
