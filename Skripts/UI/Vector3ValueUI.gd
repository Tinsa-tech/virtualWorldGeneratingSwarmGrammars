class_name Vector3ValueUI extends Node

@export
var x : LineEdit
@export
var y : LineEdit
@export
var z : LineEdit

var value : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !x:
		print("x not set in Vector3ValueUI")
	if !y:
		print("y not set in Vector3ValueUI")
	if !z:
		print("z not set in Vector3ValueUI")
	
	x.text_changed.connect(_on_x_changed)
	y.text_changed.connect(_on_y_changed)
	z.text_changed.connect(_on_z_changed)

func _on_x_changed(new_value : String):
	value = Vector3(float(new_value), value.y, value.z)

func _on_y_changed(new_value : String):
	value = Vector3(value.x, float(new_value), value.z)

func _on_z_changed(new_value : String):
	value = Vector3(value.x, value.y, float(new_value))

func set_value(to_set : Vector3):
	value = to_set
	x.text = str(to_set.x)
	y.text = str(to_set.y)
	z.text = str(to_set.z)
