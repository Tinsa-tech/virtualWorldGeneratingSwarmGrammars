class_name MiscUI extends PanelContainer

@export
var first_gen_obj : UIList
@export
var t_obj : FloatValueUI
@export
var terrain_size_obj : FloatValueUI

func fill():
	var data = Database.getInstance()
	for member in data.first_generation:
		first_gen_obj.add_item()
		var obj = first_gen_obj.get_item(first_gen_obj.size() - 1)
		obj.set_value(member)
	
	t_obj.set_value(data.t)
	terrain_size_obj.set_value(data.terrain_size)

func get_data():
	var data = Database.getInstance()
	for member : UIListElementString in first_gen_obj.list_elements:
		data.first_generation.append(member.value)
	data.t = t_obj.value
	data.terrain_size = terrain_size_obj.value
