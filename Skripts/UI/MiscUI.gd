class_name MiscUI extends PanelContainer

@export
var first_gen_obj : UIList
@export
var t_obj : FloatValueUI
@export
var terrain_size_obj : FloatValueUI

func fill(database : Database):
	for member in database.first_generation:
		first_gen_obj.add_item()
		var obj = first_gen_obj.get_item(first_gen_obj.size() - 1)
		obj.set_value(member)
	
	t_obj.set_value(database.t)
	terrain_size_obj.set_value(database.terrain_size)

func get_data(database : Database):
	database.first_generation.clear()
	for member : UIListElementString in first_gen_obj.list_elements:
		database.first_generation.append(member.value)
	database.t = t_obj.value
	database.terrain_size = terrain_size_obj.value
