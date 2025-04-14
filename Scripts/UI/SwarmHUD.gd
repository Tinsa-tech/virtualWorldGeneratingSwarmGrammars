class_name SwarmHUD extends CanvasLayer

@export
var agent_count : Label
@export
var artifact_count : Label
@export
var step_count : Label
@export
var finish_reason : Label

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

func set_step_count(count : int):
	step_count.text = str(count)

func set_finish_reason(reason : int):
	match reason:
		vSG.finish_code.AGENTS_DEAD:
			finish_reason.text = "Finished: All Agents died"
		vSG.finish_code.TOO_MANY_AGENTS:
			finish_reason.text = "Finished: Too many Agents"
			agent_count.set("theme_override_colors/font_color", Color.RED)
		vSG.finish_code.TOO_MANY_ARTIFACTS:
			finish_reason.text = "Finished: Too many Artifacts"
		vSG.finish_code.TOO_MANY_STEPS:
			finish_reason.text = "Finished: Too many Steps"
		vSG.finish_code.MANUAL:
			finish_reason.text = "Finished: Stopped manually"

func hide_controls():
	controls.hide()

func show_controls():
	controls.show()

func _on_resize():
	var size = $MarginContainer.size
	var height = size.y
	var font_size = height / 50

func clear():
	agent_count.text = "0"
	agent_count.set("theme_override_colors/font_color", Color.WHITE)
	artifact_count.text = "0"
	step_count.text = "0"
	finish_reason.text = ""
