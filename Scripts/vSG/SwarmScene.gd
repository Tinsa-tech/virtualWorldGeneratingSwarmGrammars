class_name SwarmScene extends Node3D

var vsg : vSG

@export
var hud : SwarmHUD
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

var selection : Selection

func _ready() -> void:
	selection = Selection.new()
	selection.selection_changed.connect(_on_selection_changed)
	selection.moved.connect(hud._on_selected_position_changed)
	hud.position_changed.connect(selection.move)
	
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
	_on_finished(vSG.finish_code.MANUAL)

func _input(event: InputEvent) -> void:
	if !has_focus:
		return
	
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			should_play = !should_play
		elif event.keycode == KEY_P:
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
		elif event.keycode == KEY_H:
			toggle_controls()

func disable_camera():
	camera.active = false

func enable_camera():
	camera.active = true

func set_vsg(to_set : vSG):
	if vsg:
		vsg.on_finished.disconnect(_on_finished)
		vsg.actor_added.disconnect(_on_actor_added)
	
	vsg = to_set
	
	if agents_hidden:
		vsg.hide_agents()
	if artifacts_hidden:
		vsg.hide_artifacts()
	if connections_hidden:
		vsg.hide_connections()
	if terrain_hidden:
		vsg.hide_terrain()
	
	vsg.keep_running = keep_running
	
	vsg.on_finished.connect(_on_finished)
	vsg.actor_added.connect(_on_actor_added)
	
	for actor in vsg.actors:
		actor.selected.connect(selection.other_selected)

func init_vsg(database : Database):
	
	for child in parent.get_children():
		child.queue_free()
	if vsg:
		swarm_info.clear()
	hud.clear()
	vsg = vSG.new(database, camera, parent, hud)
	
	if agents_hidden:
		vsg.hide_agents()
	if artifacts_hidden:
		vsg.hide_artifacts()
	if connections_hidden:
		vsg.hide_connections()
	if terrain_hidden:
		vsg.hide_terrain()
	
	vsg.keep_running = keep_running
	
	vsg.on_finished.connect(_on_finished)
	vsg.actor_added.connect(_on_actor_added)
	
	for actor in vsg.actors:
		actor.selected.connect(selection.other_selected)
	
	swarm_info.set_data(database)
	swarm_info.lock()

func new_data(database : Database):
	if vsg:
		vsg.database = database
	else:
		vsg = vSG.new(database, camera, parent, hud)
		vsg.on_finished.connect(_on_finished)
		vsg.actor_added.connect(_on_actor_added)
	
	vsg.keep_running = keep_running
	swarm_info.clear_ui()
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

func toggle_controls():
	hud.toggle_controls()

func restart_swarm():
	new_data(swarm_info.gather_data())
	hud.clear()
	vsg.restart_swarm()
	

func hide_controls():
	hud.hide_controls()

func show_controls():
	hud.show_controls()

func _on_finished(finish_reason : int):
	hud.set_finish_reason(finish_reason)

func _on_selection_changed(selected : ActorObject):
	var template : ActorTemplate
	for t in vsg.database.templates:
		if t.type == selected.actor.type:
			template = t
	hud.on_selected(selected, template)

func _on_actor_added(added : ActorObject):
	added.selected.connect(selection.other_selected)

func unlock_seed():
	swarm_info.unlock_seed()
