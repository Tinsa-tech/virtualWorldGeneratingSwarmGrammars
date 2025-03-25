class_name ActorObject extends Node3D

var actor : Actor

@export
var move : Move
var editable : bool = false
var q_hide : bool = false

@export
var static_body : StaticBody3D

signal destroyed
signal moved 

func _ready() -> void:
	static_body.input_event.connect(_on_static_body_3d_input_event)
	move.moved.connect(_on_moved)
	move.clicked.connect(interacted_with)

func _process(delta: float) -> void:
	if q_hide:
		move.hide()

func _on_destroyed():
	destroyed.emit()

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if !editable:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				q_hide = false
				move.show()

func _input(event: InputEvent) -> void:
	if !editable:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				q_hide = true
				#move.hide()

func interacted_with():
	q_hide = false

func _on_moved(new_pos : Vector3):
	actor.actor_position = new_pos 
	moved.emit()
