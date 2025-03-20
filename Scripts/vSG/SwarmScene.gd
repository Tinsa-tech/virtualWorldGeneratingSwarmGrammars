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
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			should_play = !should_play
		elif event.keycode == KEY_RIGHT:
			should_step = true
		elif event.keycode == KEY_ESCAPE:
			toggle_info()

func disable_camera():
	camera.active = false

func enable_camera():
	camera.active = true

func set_vsg(to_set : vSG):
	vsg = to_set

func init_vsg(database : Database):
	for child in parent.get_children():
		child.queue_free()
	vsg = vSG.new(database, camera, parent, hud)
	swarm_info.set_data(database)

func save(save_path):
	vsg.database.save_data(save_path)

func toggle_info():
	if swarm_info.visible == true:
		swarm_info.hide()
		hud.show()
	else:
		swarm_info.show()
		hud.hide()
