class_name EvoElement extends Control

@export
var viewport : SubViewportContainer

@export
var slider : HSlider
@export
var label : Label
var rating : float

@export
var swarm_scene : SwarmScene

@export
var panel : Panel
@export
var play : Button
@export
var step : Button
@export
var end : Button
var is_playing : bool = false

func _ready() -> void:
	swarm_scene.disable_camera()
	
	play.pressed.connect(_on_play_button_pressed)
	step.pressed.connect(_on_step_button_pressed)
	end.pressed.connect(_on_end_button_pressed)

	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Control.focus_entered.connect(_on_focus_entered)
	play.focus_entered.connect(_on_focus_entered)
	step.focus_entered.connect(_on_focus_entered)
	end.focus_entered.connect(_on_focus_entered)
	viewport.focus_entered.connect(_on_focus_entered)
	slider.focus_entered.connect(_on_focus_entered)
	label.focus_entered.connect(_on_focus_entered)
	
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Control.focus_exited.connect(_on_focus_exited)
	play.focus_exited.connect(_on_focus_exited)
	step.focus_exited.connect(_on_focus_exited)
	end.focus_exited.connect(_on_focus_exited)
	viewport.focus_exited.connect(_on_focus_exited)
	slider.focus_exited.connect(_on_focus_exited)
	label.focus_exited.connect(_on_focus_exited)
	
	slider.value_changed.connect(_on_slider_value_changed)
	



func set_viewport_size(new_size : Vector2i):
	viewport.size = new_size

func _on_slider_value_changed(new_value : float):
	label.text = str(new_value)
	rating = new_value

func _on_focus_entered():
	swarm_scene.enable_camera()
	var stylebox : StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color.DIM_GRAY
	panel.add_theme_stylebox_override("panel", stylebox)

func _on_focus_exited():
	swarm_scene.disable_camera()
	var stylebox : StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color(.2, .2, .2, 1)
	panel.add_theme_stylebox_override("panel", stylebox)

func _on_play_button_pressed():
	swarm_scene.play()
	if is_playing:
		play.text = "Play"
	else:
		play.text = "Pause"
	is_playing = !is_playing

func _on_step_button_pressed():
	swarm_scene.step()

func _on_end_button_pressed():
	swarm_scene.end()
