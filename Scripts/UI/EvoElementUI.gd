class_name EvoElementUI extends Control

@export
var viewport : SubViewportContainer

@export
var slider : HSlider
@export
var label : Label

@export
var swarm_scene : SwarmScene

@export
var panel : Panel
@export
var play : Button
@export
var step : Button
@export
var save : Button
@export
var end : Button
var is_playing : bool = false

@export
var save_window : Window
@export
var line_edit : LineEdit
@export
var okay_button : Button

func _ready() -> void:
	play.pressed.connect(_on_play_button_pressed)
	step.pressed.connect(_on_step_button_pressed)
	end.pressed.connect(_on_end_button_pressed)
	save.pressed.connect(_on_save_button_pressed)

	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Control.focus_entered.connect(_on_focus_entered)
	play.focus_entered.connect(_on_focus_entered)
	step.focus_entered.connect(_on_focus_entered)
	end.focus_entered.connect(_on_focus_entered)
	save.focus_entered.connect(_on_focus_entered)
	viewport.focus_entered.connect(_on_focus_entered)
	slider.focus_entered.connect(_on_focus_entered)
	label.focus_entered.connect(_on_focus_entered)
	
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Control.focus_exited.connect(_on_focus_exited)
	play.focus_exited.connect(_on_focus_exited)
	step.focus_exited.connect(_on_focus_exited)
	end.focus_exited.connect(_on_focus_exited)
	save.focus_exited.connect(_on_focus_exited)
	viewport.focus_exited.connect(_on_focus_exited)
	slider.focus_exited.connect(_on_focus_exited)
	label.focus_exited.connect(_on_focus_exited)
	
	slider.value_changed.connect(_on_slider_value_changed)
	
	save_window.close_requested.connect(_window_close_requested)
	okay_button.pressed.connect(_on_okay_button_pressed)
	
	if !DirAccess.dir_exists_absolute("user://Saved"):
		DirAccess.make_dir_absolute("user://Saved")
	
	swarm_scene.has_focus = false

func set_viewport_size(new_size : Vector2i):
	viewport.size = new_size

func _on_slider_value_changed(new_value : float):
	label.text = str(new_value)

func _on_focus_entered():
	swarm_scene.enable_camera()
	var stylebox : StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color.GREEN
	panel.add_theme_stylebox_override("panel", stylebox)
	swarm_scene.has_focus = true

func _on_focus_exited():
	swarm_scene.disable_camera()
	var stylebox : StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = Color.DARK_GREEN
	panel.add_theme_stylebox_override("panel", stylebox)
	swarm_scene.has_focus = false

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

func _on_save_button_pressed():
	save_window.show()
	swarm_scene.hide_controls()

func init_vsg(database : Database):
	swarm_scene.init_vsg(database)

func _window_close_requested():
	line_edit.text = ""
	save_window.hide()
	swarm_scene.show_controls()

func _on_okay_button_pressed():
	var save_name = line_edit.text
	var image = viewport.get_child(0).get_texture().get_image()
	var save_path = "user://Saved/" + save_name
	image.save_png(save_path + "img.png")
	swarm_scene.save(save_path + ".json")
	_window_close_requested()
	
