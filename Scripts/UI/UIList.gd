class_name UIList extends Node

@export
var add_button : Button
@export
var scene_to_add : PackedScene
@export
var list_parent : BoxContainer

var list_elements : Array[UIListElement]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_button.pressed.connect(_on_add_button_pressed)

func _on_add_button_pressed():
	var inst = scene_to_add.instantiate()
	var b
	for child in list_parent.get_children():
		if child is Button:
			b = child
	list_parent.remove_child(b)
	list_parent.add_child(inst)
	list_parent.add_child(b)
	
	var index = list_elements.size()
	inst.set_index(index)
	list_elements.append(inst)
	inst.delete.connect(_on_item_deleted)
	
func _on_item_deleted(index : int):
	list_elements.remove_at(index)
	
	if list_elements.is_empty():
		return

	for i in range(index, list_elements.size()):
		list_elements[i].set_index(i)

func add_item():
	var inst = scene_to_add.instantiate()
	var b
	for child in list_parent.get_children():
		if child is Button:
			b = child
	list_parent.remove_child(b)
	list_parent.add_child(inst)
	list_parent.add_child(b)
	
	var index = list_elements.size()
	inst.set_index(index)
	list_elements.append(inst)
	inst.delete.connect(_on_item_deleted)

func get_item(index : int) -> UIListElement:
	return list_elements[index]

func size() -> int:
	return list_elements.size()

func clear():
	for element in list_elements:
		remove_child(element)
		element.queue_free()
	
	list_elements.clear()
