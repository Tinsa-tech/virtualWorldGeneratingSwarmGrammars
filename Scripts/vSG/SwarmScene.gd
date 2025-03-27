class_name SwarmScene extends Node3D

var vsg : vSG

@export
var hud : HUD
@export
var parent : Node3D

@export
var camera : FreeLookCamera
var should_play : bool = false
var should_step : bool = false

@export
var swarm_info : SwarmInfo

var keep_running : bool = false

var agents_hidden : bool = false
var artifacts_hidden : bool = false
var connections_hidden : bool = false
var terrain_hidden : bool = false

var has_focus : bool = true

func _ready() -> void:
	camera.active = false
	

func _process(delta: float) -> void:
	if !should_play and !should_step:
		return
	if !vsg:
		print("vsg not initialized yet!")
		return
	if vsg.finished:
		return
	vsg.step()
	should_step = false

func play():
	should_play = !should_play

func step():
	should_step = true

func end():
	vsg.clean_up()

func _input(event: InputEvent) -> void:
	if !has_focus:
		return
	
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			should_play = !should_play
		elif event.keycode == KEY_RIGHT:
			should_step = true
		elif event.keycode == KEY_ESCAPE:
			toggle_info()
		elif event.keycode == KEY_G:
			toggle_agents()
		elif event.keycode == KEY_F:
			toggle_artifacts()
		elif event.keycode == KEY_C:
			toggle_connections()
		elif event.keycode == KEY_T:
			toggle_terrain()
		elif event.keycode == KEY_R:
			restart_swarm()

func disable_camera():
	camera.active = false

func enable_camera():
	camera.active = true

func set_vsg(to_set : vSG):
	vsg = to_set

func init_vsg(database : Database):
	for child in parent.get_children():
		child.queue_free()
	if vsg:
		swarm_info.clear()
	vsg = vSG.new(database, camera, parent, hud)
	vsg.keep_running = keep_running
	swarm_info.set_data(database)
	swarm_info.lock()

func new_data(database : Database):
	if vsg:
		vsg.database = database
	else:
		vsg = vSG.new(database, camera, parent, hud)
	vsg.keep_running = keep_running
	swarm_info.set_data(database)
	swarm_info.lock()

func save(save_path):
	vsg.database.save_data(save_path)

func toggle_info():
	if swarm_info.visible == true:
		swarm_info.hide()
		hud.show()
	else:
		swarm_info.show()
		hud.hide()

func add_actor(type : String):
	should_play = false
	vsg.add_actor(type)

func hide_scene():
	self.hide()
	hud.hide()

func show_scene():
	self.show()
	hud.show()

func set_keep_running(new_value : bool):
	keep_running = new_value

func toggle_agents():
	if agents_hidden:
		vsg.show_agents()
	else:
		vsg.hide_agents()
	agents_hidden = !agents_hidden
	
func toggle_artifacts():
	if artifacts_hidden:
		vsg.show_artifacts()
	else:
		vsg.hide_artifacts()
	artifacts_hidden = !artifacts_hidden

func toggle_connections():
	if connections_hidden:
		vsg.show_connections()
	else:
		vsg.hide_connections()
	connections_hidden = !connections_hidden

func toggle_terrain():
	if terrain_hidden:
		vsg.show_terrain()
	else:
		vsg.hide_terrain()
	terrain_hidden = !terrain_hidden

func restart_swarm():
	vsg.restart_swarm()

func hide_controls():
	hud.hide_controls()

func show_controls():
	hud.show_controls()
