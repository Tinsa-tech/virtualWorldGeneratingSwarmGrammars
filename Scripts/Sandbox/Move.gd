class_name Move extends Node3D

@export
var x_arrow : StaticBody3D
@export
var y_arrow : StaticBody3D
@export
var z_arrow : StaticBody3D

@export
var to_move : Node3D


var camera : Camera3D

var drag_x : bool = false
var drag_y : bool = false
var drag_z : bool = false

signal moved(new_pos)
signal clicked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !camera:
		var q : Array = [get_tree().root]
		while !q.is_empty():
			var node : Node = q.pop_front()
			if node is Camera3D:
				camera = node
				break
			q.append_array(node.get_children())


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var dist_to_camera = (self.get_child(0).position - camera.position).length() / 300

		var world_dir = Vector3(event.screen_relative.x, -event.screen_relative.y, 0)
		world_dir = camera.transform * world_dir
		world_dir -= camera.position
		
		if drag_x == true:
			to_move.global_translate(Vector3.RIGHT * world_dir.x * dist_to_camera)
		
		if drag_y == true:
			to_move.global_translate(Vector3.UP * world_dir.y * dist_to_camera)
		
		if drag_z == true:
			to_move.global_translate(Vector3.FORWARD * -world_dir.z * dist_to_camera)
		
		if drag_x or drag_y or drag_z:
			moved.emit(to_move.global_position)
		
		clicked.emit()
		
	if event is InputEventMouseButton:
		if event.is_released():
			drag_x = false
			drag_y = false
			drag_z = false

func _on_x_arrow_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				clicked.emit()
				drag_x = true

func _on_y_arrow_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				clicked.emit()
				drag_y = true

func _on_z_arrow_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				clicked.emit()
				drag_z = true
	
