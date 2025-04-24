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
var controls_hidden = false

@export
var selected_name : Label
@export
var position_x : LineEdit
@export
var position_y : LineEdit
@export
var position_z : LineEdit
@export
var details_agent : AgentUI
@export
var details_artifact : ArtifactUI

@export
var arrow_button : Button
@export
var info : PanelContainer
var info_hidden = true
var pos = Vector3.ZERO

signal position_changed(position : Vector3)

func _ready() -> void:
	arrow_button.pressed.connect(_on_arrow_pressed)
	
	position_x.text_changed.connect(_on_pos_x_changed)
	position_y.text_changed.connect(_on_pos_y_changed)
	position_z.text_changed.connect(_on_pos_z_changed)
	
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
			artifact_count.set("theme_override_colors/font_color", Color.RED)
		vSG.finish_code.TOO_MANY_STEPS:
			finish_reason.text = "Finished: Too many Steps"
			step_count.set("theme_override_colors/font_color", Color.RED)
		vSG.finish_code.MANUAL:
			finish_reason.text = "Finished: Stopped manually"

func hide_controls():
	controls.hide()

func show_controls():
	controls.show()

func toggle_controls():
	if controls_hidden:
		show_controls()
	else:
		hide_controls()
	controls_hidden = !controls_hidden

func _on_resize():
	var size = $MarginContainer.size
	var height = size.y
	var font_size = height / 50

func clear():
	agent_count.text = "0"
	agent_count.set("theme_override_colors/font_color", Color.WHITE)
	artifact_count.text = "0"
	artifact_count.set("theme_override_colors/font_color", Color.WHITE)
	step_count.text = "0"
	step_count.set("theme_override_colors/font_color", Color.WHITE)
	finish_reason.text = ""

func on_selected(selected : ActorObject, selected_template : ActorTemplate) -> void:
	details_agent.hide()
	details_artifact.hide()
	
	selected_name.text = selected.actor.type
	
	pos = selected.position
	position_x.text = str(pos.x)
	position_y.text = str(pos.y)
	position_z.text = str(pos.z)
	
	if selected.editable:
		position_x.editable = true
		position_y.editable = true
		position_z.editable = true
	else:
		position_x.editable = false
		position_y.editable = false
		position_z.editable = false
	
	if selected is AgentObject:
		details_agent.from_template(selected_template)
		details_agent.show()
	else:
		details_artifact.from_artifact(selected_template)
		details_artifact.show()

func _on_arrow_pressed():
	if info_hidden:
		info.show()
		arrow_button.text = ">"
		info_hidden = false
	else:
		info.hide()
		arrow_button.text = "<"
		info_hidden = true

func _on_pos_x_changed(new_x : String):
	pos = Vector3(float(new_x), pos.y, pos.z)
	position_changed.emit(pos)

func _on_pos_y_changed(new_y : String):
	pos = Vector3(pos.x, float(new_y), pos.z)
	position_changed.emit(pos)

func _on_pos_z_changed(new_z : String):
	pos = Vector3(pos.x, pos.y, float(new_z))
	position_changed.emit(pos)

func _on_selected_position_changed(new_pos : Vector3):
	pos = new_pos
	position_x.text = str(pos.x)
	position_y.text = str(pos.y)
	position_z.text = str(pos.z)
